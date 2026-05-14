# EasyWard — Regras de Negócio

## 1. Objetivo

Centralizar todas as regras de negócio do sistema em um único documento de referência para implementação no backend.

---

## 2. Membros

### RN-001 — Inativação de membro
- Membros não podem ser excluídos permanentemente
- Ao inativar (`ativo = false`), o membro deixa de aparecer em listas e relatórios
- O histórico de frequência, entrevistas e tarefas permanece no banco
- Um membro inativo pode ser reativado a qualquer momento

### RN-002 — Vínculo usuário-membro
- Todo usuário do sistema deve ser também um membro cadastrado na ala
- Ao criar o primeiro usuário (onboarding), o sistema cria o membro automaticamente
- Para os demais usuários, o membro deve existir antes de criar a conta
- A verificação de existência é feita por **nome completo** (case-insensitive)
- Se houver homônimos, o usuário deve entrar em contato com o administrador da ala

### RN-003 — Aptidão para troca de chamado
Um membro é marcado como `apto_trocar_chamado = true` quando:
- Está há **mais de 18 meses** no chamado atual (baseado em `data_inicio_chamado`)
- **OU** o campo foi marcado manualmente por um usuário autorizado

O job mensal atualiza esse campo automaticamente. O usuário pode sobrescrever manualmente a qualquer momento. A data de referência é o primeiro dia do mês em que o job é executado.

### RN-004 — Aptidão de recomendação do templo
Um membro é marcado como `apto_recomendacao = true` quando:
- O mês de vencimento (`mes_recomendacao`) é o **mês atual ou até 2 meses à frente**
- **OU** o campo foi marcado manualmente

O job mensal atualiza automaticamente. O mês é comparado considerando o ano corrente e a virada de ano (ex: em novembro, identifica vencimentos em nov, dez e jan).

### RN-005 — Ausência prolongada
- Um membro é considerado com ausência prolongada quando não aparece como `presente = true` nas últimas **N reuniões sacramentais** consecutivas da ala
- N é configurável por ala em `system_config` com a chave `absence_threshold_weeks` (padrão: `2`)
- Apenas membros **ativos** são considerados
- Membros sem nenhum registro de frequência também são incluídos

### RN-006 — Sexo e cargo
- Os campos `sexo` e `cargo` são opcionais no cadastro
- Valores aceitos para `sexo`: `masculino`, `feminino`, `outro`
- `cargo` é texto livre (ex: Diácono, Mestre, Padre, Élder, Sumo Sacerdote)

---

## 3. Visitantes

### RN-007 — Visitante frequente
- Um visitante é marcado como `frequente = true` manualmente por um usuário autorizado
- Não há cálculo automático para esse campo
- Visitantes frequentes aparecem em destaque na lista de presença

### RN-008 — Registro de frequência para externos
- A presença de uma pessoa sem cadastro pode ser registrada via `nome_externo` (texto livre)
- Exatamente um dos três campos deve ser preenchido por registro de frequência: `membro_id`, `visitante_id` ou `nome_externo`
- A constraint no banco garante essa regra

---

## 4. Onboarding e Alas

### RN-009 — Criação de nova ala
Ao criar uma nova ala, o sistema executa automaticamente na seguinte ordem:
1. Criar a estaca (se não existir)
2. Criar a ala
3. Inserir seeds globais para a ala: hinos, organizações e chamados padrão
4. Criar o membro com os dados informados pelo usuário
5. Criar o usuário vinculado ao membro
6. Conceder **todas as 42 permissões** ao primeiro usuário

### RN-010 — Seeds por ala
Ao criar uma ala, são inseridos automaticamente:
- Todos os hinos globais (`origem = 'global'`)
- Organizações principais (5): Quórum de Élderes, Sociedade de Socorro, Rapazes, Moças, Primária — ver `docs/seeds-organizacoes.sql`
- Organizações auxiliares (8): Missionários de Ala, Templo e História da Família, Escola Dominical, Bispado, Jovens Adultos Solteiros, Bem-estar e Autossuficiência, Instalações, Música
- Grupos de orçamento padrão (4): Quórum de Élderes, Sociedade de Socorro, Jovens (Rapazes + Moças), Primária
- Chamados globais: Bispo, Conselheiro, Secretário da Ala, Secretário Executivo, Secretário Adjunto (e outros da lista global)

### RN-011 — Isolamento de dados
- Nenhum usuário acessa dados de outra ala
- Todo filtro de consulta no backend aplica automaticamente `WHERE ala_id = current_user.ward_id`
- A lista pública de alas (para onboarding) expõe apenas: id, nome da ala, nome da estaca e nome do estado

---

## 5. Chamados e Organizações

### RN-012 — Chamados globais vs. locais
- Chamados com `origem = 'global'` são seeds — não podem ser editados nem removidos
- Chamados globais podem ser **inativados** dentro de uma ala específica (campo `ativo`)
- Chamados com `origem = 'local'` foram criados pela ala e podem ser editados ou removidos

### RN-013 — Organizações sempre visíveis
- Organizações com `origem = 'global'` são sempre visíveis — não podem ser inativadas
- Organizações com `origem = 'local'` podem ser editadas ou removidas

---

## 6. Limpeza

### RN-014 — Rotação de grupos de limpeza
- Os grupos se revezam em ordem crescente pelo campo `grupos_limpeza.ordem`
- A semana de referência é a **semana do domingo da reunião sacramental**
- O grupo responsável é determinado por: `(número_da_semana_do_ano MOD total_de_grupos)`
- Exemplo: semana 3 do ano, 4 grupos → grupo número `(3 MOD 4) = 3` (índice base 0)
- Se um grupo for removido, o sistema recalcula automaticamente a partir da semana seguinte

### RN-015 — Aviso de limpeza
- Gerado pelo job semanal sempre que há ao menos um grupo cadastrado
- Se não houver grupos cadastrados, a seção de limpeza é omitida do relatório semanal

---

## 7. Orçamento

### RN-016 — Distribuição orçamentária
A distribuição é feita por **grupos de orçamento**, não por organização diretamente. Ver também RN-039.

```
frequencia_grupo  = SUM(presenças das organizações do grupo no trimestre)
                    / SUM(membros ativos das organizações do grupo)
fator_calculo     = peso_do_grupo × frequencia_grupo
percentual        = fator_calculo / SUM(todos_os_fatores) × 100
valor_distribuido = valor_recebido × (percentual / 100)
```

Onde:
- `peso_do_grupo` = campo `grupos_orcamento.peso` (configurado pelo usuário por ala)
- `frequencia_grupo` = frequência média ponderada de todas as organizações do grupo no trimestre
- Para o grupo "Jovens": soma as presenças de Rapazes e Moças, divide pelo total de membros dos dois

### RN-017 — Acumulado do ano
- `orcamentos_trimestrais.acumulado_ano` = soma dos `valor_recebido` dos trimestres anteriores do mesmo ano + trimestre atual
- Calculado automaticamente ao criar ou atualizar um orçamento trimestral

### RN-018 — Unicidade do orçamento
- Só pode existir um orçamento por `(ala_id, ano, trimestre)`
- Tentativa de duplicar retorna erro `400`

---

## 8. Reunião Sacramental

### RN-019 — Estrutura da ata
A ata da reunião sacramental é composta por blocos independentes. Cada bloco pode ser criado, editado ou removido individualmente:
- Boas-vindas (1:1 com a reunião)
- Reconhecimentos (0:N)
- Anúncios (0:N)
- Assuntos da estaca (flag booleano na própria reunião)
- Assuntos da ala (0:N)
- Músicas (0:N, obrigatório: abertura, sacramental, encerramento)
- Mensagens/discursos (0:N) — ver RN-021

### RN-020 — Músicas obrigatórias
Toda reunião sacramental deve ter ao menos:
- 1 hino de abertura (`tipo_hino = 'abertura'`)
- 1 hino sacramental (`tipo_hino = 'sacramental'`)
- 1 hino de encerramento (`tipo_hino = 'encerramento'`)

Essa validação é feita no backend ao finalizar/fechar a ata.

### RN-021 — Discursos e mensagens
Cada discurso/mensagem deve ter:

| Campo | Obrigatório | Regra |
|---|---|---|
| Orador | ✅ Sim | Deve ser membro cadastrado, visitante cadastrado ou nome externo — ao menos um |
| Tema | ❌ Não | Pode ser preenchido antes ou após o discurso |
| Material de apoio | ❌ Não | Texto livre: escrituras, referências, links |
| Tempo (minutos) | ❌ Não | Inteiro positivo — tempo alocado para o discurso |
| Ordem | ❌ Não | Define sequência na programação; pode ser reordenado |
| Tipo | ✅ Sim | `mensagem`, `testemunho` ou `hino_intermediario` |

- A soma dos tempos dos discursos não é validada automaticamente (apenas informativa)
- A reordenação é feita via `PATCH /meetings/{id}/messages/reorder` enviando a nova sequência de IDs
- Discursos podem ser cadastrados antes da reunião (planejamento) e editados depois (registro real)

### RN-022 — Frequência vinculada à reunião
- Registros de frequência devem estar vinculados a uma reunião sacramental existente
- Não é possível registrar frequência sem selecionar uma reunião

---

## 9. Entrevistas

### RN-023 — Status da entrevista
- Toda entrevista começa com status `pendente`
- Pode ser marcada como `realizada` ou `cancelada`
- Uma entrevista `realizada` não pode ser reaberta (apenas registrada nova)

### RN-024 — Campos opcionais
- `data`, `entrevistador_id` e `observacoes` são opcionais no cadastro inicial
- Podem ser preenchidos posteriormente ao confirmar a realização

---

## 10. Tarefas do Bispado

### RN-025 — Responsável pela tarefa
- O responsável deve ser um **usuário ativo** da ala (tabela `usuarios`)
- Ao inativar um usuário, suas tarefas abertas permanecem atribuídas a ele
- O usuário que inativa deve reatribuir as tarefas manualmente

### RN-026 — Conclusão de tarefa
- Uma tarefa concluída não pode ser reaberta (deve criar uma nova se necessário)
- A data de conclusão é registrada automaticamente como `updated_at`

---

## 11. Permissões

### RN-027 — Proteção da permissão crítica
A permissão `manage_user_permissions` tem proteção especial:
1. O sistema verifica se há **outro usuário ativo** na ala com essa permissão
2. Se não houver → operação bloqueada com mensagem de erro explicando o motivo
3. Se houver → cria uma solicitação pendente de aprovação
4. O outro usuário recebe notificação push e em tela
5. Somente após aprovação ativa a permissão é revogada
6. Solicitações pendentes expiram após **48 horas** sem aprovação

### RN-028 — Primeiro usuário
- O primeiro usuário de uma ala recebe todas as 42 permissões automaticamente no onboarding
- Essa atribuição é feita pelo sistema, não por outro usuário

### RN-029 — Usuário sem permissões
- Um usuário sem nenhuma permissão consegue fazer login
- Vê apenas o dashboard vazio com mensagem informando que aguarda permissões
- Não acessa nenhum módulo até receber ao menos uma permissão

---

## 12. Jobs e Automações

### RN-030 — Idempotência
Antes de processar qualquer job, o sistema verifica:
- Para o job semanal: se já existe relatório com `tipo = 'weekly'` e `periodo_ref` igual ao domingo da semana atual
- Para o job mensal: se já existe relatório com `tipo = 'monthly'` e `periodo_ref` igual ao primeiro dia do mês atual
- Para o job trimestral: se já existe relatório com `tipo = 'quarterly'` e `periodo_ref` igual ao primeiro dia do trimestre atual
- Se o relatório já existe → job encerrado sem reprocessamento

### RN-031 — Isolamento de falhas
- Falha ao processar uma ala não interrompe o processamento das demais
- Cada ala é processada em bloco independente com seu próprio tratamento de erro

---

## 13. Notificações

### RN-032 — Notificações em tela
- Notificações em tela são retidas por **60 dias**
- O job mensal remove notificações com `created_at < NOW() - INTERVAL '60 days'`

### RN-033 — Tokens FCM
- Se o token FCM de um dispositivo for rejeitado pelo Firebase (token inválido), ele deve ser removido da tabela `fcm_tokens` automaticamente

---

*EasyWard v0.1*

---

## 14. Organizações e Atribuição de Membros

### RN-034 — Tipos de organização
- **Principal** (`tipo = 'principal'`): todo membro ativo pertence a exatamente uma. Frequência é contabilizada por ela.
- **Auxiliar** (`tipo = 'auxiliar'`): existe apenas para fins de chamado. Sem frequência e sem restrição de faixa etária.

### RN-035 — Cálculo de idade para atribuição de organização
A idade é calculada pelo **ano de nascimento**, não pela data exata:

```
idade_no_ano = ano_corrente - EXTRACT(YEAR FROM aniversario)
```

Exemplos:
- Menino nascido em 15/12/2014 → em 01/01/2026 tem "idade no ano" = 12 → passa para Rapazes em 1º de janeiro de 2026
- Menina nascida em 03/01/2008 → em 01/01/2026 tem "idade no ano" = 18 → passa para Sociedade de Socorro em 1º de janeiro de 2026

### RN-036 — Regras de atribuição automática por organização

| Organização | Sexo | Idade no ano (calculada pelo ano) |
|---|---|---|
| Quórum de Élderes | Masculino | ≥ 18 |
| Sociedade de Socorro | Feminino | ≥ 18 |
| Rapazes | Masculino | 12 a 17 |
| Moças | Feminino | 12 a 17 |
| Primária | Qualquer | 0 a 11 |

- Membros sem `aniversario` cadastrado ficam sem organização (`organizacao_id = NULL`) até que o dado seja preenchido
- Membros com `sexo = 'outro'` ou `sexo = NULL` não são atribuídos automaticamente — requerem atribuição manual
- A atribuição automática pode ser **sobrescrita manualmente** pelo usuário com permissão `manage_members`

### RN-037 — Recálculo anual de organizações
- Executado pelo **job de virada de ano** (1º de janeiro às 00:01 BRT)
- Para cada membro ativo da ala, recalcula a organização com base na nova `idade_no_ano`
- Membros que mudam de faixa etária têm `organizacao_id` atualizado automaticamente
- O recálculo é registrado no `audit_log` com `action = 'member.organization_updated'`

### RN-038 — Frequência por organização principal
- A frequência lançada por reunião é consolidada pela organização principal (`organizacao_id`) de cada membro
- Visitantes sem organização principal podem ter `organizacao_id` informado manualmente no lançamento de frequência
- Membros sem organização (`organizacao_id = NULL`) são contabilizados em um grupo "Sem organização" nos relatórios

---

## 15. Grupos de Orçamento

### RN-039 — Separação entre organização e grupo de orçamento
- **Organização principal**: entidade de frequência (onde o membro está)
- **Grupo de orçamento**: entidade de distribuição financeira (pode agrupar várias organizações)
- Um grupo pode conter uma ou mais organizações principais
- Uma organização pode pertencer a apenas um grupo de orçamento por ala

### RN-040 — Cálculo de distribuição com grupos
A distribuição orçamentária usa os **grupos de orçamento**, não as organizações diretamente:

```
frequencia_grupo = SUM(presenças das organizações do grupo) / SUM(membros das organizações do grupo)
fator_calculo    = peso_do_grupo × frequencia_grupo
percentual       = fator_calculo / SUM(todos os fatores) × 100
valor_distribuido = valor_recebido × (percentual / 100)
```

Para o grupo "Jovens" (Rapazes + Moças):
- Soma as presenças de Rapazes e Moças
- Divide pelo total de membros de Rapazes e Moças combinados
- Usa o peso do grupo "Jovens" (não o peso de cada org separada)

### RN-041 — Grupos de orçamento customizados
- Usuários com permissão `manage_budget` podem criar grupos de orçamento locais (`origem = 'local'`)
- Um grupo local pode incluir qualquer combinação de organizações principais da ala
- Grupos globais (seed) não podem ser editados ou removidos — apenas o peso pode ser ajustado
- Ao criar um grupo local, o usuário define quais organizações o compõem e o peso inicial

*EasyWard v0.1*
