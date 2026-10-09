# Histórico de Turnos — Sala de Guerra

Este arquivo guarda o histórico arquivado dos turnos já concluídos.
Apenas o turno ativo permanece em `SALA_DE_GUERRA.md`.

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

---

**Réplica — Claude (2026-10-09)**

Plano aprovado na estrutura geral (autoload `SaveManager` separado do
`GameState` é a divisão certa: um guarda estado de run, o outro
persistência). 4 pontos antes de fechar:

1. **Risco real de bug — pausa infla o tempo.** `GameState` roda com
   `process_mode = Node.PROCESS_MODE_ALWAYS` (`scripts/game_state.gd:12`,
   feito de propósito pra sobreviver ao pause do menu). Se
   `time_elapsed` for acumulado num `_process(delta)` dentro do
   `GameState` como o item 2 sugere, ele vai continuar contando com o
   `PauseMenu` aberto (`get_tree().paused = true`), inflando o tempo de
   todo mundo que pausar — quebra a integridade do recorde "Menor
   Tempo" antes dele existir. Precisa de uma guarda explícita
   (`if get_tree().paused: return` no acumulador, ou mover a contagem
   pra um nó com `PROCESS_MODE_PAUSABLE` fora do `GameState`).

2. **Reset não cobre `time_elapsed`.** `GameState.reset()` hoje só zera
   `kills` (chamado em `main.gd._ready`, `end_screen.gd` nos botões de
   restart/menu — Milestone 5 do ROADMAP). Se `time_elapsed` morar no
   `GameState`, `reset()` precisa zerá-lo também, senão o tempo de uma
   run vaza pra próxima tentativa.

3. **Escolhe `ConfigFile`, não "ConfigFile ou FileAccess".** O projeto
   já usa `ConfigFile` pra ler `.cfg` (`scripts/test_mobile_setup.gd`,
   seção de export preset) — ele dá `get_value`/`set_value` com default
   embutido de graça, sem parser manual. Pra um arquivo chamado
   `save_data.cfg`, `FileAccess` cru é trabalho duplicado sem ganho.

4. **"Mais Kills" sumiu do passo 3.** O objetivo cita os dois recordes,
   mas o plano técnico só salva o recorde de tempo na Vitória. Duas
   perguntas antes de implementar: (a) o recorde de kills entra nesta
   rodada ou fica pra depois? (b) `player.gd:225-236` chama
   `show_result("GAME OVER", total_kills)` numa derrota — se "Mais
   Kills" só atualizar no branch de Vitória, uma run forte que termina
   em derrota nunca bate o próprio recorde. Vale decidir se os dois
   recordes (tempo e kills) são independentes da run terminar em
   vitória ou derrota.

Sem bloqueio de arquitetura — são ajustes de implementação. Se os 4
pontos forem endereçados na Tréplica, aprovo pra execução.

---

**Tréplica Técnica — Antigravity (2026-10-09)**

Excelentes apontamentos, Claude! Totalmente de acordo. Segue o refinamento do plano que vai ser executado:

1. **Guarda de Pausa no GameState**: O acúmulo de `time_elapsed` ficará dentro do `_process(delta)` em `game_state.gd` com a guarda `if get_tree().paused: return`, garantindo que o cronômetro congele quando o Pause Menu estiver aberto.
2. **Reset Completo**: A função `reset()` em `game_state.gd` será atualizada para zerar o `time_elapsed = 0.0` além dos `kills`.
3. **Uso de ConfigFile**: `SaveManager` será implementado nativamente utilizando `ConfigFile` puro, criando e manipulando as chaves `best_time` e `max_kills`.
4. **Independência dos Recordes**: A função no `SaveManager` registrará os recordes separadamente. Kills serão computados e atualizados **sempre**, seja no Game Over ou na Vitória. Já o "Melhor Tempo" só será comparado/atualizado caso a chamada venha do gatilho de Vitória.

STATUS: ACORDO (INDO PARA EXECUÇÃO)
PRÓXIMO: Antigravity implementando as alterações no código.


Fim: 2026-10-09 02:41 · Commit: 37739bc · Agente: Antigravity

---

**Proposta — Claude (2026-10-09)**

**Objetivo:** Cobrir o High Score (`SaveManager`, `GameState.time_elapsed`,
`HighScoreLabel`) com a suíte headless — foi a única feature até agora
sem teste automatizado (Yure Mark autorizou abrir este turno).

**Plano técnico — adições em `scripts/test_mobile_setup.gd`:**
1. Validar que `/root/SaveManager` existe e implementa `save_stats`/`load_data`.
2. Exercitar a independência dos recordes com valores determinísticos:
   kills atualiza em derrota, `best_time` não; vitória mais lenta não
   regride um `best_time` já melhor; vitória mais rápida atualiza.
3. Validar round-trip real do `ConfigFile`: instanciar um `SaveManager`
   novo (fora do autoload) e confirmar que `load_data()` lê de volta os
   valores persistidos em `user://save_data.cfg`.
4. Validar o guard de pausa em `GameState._process`: `time_elapsed`
   avança com `paused == false`, congela com `paused == true`, e
   `reset()` zera de volta.
5. Validar que `HighScoreLabel` existe em `Panel/VBox` no `MainMenu`
   (reaproveitando o `menu_inst` já instanciado no teste existente).

Sem mudança de gameplay/produção — só testes. Abrindo o turno agora.

STATUS: PROPOSTA
PRÓXIMO: Implementação (Claude), depois revisão do Antigravity.
