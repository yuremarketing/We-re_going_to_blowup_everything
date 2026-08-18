# 🔄 Bastão de Handover (Revezamento Ativo)

* **Tech Lead / Chefe**: `Claudão (Claude Code)` 👑
* **Implementador**: `Antigravity (Gemini)` ⚡
* **Turno Atual**: `Antigravity (Implementador)` 🟢
* **Próximo Turno**: `Claudão (Chefe)` ⏳

---

## 📌 Status Atual
* **Último Agente a Atuar**: Claudão
* **Revisão do protótipo (Milestone 1)**: Aprovado. `player.gd` e `main.tscn` revisados linha a linha — movimento travado no eixo Z, gravidade, ataque placeholder com Tween, cena com chão/luz/câmera, tudo consistente com o pedido. Mesclei sua branch (`agent/antigravity`) na minha (`agent/claude`) sem conflitos.
* **Decisão do Chefe**: seguir para o **Milestone 2 (Core Gameplay)** agora — o Spike Técnico do MCP do Godot fica registrado como pendente no `ROADMAP.md`, mas não bloqueia o gameplay, então adiado por prioridade (valor de jogo jogável > automação de pipeline nesse momento).

---

## 🏗️ Arquitetura definida pelo Chefe para o Antigravity implementar

**Escopo desta rodada**: sistema de spawn de ondas + inimigo básico + ligação com o ataque do player já existente. Sem HP do player, sem chefão ainda — isso fica pra próxima rodada do Milestone 2, de propósito, pra manter a tarefa atômica.

### 1. `scripts/enemy.gd` (novo)
```gdscript
extends CharacterBody3D

@export var speed: float = 3.0
@export var hp: int = 1

func _ready() -> void:
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	# Anda em direção ao player, no sentido +Z (o player nasce em Z menor e avança em -Z)
	velocity.z = speed
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	move_and_slide()

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		queue_free()
```

### 2. `scenes/enemy.tscn` (novo)
Igual ao `Player` da `main.tscn` (CapsuleMesh + CapsuleShape3D como placeholder visual), mas com `script = enemy.gd` e sem `Camera3D`.

### 3. `scripts/wave_manager.gd` (novo) + node `WaveManager` (Node3D) em `main.tscn`
```gdscript
extends Node3D

@export var enemy_scene: PackedScene
@export var enemies_per_wave: int = 5
@export var spawn_interval: float = 1.5
@export var spawn_z_offset: float = -30.0
@export var lane_width: float = 8.0  # metade pra cada lado do centro

var _spawned_this_wave: int = 0
var _timer: Timer

func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = spawn_interval
	_timer.timeout.connect(_on_spawn_tick)
	add_child(_timer)
	_timer.start()

func _on_spawn_tick() -> void:
	if _spawned_this_wave >= enemies_per_wave:
		return
	var enemy = enemy_scene.instantiate()
	var x = randf_range(-lane_width / 2.0, lane_width / 2.0)
	enemy.position = Vector3(x, 1.0, spawn_z_offset)
	get_tree().current_scene.add_child(enemy)
	_spawned_this_wave += 1
```
(5 ondas fixas e transição entre ondas ficam pra próxima iteração — por ora, spawna 1 onda de `enemies_per_wave` e para.)

### 4. Ligar o ataque do player aos inimigos
Em `scripts/player.gd`, dentro de `attack()`, adicionar checagem de dano por proximidade:
```gdscript
func attack() -> void:
	print("POW! Ataque placeholder executado contra a horda.")
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1.2, 1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 0.1)

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if abs(enemy.position.z - position.z) < 2.0:
			enemy.take_damage(1)
```

---

## 🎯 Próxima Tarefa para o Antigravity (Implementador)
1. Criar os 3 arquivos/nós acima exatamente como especificado (não decidir arquitetura nova, só implementar).
2. Adicionar o node `WaveManager` na `main.tscn` com `enemy_scene` apontando pra `enemy.tscn`.
3. Testar localmente no editor Godot: rodar a cena, confirmar que inimigos aparecem à frente e andam em direção ao player, e que apertar o ataque (`ui_accept`) destrói inimigo próximo.
4. Commitar na branch `agent/antigravity`, atualizar este `HANDOVER.md` passando o turno de volta pro Claudão e dar push.

---

## 📝 Notas & Contexto Rápido
* Mantenha as alterações atômicas e consulte [`COLLAB_PROTOCOL.md`](./COLLAB_PROTOCOL.md) para diretrizes de economia de tokens.
* As lacunas 1–7 listadas no final do `ROADMAP.md` bloqueiam decisões de escopo definitivo — não travar o desenvolvimento por causa delas.
* Estilo artístico assumido (🟡 a validar): Low Poly 3D — por isso as cenas usam `Node3D`/`CharacterBody3D`, não 2D.
* `TEST_CHAT.md` na raiz é só um teste de handoff (Copa do Mundo) — pode ser removido quando quiserem, não faz parte do projeto.
