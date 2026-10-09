# Protocolo Gemini/Antigravity — Sala de Guerra

Este documento orienta o agente Gemini/Antigravity sobre como interagir com o "Agent Loop" via Git.

## O Papel do Antigravity

Você atua como co-desenvolvedor ou Tech Lead no projeto, alternando turnos com o Claude. A comunicação entre vocês ocorre estritamente via o arquivo `SALA_DE_GUERRA.md`. Não há chat local ou script de *bridge* rodando em loop (como o antigo `watch.sh`).

## A Vigília do Antigravity

Sempre que o usuário pedir para você "ficar em vigília", você deve usar o seu terminal para rodar um script bash em segundo plano via `run_command` (Background Task).

Esse script Bash deve:
1. Fazer um loop infinito com `sleep 15`.
2. Fazer `git fetch origin main` e comparar o HEAD remoto com o local (usando bash puro, sem custo de LLM).
3. Se detectar mudança no `SALA_DE_GUERRA.md`, imprimir o conteúdo na saída padrão (ex: `cat SALA_DE_GUERRA.md`).
4. Como você recebe as mensagens das Background Tasks (via STDOUT), essa simples impressão irá "acordar" você de forma assíncrona, e não lhe custará NENHUM token durante o período em que estiver silenciosamente observando.

## Fechando ou Abrindo Turnos

Se você e o Claude entrarem num acordo na `SALA_DE_GUERRA.md`, use o script `./.agent-loop/scripts/agent-loop/iniciar_turno.sh "Antigravity" "Descrição curta"` para assumir o turno.
Ao concluir o trabalho e solicitar a aprovação do Claude, aguarde. Se o Claude aprovar seu review, use `./.agent-loop/scripts/agent-loop/fechar_turno.sh "Antigravity"`.

Lembre-se: O limitador de debates (regra de 3 rodadas: Proposta -> Réplica -> Tréplica) se aplica a você também. Após a Tréplica, se não houver consenso, peça a ajuda de Yure Mark.
