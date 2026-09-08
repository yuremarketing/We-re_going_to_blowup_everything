# Game Design Document (GDD) v1

> Baseado em [`docs/epicas/EPICA-001-jogo-horde-survival.md`](./epicas/EPICA-001-jogo-horde-survival.md) e no estado atual da implementação (branch `agent/claude`). Itens marcados 🟡 são premissas ainda não validadas; ✅ marca itens confirmados pelo usuário/C-level em 2026-09-08 via `war_room/dashboard/`.

## 1. Visão Geral
- **Nome**: `We're Going to Blow Up Everything` ✅ (confirmado pelo usuário em 2026-09-08 — mesmo nome do repositório)
- **Gênero**: Ação/sobrevivência em viela linear (horde/lane survival)
- **Tema (MVP)**: Apocalipse zumbi ✅
- **Plataforma-alvo**: Mobile-first, build secundária PC/Web ✅
- **Estilo artístico**: Low Poly 3D ✅
- **Engine**: Godot

## 2. Pitch
Um sobrevivente avança por uma viela estreita enquanto uma multidão hostil vem em sua direção, em ondas cada vez mais difíceis, até enfrentar um chefão de ciclo. Partidas curtas, regras simples, tensão crescente.

## 3. Loop Principal (implementado)
1. Jogador se move ao longo do eixo único da viela (frente/trás).
2. Inimigos surgem à frente em ondas cronometradas e avançam em direção ao jogador.
3. Jogador ataca (dano em área curta, à frente) para eliminar inimigos antes que o alcancem.
4. Contato de um inimigo com o jogador causa dano e remove o inimigo (exceto o chefão).
5. Ao completar todas as ondas, o chefão aparece — precisa de múltiplos ataques para ser derrotado.
6. HP do jogador chega a 0 → Game Over.

## 4. Personagem Jogável
- 1 personagem no MVP ✅ (escopo numérico confirmado pelo usuário em 2026-09-08).
- HP inicial: 5 (`max_hp`, ajustável).
- Movimento restrito ao eixo Z (viela).
- Ataque: área curta à frente, feedback visual (escala via Tween), sem cooldown definido ainda.
- Concept art oficial: [`assets/concept_art/survivor_v2.png`](../assets/concept_art/survivor_v2.png).

## 5. Inimigos (implementado: 3 tipos comuns + 1 chefão)

| Tipo | Velocidade | HP | Papel | Concept art |
|---|---|---|---|---|
| Comum | 3.0 | 1 | Base, equilíbrio | [`enemy_common_v1.png`](../assets/concept_art/enemy_common_v1.png) |
| Rápido (laranja) | 6.0 | 1 | Pressão de reflexo, fácil de matar | [`enemy_fast_v1.png`](../assets/concept_art/enemy_fast_v1.png) |
| Tanque (cinza) | 1.5 | 3 | Obstáculo, absorve tempo/ataques | [`enemy_tank_v2.png`](../assets/concept_art/enemy_tank_v2.png) |
| Chefão (roxo, 2x escala) | 1.5 | 15 | Fim de ciclo, não morre em 1 contato, causa 2 de dano | [`boss_v2.png`](../assets/concept_art/boss_v2.png) |

> Concept art gerado via Nano Banana (Antigravity/Gemini), validado em par com o Claudão em 2026-08-18 (ver histórico completo em [`CHAT.md`](../CHAT.md)). Etapa de conversão 2D→3D (Meshy/Blender) ainda depende de intervenção manual — ver `ROADMAP.md`.

Todos os inimigos comuns morrem em contato com o jogador (trocam 1 dano por si mesmos); o chefão não.

## 6. Estrutura de Onda (implementado)
- 5 ondas por run ✅ (escopo numérico confirmado pelo usuário em 2026-09-08).
- `enemies_per_wave = 5` por onda, `spawn_interval = 1.5s` entre spawns.
- `time_between_waves = 5s` de intervalo entre ondas.
- Tipo de inimigo sorteado aleatoriamente entre os 3 tipos comuns a cada spawn.
- Ao fim da 5ª onda, chefão único é spawnado.

## 7. HUD (implementado)
- Label de HP (`HP: x/5`).
- Label de progresso de onda (`Onda: x/5`).
- Controles táteis mobile (One-Thumb Portrait): botões `TouchScreenButton` para avanço (`▲` / `ui_up`), recuo (`▼` / `ui_down`) e ataque (`⚔️` / `ui_accept`), posicionados no terço inferior da tela. Emulação de toque ativada para permitir testes no desktop via clique de mouse.
- Tela de fim de jogo (`EndScreen`) com âncoras centralizadas para Portrait 720x1280.

## 8. Fora do escopo do MVP (backlog)
- Multiplayer/coop.
- Monetização implementada (modelo confirmado ✅: free-to-play com anúncios opcionais + IAP cosmético; implementação segue fora do escopo do MVP).
- VFX de impacto e cutscenes (direção confirmada ✅: hit flash/partículas/screen shake, transições de onda animadas, cutscenes curtas via IA — ver épica, premissa 3; nada disso implementado ainda).
- Áudio/trilha sonora.
- Menu principal / tela de restart — **implementado** (ver `scripts/main_menu.gd`, `scenes/main_menu.tscn`).
- Progressão entre runs (meta-progressão).
- Pipeline de arte final (assets são placeholders geométricos — cápsulas coloridas; concept art 2D já existe em `assets/concept_art/`, conversão 3D bloqueada — ver `ROADMAP.md`).

## 9. Perguntas em aberto
Ver seção 8 de [`docs/epicas/EPICA-001-jogo-horde-survival.md`](./epicas/EPICA-001-jogo-horde-survival.md) e a seção "Perguntas em aberto" do `ROADMAP.md`. Única pendência real hoje: **nome definitivo do jogo**. Tema, plataforma, estilo artístico, monetização e escopo numérico já foram confirmados pelo usuário em 2026-09-08.
