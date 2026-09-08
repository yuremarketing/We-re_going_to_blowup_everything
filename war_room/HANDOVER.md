# 🔄 Bastão de Handover (Revezamento Ativo)

* **Tech Lead / Chefe**: `Claudão (Claude Code)` 👑
* **Implementador**: `Antigravity (Gemini)` ⚡
* **Turno Atual**: `Usuário` 🧑
* **Próximo Turno**: `Antigravity (Gemini)` ⚡ (implementar itens 3 e 4, dentro do allowlist) — mas só depois do Usuário decidir o item abaixo

---

## 📌 Status Atual
* **Último Agente a Atuar**: Claudão — validou o diagnóstico de lag do Antigravity direto no código. Concorda com os itens 1 (renderer Vulkan Mobile), 2 (MSAA 3D), 3 (sombra dinâmica) e 4 (alocação de partículas por morte). Descartou o item 5 (despawn de inimigo) por falta de evidência no código (`enemy.gd` já dá `queue_free()` no contato com o player).
* **Issue #6: concluída.** **Issue #5 (device real): teste feito, resultado negativo** — lag/travamento confirmado, causa raiz agora mapeada (itens 1-4 do diagnóstico em `CHAT.md`).
* **Bloqueado, aguardando Usuário**: itens 1 e 2 exigem editar `project.godot` (mudar `renderer/rendering_method` pra `gl_compatibility` e desativar `msaa_3d`), que está fora do allowlist da ponte autônoma (`.claude/settings.json`) e conta como mudança de configuração de build/render — precisa de confirmação humana explícita antes de qualquer agente tocar nesse arquivo. Ponte autônoma pausada até essa decisão (ver `CHAT.md`).
* Itens 3 (`scenes/main.tscn`) e 4 (`scripts/enemy.gd`/`scripts/boss.gd`) já estão liberados pro Antigravity implementar assim que o Usuário der sinal — não dependem do `project.godot`.

---

## 📝 Notas & Contexto Rápido
* Mantenha as alterações atômicas e consulte [`COLLAB_PROTOCOL.md`](./COLLAB_PROTOCOL.md) para diretrizes de economia de tokens.
* Usar `war_room/dashboard/index.html` pra acompanhar pendências, handover e chat de forma visual — ele lê/escreve direto nos `.md` deste repositório (File System Access API, Chrome/Edge).
