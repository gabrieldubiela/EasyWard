# EasyWard — Monitoramento

## 1. Objetivo

Garantir visibilidade sobre funcionamento, falhas e uso do sistema, com ferramentas gratuitas e adequadas ao ambiente de plano gratuito.

---

## 2. Stack de Monitoramento

| Necessidade | Ferramenta | Custo |
|---|---|---|
| Logs estruturados no backend | `structlog` ou `loguru` | Gratuito |
| Rastreamento de erros e alertas | Sentry Free | Gratuito |
| Disponibilidade + anti-cold start | UptimeRobot | Gratuito |
| Logs de auditoria | Tabela `audit_logs` no banco | Gratuito |
| Logs de jobs | Tabela `job_execution_logs` no banco | Gratuito |

---

## 3. UptimeRobot

Configurar um monitor HTTP no UptimeRobot apontando para:

```
GET https://easyward-api.onrender.com/api/v1/health
```

- Intervalo: **5 minutos**
- Efeitos: mantém o backend do Render acordado, mantém o Supabase ativo e alerta por e-mail em caso de indisponibilidade
- Alertas: e-mail para o responsável técnico

---

## 4. Sentry

Integrar o Sentry ao backend FastAPI para capturar exceções não tratadas:

```python
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration

sentry_sdk.init(
    dsn=os.getenv("SENTRY_DSN"),
    integrations=[FastApiIntegration()],
    traces_sample_rate=0.2,
    environment=os.getenv("APP_ENV", "production"),
)
```

- Plano gratuito: 5.000 eventos/mês — suficiente para o volume esperado
- Alertas por e-mail em caso de novo erro ou regressão
- Stack trace completo, contexto do usuário e da requisição

---

## 5. Logs Estruturados no Backend

Usar `structlog` para gerar logs em formato JSON, facilitando filtragem e análise:

```python
import structlog

log = structlog.get_logger()

log.info("attendance.registered",
    user_id=user.id,
    ward_id=user.ward_id,
    meeting_id=meeting_id,
    records=len(records)
)
```

### Separação por tipo

| Tipo | Destino | Conteúdo |
|---|---|---|
| Logs de aplicação | Console do Render (efêmero) + Sentry (erros) | Requisições, tempos de resposta, erros |
| Logs de auditoria | Tabela `audit_logs` no banco | Operações críticas por usuário |
| Logs de jobs | Tabela `job_execution_logs` no banco | Execuções automáticas e manuais |
| Relatórios gerados | Tabela `relatorios` no banco | Conteúdo completo em JSONB, persistido para consulta futura |
| Logs de erros críticos | Sentry | Exceções com stack trace |

> ⚠️ Logs no console do Render são efêmeros — somem ao reiniciar o serviço. Apenas logs de auditoria e jobs têm persistência garantida (banco de dados).

---

## 6. Eventos Registrados

### 6.1 Autenticação
- Login bem-sucedido
- Login falho (com IP e e-mail tentado)
- Logout
- Refresh de token
- Token inválido ou expirado

### 6.2 Autorização
- Tentativa de acesso a recurso sem permissão (403)
- Tentativa de acesso a dado de outra ala

### 6.3 Operações críticas (tabela `audit_logs`)
- Criação, edição e inativação de membro
- Alteração de permissões de usuário
- Criação e remoção de usuário
- Lançamento de frequência
- Geração de relatório
- Criação e conclusão de tarefa
- Registro de entrevista
- Alteração de orçamento
- Disparo manual de job

### 6.4 Jobs
- Início e fim de cada execução
- Número de alas processadas
- Status final e mensagem de erro (se houver)

### 6.5 Erros de sistema
- Falha de conexão com banco
- Exceção não tratada
- Tempo de resposta elevado
- Falha em job periódico

---

## 7. Estrutura dos Logs de Auditoria

Tabela `audit_logs`:

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | Identificador |
| `user_id` | INT | Usuário que executou a ação |
| `ward_id` | INT | Ala do contexto |
| `action` | VARCHAR | Código da ação (ex: `member.deactivated`) |
| `entity` | VARCHAR | Entidade afetada (ex: `members`) |
| `entity_id` | INT | ID do registro afetado |
| `before` | JSONB | Estado anterior (quando aplicável) |
| `after` | JSONB | Estado posterior (quando aplicável) |
| `ip_address` | VARCHAR | IP da requisição |
| `created_at` | TIMESTAMPTZ | Data e hora |

---

## 8. Níveis de Severidade

| Nível | Uso |
|---|---|
| `INFO` | Operações normais (login, lançamento de frequência) |
| `WARNING` | Situações que merecem atenção (falha de login repetida, token expirado) |
| `ERROR` | Falha em funcionalidade específica (erro ao gerar relatório) |
| `CRITICAL` | Falha grave (banco inacessível, job com falha total) |

---

## 9. Retenção de Logs

| Tipo | Retenção |
|---|---|
| Logs de auditoria (`audit_logs`) | 1 ano |
| Logs de jobs (`job_execution_logs`) | 6 meses |
| Logs de console (Render) | Efêmeros — sem retenção garantida |
| Eventos no Sentry | 30 dias (plano gratuito) |

---

## 10. Segurança dos Logs

Os logs não devem expor:
- Senhas ou hashes de senha
- Tokens JWT completos
- Dados sensíveis de entrevistas
- Informações pessoais além do necessário para auditoria

---

## 11. Alertas Operacionais

| Evento | Canal | Responsável |
|---|---|---|
| Backend indisponível | E-mail (UptimeRobot) | Responsável técnico |
| Novo erro não tratado | E-mail (Sentry) | Responsável técnico |
| Falha em job periódico | E-mail (Sentry) + notificação em tela | Responsável técnico |
| Múltiplas falhas de login | Log de auditoria | Revisão manual |

---

*EasyWard v0.1*
