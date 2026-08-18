# 🔄 Bastão de Handover (Revezamento Ativo)

* **Tech Lead / Chefe**: `Claudão (Claude Code)` 👑
* **Implementador**: `Antigravity (Gemini)` ⚡
* **Turno Atual**: `Antigravity (Implementador)` 🟢
* **Próximo Turno**: `Claudão (Chefe)` ⏳

---

## 📌 Status Atual
* **Último Agente a Atuar**: Claudão
* **Revisão (variedade de inimigos)**: Aprovado — 3 tipos reaproveitando `enemy.gd`, `load_steps` correto. Mesclado sem conflitos.
* **Trabalho próprio deste turno (não precisou do Godot)**: escrevi `docs/GDD.md`, `docs/LDD.md` e `docs/LORE.md` (v1), e atualizei o `ROADMAP.md` — Milestone 3 quase fechado, só falta "Ajustes de performance" (bloqueado até termos dispositivo-alvo definido).
* **Lacuna identificada no LDD**: não existe tela de fim de jogo — hoje `game_over()` só pausa e imprime no console. Vira a próxima tarefa.

---

## 🏗️ Arquitetura definida pelo Chefe: Tela de fim de run (Game Over / Vitória) + Restart

**Escopo**: uma tela simples que aparece tanto na derrota (HP zerado) quanto na vitória (chefão derrotado), com botão pra reiniciar a run.

### 1. `scenes/main.tscn` — adicionar `EndScreen`
```
[node name="EndScreen" type="CanvasLayer" parent="." groups=["end_screen"]]
visible = false
process_mode = 3

[node name="ResultLabel" type="Label" parent="EndScreen"]
offset_left = 300.0
offset_top = 200.0
text = "GAME OVER"

[node name="RestartButton" type="Button" parent="EndScreen"]
offset_left = 300.0
offset_top = 250.0
text = "Reiniciar"
```
(`process_mode = 3` = `PROCESS_MODE_ALWAYS`, necessário pra o botão continuar clicável mesmo com `get_tree().paused = true`. Os filhos herdam por padrão.)

### 2. `scripts/end_screen.gd` (novo, anexar ao node `EndScreen`)
```gdscript
extends CanvasLayer

@onready var restart_button: Button = $RestartButton
@onready var result_label: Label = $ResultLabel

func _ready() -> void:
	visible = false
	restart_button.pressed.connect(_on_restart_pressed)

func show_result(text: String) -> void:
	result_label.text = text
	visible = true

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
```

### 3. `scripts/player.gd` — chamar a tela na derrota
Dentro de `game_over()`, depois de `get_tree().paused = true`:
```gdscript
	var screen = get_tree().get_first_node_in_group("end_screen")
	if screen:
		screen.show_result("GAME OVER")
```

### 4. `scripts/boss.gd` — chamar a tela na vitória
Dentro de `take_damage()`, no bloco `if hp <= 0:`, depois do `queue_free()`:
```gdscript
		get_tree().paused = true
		var screen = get_tree().get_first_node_in_group("end_screen")
		if screen:
			screen.show_result("VITÓRIA!")
```

---

## 🎯 Próxima Tarefa para o Antigravity (Implementador)
1. Implementar os 4 pontos acima.
2. Testar no editor: perder (encostar em inimigos até HP zerar) deve mostrar "GAME OVER" com botão funcional; derrotar o chefão deve mostrar "VITÓRIA!" também com botão funcional. O botão precisa reiniciar a run do zero.
3. Ler também `docs/GDD.md`, `docs/LDD.md` e `docs/LORE.md` que acabei de escrever — é só pra contexto, não precisa alterar nada lá.
4. Commitar na branch `agent/antigravity`, atualizar este `HANDOVER.md` e dar push.

---

## 📝 Notas & Contexto Rápido
* Mantenha as alterações atômicas e consulte [`COLLAB_PROTOCOL.md`](./COLLAB_PROTOCOL.md) para diretrizes de economia de tokens.
* As lacunas 1–7 listadas no final do `ROADMAP.md` bloqueiam decisões de escopo definitivo — não travar o desenvolvimento por causa delas.
* Estilo artístico assumido (🟡 a validar): Low Poly 3D — por isso as cenas usam `Node3D`/`CharacterBody3D`, não 2D.
