# EasyWard — API

## 1. Objetivo

Definir o contrato de comunicação entre frontend e backend: recursos expostos, operações, formatos de requisição e resposta, autenticação e autorização.

---

## 2. Convenções

### 2.1 Base de rota
```
/api/v1/
```

### 2.2 Métodos HTTP
- `GET` — consulta
- `POST` — criação
- `PUT` — atualização completa
- `PATCH` — atualização parcial
- `DELETE` — remoção

### 2.3 Formato de resposta padrão

**Sucesso:**
```json
{
  "success": true,
  "message": "Operação realizada com sucesso.",
  "data": { }
}
```

**Erro:**
```json
{
  "success": false,
  "message": "Erro de validação.",
  "errors": [
    { "field": "email", "message": "E-mail inválido." }
  ]
}
```

### 2.4 Códigos de status

| Código | Situação |
|---|---|
| `200` | Sucesso |
| `201` | Criado |
| `204` | Sem conteúdo (ex: delete) |
| `400` | Erro semântico |
| `401` | Não autenticado |
| `403` | Sem permissão |
| `404` | Não encontrado |
| `422` | Erro de validação (padrão FastAPI/Pydantic) |
| `429` | Rate limit excedido |
| `500` | Erro interno |

> O frontend deve tratar tanto `400` quanto `422` como erros de validação.

### 2.5 Paginação

Todos os endpoints de listagem aceitam:

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `page` | int | 1 | Página atual |
| `page_size` | int | 20 | Itens por página (máx. 100) |
| `order_by` | string | — | Campo de ordenação |
| `order_dir` | asc/desc | asc | Direção |
| `search` | string | — | Busca textual |

**Resposta paginada:**
```json
{
  "success": true,
  "data": {
    "items": [],
    "total": 150,
    "page": 1,
    "page_size": 20,
    "total_pages": 8
  }
}
```

---

## 3. Autenticação

### 3.1 Fluxo JWT

1. `POST /api/v1/auth/login` → retorna `access_token` (30 min) e `refresh_token` (7 dias, cookie httpOnly)
2. Frontend envia `Authorization: Bearer <access_token>` em cada requisição
3. Ao expirar, interceptor Axios chama `POST /api/v1/auth/refresh` automaticamente
4. `POST /api/v1/auth/logout` invalida o refresh token no servidor

### 3.2 Cabeçalho esperado
```http
Authorization: Bearer <access_token>
```

---

## 4. Domínios

### 4.1 Autenticação — `/api/v1/auth`

| Método | Rota | Descrição |
|---|---|---|
| POST | `/auth/login` | Autentica usuário |
| POST | `/auth/logout` | Encerra sessão |
| POST | `/auth/refresh` | Renova access token via refresh token (cookie) |
| POST | `/auth/register/new-ward` | Onboarding: cria estaca (se nova), ala, membro e primeiro usuário |
| POST | `/auth/register/existing-ward` | Onboarding: cria usuário em ala existente (verifica membro pelo nome) |

**Saída do login:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJ...",
    "user": {
      "id": 1,
      "name": "Nome Completo",
      "ward_id": 3,
      "permissions": ["register_attendance", "view_reports"]
    }
  }
}
```

---

### 4.2 Estados e Estacas — `/api/v1/geo`

| Método | Rota | Descrição |
|---|---|---|
| GET | `/geo/states` | Lista estados (seed fixo) |
| GET | `/geo/states/{id}/stakes` | Lista estacas de um estado |
| POST | `/geo/stakes` | Cria nova estaca (no onboarding) |
| GET | `/geo/stakes/{id}/wards` | Lista alas de uma estaca (público — para onboarding) |

---

### 4.3 Alas — `/api/v1/wards`

| Método | Rota | Descrição |
|---|---|---|
| GET | `/wards/me` | Retorna dados da ala do usuário autenticado |
| PUT | `/wards/me` | Atualiza dados da própria ala |

> Nenhum usuário acessa alas de outros — não há listagem global de alas para usuários autenticados.

---

### 4.4 Usuários — `/api/v1/users`

| Método | Rota | Descrição |
|---|---|---|
| GET | `/users` | Lista usuários da ala |
| GET | `/users/{id}` | Retorna usuário específico |
| PUT | `/users/{id}` | Atualiza usuário |
| PATCH | `/users/{id}/status` | Ativa ou inativa usuário |
| GET | `/users/{id}/permissions` | Lista permissões do usuário |
| PUT | `/users/{id}/permissions` | Atualiza permissões do usuário |
| POST | `/users/{id}/permissions/revoke-request` | Solicita aprovação para revogar permissão crítica |

---

### 4.5 Membros — `/api/v1/members`

| Método | Rota | Descrição |
|---|---|---|
| GET | `/members` | Lista membros |
| POST | `/members` | Cria membro |
| GET | `/members/{id}` | Retorna membro |
| PUT | `/members/{id}` | Atualiza membro |
| PATCH | `/members/{id}/status` | Ativa ou inativa membro (soft delete) |
| PATCH | `/members/{id}/organization` | Atribui organização principal manualmente |
| GET | `/members/by-organization` | Lista membros por organização principal |
| GET | `/members/by-calling` | Lista por chamado |
| GET | `/members/by-cleaning-group` | Lista por grupo de limpeza |
| GET | `/members/eligible-for-calling-change` | Aptos a trocar de chamado |
| GET | `/members/recommendations-expiring` | Recomendações vencidas ou próximas |
| GET | `/members/without-organization` | Membros sem organização principal atribuída |

**Filtros disponíveis em `GET /members`:**

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `organizacao_id` | int | Filtra por organização principal |
| `chamado_id` | int | Filtra por chamado |
| `grupo_limpeza_id` | int | Filtra por grupo de limpeza |
| `ativo` | bool | Filtra ativos/inativos (padrão: `true`) |
| `sexo` | string | Filtra por sexo (`masculino`, `feminino`, `outro`) |
| `search` | string | Busca por nome |

---

### 4.6 Famílias — `/api/v1/families`

| Método | Rota | Descrição |
|---|---|---|
| GET | `/families` | Lista famílias |
| POST | `/families` | Cria família |
| GET | `/families/{id}` | Retorna família |
| PUT | `/families/{id}` | Atualiza família |
| DELETE | `/families/{id}` | Remove família |

---

### 4.7 Visitantes — `/api/v1/visitors`

| Método | Rota | Descrição |
|---|---|---|
| GET | `/visitors` | Lista visitantes |
| POST | `/visitors` | Cria visitante |
| GET | `/visitors/{id}` | Retorna visitante |
| PUT | `/visitors/{id}` | Atualiza visitante |
| DELETE | `/visitors/{id}` | Remove visitante |
| GET | `/visitors/frequent` | Lista visitantes frequentes |

---

### 4.8 Organizações — `/api/v1/organizations`

| Método | Rota | Descrição |
|---|---|---|
| GET | `/organizations` | Lista organizações (globais + locais da ala) |
| GET | `/organizations/principal` | Lista apenas organizações principais (para frequência e atribuição de membros) |
| GET | `/organizations/auxiliary` | Lista apenas organizações auxiliares (para chamados) |
| POST | `/organizations` | Cria organização local auxiliar |
| GET | `/organizations/{id}` | Retorna organização |
| PUT | `/organizations/{id}` | Atualiza organização local |

**Filtros disponíveis em `GET /organizations`:**

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `tipo` | string | `principal` ou `auxiliar` |
| `origem` | string | `global` ou `local` |
| `ativo` | bool | Filtra ativos/inativos (padrão: `true`) |

> Organizações globais (seed) não podem ser editadas ou removidas. Apenas organizações auxiliares locais podem ser criadas via API.

---

### 4.9 Chamados — `/api/v1/callings`

| Método | Rota | Descrição |
|---|---|---|
| GET | `/callings` | Lista chamados (globais + locais da ala) |
| POST | `/callings` | Cria chamado local |
| GET | `/callings/{id}` | Retorna chamado |
| PUT | `/callings/{id}` | Atualiza chamado local |
| PATCH | `/callings/{id}/status` | Ativa ou inativa chamado |

> Chamados globais (seed) não podem ser editados, apenas inativados dentro da ala.

---

### 4.10 Grupos de Limpeza — `/api/v1/cleaning-groups`

| Método | Rota | Descrição |
|---|---|---|
| GET | `/cleaning-groups` | Lista grupos |
| POST | `/cleaning-groups` | Cria grupo |
| GET | `/cleaning-groups/{id}` | Retorna grupo |
| PUT | `/cleaning-groups/{id}` | Atualiza grupo |
| DELETE | `/cleaning-groups/{id}` | Remove grupo |
| GET | `/cleaning-groups/schedule` | Retorna aviso de limpeza da semana |

---

### 4.11 Reunião Sacramental — `/api/v1/meetings`

| Método | Rota | Descrição |
|---|---|---|
| GET | `/meetings` | Lista reuniões sacramentais |
| POST | `/meetings` | Cria reunião |
| GET | `/meetings/{id}` | Retorna reunião completa |
| PUT | `/meetings/{id}` | Atualiza reunião |
| DELETE | `/meetings/{id}` | Remove reunião |
| POST | `/meetings/{id}/welcome` | Registra/atualiza boas-vindas |
| POST | `/meetings/{id}/recognitions` | Adiciona reconhecimento |
| DELETE | `/meetings/{id}/recognitions/{rid}` | Remove reconhecimento |
| POST | `/meetings/{id}/announcements` | Adiciona anúncio |
| DELETE | `/meetings/{id}/announcements/{aid}` | Remove anúncio |
| PUT | `/meetings/{id}/stake-topics` | Atualiza assuntos da estaca |
| POST | `/meetings/{id}/ward-topics` | Adiciona assunto da ala |
| DELETE | `/meetings/{id}/ward-topics/{wid}` | Remove assunto da ala |
| POST | `/meetings/{id}/songs` | Adiciona música |
| DELETE | `/meetings/{id}/songs/{sid}` | Remove música |
| POST | `/meetings/{id}/messages` | Adiciona mensagem/discurso |
| PUT | `/meetings/{id}/messages/{mid}` | Atualiza mensagem/discurso |
| DELETE | `/meetings/{id}/messages/{mid}` | Remove mensagem |
| PATCH | `/meetings/{id}/messages/reorder` | Reordena discursos (atualiza campo `ordem`) |

**Campos de mensagem/discurso:**
```json
{
  "tipo_item": "mensagem",
  "membro_id": 42,
  "visitante_id": null,
  "orador_externo": null,
  "tema": "A Fé em Jesus Cristo",
  "material_apoio": "Moroni 10:3-5; Alma 32:21",
  "tempo_minutos": 15,
  "ordem": 1,
  "tem_hino_intermediario": false
}
```

---

### 4.12 Reunião de Bispado — `/api/v1/bishopric-meetings`

| Método | Rota | Descrição |
|---|---|---|
| GET | `/bishopric-meetings` | Lista reuniões de bispado |
| POST | `/bishopric-meetings` | Cria reunião |
| GET | `/bishopric-meetings/{id}` | Retorna reunião |
| PUT | `/bishopric-meetings/{id}` | Atualiza reunião |
| DELETE | `/bishopric-meetings/{id}` | Remove reunião |
| POST | `/bishopric-meetings/{id}/topics` | Adiciona assunto |
| DELETE | `/bishopric-meetings/{id}/topics/{tid}` | Remove assunto |
| POST | `/bishopric-meetings/{id}/assignments` | Adiciona designação |
| DELETE | `/bishopric-meetings/{id}/assignments/{aid}` | Remove designação |

---

### 4.13 Reunião de Conselho da Ala — `/api/v1/ward-council`

| Método | Rota | Descrição |
|---|---|---|
| GET | `/ward-council` | Lista reuniões de conselho |
| POST | `/ward-council` | Cria reunião |
| GET | `/ward-council/{id}` | Retorna reunião |
| PUT | `/ward-council/{id}` | Atualiza reunião |
| DELETE | `/ward-council/{id}` | Remove reunião |
| POST | `/ward-council/{id}/topics` | Adiciona assunto |
| DELETE | `/ward-council/{id}/topics/{tid}` | Remove assunto |
| POST | `/ward-council/{id}/assignments` | Adiciona designação |
| DELETE | `/ward-council/{id}/assignments/{aid}` | Remove designação |

---

### 4.14 Frequência — `/api/v1/attendance`

| Método | Rota | Descrição |
|---|---|---|
| POST | `/attendance` | Registra frequência |
| GET | `/attendance` | Lista registros |
| GET | `/attendance/{id}` | Retorna registro |
| GET | `/attendance/by-meeting/{meetingId}` | Frequência de uma reunião |
| GET | `/attendance/follow-up` | Membros ausentes por 2 ou 3 semanas |

---

### 4.15 Tarefas do Bispado — `/api/v1/bishopric-tasks`

| Método | Rota | Descrição |
|---|---|---|
| GET | `/bishopric-tasks` | Lista tarefas |
| POST | `/bishopric-tasks` | Cria tarefa |
| GET | `/bishopric-tasks/{id}` | Retorna tarefa |
| PUT | `/bishopric-tasks/{id}` | Atualiza tarefa |
| DELETE | `/bishopric-tasks/{id}` | Remove tarefa |
| PATCH | `/bishopric-tasks/{id}/complete` | Marca como concluída |

---

### 4.16 Entrevistas — `/api/v1/interviews`

| Método | Rota | Descrição |
|---|---|---|
| GET | `/interviews` | Lista entrevistas |
| POST | `/interviews` | Cria entrevista |
| GET | `/interviews/{id}` | Retorna entrevista |
| PUT | `/interviews/{id}` | Atualiza entrevista |
| DELETE | `/interviews/{id}` | Remove entrevista |
| GET | `/interviews/pending` | Lista entrevistas pendentes |

---

### 4.17 Orçamento — `/api/v1/budget`

| Método | Rota | Descrição |
|---|---|---|
| GET | `/budget` | Lista orçamentos trimestrais |
| POST | `/budget` | Cria orçamento trimestral |
| GET | `/budget/{id}` | Retorna orçamento |
| PUT | `/budget/{id}` | Atualiza orçamento |
| DELETE | `/budget/{id}` | Remove orçamento |
| GET | `/budget/{id}/distribution` | Retorna distribuição por grupo de orçamento |
| POST | `/budget/{id}/distribution/calculate` | Recalcula distribuição com base na frequência do trimestre |

### 4.17.1 Grupos de Orçamento — `/api/v1/budget/groups`

| Método | Rota | Descrição |
|---|---|---|
| GET | `/budget/groups` | Lista grupos de orçamento da ala |
| POST | `/budget/groups` | Cria grupo de orçamento local |
| GET | `/budget/groups/{id}` | Retorna grupo específico |
| PUT | `/budget/groups/{id}` | Atualiza nome ou peso do grupo |
| DELETE | `/budget/groups/{id}` | Remove grupo local |
| GET | `/budget/groups/{id}/organizations` | Lista organizações do grupo |
| PUT | `/budget/groups/{id}/organizations` | Atualiza organizações do grupo |

> Grupos com `origem = 'global'` (seeds) não podem ser removidos. Apenas o `peso` pode ser atualizado.

---

### 4.18 Relatórios — `/api/v1/reports`

| Método | Rota | Descrição |
|---|---|---|
| GET | `/reports/weekly` | Relatório semanal mais recente (ou por `?date=YYYY-MM-DD`) |
| GET | `/reports/monthly` | Relatório mensal (por `?month=N&year=YYYY`) |
| GET | `/reports/quarterly` | Relatório trimestral (por `?quarter=N&year=YYYY`) |
| GET | `/reports/weekly/history` | Histórico de relatórios semanais (paginado) |
| GET | `/reports/monthly/history` | Histórico de relatórios mensais |
| GET | `/reports/quarterly/history` | Histórico de relatórios trimestrais |

---

### 4.19 Notificações — `/api/v1/notifications`

| Método | Rota | Descrição |
|---|---|---|
| GET | `/notifications` | Lista notificações do usuário (paginado) |
| PATCH | `/notifications/{id}/read` | Marca notificação como lida |
| PATCH | `/notifications/read-all` | Marca todas como lidas |
| DELETE | `/notifications/{id}` | Remove notificação |
| POST | `/notifications/fcm-token` | Registra token FCM do dispositivo |

---

### 4.20 Hinos — `/api/v1/hymns`

| Método | Rota | Descrição |
|---|---|---|
| GET | `/hymns` | Lista hinos (globais + locais da ala) |
| POST | `/hymns` | Adiciona hino local |
| PUT | `/hymns/{id}` | Atualiza hino local |

> Hinos globais (seed) não podem ser editados.

---

### 4.21 Jobs — `/api/v1/jobs`

| Método | Rota | Descrição |
|---|---|---|
| GET | `/jobs` | Lista histórico de execuções |
| GET | `/jobs/{id}` | Retorna execução específica |
| POST | `/jobs/{name}/run` | Dispara job manualmente (requer permissão `run_jobs`) |

**Valores válidos para `{name}`:**

| Valor | Job | Quando roda automaticamente |
|---|---|---|
| `weekly` | Semanal: relatório, limpeza, tarefas, entrevistas, ausências | Todo domingo 12:00 BRT |
| `monthly` | Mensal: relatório, chamados, recomendações | Dia 1 de cada mês 00:01 BRT |
| `quarterly` | Trimestral: relatório de frequência | Dia 1 de jan/abr/jul/out 00:01 BRT |
| `yearly` | Anual: recálculo de organização de todos os membros | 1º de janeiro 00:01 BRT |

---

### 4.22 Health Check — `/api/v1/health`

| Método | Rota | Descrição |
|---|---|---|
| GET | `/health` | Verifica se o backend está no ar (usado pelo UptimeRobot) |

---

## 5. Segurança

- Todas as rotas (exceto `/auth/*`, `/geo/*` e `/health`) exigem autenticação
- Autorização verificada por permissão granular em cada endpoint
- Dados filtrados automaticamente pela ala do usuário autenticado
- CORS configurado para aceitar apenas a origem do frontend (Vercel)
- Rate limiting aplicado nas rotas de autenticação
- HTTPS obrigatório em produção

---

*EasyWard v0.1*
