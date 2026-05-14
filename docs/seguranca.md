# EasyWard — Segurança

## 1. Objetivo

Consolidar todas as práticas, decisões e controles de segurança do EasyWard em um único documento de referência.

---

## 2. Autenticação

### 2.1 JWT — Access Token
- Algoritmo: `HS256`
- Validade: **30 minutos**
- Payload: `{ "sub": user_id, "ward_id": ward_id, "exp": timestamp }`
- Transmitido no header: `Authorization: Bearer <token>`

### 2.2 JWT — Refresh Token
- Algoritmo: `HS256`
- Validade: **7 dias**
- Armazenado em **cookie `httpOnly`** — inacessível via JavaScript
- Atributos do cookie:
  ```
  HttpOnly=true
  Secure=true       (apenas HTTPS)
  SameSite=Strict   (previne CSRF)
  Path=/api/v1/auth (restrito à rota de refresh)
  ```
- Hash do token armazenado na tabela `refresh_tokens` (nunca o token em texto claro)
- Ao fazer logout, o token é marcado como `revoked = true` no banco

### 2.3 Política de Senhas
- Mínimo de **8 caracteres**
- Deve conter ao menos: 1 letra maiúscula, 1 letra minúscula e 1 número
- Hash com **bcrypt**, fator de custo 12
- A senha nunca é armazenada em texto claro, nunca é logada e nunca aparece em respostas da API

### 2.4 Proteção contra Força Bruta
- Rate limiting em `POST /api/v1/auth/login`: **10 requisições por minuto por IP**
- Após **5 tentativas falhas** para o mesmo e-mail: bloqueio temporário de **15 minutos**
- Implementado via `slowapi` no backend
- Tentativas falhas são registradas no `audit_log`

---

## 3. Autorização

### 3.1 Fluxo de validação por requisição
Toda requisição protegida passa por estas verificações na ordem:

```
1. Token JWT presente no header? → 401 se não
2. Token válido e não expirado?  → 401 se não
3. Usuário existe e está ativo?  → 401 se não
4. Usuário pertence à ala do recurso solicitado? → 403 se não
5. Usuário possui a permissão específica da operação? → 403 se não
```

### 3.2 Isolamento por ala
- Toda query no banco filtra automaticamente por `ala_id = current_user.ward_id`
- Nenhum endpoint retorna dados de outra ala, mesmo que o ID seja passado explicitamente
- A única exceção é a lista pública de alas (onboarding), que expõe apenas: id, nome da ala, nome da estaca, nome do estado

### 3.3 Permissões granulares
- Cada endpoint verifica a permissão específica necessária (ex: `manage_members`)
- A verificação é feita via `Depends(require_permission("codigo"))` no FastAPI
- Sem permissão → `403 Forbidden` com mensagem: "Permissão insuficiente para esta operação."

---

## 4. Proteção de Dados Sensíveis

### 4.1 Entrevistas
- Dados de entrevistas são considerados pastoralmente sensíveis
- O acesso requer permissões explícitas (`view_interviews`, `manage_interviews`)
- O campo `observacoes` nunca aparece em listagens — apenas na visualização individual
- Logs de auditoria registram todo acesso a registros de entrevista

### 4.2 Senhas e Tokens
- Senhas: armazenadas apenas como hash bcrypt
- Refresh tokens: armazenados apenas como hash SHA-256
- Tokens JWT: nunca logados em texto claro
- A `DATABASE_URL` e demais secrets nunca aparecem em logs ou respostas

### 4.3 Respostas da API
- Respostas de erro nunca expõem stack traces ou mensagens internas do banco
- O campo `senha` nunca é incluído em nenhuma resposta da API
- Dados de outras alas nunca aparecem em nenhuma resposta

---

## 5. Segurança na Transmissão

### 5.1 HTTPS
- Obrigatório em produção (Vercel e Render fornecem TLS automaticamente)
- Em desenvolvimento local, HTTP é aceito
- O cookie de refresh token tem `Secure=true`, funcionando apenas em HTTPS

### 5.2 CORS
```python
origins = [
    "https://easyward.vercel.app",  # produção
    "http://localhost:5173",         # desenvolvimento local
]
```
- `allow_credentials=True` é obrigatório para o cookie httpOnly funcionar
- Domínios não listados recebem erro de CORS e a requisição é bloqueada

### 5.3 Headers de Segurança
Adicionar ao backend via middleware:

```python
@app.middleware("http")
async def add_security_headers(request, call_next):
    response = await call_next(request)
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    return response
```

---

## 6. Proteção contra Ataques Comuns

### 6.1 SQL Injection
- Prevenido pelo uso de SQLAlchemy com queries parametrizadas
- Nenhuma query é construída por concatenação de strings com input do usuário

### 6.2 XSS (Cross-Site Scripting)
- O frontend React escapa automaticamente valores renderizados
- O backend não renderiza HTML — retorna apenas JSON
- O cookie de refresh token é `httpOnly` — JavaScript não consegue acessá-lo

### 6.3 CSRF (Cross-Site Request Forgery)
- Mitigado pelo `SameSite=Strict` no cookie de refresh token
- O access token é enviado no header `Authorization` — não em cookie — e requisições cross-site não conseguem definir headers customizados

### 6.4 Rate Limiting
- Login: 10 req/min por IP
- Registro: 5 req/min por IP
- Demais endpoints: sem limite explícito na versão inicial (monitorar via Sentry)

### 6.5 Validação de Entrada
- Toda entrada é validada via **Pydantic v2** no backend
- Validação de tamanho máximo em todos os campos de texto
- Tipos enumerados usam enum PostgreSQL ou CHECK constraints
- A validação do frontend é apenas UX — não substitui a do backend

---

## 7. Gestão de Secrets

### 7.1 Variáveis de Ambiente
Nunca commitar secrets no repositório. Usar:
- `.env` local (no `.gitignore`)
- Secrets do GitHub (para Actions)
- Variáveis de ambiente do Render (para o backend em produção)
- Variáveis de ambiente da Vercel (para o frontend em produção)

### 7.2 Rotação de Secrets
Rotacionar periodicamente (recomendado: a cada 6 meses):
- `JWT_SECRET`
- `JWT_REFRESH_SECRET`
- `JOB_SECRET`

Ao rotacionar `JWT_SECRET`, todos os access tokens existentes são invalidados automaticamente. Os refresh tokens precisam ser invalidados manualmente (marcar todos como `revoked = true`).

### 7.3 Secrets no GitHub Actions
Os seguintes secrets devem ser cadastrados no repositório GitHub:
- `DATABASE_URL` — string de conexão do Supabase
- `API_URL` — URL do backend no Render
- `JOB_SECRET` — token de autenticação dos jobs
- `RCLONE_CONFIG` — configuração do rclone para Google Drive (backup)

---

## 8. Monitoramento de Segurança

- Tentativas de login falhas: registradas no `audit_log`
- Acessos negados (403): registrados no `audit_log`
- Erros 500: capturados pelo Sentry com contexto da requisição (sem dados sensíveis)
- Disponibilidade: monitorada pelo UptimeRobot
- Tokens FCM inválidos: removidos automaticamente ao receber erro do Firebase

---

## 9. Dados Pessoais e Privacidade

O EasyWard armazena dados pessoais de membros (nome, data de nascimento, sexo, cargo) e dados pastorais (entrevistas). Boas práticas:

- Coletar apenas os dados necessários para a operação do sistema
- Membros inativados (`ativo = false`) continuam no banco mas não são exibidos
- Não há mecanismo de exportação de dados pessoais na versão inicial (pode ser necessário no futuro conforme regulamentações)
- O sistema não compartilha dados com terceiros (exceto os serviços utilizados: Supabase, Render, FCM, Resend)

---

## 10. Checklist de Segurança Pré-Deploy

Antes de colocar em produção, verificar:

- [ ] `JWT_SECRET` e `JWT_REFRESH_SECRET` são strings aleatórias longas (32+ caracteres)
- [ ] `JOB_SECRET` é uma string aleatória (não usar o valor padrão de dev)
- [ ] `DATABASE_URL` aponta para o projeto de **produção** do Supabase
- [ ] `CORS_ORIGINS` contém apenas a URL de produção do frontend
- [ ] `APP_ENV` está definido como `production`
- [ ] Cookie de refresh token tem `Secure=true` e `SameSite=Strict`
- [ ] Rate limiting está ativo nas rotas de autenticação
- [ ] Sentry configurado e testado
- [ ] UptimeRobot configurado
- [ ] Backup automático configurado e testado

---

*EasyWard v0.1*
