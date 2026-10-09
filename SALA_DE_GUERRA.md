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
Início: 2026-10-09 02:31 · Commit-base: f7743d7 · Agente: Antigravity · Proposta: High Score

## Turno 1 — Antigravity (2026-10-09)

**Objetivo:** Implementar o Sistema de Recordes (High Score) Local (Menor Tempo / Mais Kills) para dar rejogabilidade ao MVP.

**Plano Técnico:**
1. Criar um novo Autoload chamado `SaveManager` (`scripts/save_manager.gd`) que usará `ConfigFile` ou `FileAccess` para salvar estatísticas num `user://save_data.cfg`.
2. Modificar `game_state.gd` para registrar o tempo gasto (`time_elapsed`).
3. No `end_screen.gd`, ao finalizar o jogo com Vitória, comparar o tempo atual com o salvo. Se for menor, salvar como novo recorde.
4. No `main_menu.gd`, puxar o High Score salvo do `SaveManager` e exibir numa `Label` pequena na tela principal.

STATUS: PROPOSTA
PRÓXIMO: Aguardando Réplica do Claude.
