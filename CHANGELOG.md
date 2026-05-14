# Changelog — EasyWard

Todas as mudanças relevantes do projeto serão documentadas neste arquivo.

O formato segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e o projeto adere ao [Versionamento Semântico](https://semver.org/lang/pt-BR/).

---

## Tipos de Mudança

- **Adicionado** — novas funcionalidades
- **Alterado** — mudanças em funcionalidades existentes
- **Corrigido** — correções de bugs
- **Removido** — funcionalidades removidas
- **Segurança** — correções de vulnerabilidades
- **Depreciado** — funcionalidades que serão removidas em versões futuras

---

## [Não lançado]

### Adicionado
- Estrutura inicial do projeto (backend, frontend, documentação)
- Schema do banco de dados PostgreSQL completo
- Seeds: estados brasileiros, tipos de organização, tipos de hino, tipos de entrevista, chamados globais
- Documentação completa: arquitetura, API, backend, frontend, permissões, jobs, monitoramento, backup, deploy, segurança, notificações, ambiente de desenvolvimento, glossário, regras de negócio, modelo de relatórios, fluxos de tela, estrutura de pastas, design

---

## Como Versionar

Ao lançar uma nova versão, criar uma seção com o formato:

```markdown
## [1.0.0] — 2024-01-14

### Adicionado
- Módulo de membros: cadastro, edição e inativação
- Módulo de frequência: lançamento e consolidação por organização
- Autenticação JWT com refresh token

### Corrigido
- Cálculo incorreto de ausência prolongada na virada do ano

### Segurança
- Rate limiting aplicado às rotas de autenticação
```

### Regras de versionamento

| Mudança | Versão |
|---|---|
| Correção de bug sem impacto na API | Patch (0.0.X) |
| Nova funcionalidade retrocompatível | Minor (0.X.0) |
| Mudança que quebra compatibilidade | Major (X.0.0) |

---

*EasyWard — Changelog iniciado em 2024*
