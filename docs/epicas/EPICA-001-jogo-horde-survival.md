# Épica 001 — Jogo de Ação/Sobrevivência contra Multidão (Horde/Lane Survival)

> Status: rascunho v1 — baseado na entrevista de pré-elicitação com Felipe Pessanha (fonte: `Transcrição da Entrevista de Pré-Elicitação de Requisitos — Felipe Pessanha`).
> Lacunas da entrevista foram preenchidas com premissas explícitas (marcadas com 🟡) para destravar o desenho da épica. Cada premissa deve ser confirmada ou substituída na próxima rodada de elicitação.

## 1. Contexto

O produto é um jogo de ação/sobrevivência em que o personagem avança por uma "esteira"/viela linear, enfrentando ondas crescentes de uma multidão hostil, com chefões periódicos. Proposta de experiência: **partidas curtas, simples de entender, difíceis de largar** (estilo horde/lane survival).

A visão inicial partiu do C-level; o know-how técnico e de produção veio do Felipe Pessanha (Blender, pipeline de arte 3D/2D, e uso de IA/MCPs no fluxo de trabalho).

## 2. Objetivo de negócio

Entregar um jogo rápido de produzir e rápido de jogar, com um pipeline de produção fortemente apoiado por IA (Claude + MCPs) para reduzir o tempo entre concept → asset → engine, mantendo coerência visual e narrativa em todas as partes do jogo.

## 3. Premissas assumidas (lacunas da entrevista)

| # | Lacuna | Premissa assumida | Justificativa | Risco se errado |
|---|---|---|---|---|
| 1 | Nome do jogo | **A definir** — usar codinome `HORDA` até definição de branding | Não mencionado na entrevista | Baixo (só nomenclatura) |
| 2 | Modo de jogo | Single-player, corrida por ondas (**endless/arcade** com meta-progressão leve entre runs) | Consistente com "jogo simples e rápido" citado pelo C-level | Médio — muda estrutura de níveis e economia |
| 3 | Motion design/VFX/Cutscenes (Rodada 3 truncada) | VFX de impacto "juicy" (hit flash, partículas, screen shake), transições de onda animadas, e cutscenes curtas geradas via IA (transformação de animação/vídeo em sprite sequence, citado na Rodada 5) | Único fio deixado pelo próprio Felipe na Rodada 5 | Médio — sem validação direta do Felipe |
| 4 | Tema da multidão | **Apocalipse zumbi** como tema do MVP | Único exemplo concreto citado ("pode ser zumbi, etc.") | Médio — afeta arte, lore, nome |
| 5 | Plataforma-alvo | **Mobile-first** (Android/iOS), com build secundária para PC/Web via Godot | Perfil "jogo simples e rápido" é típico de mobile arcade; Godot facilita multiplataforma | Alto — impacta performance target, controles, UI |
| 6 | Estilo artístico (conflito Low Poly vs Pixel Art) | **Low Poly 3D** como direção oficial (Blender → Meshy → Godot), Pixel Art descartado para não gerar inconsistência | Felipe usa stack 3D (Blender/Meshy) e citou Low Poly como preferência real; "Pixel Art" apareceu apenas como exemplo hipotético de coerência | Alto — decisão central de arte, precisa validação explícita |
| 7 | Monetização/distribuição | Free-to-play com anúncios opcionais + IAP cosmético | Padrão de mercado para o perfil de jogo descrito | Médio — não validado com C-level |
| 8 | Escopo de conteúdo do MVP | 1 personagem jogável, 3 tipos de inimigo comum, 1 chefão, 5 ondas por run | Necessário para estimar esforço; nenhum número foi dado | Alto — pode divergir muito da expectativa real |
| 9 | Existência de MCP do Godot | ✅ **Resolvido** — confirmado que existe (spike concluído em `ROADMAP.md`, Milestone 1). Múltiplos MCPs open-source disponíveis. | O próprio Felipe disse "não sei se tem... mas deve ter" | Baixo — risco eliminado |
| 10 | Áudio/trilha sonora | Fora do escopo desta épica (não coberto na entrevista) | Não perguntado | Baixo — vira épica separada |
| 11 | Papel da "persona agêntica" | Agente interno de **produção** (orquestra pipeline de arte/documentação via MCPs), não um NPC/assistente dentro do jogo | Alinhado com Rodadas 4 e 5 | Médio |

## 4. Escopo

### Dentro do escopo (MVP)
- Loop principal: personagem em viela linear, ataque automático ou direcionado, ondas de inimigos progressivas, 1 chefão de ciclo.
- Pipeline de arte: concept (Nano Banana) → modelo 3D (Meshy ou Blender manual) → textura (Photoshop/Blender) → export → Godot.
- Documentação viva gerada/assistida por IA: GDD e LDD.
- Lore mínima coerente com o tema (apocalipse zumbi) para dar contexto ao jogo.
- Automação via MCPs (Claude) para pelo menos uma etapa ponta-a-ponta do pipeline de sprite (ex.: Nano Banana → Photoshop → import no Godot), validando a hipótese de orquestração.

### Fora do escopo (nesta épica)
- Multiplayer/coop.
- Sistema de monetização implementado (só a hipótese registrada).
- Áudio/trilha sonora.
- Motion design 2D avançado / After Effects pipeline (mencionado mas não decidido — ver premissa 3).

## 5. Stack tecnológica

| Camada | Ferramenta | Observação |
|---|---|---|
| Modelagem 3D | Blender | Confirmado |
| Conversão IA 2D→3D | Meshy | Confirmado |
| Engine | Godot | Sugestão do Felipe para este projeto (ele prefere Unreal em geral) |
| Concept art / IA generativa | Nano Banana | Confirmado |
| Edição 2D | Photoshop, Illustrator, After Effects | Confirmado |
| Orquestração de IA | Claude + MCPs (Photoshop, Blender, Nano Banana, Godot*) | *MCP do Godot não confirmado — ver premissa 9 |

## 6. Pipeline de produção assistido por IA (visão-alvo)

1. Prompt → **Nano Banana** gera concept/referência visual.
2. Referência → **Meshy** (ou Blender manual/MCP Claude) gera modelo 3D.
3. Materiais/texturas trabalhados no Blender (prévia) ou pintados no Photoshop.
4. Sprites/animações direcionais geradas e separadas via **MCP do Photoshop**.
5. Import automatizado no **Godot** (via MCP, sujeito a spike técnico — premissa 9).
6. Lore, GDD e LDD gerados/mantidos com apoio de IA, garantindo coerência entre arte, narrativa e progressão.

## 7. Critérios de aceite da épica

- [ ] Nome, modo de jogo, tema e plataforma-alvo confirmados com o C-level.
- [ ] Estilo artístico (Low Poly 3D) validado com Felipe Pessanha.
- [ ] Spike técnico sobre existência/viabilidade de MCP para Godot concluído.
- [ ] GDD v1 e LDD v1 gerados e revisados por um humano.
- [ ] Protótipo jogável do loop principal (viela + onda + chefão) rodando no Godot.
- [ ] Pelo menos uma etapa do pipeline de arte automatizada ponta-a-ponta via MCPs, documentada como prova de conceito.

## 8. Perguntas em aberto para a próxima rodada de elicitação

1. Confirmar nome e tema definitivo do jogo.
2. Completar a resposta da Rodada 3 (motion design/VFX/cutscenes) diretamente com o Felipe.
3. Validar estilo artístico único (Low Poly 3D vs. outra direção).
4. Definir plataforma-alvo e requisitos de performance.
5. Definir escopo numérico do MVP (inimigos, armas, ondas, chefões).
6. Confirmar modelo de monetização.
7. Validar se existe/é viável um MCP para Godot; se não, definir plano B de automação.

## 9. Referências

- Transcrição da Entrevista de Pré-Elicitação de Requisitos — Felipe Pessanha (fonte primária desta épica).
