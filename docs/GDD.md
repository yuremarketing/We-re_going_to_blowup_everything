# Game Design Document (GDD) v1

> Baseado em [`docs/epicas/EPICA-001-jogo-horde-survival.md`](./epicas/EPICA-001-jogo-horde-survival.md) e no estado atual da implementação (branch `agent/claude`). Itens marcados 🟡 são premissas assumidas, ainda não validadas com o C-level/Felipe Pessanha.

## 1. Visão Geral
- **Codinome**: `HORDA` 🟡 (nome definitivo pendente)
- **Gênero**: Ação/sobrevivência em viela linear (horde/lane survival)
- **Tema (MVP)**: Apocalipse zumbi 🟡
- **Plataforma-alvo**: Mobile-first, build secundária PC/Web 🟡
- **Estilo artístico**: Low Poly 3D 🟡
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
- 1 personagem no MVP 🟡 (número de personagens ainda não validado com o C-level).
- HP inicial: 5 (`max_hp`, ajustável).
- Movimento restrito ao eixo Z (viela).
- Ataque: área curta à frente, feedback visual (escala via Tween), sem cooldown definido ainda.

## 5. Inimigos (implementado: 3 tipos comuns + 1 chefão)

| Tipo | Velocidade | HP | Papel |
|---|---|---|---|
| Comum | 3.0 | 1 | Base, equilíbrio |
| Rápido (laranja) | 6.0 | 1 | Pressão de reflexo, fácil de matar |
| Tanque (cinza) | 1.5 | 3 | Obstáculo, absorve tempo/ataques |
| Chefão (roxo, 2x escala) | 1.5 | 15 | Fim de ciclo, não morre em 1 contato, causa 2 de dano |

Todos os inimigos comuns morrem em contato com o jogador (trocam 1 dano por si mesmos); o chefão não.

## 6. Estrutura de Onda (implementado)
- 5 ondas por run 🟡 (número do MVP, a validar).
- `enemies_per_wave = 5` por onda, `spawn_interval = 1.5s` entre spawns.
- `time_between_waves = 5s` de intervalo entre ondas.
- Tipo de inimigo sorteado aleatoriamente entre os 3 tipos comuns a cada spawn.
- Ao fim da 5ª onda, chefão único é spawnado.

## 7. HUD (implementado)
- Label de HP (`HP: x/5`).
- Label de progresso de onda (`Onda: x/5`).
- Sem estilização ainda — puramente funcional.

## 8. Fora do escopo do MVP (backlog)
- Multiplayer/coop.
- Monetização implementada (hipótese: free-to-play + IAP cosmético 🟡).
- Áudio/trilha sonora.
- Menu principal / tela de restart (ainda não implementado).
- Progressão entre runs (meta-progressão).
- Pipeline de arte final (assets são placeholders geométricos — cápsulas coloridas).

## 9. Perguntas em aberto
Ver seção 8 de [`docs/epicas/EPICA-001-jogo-horde-survival.md`](./epicas/EPICA-001-jogo-horde-survival.md) — nome, tema, plataforma, estilo artístico, monetização, e escopo numérico ainda pendem de validação com o C-level e com Felipe Pessanha.
