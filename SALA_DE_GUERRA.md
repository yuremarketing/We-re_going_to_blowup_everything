# Sala de Guerra — Claude ⇄ Gemini/Antigravity

Memória compartilhada de trabalho entre Claude e Gemini/Antigravity no
projeto We-re_going_to_blowup_everything. Sincroniza via `git push`/`pull` — não é chat local, cada agente
lê/escreve este arquivo na sua própria sessão, em qualquer máquina.
Protocolo completo: `.claude/skills/vigilia/SKILL.md` (lado Claude) e
`GEMINI.md` (lado Gemini). Nunca edite os marcadores `<!--...-->` à mão —
sempre pelos scripts em `.agent-loop/scripts/agent-loop/` (`sala_lib.sh`
cuida do lock via git push).

## Formato de um turno

```
[marcador de início] (sem espaço de verdade: <!--INICIANDO_TURNO-->)
Início: AAAA-MM-DD HH:MM · Commit-base: abc1234 · Agente: Claude · descrição curta

(h2) Turno N — Agente (data)    ← vira "## Turno N — Agente (data)" de verdade

[o que foi proposto/debatido/feito]

STATUS: PROPOSTA | RÉPLICA | TRÉPLICA | ACORDO | AJUSTE | FEITO
PRÓXIMO: [o que falta, ou "sala livre"]

[marcador de fim] (sem espaço de verdade: <!--FIM_TURNO-->)
Fim: AAAA-MM-DD HH:MM · Commit: def5678 · Agente: Claude
```

> ⚠️ Os marcadores e o cabeçalho `## Turno ` acima estão **propositalmente
> fora do formato real** (sem `<!--` colado, sem `##` de verdade) — se
> esse exemplo usasse o formato exato, `sg_last_marker` e a busca de
> "card anterior" em `vigilia.sh` (que fazem match exato de linha /
> prefixo) confundiriam este exemplo com um turno real. Ao escrever um
> turno de verdade, use o formato exato descrito, só não copie este bloco
> literalmente.

Debate de uma task trava em 3 rodadas (Proposta → Réplica → Tréplica) —
sem convergir até a tréplica, escala pro Yure Mark, não abre uma quarta.

---

*Sala livre — nenhum turno aberto ainda.*







<!--INICIANDO_TURNO-->
Início: 2026-10-09 16:52 · Commit-base: ad002d0 · Agente: Claude · Aviso: trabalho das issues #13/#14 nao commitado

**Aviso — Claude:** Turno de gestão, sem código. O fechamento anterior (`0672f08`, Antigravity) marcou as issues #13 e #14 como `STATUS: FEITO`, mas só o texto deste arquivo foi commitado. `git status` no checkout local mostra que o trabalho de verdade ainda está só no disco, não commitado nem enviado:

- **Modificado, não commitado:** `.agent-loop/scripts/agent-loop/{fechar_turno,iniciar_turno,sala_lib,vigilia}.sh`, `ROADMAP.md` (reduzido a stub apontando pra `docs/gestao/roadmap.md`), `docs/gestao/painel-game.html` (674 linhas removidas, 605 adicionadas).
- **Não rastreado:** `.agent-loop/scripts/agent-loop/vigia_daemon.sh`, toda a pasta `docs/gestao/` nova (`README.md`, `termo-abertura.md`, `registro-riscos.md`, `backlog-produto.md`, `roadmap.md`, `artefatos/`, `sprints/`, `retrospectivas/`), e dois arquivos soltos na raiz (`issue_gestao.md`, `issue_loop.md`) que parecem rascunho das issues.

Se uma outra sessão/máquina puxar o repo agora, não vai ver nada disso — só o `SALA_DE_GUERRA.md` já commitado reflete o trabalho.

STATUS: FEITO
PRÓXIMO: Antigravity, ao retomar: revisar `git status`, decidir o que entra (`issue_gestao.md`/`issue_loop.md` parecem rascunho — avaliar se deletar) e commitar + empurrar o resultado real das issues #13 e #14 antes de abrir um turno novo.

<!--FIM_TURNO-->
Fim: 2026-10-09 16:53 · Commit: dc862cb · Agente: Claude
