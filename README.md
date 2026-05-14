# EasyWard — Sistema de Gestão do Bispado

Sistema web modular para apoio à gestão administrativa e operacional de alas da Igreja, com foco em cadastros, frequência, reuniões, tarefas do bispado, entrevistas, limpeza, orçamento, relatórios e automações periódicas.

---

## Documentação

### Visão geral
- [Arquitetura](docs/arquitetura.md)
- [Decisões Técnicas](docs/decisoes-tecnicas.md)
- [Glossário](docs/glossario.md)
- [Roadmap](docs/roadmap.md)

### Implementação
- [Backend](docs/backend.md)
- [API](docs/api.md)
- [Frontend](docs/frontend.md)
- [Estrutura de Pastas](docs/estrutura-pastas.md)
- [Design e Estilo](docs/design.md)

### Dados e regras
- [Banco de Dados](docs/banco-de-dados.md)
- [Regras de Negócio](docs/regras-de-negocio.md)
- [Permissões](docs/permissoes.md)
- [Modelo de Relatórios](docs/modelo-relatorios.md)
- [Fluxos de Tela](docs/fluxos-de-tela.md)
- [Seeds por Ala](docs/modelo-dados-seed.md)

### Automação e operação
- [Jobs e Automação](docs/jobs.md)
- [Notificações](docs/notificacoes.md)
- [Monitoramento](docs/monitoramento.md)
- [Backup](docs/backup.md)
- [Segurança](docs/seguranca.md)
- [Deploy](docs/deploy.md)
- [Escalabilidade](docs/escalabilidade.md)
- [Testes](docs/testes.md)

### Desenvolvimento
- [Ambiente de Desenvolvimento](docs/ambiente-dev.md)

### SQL
- [Schema completo](docs/schema.sql)
- [Seeds de hinos](docs/seeds-hinos.sql)
- [Seeds de organizações](docs/seeds-organizacoes.sql)
- [Seeds de chamados](docs/seeds-chamados.sql)

---

## Visão Geral

O EasyWard é organizado em camadas para garantir escalabilidade, segurança e manutenibilidade:

- **Frontend:** interface do usuário, navegação e consumo da API, entregue como PWA.
- **Backend:** regras de negócio, validações, autenticação, relatórios e automações.
- **Banco de dados:** persistência relacional com integridade referencial (PostgreSQL).
- **Jobs automáticos:** tarefas periódicas semanais, mensais e trimestrais via GitHub Actions.
- **Notificações:** push (FCM), e-mail (Resend) e em tela.

---

## Hierarquia Organizacional

```
Brasil
└── Estado (seed fixo — 27 UFs)
    └── Estaca (criada pelo usuário no onboarding)
        └── Ala (criada pelo usuário no onboarding)
            └── Bispado (organização interna da ala)
```

O sistema gerencia **múltiplas alas**. Cada ala é completamente isolada — membros de uma ala não visualizam dados de outra.

---

## Stack Tecnológica

| Camada | Tecnologia |
|---|---|
| Frontend | React + TypeScript + Vite (PWA) |
| Backend | Python 3.11+ + FastAPI |
| Banco de dados | PostgreSQL — Supabase Free |
| ORM | SQLAlchemy 2.x (async) + asyncpg |
| Migrações | Alembic |
| Validação | Pydantic v2 |
| Hospedagem frontend | Vercel Free |
| Hospedagem backend | Render Free |
| Autenticação | JWT (access token 30min + refresh token 7 dias em cookie httpOnly) |
| E-mail | Resend (plano gratuito — 3.000 e-mails/mês) |
| Notificações push | Firebase Cloud Messaging (FCM) — Spark gratuito |
| Roteamento (frontend) | React Router v6 |
| Estado global (frontend) | Zustand |
| Formulários (frontend) | React Hook Form + Zod |
| HTTP client (frontend) | Axios com interceptor de refresh token |
| Logs estruturados | structlog |
| Rastreamento de erros | Sentry Free |
| Monitoramento de disponibilidade | UptimeRobot Free |
| Backup | pg_dump via GitHub Actions → Google Drive (rclone) |

---

## Módulos

| Módulo | Descrição |
|---|---|
| Onboarding | Criação de ala e primeiro usuário; cadastro em ala existente |
| Membros e Famílias | Cadastro, inativação (soft delete), vínculos com chamados e grupos de limpeza |
| Visitantes | Registro de frequentadores externos |
| Reunião Sacramental | Ata completa: informações gerais, blocos, músicas, discursos, frequência |
| Reunião de Bispado | Data, participantes, assuntos e designações |
| Reunião de Conselho da Ala | Data, participantes, assuntos e designações |
| Frequência | Lançamento em lote e consolidação por organização |
| Tarefas do Bispado | Criação, acompanhamento e conclusão |
| Entrevistas | Agendamento e registro por tipo com status |
| Limpeza | Grupos e escala semanal por rotação |
| Orçamento | Controle trimestral com distribuição por organização |
| Relatórios | Semanal, mensal e trimestral com persistência no banco |
| Automações | Jobs periódicos via GitHub Actions (semanal, mensal, trimestral) |
| Notificações | Push (FCM), e-mail (Resend) e em tela com histórico |
| Usuários e Permissões | 42 permissões granulares por função, sem perfis fixos |
| Configurações da Ala | Dados básicos, organizações locais, chamados locais, hinos locais |

---

## Seeds Automáticos por Ala

Ao criar uma nova ala, o sistema insere automaticamente:

| Seed | Origem | Editável? |
|---|---|---|
| 27 estados brasileiros | Global (`schema.sql`) | Não |
| Tipos de organização, hino, entrevista | Global (`schema.sql`) | Não |
| Chamados globais (Bispo, Conselheiro etc.) | Global (`schema.sql`) | Não — apenas inativável |
| 341 hinos do hinário SUD | Global (`seeds-hinos.sql`) | Não — mas novos podem ser adicionados |
| 5 organizações principais + 8 auxiliares | Por ala (`seeds-organizacoes.sql`) | Não editáveis — novas podem ser adicionadas |
| 113 chamados padrão | Por ala (`seeds-chamados.sql`) | Não editáveis — novos podem ser adicionados |
| 4 grupos de orçamento padrão | Por ala (`seeds-organizacoes.sql`) | Peso ajustável — novos grupos podem ser criados |
| 7 organizações padrão | Por ala (`modelo-dados-seed.md`) | Não — mas novas podem ser adicionadas |
| 30 chamados locais padrão | Por ala (`modelo-dados-seed.md`) | Podem ser inativados |
| Config: ausência prolongada = 2 semanas | Por ala (`modelo-dados-seed.md`) | Configurável por ala |

Ver detalhes em [docs/modelo-dados-seed.md](docs/modelo-dados-seed.md).

---

## Permissões

O sistema usa **42 permissões granulares por função**, sem perfis fixos. Cada usuário recebe um conjunto individual de permissões. O primeiro usuário de cada ala recebe todas as permissões automaticamente no onboarding.

Ver lista completa em [docs/permissoes.md](docs/permissoes.md).

---

## Hospedagem e Serviços Gratuitos

| Serviço | Uso | Limite gratuito |
|---|---|---|
| [GitHub](https://github.com/) | Versionamento, CI/CD, jobs, backup | Ilimitado para repositórios públicos |
| [Vercel Free](https://vercel.com/) | Hospedagem do frontend | 100 GB banda/mês |
| [Render Free](https://render.com/) | Hospedagem do backend | 512 MB RAM, hiberna após 15 min |
| [Supabase Free](https://supabase.com/) | PostgreSQL gerenciado | 500 MB, pausa após 7 dias sem acesso |
| [UptimeRobot](https://uptimerobot.com/) | Ping anti-cold start + monitoramento | 50 monitores, ping a cada 5 min |
| [Firebase Spark](https://firebase.google.com/pricing) | Notificações push (FCM) | Sem limite prático para push |
| [Resend](https://resend.com/) | Envio de e-mails transacionais | 3.000 e-mails/mês |
| [Google Drive](https://drive.google.com/) | Armazenamento de backups via rclone | 15 GB gratuitos |
| [Sentry Free](https://sentry.io/) | Rastreamento de erros | 5.000 eventos/mês |

---

## Limitações da Infraestrutura Gratuita

| Serviço | Limitação | Mitigação |
|---|---|---|
| Render Free | Hiberna após ~15 min de inatividade | UptimeRobot pinga `/health` a cada 5 min |
| Supabase Free | Pausa após 7 dias sem acesso | UptimeRobot mantém o backend ativo |
| Supabase Free | Sem backup automático | pg_dump diário via GitHub Actions → Google Drive |
| Supabase Free | 500 MB de armazenamento | ~30 alas por 1 ano antes de precisar de upgrade |
| Resend Free | 3.000 e-mails/mês | Suficiente para até ~30 alas ativas |
| Sentry Free | 5.000 eventos/mês | Suficiente para uso inicial |

> Para o roteiro de upgrades pagos e estimativas de custo, ver [docs/escalabilidade.md](docs/escalabilidade.md).

---

## Segurança

- JWT com access token (30 min) e refresh token (7 dias em cookie httpOnly)
- Permissões verificadas por requisição no backend
- Dados filtrados automaticamente pela ala do usuário autenticado
- Rate limiting nas rotas de autenticação
- Logs de auditoria para operações críticas
- Backup diário no Google Drive

Ver detalhes em [docs/seguranca.md](docs/seguranca.md).

---

## Estrutura do Repositório

```
easyward/
├── .github/
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── workflows/
│       ├── backup.yml
│       └── jobs.yml
├── backend/
├── frontend/
├── docs/
│   ├── schema.sql
│   ├── seeds-hinos.sql
│   ├── seeds-organizacoes.sql
│   └── seeds-chamados.sql
│   └── *.md  (29 documentos)
├── CHANGELOG.md
└── README.md
```

Ver estrutura completa em [docs/estrutura-pastas.md](docs/estrutura-pastas.md).

---

## Início Rápido

1. Configurar ambiente local → [docs/ambiente-dev.md](docs/ambiente-dev.md)
2. Entender a ordem de desenvolvimento → [docs/roadmap.md](docs/roadmap.md)
3. Consultar regras de negócio → [docs/regras-de-negocio.md](docs/regras-de-negocio.md)
4. Entender o modelo de dados → [docs/banco-de-dados.md](docs/banco-de-dados.md)

---

*EasyWard v0.1*
