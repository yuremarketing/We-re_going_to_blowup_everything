# 🗺️ Roadmap do Projeto: We-re_going_to_blowup_everything

> Alinhado com [`docs/epicas/EPICA-001-jogo-horde-survival.md`](./docs/epicas/EPICA-001-jogo-horde-survival.md). Premissas marcadas 🟡 na épica ainda não foram validadas com o C-level/Felipe Pessanha — revisar antes de fechar escopo definitivo.

## 🎯 Visão Geral
* **Objetivo do Projeto**: Jogo de ação/sobrevivência contra multidão em viela linear ("esteira"), estilo horde/lane survival — ondas progressivas de inimigos + chefões, partidas curtas e simples de jogar.
* **Tema (MVP)**: Apocalipse zumbi ✅ confirmado pelo C-level.
* **Estilo artístico**: Low Poly 3D (Blender → Meshy → Godot) ✅ confirmado pelo C-level.
* **Plataforma-alvo**: Mobile-first, com build secundária PC/Web ✅ confirmado pelo C-level.
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
- [x] VFX de impacto e feedback "juicy" (hit flash, partículas, screen shake) — [issue #3](https://github.com/yuremarketing/We-re_going_to_blowup_everything/issues/3): **concluído**: implementados hit flash óptico via duplicação de `StandardMaterial3D` e Tween nos inimigos e chefão, screen shake procedural na `Camera3D` do jogador (com decay e reset explícito de offset) e emissão de detritos 3D leves (`CPUParticles3D`) com persistência mesmo em pause na eliminação. Validado 100% headless no Godot 4.3 stable.
- [x] Gerar build Android funcional (baixar export templates, produzir/testar APK) — [issue #6](https://github.com/yuremarketing/We-re_going_to_blowup_everything/issues/6): **concluído**: export templates oficiais do Godot 4.3 instalados, Android SDK e Build-Tools 34.0.0 configurados com keystore de depuração, preset Android (`arm64-v8a`, portrait, package `com.gameengine.weregoingtoblowupeverything`) gerado e APK compilado e assinado com sucesso em `build/android/WereGoingToBlowUpEverything-debug.apk` (24MB, esquemas de assinatura v1/v2/v3 válidos).
- [ ] Validar performance/UX em dispositivo mobile real — [issue #5](https://github.com/yuremarketing/We-re_going_to_blowup_everything/issues/5): **otimizações aplicadas, validação de campo pendente**: diagnosticados e corrigidos gargalos de Vulkan Mobile (migrado para OpenGL ES 3.0 / `gl_compatibility`), desativado MSAA 3D e sombras dinâmicas da DirectionalLight3D, e aplicado cache estático de alocação de partículas de morte. APK debug recompilado. Usuário decidiu (2026-09-08 17:45) adiar o reteste no Redmi físico e seguir para as próximas issues; **nenhum FPS real foi medido ainda** — não afirmar "concluído" até o Usuário confirmar o teste em device.
- [x] Áudio e trilha sonora — [issue #4](https://github.com/yuremarketing/We-re_going_to_blowup_everything/issues/4): **concluído**: implementado gerador de SFX e BGM procedurais (`scripts/generate_audio_assets.py` com 8 assets `.wav` em `assets/audio/`), barramentos de áudio Master/Music/SFX (`default_bus_layout.tres`), singleton Autoload `AudioManager` (`scripts/audio_manager.gd`) com pool polifônico de 8 canais, jitter de pitch e controle de fade de música, e hooks de áudio integrados no jogador (ataque, acerto, dano recebido), inimigos/chefão (morte e aparição), e telas de vitória/derrota. Validado 100% headless no Godot 4.3 e empacotado no APK Android.
- [x] Balancear parâmetros de gameplay via playtest (HP, velocidade, dano, progressão entre ondas) — [issue #7](https://github.com/yuremarketing/We-re_going_to_blowup_everything/issues/7): **concluído**: implementados cooldown de ataque (0.22s) e quadros de invulnerabilidade (i-frames de 0.75s com piscar de opacidade) no sobrevivente, cooldown de dano de contato no chefão (1.0s) eliminando morte instantânea a 60Hz, despawn de segurança de inimigos passados da pista (`position.z > 25.0`), e progressão dinâmica de ondas no `wave_manager.gd` (ondas 1 a 5 escalando de 5 a 15 inimigos, redução gradual de intervalo de 1.8s a 0.9s e distribuição inteligente entre comuns, rápidos e tanques). Validado headless e testado no Android.

### Milestone 5: Release & Polimento Final
- [x] Contador de Abates (Kills) & Run State — **concluído**: implementado singleton Autoload `GameState` (`scripts/game_state.gd`) com rastreamento centralizado de kills, atualização reativa do HUD (`KillsLabel` no grupo `hud_kills`), contabilização no abate de inimigos/chefão (`spawn_death_particles`), exibição de resumo na tela de fim de jogo (`EndScreen/KillsSummaryLabel`), e reset explícito de estado a cada início de run (`Main._ready`, `_on_restart_pressed`, `_on_menu_pressed`).
- [x] Banner Animado de Onda & Alerta de Chefão — **concluído**: implementado banner animado no HUD de `scenes/main.tscn` (`WaveBanner` no grupo `wave_banner`), acionado diretamente a partir de `wave_manager.gd::_update_wave_label()` ("ONDA X/5") e do bloco canônico de spawn do chefão ("⚠️ ALERTA: O CHEFÃO CHEGOU!"), com animação fluida de Tween e destaque visual para o chefe.
- [x] Ícone Android & Boot Splash — **concluído**: gerador Pillow determinístico (`scripts/generate_app_icons.py`) gerando ícone adaptativo 432x432 (foreground com safe-zone 66dp e background gradiente), ícone legado 192x192 e boot splash, configurados em `project.godot` e `export_presets.cfg`.
- [x] Pipeline CI/CD para build/export automatizado do APK Android — [issue #9](https://github.com/yuremarketing/We-re_going_to_blowup_everything/issues/9): **concluído (Jobs 1+2)**: implementado workflow GitHub Actions (`.github/workflows/android-build.yml`) com Job 1 (gate obrigatório de testes headless com validação de hash sha512 oficial do Godot 4.3) e Job 2 (compilação do APK de debug, geração de debug keystore, exportação com templates 4.3 oficiais sob cache, verificação com `apksigner` e upload do artefato APK para download).
- [ ] Validação de Gameplay & Performance em Device Físico (Gate de Release).
- [ ] Keystore de Release & Exportação de APK Release Assinado (Job 3 da Issue #9).


---

## 📝 Backlog Detalhado
*(Atualizado pelos agentes conforme o avanço das tarefas)*

### Perguntas em aberto (herdadas da épica — bloqueiam decisões de escopo)
1. ~~Tema definitivo~~ — resolvido (apocalipse zumbi confirmado). ~~Nome do jogo~~ — resolvido pelo usuário (2026-09-08): **"We're Going to Blow Up Everything"** (mesmo nome do repositório) — [issue #1](https://github.com/yuremarketing/We-re_going_to_blowup_everything/issues/1) fechada.
2. ~~Resposta completa da Rodada 3 da entrevista (motion design/VFX/cutscenes)~~ — respondido pelo usuário (2026-09-08): "VFX de impacto "juicy" (hit flash, partículas, screen shake), transições de onda animadas, e cutscenes curtas geradas via IA (transformação de animação/vídeo em sprite sequence, citado na Rodada 5)"
3. ~~Validação do estilo artístico único (Low Poly 3D)~~ — respondido pelo usuário (2026-09-08): "**Low Poly 3D** como direção oficial (Blender → Meshy → Godot), Pixel Art descartado para não gerar inconsistência"
4. ~~Plataforma-alvo e requisitos de performance~~ — respondido pelo usuário (2026-09-08): "**Mobile-first** (Android/iOS), com build secundária para PC/Web via Godot"
5. ~~Escopo numérico definitivo do MVP~~ — respondido pelo usuário (2026-09-08): "1 personagem jogável, 3 tipos de inimigo comum, 1 chefão, 5 ondas por run"
6. ~~Modelo de monetização~~ — respondido pelo usuário (2026-09-08): "Free-to-play com anúncios opcionais + IAP cosmético"
7. ~~Viabilidade de um MCP para Godot~~ — resolvido, ver Milestone 1
