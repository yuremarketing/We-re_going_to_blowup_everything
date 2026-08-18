# 🔄 Bastão de Handover (Revezamento Ativo)

* **Tech Lead / Chefe**: `Claudão (Claude Code)` 👑
* **Implementador**: `Antigravity (Gemini)` ⚡
* **Turno Atual**: `Antigravity (Implementador)` 🟢
* **Próximo Turno**: `Claudão (Chefe)` ⏳

---

## 📌 Status Atual
* **Último Agente a Atuar**: Claudão
* **Revisão (tela de fim de run)**: Aprovado — `end_screen.gd` reaproveitando o padrão de grupos, `player.gd`/`boss.gd` disparando corretamente, `load_steps` certo. Mesclado sem conflitos.
* **Trabalho próprio deste turno**: pesquisei o spike técnico pendente (premissa 9 da épica) — **confirmado que existem MCPs para Godot** (`Dokujaa/Godot-MCP`, `ee0pdt/Godot-MCP`, `DaRealDaHoodie/Claude-GoDot-MCP`, entre outros). Marquei como resolvido no `ROADMAP.md` e na épica.
* Boa sugestão do Antigravity: Menu Principal é mesmo a peça que falta. Indo nessa.

---

## 🏗️ Arquitetura definida pelo Chefe: Menu Principal

**Escopo**: tela inicial simples com título e botão "Jogar", que vira a nova cena de entrada do jogo (hoje o jogo abre direto na `main.tscn`).

### 1. `scenes/main_menu.tscn` (novo)
```
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/main_menu.gd" id="1_script"]

[node name="MainMenu" type="CanvasLayer"]
script = ExtResource("1_script")

[node name="TitleLabel" type="Label" parent="."]
offset_left = 300.0
offset_top = 150.0
text = "HORDA"

[node name="PlayButton" type="Button" parent="."]
offset_left = 300.0
offset_top = 220.0
text = "Jogar"
```

### 2. `scripts/main_menu.gd` (novo)
```gdscript
extends CanvasLayer

@onready var play_button: Button = $PlayButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
```

### 3. `project.godot`
Trocar `run/main_scene="res://scenes/main.tscn"` por `run/main_scene="res://scenes/main_menu.tscn"` — o jogo passa a abrir no menu, não direto na run.

### 4. Bônus (se sobrar tempo, não bloqueante): no `end_screen.gd`, considerar um botão extra "Menu Principal" além do "Reiniciar" — não é obrigatório nesta rodada, só implementar o "Reiniciar" que já existe é suficiente.

---

## 🎯 Próxima Tarefa para o Antigravity (Implementador)
1. Implementar os 3 pontos obrigatórios acima (o 4 é opcional).
2. Testar no editor: o jogo deve abrir no Menu Principal, e o botão "Jogar" deve levar pra `main.tscn` normalmente.
3. Commitar na branch `agent/antigravity`, atualizar este `HANDOVER.md` e dar push.

---

## 📝 Notas & Contexto Rápido
* Mantenha as alterações atômicas e consulte [`COLLAB_PROTOCOL.md`](./COLLAB_PROTOCOL.md) para diretrizes de economia de tokens.
* As lacunas 1–6 listadas no final do `ROADMAP.md` bloqueiam decisões de escopo definitivo (nome, tema, plataforma, estilo, monetização, números do MVP) — não travar o desenvolvimento por causa delas, mas não hardcodar decisões que dependem dessas respostas.
* Estilo artístico assumido (🟡 a validar): Low Poly 3D — por isso as cenas usam `Node3D`/`CharacterBody3D`, não 2D.

---

## 📝 Notas & Contexto Rápido
* Mantenha as alterações atômicas e consulte [`COLLAB_PROTOCOL.md`](./COLLAB_PROTOCOL.md) para diretrizes de economia de tokens.
* As lacunas 1–7 listadas no final do `ROADMAP.md` bloqueiam decisões de escopo definitivo — não travar o desenvolvimento por causa delas.
* Estilo artístico assumido (🟡 a validar): Low Poly 3D — por isso as cenas usam `Node3D`/`CharacterBody3D`, não 2D.
