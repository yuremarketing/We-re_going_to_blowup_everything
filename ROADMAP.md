# 🗺️ Roadmap do Projeto: We-re_going_to_blowup_everything

> Alinhado com [`docs/epicas/EPICA-001-jogo-horde-survival.md`](./docs/epicas/EPICA-001-jogo-horde-survival.md). Premissas marcadas 🟡 na épica ainda não foram validadas com o C-level/Felipe Pessanha — revisar antes de fechar escopo definitivo.

## 🎯 Visão Geral
* **Objetivo do Projeto**: Jogo de ação/sobrevivência contra multidão em viela linear ("esteira"), estilo horde/lane survival — ondas progressivas de inimigos + chefões, partidas curtas e simples de jogar.
* **Tema (MVP, 🟡 a validar)**: Apocalipse zumbi.
* **Estilo artístico (🟡 a validar)**: Low Poly 3D (Blender → Meshy → Godot).
* **Plataforma-alvo (🟡 a validar)**: Mobile-first, com build secundária PC/Web.
* **Stack Principal**: Godot Engine (sugestão do Felipe Pessanha para este projeto). Pipeline de arte: Blender, Meshy, Nano Banana, Photoshop/Illustrator/After Effects.

---

## 📌 Milestones

### Milestone 1: Setup & Arquitetura Base
- [ ] Criar projeto Godot com estrutura de diretórios base (scenes/, scripts/, assets/, docs/)
- [ ] Configurar versionamento de assets (.gitignore para binários pesados/exports do Godot)
- [ ] Prototipar o loop principal: personagem em viela linear com movimento/ataque básico
- [ ] Spike técnico: validar se existe MCP para Godot (ver premissa 9 da épica); se não existir, definir plano B de automação do pipeline sprite→engine

### Milestone 2: Core Gameplay
- [ ] Sistema de spawn de ondas de inimigos (progressão de dificuldade)
- [ ] Sistema de combate básico (ataque automático/direcionado, dano, morte de inimigo)
- [ ] Chefão de ciclo (1 chefão no MVP)
- [ ] Pipeline de arte ponta-a-ponta (concept Nano Banana → 3D Meshy/Blender → import Godot) validado para pelo menos 1 asset

### Milestone 3: Conteúdo & Polimento do MVP
- [ ] Escopo de conteúdo do MVP: 1 personagem jogável, 3 tipos de inimigo comum, 1 chefão, 5 ondas por run (🟡 números a validar com C-level)
- [ ] GDD e LDD v1 (gerados/mantidos com apoio de IA)
- [ ] Lore mínima coerente com o tema
- [ ] Ajustes de performance para o dispositivo-alvo

---

## 📝 Backlog Detalhado
*(Atualizado pelos agentes conforme o avanço das tarefas)*

### Perguntas em aberto (herdadas da épica — bloqueiam decisões de escopo)
1. Nome e tema definitivo do jogo
2. Resposta completa da Rodada 3 da entrevista (motion design/VFX/cutscenes)
3. Validação do estilo artístico único (Low Poly 3D)
4. Plataforma-alvo e requisitos de performance
5. Escopo numérico definitivo do MVP
6. Modelo de monetização
7. Viabilidade de um MCP para Godot
