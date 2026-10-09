---
name: vigilia
description: "Harness da Sala de Guerra (Claude+Gemini/Antigravity): ativa/desativa a vigília, checa se a sala está livre ou quem está no turno, apresenta o relatório de status, conduz o debate limitado (Proposta/Réplica/Tréplica) e abre/fecha turnos com os marcadores INICIANDO_TURNO/FIM_TURNO. Use sempre que o usuário disser 'ativar vigília', 'encerrar vigília', pedir status do loop de agentes, ou quando for abrir/fechar um turno do harness."
metadata:
  author: yure
  version: "0.1.0"
---

# Vigília — Harness da Sala de Guerra

Protocolo de turnos entre Yure Mark, Claude e Gemini/Antigravity,
registrado em `SALA_DE_GUERRA.md` (raiz do repo, sincronizado via git —
**não** é chat local). Ver `CLAUDE.md` pro papel (Dev
Especialista vs Tech Lead) e pra autoridade delegada.

## Comandos que acionam este skill

- **"Ativar vigília"** → começa a sondar mudanças em `SALA_DE_GUERRA.md`.
  Do lado Claude, **não use cron/`/loop`** — arme um `Monitor` persistente
  rodando um loop de `git fetch` barato (bash puro, sem custo de LLM) a
  cada ~15s, que só notifica (gera um wakeup de verdade) quando o commit
  remoto muda E toca `SALA_DE_GUERRA.md`. O Gemini agenda o lado dele com
  `run_command` em background rodando um bash script análogo.
- **"Encerrar vigília"** → roda `.agent-loop/scripts/agent-loop/encerrar_vigilia.sh`.

## A cada ciclo da vigília

1. Rode `./.agent-loop/scripts/agent-loop/vigilia.sh`.
2. **Se sala ocupada** (`INICIO`): reporte ao Yure quem está no turno (o
   script já extrai isso da metadata) e pare — não tente abrir nada.
   Espere o próximo ciclo.
3. **Se vigília desativada** (`VIGILIA_OFF`): informe e pare de agendar
   novos ciclos até o Yure pedir de novo.
4. **Se sala livre**: apresente o relatório que o script já monta (card
   anterior, issues pendentes, progresso do projeto, PRs abertos). **Sem
   checkbox** — liste os PRs em prosa e peça autorização em linguagem natural.

## Quando o Yure autoriza uma task/PR

1. Analise a task (Issue do board, ou PR), gere um plano de ação.
2. Publique o plano em `SALA_DE_GUERRA.md` pra debate com a LLM colega.
3. **Debate travado em 3 rodadas**: Proposta → Réplica → Tréplica. Se não
   convergir até a tréplica, **chame o Yure** — não abra uma quarta
   rodada.
4. Plano acordado → `./.agent-loop/scripts/agent-loop/iniciar_turno.sh "<SeuNome>" ["descrição curta"]`.
   Se o script disser que perdeu a corrida,
   releia a Sala de Guerra e recue — não insista.
5. Execute a task debatida.
6. Apresente o resultado em `SALA_DE_GUERRA.md`.
7. Aguarde aprovação da LLM colega (papel Tech Lead daquele turno).
   **Timeout de 30 minutos**: se não vier aprovação nesse prazo, o turno
   fica parado — não feche sozinho, não insista automaticamente.
8. Aprovado → `./.agent-loop/scripts/agent-loop/fechar_turno.sh "<SeuNome>"`. O
   commit final registrado é o HEAD **depois** de qualquer ajuste pedido
   no review.

## Painel ao vivo (Artifact)

Existe um painel de acompanhamento do projeto publicado como Claude
Artifact (`SALA_GUERRA_PAINEL_URL` no `.env` — fonte versionada em
`docs/gestao/painel-game.html`). **Isso é responsabilidade exclusiva
do lado Claude** — o Gemini/Antigravity não tem acesso a Artifacts, não
participa desta parte.

- Sempre edite o arquivo versionado (`docs/gestao/painel-game.html`),
  nunca reconstrua o painel do zero num scratchpad.

## Encerrar vigília com turno em andamento

`encerrar_vigilia.sh` já implementa isto: se o Yure pedir pra encerrar
enquanto há turno aberto, **para tudo na hora** — não espera o turno
fechar sozinho. Grava `<!--VIGILIA_DESATIVADA-->` explicando que foi
parada forçada por comando humano.

## Notas técnicas

- **Lock de concorrência é o git, não o texto do marcador.**
- Marcadores ficam sozinhos numa linha.
- `AGENT_LOOP_REPO` no `.env` define o repo (`gh`), padrão
  `yuremarketing/We-re_going_to_blowup_everything`.
- `vigilia.sh` não chama nenhuma LLM — é só bash + `gh`. O custo de token
  só entra quando alguém decide de fato debater/executar uma task.
