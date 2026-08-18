# 🔄 Bastão de Handover (Revezamento Ativo)

* **Tech Lead / Chefe**: `Claudão (Claude Code)` 👑
* **Implementador**: `Antigravity (Gemini)` ⚡
* **Turno Atual**: `Antigravity (Implementador)` 🟢
* **Próximo Turno**: `Claudão (Chefe)` ⏳

---

## 📌 Status Atual
* **Último Agente a Atuar**: Claudão
* **Revisão (HP/game-over/múltiplas ondas)**: Aprovado sem bugs — tracei a lógica de `_current_wave` no `wave_manager.gd` manualmente: com `total_waves=5`, spawna exatamente 5 ondas completas de `enemies_per_wave` antes de parar. Mesclado em `agent/claude` sem conflitos.

---

## 🏗️ Arquitetura definida pelo Chefe: Chefão de ciclo (última peça do Milestone 2)

**Escopo desta rodada**: 1 chefão (conforme MVP da épica) aparece depois da 5ª onda. Reaproveita o grupo `"enemies"` já existente, então o `player.gd` **não precisa mudar** — o ataque do player já detecta qualquer coisa nesse grupo.

### 1. `scripts/boss.gd` (novo)
```gdscript
extends CharacterBody3D

@export var speed: float = 1.5
@export var hp: int = 15
@export var contact_damage: int = 2

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("boss")

func _physics_process(delta: float) -> void:
	velocity.z = speed
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	move_and_slide()

	var player = get_tree().get_first_node_in_group("player")
	if player and abs(player.position.z - position.z) < 2.0:
		player.take_damage(contact_damage)
		# Chefão NÃO morre no contato (diferente do inimigo comum) — precisa de vários ataques.

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		print("Chefão derrotado! Run concluída.")
		queue_free()
```

### 2. `scenes/boss.tscn` (novo)
Igual ao `enemy.tscn`, mas maior e com cor diferente: `CapsuleMesh`/`CapsuleShape3D` com `transform` escalado (ex.: `Vector3(2, 2, 2)` no node raiz) e `StandardMaterial3D` roxo/escuro em vez de vermelho, pra diferenciar visualmente do inimigo comum. Script apontando pra `boss.gd`.

### 3. `scripts/wave_manager.gd` — spawnar o chefão ao fim da 5ª onda
Adicionar `@export var boss_scene: PackedScene` e uma flag `var _boss_spawned: bool = false`. No trecho onde `_current_wave >= total_waves` (que hoje só imprime "Todas as ondas concluídas!" e para o timer), antes de parar: se `not _boss_spawned`, instanciar o `boss_scene` na posição `Vector3(0, 1.0, spawn_z_offset)`, adicionar à cena, marcar `_boss_spawned = true`.

### 4. `scenes/main.tscn`
Adicionar o `ext_resource` do `boss.tscn` e atribuir `boss_scene` no node `WaveManager` (mesmo padrão já usado pra `enemy_scene`).

---

## 🎯 Próxima Tarefa para o Antigravity (Implementador)
1. Implementar os 4 pontos acima.
2. Testar no editor: confirmar que o chefão aparece só depois da 5ª onda, leva vários hits do ataque do player pra morrer, e causa mais dano por contato que o inimigo comum.
3. Commitar na branch `agent/antigravity`, atualizar este `HANDOVER.md` e dar push.

---

## 📝 Notas & Contexto Rápido
* Mantenha as alterações atômicas e consulte [`COLLAB_PROTOCOL.md`](./COLLAB_PROTOCOL.md) para diretrizes de economia de tokens.
* As lacunas 1–7 listadas no final do `ROADMAP.md` bloqueiam decisões de escopo definitivo — não travar o desenvolvimento por causa delas.
* Estilo artístico assumido (🟡 a validar): Low Poly 3D — por isso as cenas usam `Node3D`/`CharacterBody3D`, não 2D.
