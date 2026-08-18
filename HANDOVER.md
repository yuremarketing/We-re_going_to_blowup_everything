# 🔄 Bastão de Handover (Revezamento Ativo)

* **Última Atualização**: 2026-08-18
* **Turno Atual**: `Antigravity (Gemini)` 🟢
* **Próximo Turno**: `Claudão (Claude Code)` ⏳

---

## 📌 Status Atual
* **Último Agente a Atuar**: Claudão
* **Último Commit / Entrega**:
  1. Trouxe `docs/epicas/EPICA-001-jogo-horde-survival.md` (épica de fundação) e realinhou o `ROADMAP.md` com o escopo real do projeto.
  2. Criou o esqueleto do projeto Godot: `project.godot` (config mínima, main scene apontando pra `scenes/main.tscn`), `scenes/main.tscn` (root `Node3D` vazio), diretórios `scripts/` e `assets/`, e `.gitignore` atualizado com entradas do Godot (`.godot/`, `*.import`, `export_presets.cfg`).
  * Nota: este passo foi adiantado fora da ordem estrita do turno porque a sincronização com o `origin` estava bloqueada (permissão de push do Claudão pendente de ajuste). Se o Antigravity já tiver começado a mesma tarefa em paralelo, comparar e manter a versão mais completa, sem duplicar.

---

## 🎯 Próxima Tarefa para o Antigravity
1. Ler [`docs/epicas/EPICA-001-jogo-horde-survival.md`](./docs/epicas/EPICA-001-jogo-horde-survival.md) e o [`ROADMAP.md`](./ROADMAP.md).
2. Abrir o projeto Godot criado (`project.godot`) e validar que carrega sem erros.
3. Executar a próxima micro-tarefa do **Milestone 1**: prototipar o loop principal — personagem em `scenes/main.tscn` com movimento básico ao longo de uma viela linear (eixo único) e um ataque simples (placeholder, sem arte final).
4. Ao concluir, commitar na branch `agent/antigravity`, atualizar este `HANDOVER.md` passando o turno de volta para o Claudão e commitar.

---

## 📝 Notas & Contexto Rápido
* Mantenha as alterações atômicas e consulte [`COLLAB_PROTOCOL.md`](./COLLAB_PROTOCOL.md) para diretrizes de economia de tokens.
* As lacunas 1–7 listadas no final do `ROADMAP.md` bloqueiam decisões de escopo definitivo — não travar o desenvolvimento por causa delas, mas evitar hardcodar decisões que dependem dessas respostas (ex.: nome do jogo, tema, plataforma).
* Estilo artístico assumido (🟡 a validar): Low Poly 3D — por isso o root da cena principal é `Node3D`, não `Node2D`.
