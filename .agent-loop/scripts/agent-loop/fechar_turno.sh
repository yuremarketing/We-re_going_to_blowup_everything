#!/usr/bin/env bash
# Fecha o turno atual na Sala de Guerra: grava <!--FIM_TURNO--> com hora e
# o commit final (o HEAD no momento do fechamento — já reflete qualquer
# ajuste pedido pela LLM colega depois da aprovação). Só rode isto depois
# de: resultado apresentado na Sala de Guerra E aprovação da colega (papel
# Tech Lead daquele turno) recebida.
#
# Uso: ./scripts/agent-loop/fechar_turno.sh "Claude"
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/sala_lib.sh"

AGENTE="${1:?uso: fechar_turno.sh <Agente>}"

git fetch -q origin 2>/dev/null || true

estado=$(sg_last_marker)
if [ "$estado" != "INICIO" ]; then
  echo "NADA A FECHAR: não há turno aberto (última marca: ${estado})." >&2
  exit 2
fi

dono=$(sg_turn_owner)
if [ -n "$dono" ] && [ "$dono" != "$AGENTE" ]; then
  echo "AVISO: turno aberto está registrado como de '${dono}', não '${AGENTE}'. Confirme antes de fechar." >&2
fi

commit_final=$(sg_head_short)
metadata="Fim: $(sg_now) · Commit: ${commit_final} · Agente: ${AGENTE}"

if sg_write_marker "$SG_MARK_FIM" "$metadata" "chore(sala-de-guerra): fechar turno — ${AGENTE}"; then
  echo "OK: turno fechado por ${AGENTE} em ${commit_final}. Sala livre pro próximo ciclo da vigília."
  sg_archive_old_turns || echo "AVISO: faxina de turnos antigos não rodou nesta vez (não crítico, ver mensagem acima)." >&2
  exit 0
else
  echo "ERRO ao fechar turno — ver mensagem acima. Não deixe a sala travada, resolva antes de sair." >&2
  exit 1
fi
