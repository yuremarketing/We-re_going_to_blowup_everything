# 🔄 Bastão de Handover (Revezamento Ativo)

* **Tech Lead / Chefe**: `Claudão (Claude Code)` 👑
* **Implementador**: `Antigravity (Gemini)` ⚡
* **Turno Atual**: `Antigravity` ⚡
* **Próximo Turno**: `Claudão (revisão da micro-tarefa abaixo)`

---

## 📌 Status Atual
* **Último Agente a Atuar**: Claudão — formalizou as decisões do usuário no `docs/GDD.md`, `docs/epicas/EPICA-001-jogo-horde-survival.md` e `ROADMAP.md` (marcações 🟡 → ✅).
* **Decisões do usuário confirmadas em 2026-09-08** (via `war_room/dashboard/index.html`, registradas em `ROADMAP.md`, `war_room/CHAT.md` e agora também no GDD/épica):
  1. Motion design/VFX/cutscenes (Rodada 3): confirmado — VFX de impacto "juicy" (hit flash, partículas, screen shake), transições de onda animadas, cutscenes curtas via IA.
  2. Estilo artístico: confirmado — **Low Poly 3D** (Blender → Meshy → Godot), Pixel Art descartado.
  3. Plataforma-alvo: confirmado — **Mobile-first** (Android/iOS), build secundária PC/Web via Godot.
  4. Escopo numérico do MVP: confirmado — 1 personagem jogável, 3 tipos de inimigo comum, 1 chefão, 5 ondas por run (sem mudança no que já estava implementado).
  5. Monetização: confirmado — Free-to-play com anúncios opcionais + IAP cosmético.
* **Ainda em aberto**: só o **nome definitivo do jogo** e o **modo de jogo** (itens 1-2 da tabela de premissas da épica) seguem pendentes — não bloqueiam a tarefa abaixo.
* **MVP jogável completo**: Menu → Jogar → 3 tipos de inimigo em 5 ondas → Chefão → Vitória/Derrota → Reiniciar ou voltar ao Menu. Loop fechado ponta a ponta no Godot.

---

## ▶️ Próxima tarefa (Antigravity)

Com a plataforma confirmada (Mobile-first, Android/iOS), a tarefa "Ajustes de performance para o dispositivo-alvo" do Milestone 3 (`ROADMAP.md`) está desbloqueada:

1. Revisar `project.godot`: configurar o rendering method pra mobile (`Forward Mobile` em vez de `Forward+`), checar viewport/resolução-alvo pra celular.
2. Testar export para Android (mesmo que só localmente, sem assinar/publicar) e reportar aqui qualquer erro de configuração do template de export.
3. Não mexer em arte/pipeline 3D nesta tarefa — isso continua bloqueado por falta de acesso a Meshy/MCP de Blender, sem mudança nessa rodada.
4. Ao terminar: marcar o item no `ROADMAP.md`, registrar o resultado em `war_room/CHAT.md`, e devolver o turno pro Claudão aqui no `HANDOVER.md`.

---

## 📝 Notas & Contexto Rápido
* Mantenha as alterações atômicas e consulte [`COLLAB_PROTOCOL.md`](./COLLAB_PROTOCOL.md) para diretrizes de economia de tokens.
* Usar `war_room/dashboard/index.html` pra acompanhar pendências, handover e chat de forma visual — ele lê/escreve direto nos `.md` deste repositório (File System Access API, Chrome/Edge).
