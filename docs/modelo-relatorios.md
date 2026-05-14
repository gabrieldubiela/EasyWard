# EasyWard — Modelo de Relatórios

## 1. Objetivo

Definir o conteúdo, estrutura, cálculos e formato de cada relatório gerado pelo sistema.

---

## 2. Relatório Semanal

### Geração
- **Quando:** todo domingo pelo job semanal, após o encerramento da reunião sacramental
- **Disparo:** automático (GitHub Actions, 12:00 BRT) ou manual
- **Escopo:** uma semana (domingo a domingo)

### Seções

#### 2.1 Cabeçalho
| Campo | Descrição |
|---|---|
| Ala | Nome da ala |
| Período | Data da reunião (ex: 14/01/2024) |
| Data de geração | Data e hora da geração do relatório |

#### 2.2 Frequência da Reunião
| Campo | Cálculo |
|---|---|
| Total de membros ativos | COUNT(membros WHERE ativo = true) |
| Total presentes (membros) | COUNT(frequencias WHERE presente = true AND membro_id IS NOT NULL) |
| Total presentes (visitantes) | COUNT(frequencias WHERE presente = true AND visitante_id IS NOT NULL) |
| Total presentes (externos) | COUNT(frequencias WHERE presente = true AND nome_externo IS NOT NULL) |
| Total geral presente | Soma dos três anteriores |
| Percentual de frequência | (membros presentes / total de membros ativos) × 100 |

#### 2.3 Frequência por Organização Principal
Para cada **organização principal** da ala (Quórum de Élderes, Sociedade de Socorro, Rapazes, Moças, Primária):

| Campo | Cálculo |
|---|---|
| Organização | Nome da organização principal |
| Membros vinculados | COUNT(membros WHERE organizacao_id = org.id AND ativo = true) |
| Presentes | COUNT(frequencias WHERE organizacao_id = org.id AND presente = true AND reuniao_id = reunião_da_semana) |
| Percentual | (presentes / membros vinculados) × 100 |

> Membros sem organização atribuída (`organizacao_id = NULL`) são listados separadamente como "Sem organização".

#### 2.4 Membros com Ausência Prolongada
Lista de membros ausentes por 2 ou mais semanas consecutivas (configurável em `system_config.absence_threshold_weeks`).

| Campo | Descrição |
|---|---|
| Nome | Nome completo do membro |
| Organização | Organização do membro |
| Semanas ausente | Número de semanas consecutivas sem presença |
| Último comparecimento | Data da última frequência registrada |

> Cálculo: buscar membros ativos que não possuem registro `presente = true` nas últimas N reuniões sacramentais da ala.

#### 2.5 Aviso de Limpeza
| Campo | Descrição |
|---|---|
| Grupo responsável | Nome do grupo de limpeza da semana |
| Membros do grupo | Lista de membros do grupo |

> Cálculo: identificar qual grupo é o responsável pela semana com base na ordem de rotação e na data. Ver seção de regras de negócio em `docs/regras-de-negocio.md`.

#### 2.6 Tarefas do Bispado em Aberto
Lista de tarefas não concluídas, ordenadas por data limite:

| Campo | Descrição |
|---|---|
| Descrição | Texto da tarefa |
| Responsável | Nome do usuário responsável |
| Data limite | Prazo |
| Dias restantes | Diferença entre data limite e hoje |

#### 2.7 Entrevistas Pendentes
Lista de entrevistas com status `pendente`:

| Campo | Descrição |
|---|---|
| Membro | Nome do membro |
| Tipo de entrevista | Ex: renovação, batismo |
| Data agendada | Se houver |

#### 2.8 Programação da Reunião (resumo)
Resumo da ata da reunião sacramental para referência:

| Campo | Descrição |
|---|---|
| Quem presidiu | Nome do membro |
| Quem dirigiu | Nome do membro |
| Discursos | Lista: orador + tema + tempo alocado |
| Músicas | Abertura, sacramental, encerramento |
| Tempo total de discursos | Soma dos tempos alocados (quando informados) |

---

## 3. Relatório Mensal

### Geração
- **Quando:** dia 1 de cada mês às 00:01 BRT
- **Escopo:** mês anterior completo

### Seções

#### 3.1 Cabeçalho
| Campo | Descrição |
|---|---|
| Ala | Nome da ala |
| Período | Mês e ano de referência (ex: Janeiro/2024) |
| Data de geração | Data e hora |

#### 3.2 Resumo de Frequência do Mês
| Campo | Cálculo |
|---|---|
| Total de reuniões no mês | COUNT(reunioes_sacramentais no período) |
| Média de presentes por reunião | SUM(presentes) / total de reuniões |
| Média percentual de frequência | Média dos percentuais semanais |
| Melhor reunião | Reunião com maior presença |
| Pior reunião | Reunião com menor presença |

#### 3.3 Frequência Acumulada por Organização
Igual à seção semanal, mas consolidada para todo o mês:

| Campo | Cálculo |
|---|---|
| Organização | Nome |
| Total de presenças no mês | SUM das presenças em todas as reuniões |
| Frequência média | Média percentual das reuniões do mês |

#### 3.4 Membros Aptos a Trocar de Chamado
Lista de membros com `apto_trocar_chamado = true`:

| Campo | Descrição |
|---|---|
| Nome | Nome completo |
| Chamado atual | Nome do chamado |
| Data de início | Quando recebeu o chamado atual |
| Tempo no chamado | Em meses |

> Ver critério de aptidão em `docs/regras-de-negocio.md`.

#### 3.5 Recomendações do Templo
Lista de membros com recomendação vencida ou vencendo nos próximos 2 meses:

| Campo | Descrição |
|---|---|
| Nome | Nome completo |
| Mês de vencimento | Mês/ano em que vence |
| Status | `vencida` ou `vence em breve` |

---

## 4. Relatório Trimestral

### Geração
- **Quando:** dia 1 de janeiro, abril, julho e outubro às 00:01 BRT
- **Escopo:** trimestre anterior completo (ex: em 1/abr gera o relatório de jan–mar)

### Seções

#### 4.1 Cabeçalho
| Campo | Descrição |
|---|---|
| Ala | Nome da ala |
| Período | Ex: 1º Trimestre / 2024 (Jan–Mar) |
| Data de geração | Data e hora |

#### 4.2 Resumo de Frequência do Trimestre
| Campo | Cálculo |
|---|---|
| Total de reuniões | COUNT no período |
| Total de membros ativos (média) | Média do período |
| Média geral de presentes | Média por reunião |
| Percentual médio de frequência | Média dos percentuais semanais |
| Tendência | Comparação com trimestre anterior (↑ ↓ →) |

#### 4.3 Frequência por Organização (Trimestre)
| Campo | Cálculo |
|---|---|
| Organização | Nome |
| Presenças totais | SUM do trimestre |
| Frequência média | Percentual médio |
| Tendência vs. trimestre anterior | Variação percentual |

#### 4.4 Evolução Mensal no Trimestre
Tabela com os 3 meses do trimestre, mostrando a frequência de cada um:

| Mês | Reuniões | Média presentes | % Frequência |
|---|---|---|---|
| Janeiro | 4 | 87 | 68% |
| Fevereiro | 4 | 91 | 72% |
| Março | 5 | 85 | 67% |

---

## 5. Persistência dos Relatórios

Os relatórios gerados são armazenados no banco para consulta futura. Adicionar ao schema:

```sql
CREATE TABLE relatorios (
  id           SERIAL PRIMARY KEY,
  ala_id       INT          NOT NULL,
  tipo         VARCHAR(20)  NOT NULL CHECK (tipo IN ('weekly','monthly','quarterly')),
  periodo_ref  DATE         NOT NULL,  -- primeiro dia do período de referência
  conteudo     JSONB        NOT NULL,  -- relatório completo em JSON
  gerado_por   VARCHAR(50)  NOT NULL,  -- 'scheduler' ou 'user:{id}'
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_relatorios_ala FOREIGN KEY (ala_id) REFERENCES alas(id) ON DELETE CASCADE,
  CONSTRAINT uk_relatorios_ala_tipo_periodo UNIQUE (ala_id, tipo, periodo_ref)
);
CREATE INDEX idx_relatorios_ala_tipo ON relatorios(ala_id, tipo, periodo_ref DESC);
```

> A constraint `UNIQUE (ala_id, tipo, periodo_ref)` garante idempotência — tentar gerar o mesmo relatório duas vezes não cria duplicatas.

---

## 6. Endpoints de Consulta

| Método | Rota | Descrição |
|---|---|---|
| GET | `/api/v1/reports/weekly` | Relatório semanal mais recente (ou por data) |
| GET | `/api/v1/reports/monthly` | Relatório mensal mais recente (ou por mês/ano) |
| GET | `/api/v1/reports/quarterly` | Relatório trimestral mais recente (ou por trimestre/ano) |
| GET | `/api/v1/reports/weekly/history` | Histórico de relatórios semanais (paginado) |
| GET | `/api/v1/reports/monthly/history` | Histórico de relatórios mensais |
| GET | `/api/v1/reports/quarterly/history` | Histórico de relatórios trimestrais |

**Query params comuns:**
- `?date=2024-01-14` — relatório semanal de uma data específica
- `?month=1&year=2024` — relatório mensal
- `?quarter=1&year=2024` — relatório trimestral

---

*EasyWard v0.1*
