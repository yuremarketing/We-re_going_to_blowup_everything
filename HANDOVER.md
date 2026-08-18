# 🔄 Bastão de Handover (Revezamento Ativo)

* **Última Atualização**: 2026-08-18
* **Turno Atual**: `Antigravity (Gemini)` 🟢
* **Próximo Turno**: `Claudão (Claude Code)` ⏳

---

## 📌 Status Atual
* **Último Agente a Atuar**: Claudão
* **Último Commit / Entrega**: Trouxe `docs/epicas/EPICA-001-jogo-horde-survival.md` (épica de fundação, baseada na entrevista de pré-elicitação com Felipe Pessanha) para o repositório e realinhou o `ROADMAP.md`, que estava genérico, com o escopo real do projeto: jogo horde/lane survival em Godot, arte Low Poly via Blender/Meshy/Nano Banana. Ainda **não houve código/estrutura de projeto Godot criada** — Milestone 1 segue pendente.

---

## 🎯 Próxima Tarefa para o Antigravity
1. Ler [`docs/epicas/EPICA-001-jogo-horde-survival.md`](./docs/epicas/EPICA-001-jogo-horde-survival.md) e o [`ROADMAP.md`](./ROADMAP.md) atualizado — preste atenção nos itens marcados 🟡 (premissas assumidas, ainda não validadas com o C-level).
2. Pull/merge da `main` (ou desta branch `agent/claude`) na sua branch `agent/antigravity`.
3. Executar a primeira micro-tarefa do **Milestone 1**: criar a estrutura base do projeto Godot (diretórios `scenes/`, `scripts/`, `assets/`) — sem ainda implementar gameplay, só o esqueleto do projeto.
4. Ao concluir, commitar na branch `agent/antigravity`, atualizar este `HANDOVER.md` passando o turno de volta para o Claudão e commitar.

---

## 📝 Notas & Contexto Rápido
* Mantenha as alterações atômicas e consulte [`COLLAB_PROTOCOL.md`](./COLLAB_PROTOCOL.md) para diretrizes de economia de tokens.
* As lacunas 1–7 listadas no final do `ROADMAP.md` bloqueiam decisões de escopo definitivo — não travar o desenvolvimento por causa delas, mas evitar hardcodar decisões que dependem dessas respostas (ex.: nome do jogo, tema, plataforma).
