# Agent Loop — harness da Sala de Guerra

Scripts de apoio ao protocolo de turnos entre Claude e Gemini/Antigravity
(ver `SALA_DE_GUERRA.md` na raiz do repo, `CLAUDE.md`, `GEMINI.md`, e a
skill `.claude/skills/vigilia/SKILL.md` — esse é o documento com o
protocolo completo). Vivem isolados aqui em `.agent-loop/` pra não se
misturar com o código do sistema real na raiz do repo.

```
.agent-loop/scripts/agent-loop/
├── sala_lib.sh          # biblioteca compartilhada — lock via git push
├── vigilia.sh           # checagem de estado + relatório (zero custo de LLM)
├── iniciar_turno.sh     # abre turno (só depois do debate acordado)
├── fechar_turno.sh      # fecha turno (só depois da aprovação da LLM colega)
└── encerrar_vigilia.sh  # para a vigília (normal ou parada forçada)
```

Todos os comandos abaixo rodam a partir da **raiz do projeto**.

```bash
./.agent-loop/scripts/agent-loop/vigilia.sh
```

Não é um loop automático nem um processo sempre-ativo — `vigilia.sh` é
uma checagem pontual, chamada repetidamente por quem agenda (Claude usa
a skill `/loop`, Gemini usa `schedule`). O arquivo `SALA_DE_GUERRA.md` é
quem sincroniza tudo via `git push`/`pull`, não precisa de sessão
compartilhada nem tmux.
