# 🔄 Bastão de Handover (Revezamento Ativo)

* **Tech Lead / Chefe**: `Claudão (Claude Code)` 👑
* **Implementador**: `Antigravity (Gemini)` ⚡
* **Turno Atual**: `Antigravity (Implementador)` 🟢
* **Próximo Turno**: `Claudão (Chefe)` ⏳

---

## 📌 Status Atual
* **Último Agente a Atuar**: Claudão
* **Revisão (HUD)**: Aprovado — grupos `hud_hp`/`hud_wave` corretamente ligados, `_update_*_label()` chamadas nos pontos certos (`_ready`, `take_damage`, incremento de onda). Mesclado sem conflitos.

---

## 🏗️ Arquitetura definida pelo Chefe: Variedade de inimigos (3 tipos, conforme escopo da épica)

**Motivo**: a épica define "3 tipos de inimigo comum" no MVP (`docs/epicas/EPICA-001-jogo-horde-survival.md`, seção 4), mas só existe 1 tipo até agora. **Não precisa de script novo** — `enemy.gd` já é genérico (`speed` e `hp` exportados), então isso é só criar variações de cena.

### 1. `scenes/enemy_fast.tscn` (novo, copiar `enemy.tscn` e ajustar)
- Mesmo `enemy.gd`.
- `speed = 6.0`, `hp = 1` (rápido e frágil).
- Cor: laranja (`Color(1, 0.5, 0, 1)`).

### 2. `scenes/enemy_tank.tscn` (novo, copiar `enemy.tscn` e ajustar)
- Mesmo `enemy.gd`.
- `speed = 1.5`, `hp = 3` (lento e resistente).
- Cor: cinza escuro (`Color(0.3, 0.3, 0.3, 1)`).

### 3. `scripts/wave_manager.gd` — spawnar aleatoriamente entre os 3 tipos
Trocar `@export var enemy_scene: PackedScene` por `@export var enemy_scenes: Array[PackedScene]`. No `_on_spawn_tick()`, onde hoje instancia `enemy_scene.instantiate()`, trocar por:
```gdscript
var enemy = enemy_scenes[randi() % enemy_scenes.size()].instantiate()
```

### 4. `scenes/main.tscn`
Adicionar os 2 novos `ext_resource` (`enemy_fast.tscn`, `enemy_tank.tscn`) e preencher o array `enemy_scenes` do node `WaveManager` com os 3 (`enemy.tscn` original + os 2 novos).

---

## 🎯 Próxima Tarefa para o Antigravity (Implementador)
1. Implementar os 4 pontos acima.
2. Testar no editor: confirmar que os 3 tipos aparecem variados durante as ondas (cores/velocidades diferentes visíveis).
3. Commitar na branch `agent/antigravity`, atualizar este `HANDOVER.md` e dar push.

---

## 📝 Notas & Contexto Rápido
* Mantenha as alterações atômicas e consulte [`COLLAB_PROTOCOL.md`](./COLLAB_PROTOCOL.md) para diretrizes de economia de tokens.
* As lacunas 1–7 listadas no final do `ROADMAP.md` bloqueiam decisões de escopo definitivo — não travar o desenvolvimento por causa delas.
* Estilo artístico assumido (🟡 a validar): Low Poly 3D — por isso as cenas usam `Node3D`/`CharacterBody3D`, não 2D.
