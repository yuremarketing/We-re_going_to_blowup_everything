#!/usr/bin/env bash
#
# Ponte Autônoma Claudão <-> Antigravity
#
# Observa war_room/CHAT.md. Quando um dos agentes escreve uma mensagem nova,
# invoca automaticamente o outro em modo headless — até um limite de turnos
# autônomos consecutivos (regra 4 do COLLAB_PROTOCOL.md). Depois disso, só
# notifica o usuário e espera ele digitar "continua".
#
# Arquitetura confirmada em war_room/CHAT.md (2026-09-08):
#   - Claudão: `claude -p "<prompt>"`, com allowlist restrito em
#     .claude/settings.json (edição só dentro de war_room/, docs/,
#     assets/concept_art/, scenes/, scripts/, *.md; git add/commit local
#     liberado; push/merge/reset/rm sempre negados).
#   - Antigravity: `agy -p "<prompt>"`, com allowlist restrito equivalente
#     em ~/.gemini/antigravity-cli/settings.json (write_file(<pasta>/) nas
#     mesmas pastas). Antigravity NUNCA roda shell em modo headless — o
#     motor dele (jetski) nega automaticamente qualquer comando que exija
#     confirmação humana. Por isso o commit local de qualquer edição dele
#     fica por conta deste script (auto_commit_pending), nunca por ele.
#
# Uso:
#   ./war_room/bridge/watch.sh
#
# Pré-requisitos:
#   - `claude` e `agy` no PATH.
#   - .claude/settings.json (Claudão) e ~/.gemini/antigravity-cli/settings.json
#     (Antigravity) com os allowlists restritos configurados — sem isso,
#     as invocações headless travam esperando uma confirmação que nunca vem.
#   - inotifywait (pacote inotify-tools) é opcional; sem ele, cai pra
#     polling (checa o arquivo a cada 2s).

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR" || exit 1
CHAT_FILE="$ROOT_DIR/war_room/CHAT.md"
HANDOVER_FILE="$ROOT_DIR/war_room/HANDOVER.md"
STATE_DIR="$ROOT_DIR/war_room/bridge/state"
LOG_FILE="$STATE_DIR/watch.log"
TURN_COUNT_FILE="$STATE_DIR/turn_count"
LAST_ENTRY_FILE="$STATE_DIR/last_entry"
STOP_FILE="$STATE_DIR/STOP"

MAX_AUTONOMOUS_TURNS=3
COMMIT_SETTLE_SECONDS=5   # espera isso antes de commitar, pra agrupar edições em sequência
PID_FILE="$STATE_DIR/watch.pid"

mkdir -p "$STATE_DIR"
touch "$LOG_FILE"
[ -f "$TURN_COUNT_FILE" ] || echo 0 > "$TURN_COUNT_FILE"
[ -f "$LAST_ENTRY_FILE" ] || echo "" > "$LAST_ENTRY_FILE"

# Trava de instância única: evita dois watch.sh rodando ao mesmo tempo (já
# aconteceu — um turno autônomo religou o script sem checar se já tinha um
# rodando, gerando dois processos escrevendo no mesmo estado). Se o PID salvo
# ainda estiver vivo E for mesmo um watch.sh, recusa a subir; senão, assume o
# PID antigo como morto/travado (stale) e segue.
if [ -f "$PID_FILE" ]; then
  OLD_PID="$(cat "$PID_FILE" 2>/dev/null || true)"
  if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null && ps -p "$OLD_PID" -o cmd= 2>/dev/null | grep -q "watch.sh"; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Já existe um watch.sh rodando (pid $OLD_PID) — abortando pra não duplicar." >&2
    exit 1
  fi
fi
echo $$ > "$PID_FILE"
trap 'rm -f "$PID_FILE"' EXIT

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

notify() {
  local msg="$1"
  log "NOTIFY: $msg"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Sala de Guerra — Ponte Autônoma" "$msg" || true
  fi
}

claude_invoke() {
  claude -p "$1" | tee -a "$LOG_FILE"
}

agy_invoke() {
  agy -p "$1" | tee -a "$LOG_FILE"
}

BRIDGE_INSTRUCTIONS="Não dê git push nem mexa na main. Pare e peça confirmação humana antes de qualquer ação destrutiva ou fora do escopo da tarefa atual. Siga o COLLAB_PROTOCOL.md (seção 4 - Ponte Autônoma)."

# Pega o cabeçalho ("### [timestamp] Autor") da última mensagem do CHAT.md
last_entry_header() {
  grep -E '^### \[.+\] .+$' "$CHAT_FILE" | tail -1
}

entry_author() {
  echo "$1" | sed -E 's/^### \[.+\] //'
}

handover_turno_atual() {
  # Pega o PRIMEIRO valor entre crases da linha, não o último — a linha pode
  # ter mais de um valor entre crases (ex: "Antigravity` ⚡ (se X) ou `Usuário"),
  # e regex gulosa (.*`...`.*) captura o último por engano (bug real de 2026-09-08).
  grep -m1 'Turno Atual' "$HANDOVER_FILE" | grep -oE '`[^`]+`' | head -1 | tr -d '`'
}

handover_proximo_turno() {
  grep -m1 'Próximo Turno' "$HANDOVER_FILE" | grep -oE '`[^`]+`' | head -1 | tr -d '`'
}

# Resolve quem deve agir quando o Usuário fala: normalmente é "Turno Atual",
# mas depois de uma pausa (turno 3/3) esse campo fica "Usuário" de propósito
# — nesse caso cai pro "Próximo Turno" em vez de desistir.
resolve_next_agent() {
  local turno
  turno="$(handover_turno_atual)"
  if [[ "$turno" == Claudão* || "$turno" == Antigravity* ]]; then
    echo "$turno"
    return
  fi
  handover_proximo_turno
}

reset_counter() {
  echo 0 > "$TURN_COUNT_FILE"
}

increment_counter() {
  local c
  c="$(($(cat "$TURN_COUNT_FILE") + 1))"
  echo "$c" > "$TURN_COUNT_FILE"
  echo "$c"
}

# Detecta sobrescrita destrutiva: se um arquivo crítico perdeu muito mais
# linha do que ganhou, provavelmente foi um write_file() com cópia velha em
# memória (foi exatamente o que corrompeu war_room/CHAT.md em 2026-09-08 —
# uma sessão manual e antiga do agy sobrescreveu 260 linhas com 3 de novo).
SUSPICIOUS_FILES="war_room/CHAT.md war_room/HANDOVER.md"
looks_like_destructive_overwrite() {
  local f
  for f in $SUSPICIOUS_FILES; do
    [ -f "$f" ] || continue
    local stat added removed
    stat="$(git diff --numstat -- "$f" 2>/dev/null)"
    [ -z "$stat" ] && continue
    added="$(echo "$stat" | awk '{print $1}')"
    removed="$(echo "$stat" | awk '{print $2}')"
    [[ "$added" =~ ^[0-9]+$ ]] || continue
    [[ "$removed" =~ ^[0-9]+$ ]] || continue
    if [ "$removed" -gt 20 ] && [ "$removed" -gt $((added * 3)) ]; then
      log "SUSPEITO: $f perdeu $removed linhas e ganhou só $added — parece sobrescrita, não edição normal."
      return 0
    fi
  done
  return 1
}

# Commita local (nunca push/merge) qualquer mudança pendente no working tree —
# principalmente pra cobrir edições do Antigravity, que não consegue commitar
# sozinho (shell sempre soft-denied em modo headless pelo motor dele).
auto_commit_pending() {
  cd "$ROOT_DIR" || return
  if [ -n "$(git status --porcelain)" ]; then
    sleep "$COMMIT_SETTLE_SECONDS"
    if [ -n "$(git status --porcelain)" ]; then
      if looks_like_destructive_overwrite; then
        notify "Mudança suspeita detectada (parece sobrescrita, não edição) — NÃO commitei automaticamente. Rode 'git diff' e decida manualmente. Watcher pausando (STOP criado) até você remover o arquivo STOP."
        touch "$STOP_FILE"
        return
      fi
      git add -A
      git commit -m "chore(bridge): auto-commit local de turno autônomo ($(date '+%Y-%m-%d %H:%M'))" >/dev/null 2>&1
      log "Auto-commit local feito (sem push)."
    fi
  fi
}

process_new_entry() {
  local header="$1"
  local author
  author="$(entry_author "$header")"
  local count
  count="$(cat "$TURN_COUNT_FILE")"

  if [ "$author" = "Usuário" ]; then
    reset_counter
    count=0
    log "Mensagem do Usuário — contador zerado."
  fi

  if [ "$count" -ge "$MAX_AUTONOMOUS_TURNS" ]; then
    notify "Limite de $MAX_AUTONOMOUS_TURNS turnos autônomos atingido. Diga 'continua' ou responda direto no CHAT.md pra eu seguir."
    return
  fi

  case "$author" in
    Claudão)
      count="$(increment_counter)"
      log "Turno $count/$MAX_AUTONOMOUS_TURNS — auto-invocando Antigravity (mensagem nova do Claudão)"
      agy_invoke "Nova mensagem em war_room/CHAT.md do Claudão (turno autônomo $count/$MAX_AUTONOMOUS_TURNS). Leia o arquivo, decida se cabe resposta sua, e edite os arquivos necessários. $BRIDGE_INSTRUCTIONS"
      ;;
    Antigravity)
      count="$(increment_counter)"
      log "Turno $count/$MAX_AUTONOMOUS_TURNS — auto-invocando Claudão (mensagem nova do Antigravity)"
      claude_invoke "Nova mensagem em war_room/CHAT.md do Antigravity (turno autônomo $count/$MAX_AUTONOMOUS_TURNS). Leia o arquivo, decida se cabe resposta sua. $BRIDGE_INSTRUCTIONS"
      ;;
    Usuário)
      local turno
      turno="$(resolve_next_agent)"
      log "Mensagem do Usuário — agente resolvido (Turno Atual ou, se pausado, Próximo Turno): $turno"
      count="$(increment_counter)"
      if [[ "$turno" == Claudão* ]]; then
        claude_invoke "Nova mensagem do Usuário em war_room/CHAT.md (turno autônomo $count/$MAX_AUTONOMOUS_TURNS). Leia o arquivo e o HANDOVER.md. $BRIDGE_INSTRUCTIONS"
      elif [[ "$turno" == Antigravity* ]]; then
        agy_invoke "Nova mensagem do Usuário em war_room/CHAT.md (turno autônomo $count/$MAX_AUTONOMOUS_TURNS). Leia o arquivo e o HANDOVER.md. $BRIDGE_INSTRUCTIONS"
      else
        notify "Mensagem nova do Usuário, mas HANDOVER.md não deixa claro de quem é o turno. Verifique manualmente."
      fi
      ;;
    *)
      log "Autor desconhecido '$author' — ignorando."
      ;;
  esac

  auto_commit_pending
}

check_for_new_entry() {
  if [ -f "$STOP_FILE" ]; then
    log "STOP presente ($STOP_FILE) — watcher pausado. Remova o arquivo pra retomar."
    return
  fi
  local header
  header="$(last_entry_header)"
  [ -z "$header" ] && return
  local last_seen
  last_seen="$(cat "$LAST_ENTRY_FILE")"
  if [ "$header" != "$last_seen" ]; then
    echo "$header" > "$LAST_ENTRY_FILE"
    log "Nova entrada detectada: $header"
    process_new_entry "$header"
  fi
}

log "Watcher iniciado. Observando $CHAT_FILE (limite: $MAX_AUTONOMOUS_TURNS turnos autônomos)."
log "Kill switch: crie o arquivo $STOP_FILE pra pausar sem matar o processo."
log "AVISO: confira se .claude/settings.json e ~/.gemini/antigravity-cli/settings.json têm os allowlists restritos configurados, senão as invocações headless podem travar esperando aprovação que nunca vem."

if command -v inotifywait >/dev/null 2>&1; then
  log "Usando inotifywait (evento em tempo real)."
  while true; do
    inotifywait -e close_write "$CHAT_FILE" >/dev/null 2>&1
    check_for_new_entry
  done
else
  log "inotifywait não encontrado — usando polling a cada 2s (instale 'inotify-tools' pra latência menor)."
  while true; do
    check_for_new_entry
    sleep 2
  done
fi
