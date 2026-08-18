# Level Design Document (LDD) v1

> Documenta a única "fase"/run implementada até agora. Como o jogo é endless/arcade por run (ver [`GDD.md`](./GDD.md)), o "nível" é a estrutura de uma run completa, não uma sequência de fases fixas.

## 1. Geometria da Viela
- Chão: `BoxMesh`/`BoxShape3D` de `10 x 1 x 100` (largura x altura x profundidade).
- Jogador nasce em `Z = 1` (próximo ao início do chão), avança em direção a `Z` negativo.
- Largura útil de spawn dos inimigos: `lane_width = 8` (centralizado, ±4 do eixo X).
- Inimigos nascem em `spawn_z_offset = -30` (à frente do jogador) e avançam em `+Z` até alcançá-lo.

## 2. Estrutura de uma Run
```
[Onda 1: 5 inimigos, mix aleatório dos 3 tipos comuns]
        ↓ (5s de intervalo)
[Onda 2: 5 inimigos]
        ↓ (5s de intervalo)
[Onda 3: 5 inimigos]
        ↓ (5s de intervalo)
[Onda 4: 5 inimigos]
        ↓ (5s de intervalo)
[Onda 5: 5 inimigos]
        ↓
[Chefão único — fim de ciclo]
        ↓
[Vitória (chefão derrotado) OU Game Over (HP do jogador chega a 0)]
```
- Total de inimigos comuns por run: até 25 (5 ondas × 5 inimigos), sujeitos ao jogador eliminar antes do fim.
- Ritmo de spawn dentro de uma onda: 1 inimigo a cada 1.5s.

## 3. Curva de Dificuldade (estado atual)
- **Não há progressão de dificuldade entre ondas ainda** — todas as 5 ondas usam os mesmos parâmetros (`enemies_per_wave`, `spawn_interval`, mix de tipos). Isso é uma lacuna de design: a épica menciona "progressão de inimigos e chefões", mas a implementação atual é *flat* (mesma dificuldade da onda 1 à 5).
- Sugestão para próxima iteração de LDD: aumentar `enemies_per_wave` e/ou proporção de inimigos "tanque"/"rápido" a cada onda, e reduzir `spawn_interval` gradualmente.

## 4. Pontos de Falha Conhecidos (para próxima iteração)
- Sem UI de vitória/derrota — o jogo hoje só imprime no console (`GAME OVER`, `Chefão derrotado!`) e pausa a árvore; falta uma tela de fato com opção de reiniciar.
- Largura da viela (`lane_width = 8`) vs. largura do chão (`10`) deixa pouca margem nas bordas — vale revisar quando houver arte final (placeholders atuais não deixam isso óbvio).
- Todos os inimigos avançam em linha reta sem desviar uns dos outros — pode gerar sobreposição visual quando muitos aparecem ao mesmo tempo (mais perceptível com arte final do que com cápsulas).

## 5. Fora do escopo desta versão
- Level design de fases distintas (temas, cenários variados) — o MVP é uma única viela genérica.
- Balanceamento fino de dificuldade — os números atuais (HP, velocidade, quantidade) são placeholders de prototipagem, não resultado de playtesting.
