#!/usr/bin/env bash
# Abre um turno na Sala de Guerra: grava <!--INICIANDO_TURNO--> com hora e
# commit-base, e trava a sala pra outros agentes via git push (ver
# sala_lib.sh). Só roda depois do debate (Proposta -> Réplica -> Tréplica)
# já ter chegado a um plano acordado — este script não decide O QUE fazer,
# só abre o turno pra execução.
#
# Uso: ./scripts/agent-loop/iniciar_turno.sh "Claude" ["descrição curta"]
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/sala_lib.sh"

AGENTE="${1:?uso: iniciar_turno.sh <Agente> [descrição]}"
DESCRICAO="${2:-}"

git fetch -q origin 2>/dev/null || true

estado=$(sg_last_marker)
if [ "$estado" == "INICIO" ]; then
  dono=$(sg_turn_owner)
  echo "BLOQUEADO: já existe um turno em andamento (agente: ${dono:-desconhecido})." >&2
  echo "Não abra um turno novo — aguarde o FIM_TURNO ou converse na Sala de Guerra." >&2
  exit 2
fi

commit_base=$(sg_head_short)
metadata="Início: $(sg_now) · Commit-base: ${commit_base} · Agente: ${AGENTE}"
[ -n "$DESCRICAO" ] && metadata="${metadata} · ${DESCRICAO}"

if sg_write_marker "$SG_MARK_INICIO" "$metadata" "chore(sala-de-guerra): iniciar turno — ${AGENTE}"; then
  echo "OK: turno aberto por ${AGENTE} sobre commit ${commit_base}."
  exit 0
else
  rc=$?
  if [ "$rc" -eq 2 ]; then
    echo "PERDEU A CORRIDA: outro agente abriu o turno primeiro. Releia a Sala de Guerra antes de agir." >&2
  fi
  exit "$rc"
fi
