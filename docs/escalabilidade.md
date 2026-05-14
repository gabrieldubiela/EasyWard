# EasyWard — Escalabilidade

## 1. Objetivo

Definir o roteiro de evolução da infraestrutura do EasyWard conforme o sistema cresce além do plano gratuito, com estimativas de custo e ordem de prioridade dos upgrades.

---

## 2. Situação Atual (Plano Gratuito)

| Serviço | Plano | Limitação principal |
|---|---|---|
| Render (backend) | Free | Hiberna após 15 min, 512 MB RAM, 0.1 CPU |
| Supabase (banco) | Free | Pausa após 7 dias, 500 MB, sem backup automático |
| Vercel (frontend) | Free | 100 GB banda/mês, 6.000 builds/mês |
| Resend (e-mail) | Free | 3.000 e-mails/mês |
| Firebase FCM (push) | Spark | Sem limite prático para push |
| UptimeRobot | Free | 50 monitores, ping a cada 5 min |

**Adequado para:** desenvolvimento, validação e uso por até ~5 alas com uso moderado.

---

## 3. Sinais de que é Hora de Escalar

Considerar upgrade quando:

- O UptimeRobot não conseguir mais evitar o cold start (uso intenso fora do horário comercial)
- O banco de dados ultrapassar **400 MB** (80% do limite do Supabase Free)
- O volume de e-mails se aproximar de **2.500/mês** (83% do limite do Resend Free)
- O tempo de resposta da API ultrapassar **2 segundos** consistentemente
- O número de alas ativas ultrapassar **20**
- Relatórios demorarem mais de **30 segundos** para gerar

---

## 4. Roteiro de Upgrades

### Fase 1 — Estabilidade (prioridade alta)

**Problema:** cold start do Render prejudica a experiência do usuário.

**Solução:** upgrade do Render para o plano **Starter** ($7/mês):
- Sem hibernação — backend sempre ativo
- 512 MB RAM, 0.5 CPU
- Elimina o cold start completamente
- O UptimeRobot pode ser desativado para o anti-cold start (manter para monitoramento)

**Quando fazer:** assim que o sistema entrar em uso real por pelo menos uma ala.

---

### Fase 2 — Banco de Dados (prioridade alta)

**Problema:** Supabase Free pausa por inatividade, sem backup automático, 500 MB.

**Solução:** upgrade do Supabase para o plano **Pro** ($25/mês):
- Sem pausa por inatividade
- 8 GB de armazenamento
- Backup diário automático (Point-in-Time Recovery de 7 dias)
- Elimina a necessidade do backup manual via GitHub Actions

**Quando fazer:** quando o banco ultrapassar 400 MB ou quando o sistema tiver dados de produção críticos que não podem ser perdidos.

> Com o Supabase Pro, o backup via GitHub Actions pode ser mantido como redundância ou desativado.

---

### Fase 3 — E-mail (prioridade média)

**Problema:** Resend Free limita a 3.000 e-mails/mês.

**Solução:** upgrade do Resend para o plano **Pro** ($20/mês):
- 50.000 e-mails/mês
- Logs e analytics de entrega

**Estimativa de volume:** considerando relatórios semanais, mensais e notificações, uma ala gera aproximadamente 50–100 e-mails/mês. O plano gratuito suporta até ~30 alas ativas com conforto.

**Quando fazer:** quando o volume se aproximar de 2.500 e-mails/mês.

---

### Fase 4 — Escalabilidade Horizontal (prioridade baixa)

**Problema:** uma única instância do backend não consegue atender ao volume crescente.

**Solução:** Render **Standard** ($25/mês por instância):
- 2 GB RAM, 1 CPU por instância
- Suporte a múltiplas instâncias com load balancing

**Alternativa:** migrar o backend para outro provedor (Railway, Fly.io, AWS ECS) se o Render não atender às necessidades.

**Quando fazer:** quando o backend consistentemente usar mais de 70% da CPU ou RAM.

---

### Fase 5 — CDN e Performance (prioridade baixa)

**Problema:** frontend lento para usuários em regiões distantes do servidor Vercel.

**Solução:** a Vercel já usa CDN global automaticamente. Para o backend, considerar:
- Render com região mais próxima dos usuários (São Paulo disponível)
- Cache de respostas para relatórios via Redis (Upstash Free: 10.000 req/dia)

**Quando fazer:** se identificar latência elevada em regiões específicas.

---

## 5. Estimativa de Custo por Fase

| Fase | Serviço | Custo Mensal | Custo Acumulado |
|---|---|---|---|
| Atual (gratuito) | — | R$ 0 | R$ 0 |
| Fase 1 | Render Starter | ~R$ 35 | ~R$ 35 |
| Fase 2 | Supabase Pro | ~R$ 125 | ~R$ 160 |
| Fase 3 | Resend Pro | ~R$ 100 | ~R$ 260 |
| Fase 4 | Render Standard | ~R$ 125 | ~R$ 385 |

> Valores convertidos com câmbio aproximado de R$ 5,00/USD. Sujeito a variação.

---

## 6. Escalabilidade do Banco de Dados

### Estimativa de crescimento de dados

| Tabela | Registros por ala/ano | Tamanho estimado |
|---|---|---|
| `frequencias` | ~5.000 (100 membros × 50 reuniões) | ~2 MB |
| `reunioes_sacramentais` | ~52 | < 1 MB |
| `membros` | ~100–300 | < 1 MB |
| `audit_logs` | ~10.000 | ~5 MB |
| `relatorios` | ~56 (52 semanais + 12 mensais + 4 trimestrais) | ~2 MB |

**Estimativa por ala/ano:** ~15 MB incluindo índices e overhead do PostgreSQL.

Com o Supabase Free (500 MB), o sistema suporta aproximadamente **30 alas por 1 ano** ou **10 alas por 3 anos** antes de precisar de upgrade.

### Estratégias de otimização antes do upgrade

1. **Purge de audit_logs antigos** — remover logs com mais de 1 ano
2. **Purge de notificações antigas** — remover notificações com mais de 60 dias
3. **Compressão de relatórios** — armazenar apenas o JSON essencial, não dados redundantes
4. **Arquivamento de reuniões antigas** — mover reuniões com mais de 2 anos para tabela de arquivo

---

## 7. Escalabilidade da API

### Endpoints potencialmente lentos

| Endpoint | Motivo | Otimização |
|---|---|---|
| `GET /reports/weekly` | Múltiplos JOINs e agregações | Cache do resultado em `relatorios` |
| `GET /reports/monthly` | Consolidação de 4–5 semanas | Cache do resultado em `relatorios` |
| `POST /attendance` (em lote) | Inserção de 100+ registros | Usar `INSERT ... VALUES` em lote |
| `GET /members` | Listagem com filtros complexos | Índices compostos + paginação |

### Cache com Redis (Fase 5)

Para relatórios que não mudam frequentemente, usar Upstash Redis (gratuito):

```python
# Cache de relatório por 1 hora
cache_key = f"report:weekly:{ward_id}:{week_date}"
cached = await redis.get(cache_key)
if cached:
    return json.loads(cached)

report = await generate_weekly_report(ward_id, week_date, db)
await redis.setex(cache_key, 3600, json.dumps(report))
return report
```

---

## 8. Expansão Funcional Futura

Funcionalidades não incluídas na v1.0 que podem ser adicionadas:

| Funcionalidade | Impacto técnico |
|---|---|
| Exportação de relatórios em PDF | Biblioteca `weasyprint` ou `reportlab` no backend |
| Modo offline completo (PWA) | Estratégia de sincronização no service worker |
| Múltiplos idiomas (i18n) | `react-i18next` no frontend |
| Gestão de ramos e distritos | Novos módulos na API e banco |
| Aplicativo nativo (iOS/Android) | React Native com a mesma API |
| Dashboard com gráficos históricos | Biblioteca de charts no frontend |
| Integração com sistema da Igreja | API oficial (se disponibilizada) |

---

## 9. Migração entre Provedores

Se precisar migrar de Render ou Supabase:

### Backend (Render → Railway, Fly.io, etc.)
- O backend é um container Python/FastAPI padrão
- Basta apontar as variáveis de ambiente para o novo provedor
- Tempo estimado de migração: **2–4 horas**

### Banco (Supabase → outro PostgreSQL)
- Usar o `pg_dump` gerado pelo backup automático
- Restaurar via `psql` no novo banco
- Atualizar `DATABASE_URL` no backend
- Tempo estimado de migração: **1–2 horas** (excluindo validação)

> O design de usar o Supabase apenas como PostgreSQL puro (sem SDK) garante portabilidade total — o banco pode ser migrado para qualquer provedor PostgreSQL sem alterar uma linha de código.

---

*EasyWard v0.1*
