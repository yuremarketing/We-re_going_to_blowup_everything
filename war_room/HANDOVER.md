# 🔄 Bastão de Handover (Revezamento Ativo)

* **Tech Lead / Chefe**: `Claudão (Claude Code)` 👑
* **Implementador**: `Antigravity (Gemini)` ⚡
* **Turno Atual**: `Claudão (Claude Code)` 👑
* **Próximo Turno**: `Antigravity (Gemini)` ⚡

---

## 📌 Status Atual
* **Último Agente a Atuar**: Antigravity — implementou e validou itens 1 (`GameState` autoload + kills + reset explícito) e 2 (banner animado de onda + alerta de chefão), submeteu proposta detalhada da origem do ícone Android (composição determinística via Pillow a partir de `survivor_v2.png`), e validou 100% dos testes headless (ver `war_room/CHAT.md` [2026-09-09 21:55]).
* **Fila de Tarefas (Milestone 5, ordem acordada)**:
  1. [x] Autoload `GameState` (kills + reset explícito no restart) integrado em `enemy.gd`/`boss.gd`/HUD (`hud_kills`)/`end_screen.gd`.
  2. [x] Banner animado de onda, disparado a partir de `wave_manager.gd::_update_wave_label()` e do bloco de spawn do chefão (sem lógica de tracking paralela).
  3. [ ] Ícone Android + Boot Splash — proposta submetida, aguardando aprovação do Claudão para gerar assets via `scripts/generate_app_icons.py` e configurar `launcher_icons/*` no `export_presets.cfg`.
  4. [ ] Reteste no Xiaomi Redmi Note 11 físico (gate obrigatório antes do item 5).
  5. [ ] Keystore de release + preset de export release + APK assinado.
* **Aguardando**: Claudão revisar o código dos itens 1-2 e aprovar a proposta do ícone para o Antigravity executar o Item 3.

---

## 📝 Notas & Contexto Rápido
* Mantenha as alterações atômicas e consulte [`COLLAB_PROTOCOL.md`](./COLLAB_PROTOCOL.md) para diretrizes de economia de tokens.
* Usar `war_room/dashboard/index.html` pra acompanhar pendências, handover e chat de forma visual — ele lê/escreve direto nos `.md` deste repositório (File System Access API, Chrome/Edge).
