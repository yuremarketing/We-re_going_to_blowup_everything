#!/usr/bin/env bash
# Vigília do harness da Sala de Guerra.
#
# Executa o passo "checagem de estado + relatório" do protocolo: sonda
# SALA_DE_GUERRA.md, diz se a sala está livre ou quem está no turno, e — se
# livre — monta o relatório que vai pro Yure antes de qualquer turno novo
# começar (card anterior, issues pendentes, progresso, PRs abertos em
# prosa, sem checkbox).
#
# Ativação/intervalo/agendamento NÃO são deste script — isso é responsabi-
# lidade de quem chama (Claude usa o skill /loop, Gemini usa `schedule`;
# ver CLAUDE.md/GEMINI.md). Este script é sempre uma checagem pontual,
# chamada repetidamente por quem agenda.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/sala_lib.sh"

if [ -f .env ]; then
  set -a
  source .env
  set +a
fi

REPO="${AGENT_LOOP_REPO:-sysoft-br/sysoft}"
PAINEL_URL="${SALA_GUERRA_PAINEL_URL:-}"  # sem painel hospedado pro Sysoft ainda

echo "=== Vigília — $(sg_now) ==="
git fetch -q origin 2>/dev/null || true

estado=$(sg_last_marker)
case "$estado" in
  INICIO)
    dono=$(sg_turn_owner)
    meta=$(sg_last_metadata)
    echo "SALA OCUPADA — turno em andamento (agente: ${dono:-desconhecido})"
    echo "  $meta"
    echo
    echo "Nada a reportar agora — aguardando FIM_TURNO. Próximo ciclo da vigília checa de novo."
    exit 0
    ;;
  VIGILIA_OFF)
    echo "VIGÍLIA DESATIVADA — última marca do arquivo foi um encerramento manual."
    echo "  $(sg_last_metadata)"
    echo "Se quiser reativar, é só o Yure pedir de novo."
    exit 0
    ;;
esac

echo "SALA LIVRE — pronta pra um turno novo."
echo

echo "--- Card anterior (último turno concluído) ---"
if [ -f "$SG_FILE" ]; then
  last_turno_line=$(grep -n '^## Turno ' "$SG_FILE" | tail -1 | cut -d: -f1 || true)
  if [ -n "$last_turno_line" ]; then
    sed -n "${last_turno_line},\$p" "$SG_FILE" | head -20
  fi
fi

echo
echo "--- Issues pendentes ---"
if command -v gh >/dev/null 2>&1; then
  gh issue list --repo "$REPO" --state open \
    --json number,title,updatedAt \
    --template '{{range .}}#{{.number}} {{.title}} (atualizado {{timeago .updatedAt}}){{"\n"}}{{end}}' \
    2>/dev/null || echo "  (erro consultando issues — checar 'gh auth status')"
else
  echo "  gh CLI não encontrado"
fi

echo
echo "--- Progresso do projeto ---"
if command -v gh >/dev/null 2>&1; then
  # || true em cada pipeline: grep -o sai com status 1 quando não há
  # nenhum match (ex: zero issues fechadas) — sem isso, set -e/pipefail
  # derruba o script inteiro num projeto novo com poucas issues.
  total_issues=$(gh issue list --repo "$REPO" --state all --limit 1000 --json number 2>/dev/null | grep -o '"number"' | wc -l || true)
  closed_issues=$(gh issue list --repo "$REPO" --state closed --limit 1000 --json number 2>/dev/null | grep -o '"number"' | wc -l || true)
  if [ "$total_issues" -gt 0 ] 2>/dev/null; then
    pct=$(( closed_issues * 100 / total_issues ))
    echo "  ${closed_issues}/${total_issues} issues fechadas (${pct}%)"
  else
    echo "  (sem dado suficiente pra calcular)"
  fi
  echo "  Métrica completa (velocidade, lead time, ETA) — ver skill /metricas quando publicada."
fi
[ -n "$PAINEL_URL" ] && echo "  Painel ao vivo: ${PAINEL_URL}"

echo
echo "--- PRs abertos ---"
if command -v gh >/dev/null 2>&1; then
  pr_json=$(gh pr list --repo "$REPO" --state open --json number,title,author,updatedAt,isDraft 2>/dev/null)
  pr_count=$(echo "$pr_json" | grep -o '"number"' | wc -l || true)
  echo "  Total: ${pr_count}"
  if [ "$pr_count" -gt 0 ]; then
    gh pr list --repo "$REPO" --state open \
      --json number,title,author,updatedAt,isDraft \
      --template '{{range .}}  #{{.number}} [{{if .isDraft}}draft{{else}}open{{end}}] {{.title}} (@{{.author.login}}, atualizado {{timeago .updatedAt}}){{"\n"}}{{end}}' \
      2>/dev/null
    echo
    echo "  Diga quais autorizar (ex: \"libera o #66 e #67\") pra LLM analisar, gerar plano e debater."
  fi
else
  echo "  gh CLI não encontrado"
fi
