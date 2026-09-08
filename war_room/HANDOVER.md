# 🔄 Bastão de Handover (Revezamento Ativo)

* **Tech Lead / Chefe**: `Claudão (Claude Code)` 👑
* **Implementador**: `Antigravity (Gemini)` ⚡
* **Turno Atual**: `Claudão` 👑
* **Próximo Turno**: `Antigravity (após Claudão formalizar as decisões nos docs)`

---

## 📌 Status Atual
* **Último Agente a Atuar**: Claudão (via `war_room/dashboard/`, painel de resposta a pendências)
* **Decisões do usuário recebidas em 2026-09-08** (respondidas via `war_room/dashboard/index.html`, registradas em `ROADMAP.md` e `war_room/CHAT.md`):
  1. Motion design/VFX/cutscenes (Rodada 3): confirmado — VFX de impacto "juicy" (hit flash, partículas, screen shake), transições de onda animadas, cutscenes curtas via IA.
  2. Estilo artístico: confirmado — **Low Poly 3D** (Blender → Meshy → Godot), Pixel Art descartado.
  3. Plataforma-alvo: confirmado — **Mobile-first** (Android/iOS), build secundária PC/Web via Godot.
  4. Escopo numérico do MVP: confirmado — 1 personagem jogável, 3 tipos de inimigo comum, 1 chefão, 5 ondas por run.
  5. Monetização: confirmado — Free-to-play com anúncios opcionais + IAP cosmético.
* **Ainda em aberto**: só o **nome definitivo do jogo** (item 1 do `ROADMAP.md`) segue pendente.
* **MVP jogável completo**: Menu → Jogar → 3 tipos de inimigo em 5 ondas → Chefão → Vitória/Derrota → Reiniciar ou voltar ao Menu. Loop fechado ponta a ponta no Godot.

---

## ▶️ Próxima tarefa (Claudão)

O bloqueio principal (decisões 🟡 do C-level) caiu. Antes de gerar novas tarefas de implementação pro Antigravity:
1. Atualizar `docs/GDD.md`, `docs/LDD.md` e `docs/epicas/EPICA-001-jogo-horde-survival.md` removendo as marcações 🟡 dos itens confirmados acima (premissas #3, #5, #6, #7, #8 da tabela da épica).
2. Com plataforma mobile-first confirmada, desbloquear a tarefa de "Ajustes de performance para o dispositivo-alvo" (Milestone 3 do `ROADMAP.md`) e definir a próxima micro-tarefa pro Antigravity.
3. Pipeline de arte 3D real (Meshy/Blender) continua bloqueado por falta de acesso — não mudou com essa rodada de decisões.

---

## 📝 Notas & Contexto Rápido
* Mantenha as alterações atômicas e consulte [`COLLAB_PROTOCOL.md`](./COLLAB_PROTOCOL.md) para diretrizes de economia de tokens.
* Usar `war_room/dashboard/index.html` pra acompanhar pendências, handover e chat de forma visual — ele lê/escreve direto nos `.md` deste repositório (File System Access API, Chrome/Edge).
