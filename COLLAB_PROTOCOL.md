# 🤝 Protocolo de Colaboração: Claudão (Tech Lead) & Antigravity (Implementador)

Este documento define as regras de revezamento e hierarquia de trabalho entre a equipe:
* 👑 **Claudão (Claude Code)**: **Chefe / Tech Lead**. Define arquitetura, toma decisões técnicas de alto nível, planeja as micro-tarefas e valida a direção do projeto.
* ⚡ **Antigravity (Gemini)**: **Desenvolvedor / Especialista em Implementação**. Executa as tarefas delegadas com precisão cirúrgica, otimiza performance e reporta ao Claudão.

---

## 🌿 1. Estrutura de Branches no Git

* **`main`**: Código integrado e testado.
* **`agent/antigravity`**: Branch de trabalho ativa do Antigravity.
* **`agent/claude`**: Branch de trabalho ativa do Claudão (Claude Code).

### Fluxo de Passagem de Bastão (Handover) via Sala de Guerra
A sincronização agora é baseada no Git, usando a `SALA_DE_GUERRA.md`.

1. **Ao assumir o turno**:
   - Faça `git pull` para obter a versão mais recente do repositório.
   - Leia `SALA_DE_GUERRA.md` para entender o estado atual do debate ou tarefa.
2. **Durante o turno**:
   - Use o script `./.agent-loop/scripts/agent-loop/iniciar_turno.sh "<SeuNome>"` se for propor algo novo ou aceitar uma tarefa.
   - Implemente **apenas a micro-tarefa designada**.
3. **Ao encerrar o turno**:
   - Faça commit das mudanças.
   - Atualize `SALA_DE_GUERRA.md` com o que foi feito.
   - Feche o turno usando `./.agent-loop/scripts/agent-loop/fechar_turno.sh "<SeuNome>"`.
   - Se a tarefa tiver uma Issue no GitHub, não se esqueça de gerenciar/fechar a Issue.

---

## ⚡ 2. Diretrizes Anti-Rate-Limit e Economia de Tokens

Para evitar esgotar limites de requisições por minuto (RPM) ou tokens por minuto (TPM):

1. **Tarefas Atômicas e Focadas**: Execute **1 sub-tarefa por turno**.
2. **Leitura Cirúrgica de Arquivos**: Consulte apenas os arquivos necessários para a tarefa atual.
3. **Vigília Sem Gasto de Tokens (Zero-Token-Waste)**:
   - A verificação de novos turnos não consome tokens. O script `vigilia.sh` roda localmente ou em background como um bash puro e só acorda a IA quando há mudanças confirmadas.

---

## 📋 3. Arquivos de Controle (Agent Loop)

* `SALA_DE_GUERRA.md`: Bastão ativo com o status da rodada atual e debates.
* `HISTORICO.md`: Histórico de turnos passados.
* `ROADMAP.md`: Lista de marcos, arquitetura e backlog de tarefas.

---

## 🔍 4. Engenharia de Pares Simétrica (Ciclo LLM "A" ↔ LLM "B")

Vale pra **qualquer** issue/task, dos dois lados, sem exceção, substituindo o modelo antigo de "um só planeja/julga, o outro só implementa":

1. **Análise da Issue (LLM do Turno / "A")**: quem estiver com o turno da tarefa estuda os requisitos da issue.
2. **Elaboração do Plano ("A")**: cria o plano técnico detalhado e submete pra debate na `SALA_DE_GUERRA.md` — sem implementar antes disso.
3. **Julgamento & Análise Crítica ("B")**: a outra LLM analisa criticamente o plano, apontando problemas (com limite estrito de 3 rodadas de debate: Proposta → Réplica → Tréplica).
4. **Tréplica Técnica & Consenso ("A" ↔ "B")**: Segue até o consenso formal estar fechado. Se não houver consenso na terceira rodada, escala pro humano.
5. **Implementação ("A")**: a LLM que propôs e defendeu o plano vai para o código, implementa, roda os testes e comita.
6. **Inversão de Papéis para a Próxima Tarefa**: na issue seguinte, os papéis se invertem.
