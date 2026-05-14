# EasyWard — Jobs e Automação

## 1. Objetivo

Definir o mecanismo de execução das rotinas automáticas periódicas do sistema.

---

## 2. Mecanismo de Disparo

Os jobs são executados pelo **GitHub Actions** via cron, que chama um endpoint autenticado da API:

```
POST /api/v1/jobs/{nome}/run
Authorization: Bearer <JOB_SECRET>
```

Esse modelo resolve o problema do cold start do Render Free: o Actions acorda o backend com a requisição antes de processar o job. O `JOB_SECRET` é um token fixo armazenado como secret no GitHub e como variável de ambiente no Render.

```yaml
# .github/workflows/jobs.yml
name: Jobs automáticos

on:
  schedule:
    - cron: '0 15 * * 0'       # Semanal: domingo 12:00 BRT (UTC-3)
    - cron: '1 3 1 * *'        # Mensal: dia 1 às 00:01 BRT (UTC-3)
    - cron: '1 3 1 1,4,7,10 *' # Trimestral: dia 1 de jan/abr/jul/out
    - cron: '1 3 1 1 *'        # Anual (virada de ano): dia 1 de janeiro 00:01 BRT
  workflow_dispatch:            # Permite disparo manual pelo GitHub

jobs:
  run-job:
    runs-on: ubuntu-latest
    steps:
      - name: Disparar job semanal
        if: github.event.schedule == '0 15 * * 0'
        run: |
          curl -X POST "${{ secrets.API_URL }}/api/v1/jobs/weekly/run" \
            -H "Authorization: Bearer ${{ secrets.JOB_SECRET }}"

      - name: Disparar job mensal
        if: github.event.schedule == '1 3 1 * *'
        run: |
          curl -X POST "${{ secrets.API_URL }}/api/v1/jobs/monthly/run" \
            -H "Authorization: Bearer ${{ secrets.JOB_SECRET }}"

      - name: Disparar job trimestral
        if: github.event.schedule == '1 3 1 1,4,7,10 *'
        run: |
          curl -X POST "${{ secrets.API_URL }}/api/v1/jobs/quarterly/run" \
            -H "Authorization: Bearer ${{ secrets.JOB_SECRET }}"

      - name: Disparar job anual (virada de ano)
        if: github.event.schedule == '1 3 1 1 *'
        run: |
          curl -X POST "${{ secrets.API_URL }}/api/v1/jobs/yearly/run" \
            -H "Authorization: Bearer ${{ secrets.JOB_SECRET }}"
```

---

## 3. Agendamento

| Job | Frequência | Horário (BRT) | Cron (UTC) |
|---|---|---|---|
| Semanal | Todo domingo | 12:00 | `0 15 * * 0` |
| Mensal | Dia 1 de cada mês | 00:01 | `1 3 1 * *` |
| Trimestral | Dia 1 de jan/abr/jul/out | 00:01 | `1 3 1 1,4,7,10 *` |
| **Anual** | **1º de janeiro** | **00:01** | **`1 3 1 1 *`** |

> O job anual é disparado pelo mesmo cron do job mensal de janeiro (`1 3 1 1 *`). O backend identifica que é virada de ano e executa ambos em sequência: primeiro o job anual (recálculo de organizações), depois o job mensal.

---

## 4. Princípios

- **Idempotência:** cada job verifica se já existe registro para o período antes de processar. Reexecutar não duplica dados.
- **Isolamento por ala:** cada job processa todas as alas do sistema de forma independente.
- **Registro de execução:** toda execução é registrada na tabela `job_execution_logs`.
- **Falha controlada:** em caso de erro, o job registra a falha, encerra de forma limpa e não deixa dados parciais.
- **Reutilização de lógica:** a mesma lógica é usada para execução automática e disparo manual.

---

## 5. Job Semanal

### Responsabilidades
- Identificar o grupo de limpeza responsável pela semana
- Gerar aviso de limpeza
- Listar tarefas abertas do bispado
- Listar entrevistas pendentes
- Consolidar frequência semanal por organização
- Identificar membros ausentes por 2 ou 3 semanas (configurável em `system_config`)
- Gerar relatório semanal
- Enviar notificações (push, e-mail e em tela)

### Fluxo
1. Para cada ala ativa:
   1. Verificar se relatório semanal já existe para a semana — se sim, pular
   2. Identificar grupo de limpeza da semana (rotação por ordem)
   3. Buscar tarefas abertas
   4. Buscar entrevistas pendentes
   5. Consolidar frequência da última reunião sacramental
   6. Calcular ausências prolongadas
   7. Persistir relatório semanal
   8. Enviar notificações aos usuários com `view_weekly_report`
2. Registrar execução em `job_execution_logs`

### Saídas
- Aviso de limpeza da semana
- Lista de tarefas do bispado
- Lista de entrevistas pendentes
- Relatório semanal de frequência
- Lista de membros para acompanhamento

---

## 6. Job Mensal

### Responsabilidades
- Identificar membros aptos a trocar de chamado
- Identificar membros com recomendação vencida ou próxima do vencimento
- Consolidar frequência mensal por organização
- Gerar relatório mensal
- Enviar notificações

### Fluxo
1. Para cada ala ativa:
   1. Verificar se relatório mensal já existe para o mês — se sim, pular
   2. Buscar membros ativos
   3. Verificar `apto_trocar_chamado` e `apto_recomendacao` (atualizar campos desnormalizados)
   4. Consolidar frequência do mês
   5. Agrupar por organização
   6. Persistir relatório mensal
   7. Enviar notificações
2. Registrar execução em `job_execution_logs`

### Saídas
- Lista de membros aptos a trocar de chamado
- Lista de recomendações vencidas ou próximas
- Relatório mensal de frequência

---

## 7. Job Trimestral

### Responsabilidades
- Consolidar frequência do trimestre por organização
- Gerar relatório trimestral

### Fluxo
1. Para cada ala ativa:
   1. Verificar se relatório trimestral já existe para o trimestre — se sim, pular
   2. Identificar o trimestre corrente
   3. Buscar reuniões sacramentais do trimestre
   4. Consolidar frequência acumulada
   5. Agrupar por organização
   6. Persistir relatório trimestral
   7. Enviar notificações
2. Registrar execução em `job_execution_logs`

### Saídas
- Relatório trimestral de frequência
- Consolidação por organização

---

## 8. Disparo Manual

Usuários com permissão `run_jobs` podem disparar qualquer job fora do horário programado via `POST /api/v1/jobs/{nome}/run`. O comportamento é idêntico ao automático — a idempotência garante que não haverá duplicação.

Toda execução manual é registrada com o `user_id` de quem a disparou.

---

## 9. Registro de Execução

Tabela `job_execution_logs`:

| Campo | Descrição |
|---|---|
| `id` | Identificador |
| `job_name` | Nome do job (`weekly`, `monthly`, `quarterly`) |
| `triggered_by` | `scheduler` ou `user:{id}` |
| `started_at` | Início |
| `finished_at` | Fim |
| `duration_ms` | Duração em milissegundos |
| `wards_processed` | Número de alas processadas |
| `status` | `success` ou `failure` |
| `error_message` | Mensagem de erro, se houver |

---

## 10. Tratamento de Falhas

- Erro em uma ala não interrompe o processamento das demais
- Falha é registrada no log com mensagem detalhada
- Notificação enviada ao usuário com permissão `view_jobs`
- Job pode ser reexecutado manualmente após correção

---

*EasyWard v0.1*

---

## 11. Job Anual (Virada de Ano)

### Quando executa
1º de janeiro às 00:01 BRT — mesmo cron do job mensal de janeiro. O backend identifica a virada de ano e executa o job anual **antes** do job mensal.

### Responsabilidades
- Recalcular a organização principal de todos os membros ativos de todas as alas
- Registrar no `audit_log` todos os membros que mudaram de organização

### Fluxo
1. Para cada ala ativa:
   1. Calcular o ano corrente
   2. Para cada membro ativo com `aniversario` preenchido e `sexo` definido:
      - Calcular `idade_no_ano = ano_corrente - EXTRACT(YEAR FROM aniversario)`
      - Determinar a organização correta pela tabela de regras (RN-035)
      - Se `organizacao_id` do membro divergir da organização calculada → atualizar
      - Registrar no `audit_log`: `action = 'member.organization_updated'`
   3. Membros sem `aniversario` ou com `sexo = NULL/outro` → ignorar (sem alteração)
2. Registrar execução em `job_execution_logs` com `job_name = 'yearly'`

### Saídas
- `organizacao_id` atualizado para todos os membros que mudaram de faixa etária
- Entradas no `audit_log` para rastreabilidade
- Notificação em tela para usuários com permissão `view_members`: "X membro(s) foram transferidos de organização na virada de ano"

### Exemplo
Em 1º de janeiro de 2026:
- João, nascido em 15/12/2013 → `idade_no_ano = 2026 - 2013 = 13` → permanece em Rapazes ✓
- Pedro, nascido em 03/06/2014 → `idade_no_ano = 2026 - 2014 = 12` → migra de Primária para Rapazes ✓
- Maria, nascida em 20/11/2007 → `idade_no_ano = 2026 - 2007 = 19` → migra de Moças para Sociedade de Socorro ✓
