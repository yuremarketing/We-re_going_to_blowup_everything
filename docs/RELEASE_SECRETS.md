# 🔐 Guia de Segurança e Secrets de Release

Este documento orienta o gerenciamento seguro da **Release Keystore** do projeto **We're Going to Blow Up Everything**, gerada no encerramento do **Milestone 5 (Release Candidate v1.0.0-rc1)**.

---

## ⚠️ AVISO CRÍTICO DE BACKUP (Ação Obrigatória do Usuário)

A chave de release oficial foi gerada localmente em:
- **Keystore**: `build/android/release.keystore`
- **Senha (gerada aleatoriamente)**: `build/android/release.keystore.pwd`
- **Alias**: `wgtbue_release`
- **Validade**: 10.000 dias (~27 anos)
- **Algoritmo**: RSA 2048 bits com certificado SHA384withRSA

> [!CAUTION]
> O diretório `build/` está no `.gitignore` por razões estritas de segurança para **nunca vazar chaves nem senhas para o repositório público**.  
> **Você deve copiar esses dois arquivos (`release.keystore` e `release.keystore.pwd`) para um local seguro fora desta máquina (ex: cofre de senhas como Bitwarden/1Password ou mídia externa criptografada)**. Se estes arquivos forem perdidos, será impossível atualizar o app na Google Play Store ou manter a mesma identidade de assinatura.

---

## 📦 Artefato Gerado Localmente

* **Arquivo**: `build/android/WereGoingToBlowUpEverything-release-v1.0.0-rc1.apk`
* **Assinatura**: V1 (JAR), V2 (Full APK), V3 (APK Scheme v3) válidas e confirmadas via `apksigner`.
* **Configuração no Godot**: `export_presets.cfg` aponta para a keystore local e senha.

---

## ☁️ Configuração de CI/CD para Releases Automáticos no GitHub Actions

Caso deseje ativar a publicação automática de releases via GitHub Actions ao criar tags `v*` (ex: `git tag v1.0.0-rc1 && git push origin v1.0.0-rc1`), configure os seguintes **Repository Secrets** no GitHub:

1. Acesse o repositório no GitHub: **Settings → Secrets and variables → Actions → New repository secret**.
2. Adicione os seguintes segredos:

| Nome do Secret | Descrição | Como Obter |
| :--- | :--- | :--- |
| `RELEASE_KEYSTORE_BASE64` | Conteúdo da keystore codificado em base64 | Execute no terminal: `base64 -w 0 build/android/release.keystore` e copie o output |
| `RELEASE_KEYSTORE_PASSWORD` | Senha da keystore e da chave | Conteúdo do arquivo `build/android/release.keystore.pwd` |
| `RELEASE_KEYSTORE_ALIAS` | Nome do alias da chave | `wgtbue_release` |

---

## 📋 Histórico de Versões
* `v1.0.0-rc1`: Release Candidate 1 do MVP com combate 1D, HUD de kills, banners animados, ícones adaptativos, áudio completo e renderer Compatibility GLES3. Validação funcional 100% concluída em emulador Android (AVD API 34). Validação térmica/FPS em aparelho limpo mapeada para backlog pós-lançamento.
