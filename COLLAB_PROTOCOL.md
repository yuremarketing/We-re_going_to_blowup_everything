# 🤝 Protocolo de Colaboração: Antigravity (Gemini) & Claudão (Claude Code)

Este documento define as regras de revezamento e boas práticas para trabalho em dupla entre **Antigravity** e **Claude Code**, garantindo consistência no código e **máxima economia de cotas/tokens sem estourar rate limits**.

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
   - Leia [`HANDOVER.md`](./HANDOVER.md) e [`ROADMAP.md`](./ROADMAP.md) para entender a tarefa imediata.
2. **Durante o turno**:
   - Implemente **apenas a micro-tarefa designada**.
   - Rode testes/validações da etapa.
3. **Ao encerrar o turno**:
   - Faça commit das mudanças com mensagem semântica (ex: `feat(physics): implement collision raycast`).
   - Se a etapa estiver pronta para integração, integre na `main`.
   - Atualize [`HANDOVER.md`](./HANDOVER.md) marcando o próximo agente (`Turno Atual: Claudão` ou `Turno Atual: Antigravity`) e descrevendo a próxima tarefa.

---

## ⚡ 2. Diretrizes Anti-Rate-Limit e Economia de Tokens

Para evitar esgotar limites de requisições por minuto (RPM) ou tokens por minuto (TPM):

1. **Tarefas Atômicas e Focadas**:
   - Nunca tente resolver 5 coisas ao mesmo tempo. Execute **1 sub-tarefa por turno**.
2. **Leitura Cirúrgica de Arquivos**:
   - Não leia a árvore inteira do projeto. Consulte apenas os arquivos necessários para a tarefa atual.
3. **Commit & Handover Concisos**:
   - Registre o status no [`HANDOVER.md`](./HANDOVER.md) de forma direta e técnica, sem textos redundantes.
4. **Sem Polling / Loops Bloqueantes**:
   - Cada agente executa seu turno e aguarda o usuário ou gatilho para a próxima rodada, permitindo o cooldown natural das APIs.

---

## 📋 3. Arquivos de Controle

* [`ROADMAP.md`](./ROADMAP.md): Lista de marcos, arquitetura e backlog de tarefas.
* [`HANDOVER.md`](./HANDOVER.md): Bastão ativo com o status da rodada atual e o próximo passo exato.
