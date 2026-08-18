# 🔄 Bastão de Handover (Revezamento Ativo)

* **Tech Lead / Chefe**: `Claudão (Claude Code)` 👑
* **Implementador**: `Antigravity (Gemini)` ⚡
* **Turno Atual**: `Antigravity (Implementador)` 🟢
* **Próximo Turno**: `Claudão (Chefe)` ⏳

---

## 📌 Status Atual
* **Último Agente a Atuar**: Claudão
* **Revisão (Milestone 2, parte 1)**: Aprovado sem ressalvas de lógica. Único nit cosmético: `load_steps` do `main.tscn` ficou desatualizado (7, deveria ser 9 com os 2 novos `ext_resource`) — não quebra nada no Godot, corrigir quando conveniente, não é bloqueante.
* Mesclado `agent/antigravity` → `agent/claude` sem conflitos.

---

## 🏗️ Arquitetura definida pelo Chefe: HP do player + Game Over + múltiplas ondas

**Escopo desta rodada**: fechar o loop de jogo (o jogador agora pode morrer) e fazer as ondas se repetirem (rumo às 5 ondas por run da épica), em vez de spawnar só 1 onda e parar.

### 1. `scripts/player.gd` — adicionar HP e game over
```gdscript
@export var max_hp: int = 5
var hp: int
var is_dead: bool = false

func _ready() -> void:
	add_to_group("player")
	hp = max_hp

func take_damage(amount: int) -> void:
	if is_dead:
		return
	hp -= amount
	print("Player tomou dano! HP: ", hp, "/", max_hp)
	if hp <= 0:
		game_over()

func game_over() -> void:
	is_dead = true
	print("GAME OVER")
	get_tree().paused = true
```
(UI de HP na tela fica pra outra iteração — por ora, `print()` já é suficiente pra validar a lógica.)

### 2. `scripts/enemy.gd` — inimigo passa a causar dano ao alcançar o player
Adicionar dentro de `_physics_process`, depois do `move_and_slide()`:
```gdscript
	var player = get_tree().get_first_node_in_group("player")
	if player and abs(player.position.z - position.z) < 1.5:
		player.take_damage(1)
		queue_free()
```
(Contato = dano único e o inimigo é removido — sem sistema de dano contínuo por enquanto, mantendo simples.)

### 3. `scripts/wave_manager.gd` — repetir por múltiplas ondas
Trocar a lógica de "spawna 1 onda e para" por: ao completar `enemies_per_wave`, esperar um intervalo (`@export var time_between_waves: float = 5.0`) e reiniciar o contador, até um total de `@export var total_waves: int = 5` (valor do MVP definido na épica). Ao terminar a última onda, parar o `_timer` e imprimir `"Todas as ondas concluídas!"`.

---

## 🎯 Próxima Tarefa para o Antigravity (Implementador)
1. Implementar os 3 pontos acima exatamente como especificado.
2. Testar no editor Godot: tomar dano ao encostar em inimigo, HP chegando a 0 pausa o jogo, e múltiplas ondas se sucedendo até a 5ª.
3. Commitar na branch `agent/antigravity`, atualizar este `HANDOVER.md` passando o turno de volta pro Claudão e dar push.

---

## 📝 Notas & Contexto Rápido
* Mantenha as alterações atômicas e consulte [`COLLAB_PROTOCOL.md`](./COLLAB_PROTOCOL.md) para diretrizes de economia de tokens.
* As lacunas 1–7 listadas no final do `ROADMAP.md` bloqueiam decisões de escopo definitivo — não travar o desenvolvimento por causa delas.
* Estilo artístico assumido (🟡 a validar): Low Poly 3D — por isso as cenas usam `Node3D`/`CharacterBody3D`, não 2D.
