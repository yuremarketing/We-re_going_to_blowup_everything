#!/usr/bin/env bash
# Comando "encerrar vigília" do Yure.
#
# Se a sala estiver livre (última marca = FIM_TURNO ou nenhuma), encerra
# normal: grava <!--VIGILIA_DESATIVADA--> e devolve um parecer atualizado
# pra apresentar ao Yure (delega pra vigilia.sh --relatorio).
#
# Se houver turno em andamento (INICIANDO_TURNO sem FIM_TURNO), o comando
# do Yure vale mais que o turno em execução: para tudo imediatamente e
# grava o marcador de desativação já explicando que foi parada forçada por
# pedido humano — não tenta terminar o turno primeiro.
#
# Uso: ./scripts/agent-loop/encerrar_vigilia.sh "Claude"
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/sala_lib.sh"

AGENTE="${1:?uso: encerrar_vigilia.sh <Agente>}"

git fetch -q origin 2>/dev/null || true

estado=$(sg_last_marker)

if [ "$estado" == "INICIO" ]; then
  dono=$(sg_turn_owner)
  metadata="Desativada: $(sg_now) · Por: Yure (parada forçada — turno de '${dono:-desconhecido}' interrompido) · Agente que registrou: ${AGENTE}"
  commit_msg="chore(sala-de-guerra): vigília encerrada por comando do humano — turno de ${dono:-desconhecido} interrompido"
  echo "PARADA FORÇADA: havia turno em andamento (${dono:-desconhecido}). Interrompendo por pedido do Yure." >&2
else
  metadata="Desativada: $(sg_now) · Por: Yure (comando manual, sala livre) · Agente que registrou: ${AGENTE}"
  commit_msg="chore(sala-de-guerra): vigília encerrada — sala livre"
fi

if sg_write_marker "$SG_MARK_VIGILIA_OFF" "$metadata" "$commit_msg"; then
  echo "OK: vigília desativada."
  exit 0
else
  echo "ERRO ao registrar encerramento — ver mensagem acima." >&2
  exit 1
fi
