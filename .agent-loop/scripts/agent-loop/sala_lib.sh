#!/usr/bin/env bash
# Biblioteca compartilhada do harness da Sala de Guerra.
#
# Contrato: SALA_DE_GUERRA.md é a fonte de verdade. Só tem dois marcadores
# de estado, cada um sozinho numa linha, seguido de uma linha de metadata
# (hora/commit/agente) — a linha do marcador nunca carrega variável, pra
# permitir match exato (evita reabrir cada turno com uma linha de sentinel
# diferente, o que quebraria detecção por grep -x -F):
#
#   <!--INICIANDO_TURNO-->
#   Início: 2026-09-17 14:32 · Commit-base: ab12cd3 · Agente: Gemini
#
#   <!--FIM_TURNO-->
#   Fim: 2026-09-17 15:10 · Commit: ef45gh6 · Agente: Gemini
#
#   <!--VIGILIA_DESATIVADA-->
#   Desativada: 2026-09-17 18:00 · Por: Yure (comando manual)
#
# Trava de concorrência: NÃO é o texto do marcador que impede corrida (duas
# sessões podem ler FIM_TURNO no mesmo instante). Quem trava de verdade é o
# git — sg_write_marker só considera a escrita válida depois de um `git
# push` aceito. Se o push for rejeitado (non-fast-forward), dá pull e
# checa: se o novo HEAD já tem um INICIANDO_TURNO de outro agente depois do
# nosso commit-base, a outra sessão venceu a corrida — recuamos.

set -uo pipefail

SG_FILE="${SG_FILE:-SALA_DE_GUERRA.md}"
SG_MARK_INICIO='<!--INICIANDO_TURNO-->'
SG_MARK_FIM='<!--FIM_TURNO-->'
SG_MARK_VIGILIA_OFF='<!--VIGILIA_DESATIVADA-->'

# Última marca de estado do arquivo: INICIO | FIM | VIGILIA_OFF | NENHUMA
sg_last_marker() {
  local last
  last=$(grep -n -x -E "$SG_MARK_INICIO|$SG_MARK_FIM|$SG_MARK_VIGILIA_OFF" "$SG_FILE" 2>/dev/null | tail -n 1 | cut -d: -f2-)
  case "$last" in
    "$SG_MARK_INICIO") echo "INICIO" ;;
    "$SG_MARK_FIM") echo "FIM" ;;
    "$SG_MARK_VIGILIA_OFF") echo "VIGILIA_OFF" ;;
    *) echo "NENHUMA" ;;
  esac
}

# Devolve a linha de metadata (a linha imediatamente após a última marca).
sg_last_metadata() {
  local n
  n=$(grep -n -x -E "$SG_MARK_INICIO|$SG_MARK_FIM|$SG_MARK_VIGILIA_OFF" "$SG_FILE" 2>/dev/null | tail -n 1 | cut -d: -f1)
  [ -z "$n" ] && return 1
  sed -n "$((n + 1))p" "$SG_FILE"
}

# Nome do agente dono do turno em andamento (parseia "Agente: X" da última
# metadata de INICIANDO_TURNO). Vazio se não houver turno aberto.
sg_turn_owner() {
  [ "$(sg_last_marker)" != "INICIO" ] && return 0
  sg_last_metadata | grep -oE 'Agente:\s*[^ ·]+' | sed 's/Agente:\s*//'
}

# Escreve um marcador + linha de metadata no fim do arquivo, commita e
# empurra. Em caso de rejeição de push, tenta pull + recheca uma vez; se
# perder a corrida (outro agente já abriu/fechou o turno primeiro), devolve
# status 2 e não insiste — quem chamou decide o que fazer (normalmente:
# recuar e reportar que outra sessão já está no turno).
#
# Uso: sg_write_marker "$SG_MARK_INICIO" "Início: ... · Commit-base: ... · Agente: Claude" "mensagem do commit"
sg_write_marker() {
  local marker="$1" metadata="$2" commit_msg="$3"

  {
    echo ""
    echo "$marker"
    echo "$metadata"
  } >> "$SG_FILE"

  git add "$SG_FILE"
  git commit -q -m "$commit_msg" || { echo "sg_write_marker: nada pra commitar" >&2; return 1; }

  if git push -q 2>/tmp/sg_push_err.$$; then
    rm -f /tmp/sg_push_err.$$
    return 0
  fi

  if grep -q "non-fast-forward\|fetch first\|rejected" /tmp/sg_push_err.$$ 2>/dev/null; then
    rm -f /tmp/sg_push_err.$$
    echo "sg_write_marker: push rejeitado, verificando se outro agente venceu a corrida..." >&2
    git fetch -q origin
    local remote_branch
    remote_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "origin/master")
    if git log "HEAD..$remote_branch" --format=%H -- "$SG_FILE" | grep -q .; then
      echo "sg_write_marker: outra sessão já gravou em $SG_FILE — recuando, não sobrescrever." >&2
      git reset -q --hard HEAD~1 2>/dev/null
      return 2
    fi
    git pull -q --rebase
    if git push -q; then
      return 0
    fi
    echo "sg_write_marker: push ainda falhando após retry — intervenção manual necessária." >&2
    return 1
  fi

  echo "sg_write_marker: push falhou por motivo não relacionado a corrida:" >&2
  cat /tmp/sg_push_err.$$ >&2
  rm -f /tmp/sg_push_err.$$
  return 1
}

sg_now() { date '+%Y-%m-%d %H:%M'; }
sg_head_short() { git rev-parse --short HEAD; }

HISTORICO_FILE="${HISTORICO_FILE:-HISTORICO.md}"

# Arquiva em $HISTORICO_FILE todo turno completo que NÃO seja o mais
# recente (o último <!--INICIANDO_TURNO-->...<!--FIM_TURNO-->), deixando
# em $SG_FILE só o cabeçalho fixo (tudo antes do primeiro marcador) + o
# turno mais recente. Sem-op se houver 0 ou 1 turno no arquivo.
#
# Só opera no que vem DEPOIS do cabeçalho (nunca tenta parsear as
# instruções fixas) e exige os marcadores sozinhos na linha (grep -x) —
# evita falso positivo se um turno citar os marcadores em prosa/código.
#
# Chame isso DEPOIS de um sg_write_marker("$SG_MARK_FIM", ...) bem
# sucedido. Faz seu próprio commit+push; se o push for rejeitado (outra
# sessão escreveu no meio), desiste sem insistir — não é crítico, só
# significa que a faxina fica pro próximo fechamento de turno.
sg_archive_old_turns() {
  local first_inicio last_inicio header_end old_end old_turns

  first_inicio=$(grep -n -x -F "$SG_MARK_INICIO" "$SG_FILE" 2>/dev/null | head -n 1 | cut -d: -f1)
  last_inicio=$(grep -n -x -F "$SG_MARK_INICIO" "$SG_FILE" 2>/dev/null | tail -n 1 | cut -d: -f1)
  [ -z "$first_inicio" ] && return 0
  [ "$first_inicio" = "$last_inicio" ] && return 0  # só 1 turno, nada a arquivar

  header_end=$((first_inicio - 1))
  old_end=$((last_inicio - 1))

  old_turns=$(sed -n "${first_inicio},${old_end}p" "$SG_FILE" \
    | grep -vx -F -e "$SG_MARK_INICIO" -e "$SG_MARK_FIM" -e "$SG_MARK_VIGILIA_OFF")
  [ -z "$old_turns" ] && return 0

  {
    echo ""
    echo "$old_turns"
  } >> "$HISTORICO_FILE"

  {
    sed -n "1,${header_end}p" "$SG_FILE"
    echo ""
    sed -n "${last_inicio},\$p" "$SG_FILE"
  } > "${SG_FILE}.tmp" && mv "${SG_FILE}.tmp" "$SG_FILE"

  git add "$SG_FILE" "$HISTORICO_FILE"
  git commit -q -m "chore(sala-de-guerra): arquiva turnos antigos em $HISTORICO_FILE" || {
    echo "sg_archive_old_turns: nada pra commitar" >&2
    return 1
  }

  if git push -q 2>/tmp/sg_archive_err.$$; then
    rm -f /tmp/sg_archive_err.$$
    return 0
  fi

  echo "sg_archive_old_turns: push rejeitado (outra sessão escreveu no meio) — desistindo desta faxina, sem insistir. Próximo fechamento tenta de novo." >&2
  rm -f /tmp/sg_archive_err.$$
  git reset -q --hard HEAD~1 2>/dev/null
  return 1
}
