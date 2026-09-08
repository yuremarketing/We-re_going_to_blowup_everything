# 🗺️ Roadmap do Projeto: We-re_going_to_blowup_everything

> Alinhado com [`docs/epicas/EPICA-001-jogo-horde-survival.md`](./docs/epicas/EPICA-001-jogo-horde-survival.md). Premissas marcadas 🟡 na épica ainda não foram validadas com o C-level/Felipe Pessanha — revisar antes de fechar escopo definitivo.

## 🎯 Visão Geral
* **Objetivo do Projeto**: Jogo de ação/sobrevivência contra multidão em viela linear ("esteira"), estilo horde/lane survival — ondas progressivas de inimigos + chefões, partidas curtas e simples de jogar.
* **Tema (MVP)**: Apocalipse zumbi ✅ confirmado pelo C-level.
* **Estilo artístico (🟡 a validar)**: Low Poly 3D (Blender → Meshy → Godot).
* **Plataforma-alvo (🟡 a validar)**: Mobile-first, com build secundária PC/Web.
* **Stack Principal**: Godot Engine (sugestão do Felipe Pessanha para este projeto). Pipeline de arte: Blender, Meshy, Nano Banana, Photoshop/Illustrator/After Effects.

---

## 📌 Milestones

### Milestone 1: Setup & Arquitetura Base
- [x] Criar projeto Godot com estrutura de diretórios base (scenes/, scripts/, assets/, docs/)
- [x] Configurar versionamento de assets (.gitignore para binários pesados/exports do Godot)
- [x] Prototipar o loop principal: personagem em viela linear com movimento/ataque básico
- [x] Spike técnico: validar se existe MCP para Godot (ver premissa 9 da épica) — **confirmado, existe**: múltiplos projetos open-source (`Dokujaa/Godot-MCP`, `ee0pdt/Godot-MCP`, `DaRealDaHoodie/Claude-GoDot-MCP`), cobrindo cena/nós/GDScript/config via MCP. Avaliar e adotar um deles quando formos automatizar o pipeline sprite→engine.

### Milestone 2: Core Gameplay
- [x] Sistema de spawn de ondas de inimigos (progressão de dificuldade) — 5 ondas fixas
- [x] Sistema de combate básico (ataque automático/direcionado, dano, morte de inimigo)
- [x] Chefão de ciclo (1 chefão no MVP)
- [~] Pipeline de arte ponta-a-ponta (concept Nano Banana → 3D Meshy/Blender → import Godot) — **etapa de concept art 100% concluída** para todo o elenco (Sobrevivente, 3 inimigos comuns, chefão — ver `docs/GDD.md` seções 4-5), tema zumbi confirmado em todos. **Bloqueado na conversão 2D→3D**: Antigravity confirmou não ter acesso a Meshy nem a um MCP de Blender. Etapa de modelagem 3D depende de intervenção manual do Felipe Pessanha (ou de acesso futuro a essas ferramentas) — [issue #2](https://github.com/yuremarketing/We-re_going_to_blowup_everything/issues/2).

### Milestone 3: Conteúdo & Polimento do MVP
- [x] Escopo de conteúdo do MVP: 1 personagem jogável, 3 tipos de inimigo comum, 1 chefão, 5 ondas por run — confirmado pelo usuário em 2026-09-08, sem mudanças no que já estava implementado
- [x] GDD e LDD v1 (gerados/mantidos com apoio de IA) — ver [`docs/GDD.md`](./docs/GDD.md) e [`docs/LDD.md`](./docs/LDD.md)
- [x] Lore mínima coerente com o tema — ver [`docs/LORE.md`](./docs/LORE.md)
- [x] Ajustes de performance para o dispositivo-alvo — **concluído**: plataforma configurada para Mobile-first no `project.godot` (rendering method `mobile`, fallback `gl_compatibility`, viewport Portrait 720x1280 com `sensor_portrait`, stretch `canvas_items/expand`, VSync ativado, 2x MSAA e compressão de textura ETC2/ASTC). Camera3D em `scenes/main.tscn` ajustada para `keep_aspect = KEEP_WIDTH`. Testado e validado em modo headless com Godot 4.3 stable. Baseline de export Android criado.
- [x] HUD Móvel com Controles Táteis (TouchScreenButton) — **concluído**: implementados controles táteis One-Thumb Portrait no HUD de `scenes/main.tscn` (`TouchScreenButton` para avanço `ui_up`, recuo `ui_down` e ataque `ui_accept`), ativação de emulação de toque no `project.godot` e centralização de âncoras na tela de fim de jogo (`EndScreen`). Testado e validado em modo headless no Godot 4.3 stable.

### Milestone 4: Do MVP funcional ao "pronto" (rastreado via GitHub Issues em 2026-09-08)
- [ ] VFX de impacto e feedback "juicy" (hit flash, partículas, screen shake, transições de onda, cutscenes via IA) — [issue #3](https://github.com/yuremarketing/We-re_going_to_blowup_everything/issues/3)
- [ ] Áudio e trilha sonora — [issue #4](https://github.com/yuremarketing/We-re_going_to_blowup_everything/issues/4)
- [ ] Validar performance/UX em dispositivo mobile real (hoje só testado headless no PC) — [issue #5](https://github.com/yuremarketing/We-re_going_to_blowup_everything/issues/5)
- [ ] Gerar build Android funcional (baixar export templates, produzir/testar APK) — [issue #6](https://github.com/yuremarketing/We-re_going_to_blowup_everything/issues/6)
- [ ] Balancear parâmetros de gameplay via playtest (HP, velocidade, dano, progressão entre ondas) — [issue #7](https://github.com/yuremarketing/We-re_going_to_blowup_everything/issues/7)

---

## 📝 Backlog Detalhado
*(Atualizado pelos agentes conforme o avanço das tarefas)*

### Perguntas em aberto (herdadas da épica — bloqueiam decisões de escopo)
1. ~~Tema definitivo~~ — resolvido (apocalipse zumbi confirmado). Nome do jogo ainda em aberto — [issue #1](https://github.com/yuremarketing/We-re_going_to_blowup_everything/issues/1).
2. ~~Resposta completa da Rodada 3 da entrevista (motion design/VFX/cutscenes)~~ — respondido pelo usuário (2026-09-08): "VFX de impacto "juicy" (hit flash, partículas, screen shake), transições de onda animadas, e cutscenes curtas geradas via IA (transformação de animação/vídeo em sprite sequence, citado na Rodada 5)"
3. ~~Validação do estilo artístico único (Low Poly 3D)~~ — respondido pelo usuário (2026-09-08): "**Low Poly 3D** como direção oficial (Blender → Meshy → Godot), Pixel Art descartado para não gerar inconsistência"
4. ~~Plataforma-alvo e requisitos de performance~~ — respondido pelo usuário (2026-09-08): "**Mobile-first** (Android/iOS), com build secundária para PC/Web via Godot"
5. ~~Escopo numérico definitivo do MVP~~ — respondido pelo usuário (2026-09-08): "1 personagem jogável, 3 tipos de inimigo comum, 1 chefão, 5 ondas por run"
6. ~~Modelo de monetização~~ — respondido pelo usuário (2026-09-08): "Free-to-play com anúncios opcionais + IAP cosmético"
7. ~~Viabilidade de um MCP para Godot~~ — resolvido, ver Milestone 1
