# EasyWard — Banco de Dados

## 1. Objetivo

Documentar o modelo relacional do EasyWard, suas entidades, relacionamentos, regras de integridade e decisões de design.

---

## 2. Banco e Hospedagem

- **Banco:** PostgreSQL
- **Hospedagem:** Supabase Free
- **Acesso:** exclusivamente pelo backend via variável de ambiente `DATABASE_URL`
- **SDK do Supabase:** não utilizado — PostgreSQL puro

---

## 3. Convenções do Modelo

- Toda tabela possui `id SERIAL PRIMARY KEY`
- Toda tabela possui `created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()` e `updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()`
- Soft delete via campo `ativo BOOLEAN` — registros inativados permanecem no banco
- Chaves estrangeiras com `ON DELETE CASCADE` para dependentes diretos e `ON DELETE SET NULL` para referências opcionais
- Índices em todas as chaves estrangeiras e campos de consulta frequente
- `origem VARCHAR(10)` com valores `'global'` (seed imutável) ou `'local'` (criado pela ala) nas tabelas que possuem seeds globais

---

## 4. Hierarquia Geográfica

### `estados`
Seed fixo com os 27 estados brasileiros.

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `nome` | VARCHAR(80) | Nome do estado |
| `sigla` | CHAR(2) | Sigla (ex: SP) |

### `estacas`
Criadas pelos usuários durante o onboarding.

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `estado_id` | INT | FK → estados |
| `nome` | VARCHAR(120) | Nome da estaca |

### `alas`
Criadas pelos usuários durante o onboarding.

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `estaca_id` | INT | FK → estacas |
| `nome` | VARCHAR(120) | Nome da ala |

---

## 5. Entidades de Cadastro

### `familias`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `ala_id` | INT | FK → alas |
| `nome_familia` | VARCHAR(120) | Nome da família |
| `ativo` | BOOLEAN | Soft delete |

### `grupos_limpeza`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `ala_id` | INT | FK → alas |
| `nome` | VARCHAR(80) | Nome do grupo |
| `ordem` | INT | Ordem de rotação |

### `tipos_organizacao`
Seed fixo: `principal`, `auxiliar`.

| Valor | Descrição |
|---|---|
| `principal` | Frequência + chamados. Todo membro pertence a exatamente uma. |
| `auxiliar` | Apenas chamados. Sem contagem de frequência. |

### `organizacoes`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `ala_id` | INT | FK → alas |
| `tipo_organizacao_id` | INT | FK → tipos_organizacao |
| `nome` | VARCHAR(120) | Nome da organização |
| `sexo_alvo` | VARCHAR(20) NULL | `'masculino'`, `'feminino'` ou NULL (ambos) |
| `idade_min` | SMALLINT NULL | Idade mínima para atribuição automática (por ano) |
| `idade_max` | SMALLINT NULL | Idade máxima para atribuição automática (por ano) |
| `origem` | VARCHAR(10) | `'global'` ou `'local'` |
| `ativo` | BOOLEAN | Ativo/inativo |

> **Organizações principais** (tipo `principal`): todo membro pertence a uma. A atribuição é automática por sexo e faixa etária calculada pelo ano de nascimento (não pela data exata). Pode ser sobrescrita manualmente.
> **Organizações auxiliares** (tipo `auxiliar`): existem apenas para fins de chamado. Não têm frequência nem restrição de faixa etária.

### `chamados`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `ala_id` | INT NULL | FK → alas (NULL = global) |
| `nome` | VARCHAR(120) | Nome do chamado |
| `tipo` | VARCHAR(20) | `'global'` ou `'local'` |
| `origem` | VARCHAR(10) | `'global'` ou `'local'` |
| `ativo` | BOOLEAN | Pode ser inativado dentro da ala |

### `membros`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `ala_id` | INT | FK → alas |
| `familia_id` | INT NULL | FK → familias |
| `organizacao_id` | INT NULL | FK → organizacoes (organização principal atual) |
| `grupo_limpeza_id` | INT NULL | FK → grupos_limpeza |
| `nome_completo` | VARCHAR(150) | Nome completo |
| `sexo` | sexo_tipo NULL | `'masculino'`, `'feminino'` ou `'outro'` |
| `cargo` | VARCHAR(120) NULL | Cargo sacerdotal ou outro |
| `aniversario` | DATE NULL | Data de aniversário |
| `chamado_id` | INT NULL | FK → chamados |
| `data_inicio_chamado` | DATE NULL | Início do chamado atual |
| `apto_trocar_chamado` | BOOLEAN | Atualizado pelo job mensal (editável manualmente) |
| `data_ultimo_discurso` | DATE NULL | Data do último discurso |
| `mes_recomendacao` | SMALLINT NULL | CHECK BETWEEN 1 AND 12 |
| `apto_recomendacao` | BOOLEAN | Atualizado pelo job mensal (editável manualmente) |
| `ativo` | BOOLEAN | Soft delete |

> `organizacao_id` é atribuído automaticamente pelo job anual (virada de ano) e pelo job mensal. Pode ser sobrescrito manualmente.
> `apto_trocar_chamado` e `apto_recomendacao` são campos desnormalizados mantidos pelo job mensal.

### `visitantes`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `ala_id` | INT | FK → alas |
| `nome_completo` | VARCHAR(150) | Nome completo |
| `sexo` | VARCHAR(20) NULL | |
| `cargo` | VARCHAR(120) NULL | |
| `organizacao_id` | INT NULL | FK → organizacoes |
| `frequente` | BOOLEAN | Visitante frequente |

---

## 6. Usuários e Autenticação

### `usuarios`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `membro_id` | INT NOT NULL | FK → membros (todo usuário é um membro) |
| `ala_id` | INT | FK → alas |
| `email` | VARCHAR(150) | Único |
| `senha` | VARCHAR(255) | Hash bcrypt |
| `ativo` | BOOLEAN | Ativo/inativo |

### `user_permissions`
| Campo | Tipo | Descrição |
|---|---|---|
| `user_id` | INT | FK → usuarios |
| `permission_code` | VARCHAR(60) | Código da permissão (ex: `manage_members`) |
| PK | (user_id, permission_code) | Chave composta |

### `refresh_tokens`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `user_id` | INT | FK → usuarios |
| `token_hash` | VARCHAR(255) | Hash do refresh token |
| `expires_at` | TIMESTAMPTZ | Data de expiração |
| `revoked` | BOOLEAN | Token invalidado |

---

## 7. Hinos

### `hinos`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `ala_id` | INT NULL | NULL = global (seed); INT = local da ala |
| `numero` | INT NULL | Número no hinário (apenas para globais) |
| `nome` | VARCHAR(150) | Nome do hino |
| `origem` | VARCHAR(10) | `'global'` ou `'local'` |

### `tipos_hino`
Seed fixo: `abertura`, `intermediario`, `sacramental`, `encerramento`.

### `tipos_cantor`
Seed fixo: `congregacao`, `organizacao_estrutural`, `texto_livre`.

---

## 8. Reunião Sacramental

### `reunioes_sacramentais`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `ala_id` | INT | FK → alas |
| `data` | DATE | Data da reunião |
| `preside_id` | INT NULL | FK → membros |
| `dirige_id` | INT NULL | FK → membros |
| `preludio_id` | INT NULL | FK → membros |
| `regente_id` | INT NULL | FK → membros |
| `pianista_id` | INT NULL | FK → membros |
| `tem_assuntos_estaca` | BOOLEAN | Substitui tabela `reuniao_assuntos_estaca` |

### `reuniao_boas_vindas`
| Campo | Tipo |
|---|---|
| `id` | SERIAL |
| `reuniao_id` | INT FK |
| `texto` | TEXT |

### `reuniao_reconhecimentos`
| Campo | Tipo |
|---|---|
| `id` | SERIAL |
| `reuniao_id` | INT FK |
| `nome` | VARCHAR(150) |
| `chamado` | VARCHAR(120) NULL |

### `reuniao_anuncios`
| Campo | Tipo |
|---|---|
| `id` | SERIAL |
| `reuniao_id` | INT FK |
| `descricao` | TEXT |
| `data_texto` | VARCHAR(50) NULL |

### `reuniao_assuntos_ala`
| Campo | Tipo |
|---|---|
| `id` | SERIAL |
| `reuniao_id` | INT FK |
| `tipo_assunto` | VARCHAR(50) CHECK IN ('batismo','ordenacao','liberacao','outro') |
| `prenome` | VARCHAR(80) NULL |
| `nome` | VARCHAR(150) NULL |
| `chamado` | VARCHAR(120) NULL |
| `organizacao` | VARCHAR(120) NULL |
| `oficio` | VARCHAR(120) NULL |

### `reuniao_musicas`
| Campo | Tipo |
|---|---|
| `id` | SERIAL |
| `reuniao_id` | INT FK |
| `tipo_hino_id` | INT FK |
| `hino_id` | INT NULL FK |
| `cantor_tipo_id` | INT FK |
| `cantor_texto` | VARCHAR(150) NULL |

### `reuniao_mensagens`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `reuniao_id` | INT FK | Reunião sacramental |
| `tipo_item` | ENUM | CHECK IN ('mensagem','testemunho','hino_intermediario') |
| `membro_id` | INT NULL FK | Orador membro cadastrado |
| `visitante_id` | INT NULL FK | Orador visitante cadastrado |
| `orador_externo` | VARCHAR(150) NULL | Nome quando não é membro nem visitante cadastrado |
| `tema` | VARCHAR(255) NULL | Tema ou título do discurso |
| `material_apoio` | TEXT NULL | Referências, escrituras e materiais de apoio |
| `tempo_minutos` | SMALLINT NULL | Tempo alocado em minutos (deve ser > 0) |
| `ordem` | INT NULL | Posição na programação (1º, 2º, último, etc.) |
| `hino_id` | INT NULL FK | Para hino intermediário vinculado ao discurso |
| `cantor_tipo_id` | INT NULL FK | Tipo do cantor do hino intermediário |
| `cantor_texto` | VARCHAR(150) NULL | Nome livre do cantor |
| `tem_hino_intermediario` | BOOLEAN | Se o discurso é seguido de hino intermediário |

**Constraints:**
- Para discursos (`tipo_item != 'hino_intermediario'`): ao menos um de `membro_id`, `visitante_id` ou `orador_externo` deve ser preenchido
- `tempo_minutos` deve ser positivo quando informado

---

## 9. Outras Reuniões

### `reunioes_bispado`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `ala_id` | INT | FK → alas |
| `data` | DATE | Data da reunião |
| `observacoes` | TEXT NULL | Observações gerais |

### `reunioes_conselho_ala`
Mesma estrutura de `reunioes_bispado`.

### `reuniao_participantes`
Tabela polimórfica para participantes das reuniões de bispado e conselho:

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `reuniao_tipo` | VARCHAR(20) | `'bispado'` ou `'conselho'` |
| `reuniao_id` | INT | ID da reunião |
| `membro_id` | INT | FK → membros |

### `reuniao_assuntos`
Assuntos de reunião de bispado e conselho:

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `reuniao_tipo` | VARCHAR(20) | `'bispado'` ou `'conselho'` |
| `reuniao_id` | INT | ID da reunião |
| `descricao` | TEXT | Assunto discutido |

### `reuniao_designacoes`
Designações atribuídas em reuniões:

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `reuniao_tipo` | VARCHAR(20) | `'bispado'` ou `'conselho'` |
| `reuniao_id` | INT | ID da reunião |
| `responsavel_id` | INT | FK → membros |
| `descricao` | TEXT | O que foi designado |
| `data_limite` | DATE NULL | Prazo |
| `concluida` | BOOLEAN | Concluída ou não |

---

## 10. Frequência

### `frequencias`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `ala_id` | INT | FK → alas |
| `reuniao_id` | INT | FK → reunioes_sacramentais |
| `membro_id` | INT NULL | FK → membros |
| `visitante_id` | INT NULL | FK → visitantes |
| `nome_externo` | VARCHAR(150) NULL | Para pessoa sem cadastro |
| `organizacao_id` | INT NULL | FK → organizacoes |
| `presente` | BOOLEAN | |

> Exatamente um de `membro_id`, `visitante_id` ou `nome_externo` deve ser preenchido por registro.

---

## 11. Entrevistas

### `tipos_entrevista`
Seed fixo: `sacerdocio_14`, `sacerdocio_16`, `jovem_12`, `batismo`, `jovem_18`, `renovacao`.

### `entrevistas`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `ala_id` | INT | FK → alas |
| `membro_id` | INT | FK → membros |
| `tipo_entrevista_id` | INT | FK → tipos_entrevista |
| `data` | DATE NULL | Data da entrevista |
| `status` | VARCHAR(20) | CHECK IN ('pendente','realizada','cancelada') |
| `entrevistador_id` | INT NULL | FK → membros (bispo ou líder) |
| `observacoes` | TEXT NULL | Observações gerais |

---

## 12. Tarefas do Bispado

### `tarefas_bispado`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `ala_id` | INT | FK → alas |
| `texto` | TEXT | Descrição da tarefa |
| `data_limite` | DATE | Prazo |
| `responsavel_id` | INT | FK → usuarios |
| `concluida` | BOOLEAN | |

---

## 13. Orçamento

### `grupos_orcamento`
Agrupam organizações principais para fins de distribuição orçamentária. Exemplo: grupo "Jovens" = Rapazes + Moças.

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `ala_id` | INT | FK → alas |
| `nome` | VARCHAR(120) | Nome do grupo (ex: "Jovens", "Quórum de Élderes") |
| `peso` | DECIMAL(10,2) | Peso para cálculo orçamentário |
| `ativo` | BOOLEAN | Ativo/inativo |
| `origem` | origem_tipo | `'global'` (seed) ou `'local'` (criado pela ala) |

### `grupos_orcamento_organizacoes`
Vínculo N:N entre grupos de orçamento e organizações principais.

| Campo | Tipo | Descrição |
|---|---|---|
| `grupo_id` | INT | FK → grupos_orcamento |
| `organizacao_id` | INT | FK → organizacoes |
| PK | (grupo_id, organizacao_id) | Chave composta |

**Grupos padrão por ala:**

| Grupo | Organizações incluídas |
|---|---|
| Quórum de Élderes | Quórum de Élderes |
| Sociedade de Socorro | Sociedade de Socorro |
| Jovens | Rapazes + Moças (frequências somadas) |
| Primária | Primária |

### `orcamentos_trimestrais`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `ala_id` | INT | FK → alas |
| `ano` | INT | Ano |
| `trimestre` | SMALLINT | CHECK BETWEEN 1 AND 4 |
| `valor_recebido` | DECIMAL(12,2) | Valor recebido no trimestre |
| `acumulado_ano` | DECIMAL(12,2) | Acumulado do ano até o trimestre |

### `orcamento_distribuicoes`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `orcamento_trimestral_id` | INT | FK → orcamentos_trimestrais |
| `grupo_orcamento_id` | INT | FK → grupos_orcamento |
| `frequencia` | DECIMAL(10,2) | Frequência média do grupo no trimestre |
| `fator_calculo` | DECIMAL(10,4) | peso (do grupo) × frequência |
| `percentual` | DECIMAL(6,2) | % do total |
| `valor_distribuido` | DECIMAL(12,2) | Valor distribuído ao grupo |

---

## 14. Relatórios

### `relatorios`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `ala_id` | INT | FK → alas |
| `tipo` | VARCHAR(20) | CHECK IN ('weekly','monthly','quarterly') |
| `periodo_ref` | DATE | Primeiro dia do período de referência |
| `conteudo` | JSONB | Relatório completo em JSON |
| `gerado_por` | VARCHAR(50) | `'scheduler'` ou `'user:{id}'` |
| `created_at` | TIMESTAMPTZ | (sem `updated_at` — relatórios são imutáveis) |

> Constraint `UNIQUE (ala_id, tipo, periodo_ref)` garante idempotência — gerar o mesmo relatório duas vezes não cria duplicatas.

---

## 15. Notificações

### `notifications`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `user_id` | INT | FK → usuarios |
| `ward_id` | INT | FK → alas |
| `type` | VARCHAR(60) | Tipo da notificação (ex: `weekly_report`) |
| `title` | VARCHAR(120) | Título exibido ao usuário |
| `body` | TEXT | Corpo da notificação |
| `read` | BOOLEAN | Lida ou não |
| `action_url` | VARCHAR(255) NULL | Rota do frontend para navegar ao clicar |
| `created_at` | TIMESTAMPTZ | Retidas por 60 dias |

### `fcm_tokens`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `user_id` | INT | FK → usuarios |
| `token` | VARCHAR(255) | Token FCM do dispositivo (único) |
| `device_info` | VARCHAR(120) NULL | Ex: "Android 14 / Chrome" |
| `created_at` | TIMESTAMPTZ | |
| `updated_at` | TIMESTAMPTZ | |

---

## 16. Monitoramento e Automação

### `audit_logs`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `user_id` | INT NULL | FK → usuarios |
| `ward_id` | INT NULL | FK → alas |
| `action` | VARCHAR(80) | Ex: `member.deactivated` |
| `entity` | VARCHAR(50) | Ex: `members` |
| `entity_id` | INT NULL | ID do registro afetado |
| `before` | JSONB NULL | Estado anterior |
| `after` | JSONB NULL | Estado posterior |
| `ip_address` | VARCHAR(45) NULL | IP da requisição |
| `created_at` | TIMESTAMPTZ | (sem `updated_at` — logs são imutáveis) |

### `job_execution_logs`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `job_name` | VARCHAR(30) | `weekly`, `monthly`, `quarterly` |
| `triggered_by` | VARCHAR(50) | `scheduler` ou `user:{id}` |
| `started_at` | TIMESTAMPTZ | |
| `finished_at` | TIMESTAMPTZ NULL | |
| `duration_ms` | INT NULL | |
| `wards_processed` | INT NULL | |
| `status` | VARCHAR(10) | `success` ou `failure` |
| `error_message` | TEXT NULL | |

### `system_config`
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | SERIAL | PK |
| `ala_id` | INT NULL | NULL = global; INT = específico da ala |
| `key` | VARCHAR(80) | Ex: `absence_threshold_weeks` |
| `value` | VARCHAR(255) | Ex: `2` |

---

## 15. Regras de Integridade

- Nenhuma entidade operacional pode existir sem vínculo com ala
- Chamados globais têm `ala_id` NULL — permitido pela constraint
- Frequência deve estar vinculada a uma reunião sacramental
- Tarefas devem ter responsável (usuário)
- Entrevistas devem estar vinculadas a membro e tipo
- Distribuições de orçamento dependem de orçamento trimestral e organização
- Em `frequencias`, exatamente um de `membro_id`, `visitante_id` ou `nome_externo` deve ser não-nulo
- `usuarios.membro_id` é obrigatório — todo usuário é um membro

---

## 16. Índices Recomendados

Além dos índices em chaves estrangeiras, criar índices em:

| Tabela | Campo(s) |
|---|---|
| `membros` | `(ala_id, nome_completo)`, `ativo` |
| `reunioes_sacramentais` | `(ala_id, data)` |
| `frequencias` | `(reuniao_id, presente)` |
| `tarefas_bispado` | `(ala_id, concluida, data_limite)` |
| `entrevistas` | `(ala_id, status)` |
| `audit_logs` | `(ward_id, created_at)` |
| `job_execution_logs` | `(job_name, started_at)` |
| `refresh_tokens` | `(user_id, revoked, expires_at)` |
| `relatorios` | `(ala_id, tipo, periodo_ref DESC)` |
| `notifications` | `(user_id, read, created_at DESC)` |
| `fcm_tokens` | `(user_id)` |

---

*EasyWard v0.1*
