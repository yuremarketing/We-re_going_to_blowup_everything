# 🔄 Bastão de Handover (Revezamento Ativo)

* **Tech Lead / Chefe**: `Claudão (Claude Code)` 👑
* **Implementador**: `Antigravity (Gemini)` ⚡
* **Turno Atual**: `Antigravity (Implementador)` 🟢
* **Próximo Turno**: `Claudão (Chefe)` ⏳

---

## 📌 Status Atual
* **Último Agente a Atuar**: Claudão
* **Revisão (chefão)**: Aprovado — `boss.gd`/`boss.tscn` corretos, reaproveita o grupo `"enemies"` como planejado (não precisou tocar em `player.gd`), e `load_steps` já veio certo desta vez. Mesclado sem conflitos.
* **Milestone 2 (Core Gameplay): concluído** no código — spawn de ondas, combate básico e chefão todos marcados no `ROADMAP.md`. Só falta o item de pipeline de arte, que depende de ferramentas externas (Nano Banana/Meshy) fora do nosso alcance agora — deixei anotado no ROADMAP e seguimos sem bloquear por causa disso.

---

## 🏗️ Arquitetura definida pelo Chefe: HUD básico (Milestone 3, primeira fatia)

**Motivo**: hoje HP e progresso das ondas só aparecem via `print()` no console — o jogo não é "jogável" de verdade sem feedback visual na tela.

**Escopo desta rodada**: um `CanvasLayer` simples com 2 `Label`s (HP e Onda), sem estilização — só legível.

### 1. `scenes/main.tscn` — adicionar HUD
Adicionar como novo node filho de `Main`:
```
[node name="HUD" type="CanvasLayer" parent="."]

[node name="HPLabel" type="Label" parent="HUD"]
offset_left = 20.0
offset_top = 20.0
text = "HP: 5/5"

[node name="WaveLabel" type="Label" parent="HUD"]
offset_left = 20.0
offset_top = 50.0
text = "Onda: 0/5"
```

### 2. `scripts/player.gd` — atualizar o label de HP
Dentro de `take_damage()`, além do `print()` existente, atualizar o texto do label. Forma mais simples pro protótipo (evita acoplar caminho de nó fixo): usar um grupo `"hud_hp"` no `HPLabel` (via `add_to_group` na cena, ou código) e:
```gdscript
func _update_hp_label() -> void:
	var label = get_tree().get_first_node_in_group("hud_hp")
	if label:
		label.text = "HP: %d/%d" % [hp, max_hp]
```
Chamar `_update_hp_label()` no fim de `_ready()` e no fim de `take_damage()`. No `HPLabel` da cena, adicionar `groups=["hud_hp"]`.

### 3. `scripts/wave_manager.gd` — atualizar o label de onda
Mesmo padrão: grupo `"hud_wave"` no `WaveLabel`, e uma função que atualiza o texto (`"Onda: %d/%d" % [_current_wave, total_waves]`) toda vez que `_current_wave` mudar.

---

## 🎯 Próxima Tarefa para o Antigravity (Implementador)
1. Implementar os 3 pontos acima.
2. Testar no editor: HP e número da onda devem atualizar na tela em tempo real durante o jogo.
3. Commitar na branch `agent/antigravity`, atualizar este `HANDOVER.md` e dar push.

---

## 📝 Notas & Contexto Rápido
* Mantenha as alterações atômicas e consulte [`COLLAB_PROTOCOL.md`](./COLLAB_PROTOCOL.md) para diretrizes de economia de tokens.
* As lacunas 1–7 listadas no final do `ROADMAP.md` bloqueiam decisões de escopo definitivo — não travar o desenvolvimento por causa delas.
* Estilo artístico assumido (🟡 a validar): Low Poly 3D — por isso as cenas usam `Node3D`/`CharacterBody3D`, não 2D.
