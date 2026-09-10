# 🤝 Protocolo de Colaboração: Claudão (Tech Lead) & Antigravity (Implementador)

Este documento define as regras de revezamento e hierarquia de trabalho entre a equipe:
* 👑 **Claudão (Claude Code)**: **Chefe / Tech Lead**. Define arquitetura, toma decisões técnicas de alto nível, planeja as micro-tarefas e valida a direção do projeto.
* ⚡ **Antigravity (Gemini)**: **Desenvolvedor / Especialista em Implementação**. Executa as tarefas delegadas com precisão cirúrgica, otimiza performance e reporta ao Claudão.

---

## 🌿 1. Estrutura de Branches no Git

* **`main`**: Código integrado e testado.
* **`agent/antigravity`**: Branch de trabalho ativa do Antigravity.
* **`agent/claude`**: Branch de trabalho ativa do Claudão (Claude Code).

### Fluxo de Passagem de Bastão (Handover)
1. **Ao assumir o turno**:
   - Puxe/atualize a branch da sua vez com base na `main` ou na branch do outro agente:
     ```bash
     git checkout <sua_branch>
     git merge main # ou git merge <branch_do_outro_agente>
     ```
   - Leia [`war_room/HANDOVER.md`](./war_room/HANDOVER.md) e [`ROADMAP.md`](./ROADMAP.md) para entender a tarefa imediata.
2. **Durante o turno**:
   - Implemente **apenas a micro-tarefa designada**.
   - Rode testes/validações da etapa.
3. **Ao encerrar o turno**:
   - Faça commit das mudanças com mensagem semântica (ex: `feat(physics): implement collision raycast`).
   - Se a etapa estiver pronta para integração, integre na `main`.
   - Atualize [`war_room/HANDOVER.md`](./war_room/HANDOVER.md) marcando o próximo agente (`Turno Atual: Claudão` ou `Turno Atual: Antigravity`) e descrevendo a próxima tarefa.
   - **Se a tarefa concluída tiver uma GitHub Issue vinculada, feche ela agora** (`gh issue close <n> --comment "resumo do que foi entregue, commit(s), o que ficou de fora/backlog"`) — nunca deixar pra depois "porque já tá nos `.md`". Os `.md` do `war_room/` são o registro de processo entre os agentes; a Issue é o rastreamento oficial do projeto no GitHub, e as duas coisas precisam ficar sincronizadas a cada tarefa, não só ao fechar um milestone inteiro. Se a tarefa só avançou parcialmente a issue (ex: fechou só uma fase dela), comenta o progresso em vez de fechar.
   - Isso vale pra qualquer board/Kanban que o projeto vier a usar no futuro (GitHub Projects ou equivalente) — mover o card pro status certo é parte do "encerrar o turno", não uma tarefa separada de faxina.

---

## ⚡ 2. Diretrizes Anti-Rate-Limit e Economia de Tokens

Para evitar esgotar limites de requisições por minuto (RPM) ou tokens por minuto (TPM):

1. **Tarefas Atômicas e Focadas**:
   - Nunca tente resolver 5 coisas ao mesmo tempo. Execute **1 sub-tarefa por turno**.
2. **Leitura Cirúrgica de Arquivos**:
   - Não leia a árvore inteira do projeto. Consulte apenas os arquivos necessários para a tarefa atual.
3. **Commit & Handover Concisos**:
   - Registre o status no [`war_room/HANDOVER.md`](./war_room/HANDOVER.md) de forma direta e técnica, sem textos redundantes.
4. **Sem Polling / Loops Bloqueantes manuais**:
   - Fora do modo de Ponte Autônoma (seção 4), cada agente executa seu turno e aguarda o usuário ou gatilho para a próxima rodada, permitindo o cooldown natural das APIs.

---

## 📋 3. Arquivos de Controle

* [`ROADMAP.md`](./ROADMAP.md): Lista de marcos, arquitetura e backlog de tarefas.
* [`war_room/HANDOVER.md`](./war_room/HANDOVER.md): Bastão ativo com o status da rodada atual e o próximo passo exato.

---

## 🔁 4. Ponte Autônoma (Watcher + Limite de Turnos)

Decidido em `war_room/CHAT.md` (2026-09-08). Os dois agentes editam `war_room/CHAT.md` no mesmo disco compartilhado. Depois de uma rodada inicial que achou que o mecanismo seria assimétrico, confirmamos (mensagens [17:20]–[18:10] em `war_room/CHAT.md`) que **os dois lados têm CLI headless real**, então a ponte é **simétrica**:

* **Claudão**: `claude -p "<prompt>"`. Allowlist restrito em `.claude/settings.json` — edição só dentro de `war_room/`, `docs/`, `assets/concept_art/`, `scenes/`, `scripts/`, `*.md`; `git add`/`git commit` local liberado; `git push`/`merge`/`reset --hard`/`clean`/`rm` sempre negados (explicitamente, no `deny`).
* **Antigravity**: `agy -p "<prompt>"`. Allowlist restrito equivalente em `~/.gemini/antigravity-cli/settings.json`, usando `write_file(<pasta>/)` pras mesmas pastas. **Antigravity nunca roda shell em modo headless** — o motor dele (jetski) nega automaticamente qualquer comando que exigiria confirmação humana (não existe wildcard aberto tipo `command(git *)` no allowlist dele). Por isso ele não precisa (nem deve) tentar `git add`/`commit` sozinho.

**Como funciona na prática:**
1. `watch.sh` observa `war_room/CHAT.md`. Mensagem nova do **Antigravity** → auto-invoca `claude -p`. Mensagem nova do **Claudão** → auto-invoca `agy -p`. Mensagem do **Usuário** → invoca quem estiver marcado como "Turno Atual" no `HANDOVER.md`.
2. Depois de qualquer invocação, `watch.sh` dá um `git add -A && git commit` **local** (nunca push) — cobre principalmente o Antigravity, que não consegue commitar sozinho, mas roda pros dois por simplicidade/consistência.
3. Contador de turnos e kill switch ficam em `war_room/bridge/state/turn_count` e `war_room/bridge/state/STOP`, geridos pelo próprio `watch.sh` (os agentes não precisam mexer nesses arquivos).

**Regras de segurança (obrigatórias, não opcionais, valem pros dois lados):**

1. **Limite de 3 turnos autônomos consecutivos** (trocas de mensagem entre Claudão ↔ Antigravity sem uma mensagem do "Usuário" no meio). No 4º turno, o `watch.sh` **para de auto-invocar** e só notifica o usuário — precisa de um "continua" explícito pra retomar.
2. **`git push` e merge para `main` continuam manuais**, sempre — o commit local automático do `watch.sh` nunca publica nada, e nenhum dos dois agentes tem permissão de shell pra fazer isso sozinho de qualquer forma.
3. **Nenhuma ação destrutiva ou irreversível sem humano**: apagar arquivo, sobrescrever asset já aprovado, mudar configuração de export/build, ou qualquer coisa fora do escopo da micro-tarefa atual — pausa e pede confirmação, mesmo dentro do limite de 3 turnos. Tecnicamente reforçado pelos allowlists dos dois lados (deny explícito no Claudão, ausência de allowlist de shell no Antigravity).
4. O contador de turnos **zera** sempre que uma mensagem assinada "Usuário" aparecer no `CHAT.md`.
5. Se `war_room/bridge/state/STOP` existir, `watch.sh` não invoca ninguém automaticamente.
6. Toda troca autônoma continua sendo registrada em `war_room/CHAT.md`/`HANDOVER.md` normalmente — a ponte muda quem aciona o próximo turno, não o formato de comunicação nem a rastreabilidade.

Enquanto o watcher não estiver rodando, o fluxo padrão continua sendo o handover manual da seção 1.

**Incidente conhecido (2026-09-08) e correções aplicadas:** uma sessão manual do `agy` deixada aberta no terminal (fora do `watch.sh`, iniciada antes de uma rodada de mudanças) escreveu de volta no `war_room/CHAT.md` com uma cópia desatualizada em memória, sobrescrevendo ~260 linhas — e o auto-commit do `watch.sh` gravou essa sobrescrita sem perceber. Nada foi perdido (git tinha o histórico), mas duas correções entraram no `watch.sh`:
1. `resolve_next_agent()`: se `Turno Atual` no `HANDOVER.md` estiver em estado de pausa (`Usuário`), cai pro `Próximo Turno` em vez de só notificar e não fazer nada.
2. `looks_like_destructive_overwrite()`: antes de commitar, compara linhas adicionadas/removidas em `CHAT.md`/`HANDOVER.md` — se parecer sobrescrita (muito mais remoção que adição), **não commita**, cria `war_room/bridge/state/STOP` automaticamente e notifica o usuário.

**Lição prática:** não deixe uma sessão manual/interativa do `agy` ou do `claude` aberta em paralelo enquanto o `watch.sh` estiver rodando — as invocações do próprio watcher são processos novos por turno (sem esse risco), mas uma sessão manual esquecida pode segurar uma cópia velha do arquivo por muito tempo e sobrescrever o que a ponte fez nesse meio-tempo.

---

## 🔍 5. Engenharia de Pares Simétrica (Ciclo LLM "A" ↔ LLM "B")

Formalizado por diretriz direta do Usuário (`war_room/CHAT.md` [2026-09-09 22:38], confirmada e endossada explicitamente em [2026-09-09 23:0X] — foi o próprio Usuário quem pediu ao Antigravity pra trazer essa proposta). Vale pra **qualquer** issue/task, dos dois lados, sem exceção, substituindo o modelo antigo de "um só planeja/julga, o outro só implementa":

1. **Análise da Issue (LLM do Turno / "A")**: quem estiver com o turno da tarefa estuda os requisitos da issue, os arquivos afetados e as dependências.
2. **Elaboração do Plano ("A")**: cria o plano técnico detalhado e submete pra debate no `CHAT.md` — sem implementar antes disso.
3. **Julgamento & Análise Crítica ("B")**: a outra LLM analisa criticamente o plano, com a obrigação de apontar potenciais bugs, falhas lógicas, gargalos de performance, quebras de arquitetura ou melhorias.
4. **Tréplica Técnica & Consenso ("A" ↔ "B")**: "A" avalia os apontamentos — o que tiver coerência técnica, atende e incorpora ao plano; o que for equívoco ou tiver trade-off inferior, debate e rebate com fundamentos técnicos sólidos. Segue até o consenso formal estar fechado e registrado no `CHAT.md`.
5. **Implementação ("A")**: a LLM que propôs e defendeu o plano vai para o código, implementa, roda os testes obrigatórios (headless quando aplicável), comita e documenta.
6. **Inversão de Papéis para a Próxima Tarefa**: na issue seguinte, os papéis se invertem — quem revisou ("B") assume o turno como "A" (analisa, propõe o plano, defende e coda), e quem codou assume como "B" (julga, critica e revisa).

**Exceção ao rodízio (aprovada pelo Usuário, `war_room/CHAT.md` [2026-09-09 23:1X])**: o rodízio do passo 6 é o padrão, mas não é obrigatório se um dos dois lados tiver contexto acumulado relevante pra aquela tarefa específica (ex: quem já montou o Android SDK numa issue anterior). Nesse caso, quem pede a exceção justifica **durante o próprio debate** (passos 3-4), e ela só vale se o outro concordar explicitamente — a decisão de quem implementa vira parte do consenso registrado no `CHAT.md`, igual qualquer outro ponto de debate. Não existe fórmula/pontuação separada pra isso — de propósito, pra não burocratizar um time de dois.

Isso não revoga a hierarquia da seção introdutória: Claudão mantém autoridade de desempate em decisões de arquitetura quando o debate não converge, e a responsabilidade de manter `ROADMAP.md`/`war_room/HANDOVER.md` coerentes com o estado real do projeto. O que deixa de existir é a divisão fixa "um só planeja/revisa, o outro só implementa" — implementação agora é compartilhada conforme o consenso de cada task.
