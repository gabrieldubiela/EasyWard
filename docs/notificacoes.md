# EasyWard — Notificações

## 1. Objetivo

Definir os canais, eventos, destinatários e implementação do sistema de notificações do EasyWard.

---

## 2. Canais

O sistema utiliza três canais complementares:

| Canal | Serviço | Custo | Quando usar |
|---|---|---|---|
| **Push** | Firebase Cloud Messaging (FCM) — Spark | Gratuito | Alertas imediatos no celular, mesmo com o app fechado |
| **E-mail** | Resend | Gratuito (3.000/mês) | Relatórios periódicos, resumos e notificações importantes |
| **Em tela** | Banco de dados próprio | Gratuito | Histórico de notificações dentro do app |

---

## 3. Tabela de Notificações em Tela

```sql
CREATE TABLE notifications (
  id           SERIAL PRIMARY KEY,
  user_id      INT          NOT NULL,
  ward_id      INT          NOT NULL,
  type         VARCHAR(60)  NOT NULL,
  title        VARCHAR(120) NOT NULL,
  body         TEXT         NOT NULL,
  read         BOOLEAN      NOT NULL DEFAULT FALSE,
  action_url   VARCHAR(255) NULL,     -- rota do frontend para navegar ao clicar
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE,
  CONSTRAINT fk_notifications_ward FOREIGN KEY (ward_id) REFERENCES alas(id)    ON DELETE CASCADE
);

CREATE INDEX idx_notifications_user_read ON notifications(user_id, read, created_at DESC);
```

---

## 4. Endpoints de Notificação

| Método | Rota | Descrição |
|---|---|---|
| GET | `/api/v1/notifications` | Lista notificações do usuário (paginado) |
| PATCH | `/api/v1/notifications/{id}/read` | Marca como lida |
| PATCH | `/api/v1/notifications/read-all` | Marca todas como lidas |
| DELETE | `/api/v1/notifications/{id}` | Remove notificação |
| POST | `/api/v1/notifications/fcm-token` | Registra token FCM do dispositivo |

---

## 5. Tabela de Tokens FCM

```sql
CREATE TABLE fcm_tokens (
  id          SERIAL PRIMARY KEY,
  user_id     INT          NOT NULL,
  token       VARCHAR(255) NOT NULL,
  device_info VARCHAR(120) NULL,   -- ex: "Android 14 / Chrome"
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_fcm_tokens_user FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE,
  CONSTRAINT uk_fcm_token UNIQUE (token)
);
CREATE INDEX idx_fcm_tokens_user ON fcm_tokens(user_id);
```

---

## 6. Matriz de Eventos e Notificações

### 6.1 Jobs automáticos

| Evento | Push | E-mail | Em tela | Permissão necessária | Destinatários |
|---|---|---|---|---|---|
| Relatório semanal gerado | ✅ | ✅ | ✅ | `view_weekly_report` | Usuários com a permissão |
| Relatório mensal gerado | ✅ | ✅ | ✅ | `view_monthly_report` | Usuários com a permissão |
| Relatório trimestral gerado | ✅ | ✅ | ✅ | `view_quarterly_report` | Usuários com a permissão |
| Aviso de limpeza da semana | ✅ | ❌ | ✅ | `view_cleaning` | Usuários com a permissão |
| Job falhou | ❌ | ✅ | ✅ | `view_jobs` | Usuários com a permissão |

### 6.2 Membros e frequência

| Evento | Push | E-mail | Em tela | Permissão necessária | Destinatários |
|---|---|---|---|---|---|
| Membro ausente há 2+ semanas identificado | ❌ | ❌ | ✅ | `view_weekly_report` | Usuários com a permissão |
| Recomendação vencendo no mês | ❌ | ❌ | ✅ | `view_monthly_report` | Usuários com a permissão |
| Membro apto a trocar de chamado | ❌ | ❌ | ✅ | `view_monthly_report` | Usuários com a permissão |

### 6.3 Tarefas

| Evento | Push | E-mail | Em tela | Destinatário |
|---|---|---|---|---|
| Tarefa atribuída ao usuário | ✅ | ❌ | ✅ | Responsável pela tarefa |
| Tarefa próxima do vencimento (1 dia antes) | ✅ | ❌ | ✅ | Responsável pela tarefa |
| Tarefa concluída | ❌ | ❌ | ✅ | Quem criou a tarefa |

### 6.4 Entrevistas

| Evento | Push | E-mail | Em tela | Permissão necessária | Destinatários |
|---|---|---|---|---|---|
| Entrevista pendente identificada (job semanal) | ❌ | ❌ | ✅ | `view_interviews` | Usuários com a permissão |

### 6.5 Sistema e acesso

| Evento | Push | E-mail | Em tela | Destinatário |
|---|---|---|---|---|
| Conta criada na ala | ❌ | ✅ | ❌ | Novo usuário |
| Permissões alteradas | ❌ | ❌ | ✅ | Usuário afetado |
| Solicitação de revogação de `manage_user_permissions` | ✅ | ❌ | ✅ | Usuário que deve aprovar |

---

## 7. Implementação — Push (FCM)

### Configuração

```python
# app/core/firebase.py
import firebase_admin
from firebase_admin import credentials, messaging
import json, os

cred = credentials.Certificate(json.loads(os.getenv("FIREBASE_CREDENTIALS")))
firebase_admin.initialize_app(cred)
```

### Envio de push

```python
# app/modules/notifications/fcm_service.py
from firebase_admin import messaging
from app.modules.notifications.repository import get_fcm_tokens

async def send_push(
    user_ids: list[int],
    title: str,
    body: str,
    action_url: str | None = None,
    db: AsyncSession = None,
) -> None:
    tokens = await get_fcm_tokens(user_ids, db)
    if not tokens:
        return

    message = messaging.MulticastMessage(
        tokens=tokens,
        notification=messaging.Notification(title=title, body=body),
        data={"action_url": action_url or ""},
        android=messaging.AndroidConfig(priority="normal"),
        apns=messaging.APNSConfig(
            payload=messaging.APNSPayload(
                aps=messaging.Aps(sound="default")
            )
        ),
    )
    messaging.send_each_for_multicast(message)
```

### Registro do token FCM no frontend

```typescript
// src/modules/auth/services/fcm.service.ts
import { getMessaging, getToken } from 'firebase/messaging';

export async function registerFcmToken(): Promise<void> {
  const messaging = getMessaging();
  const token = await getToken(messaging, {
    vapidKey: import.meta.env.VITE_FIREBASE_VAPID_KEY,
  });
  if (token) {
    await api.post('/notifications/fcm-token', { token });
  }
}
```

---

## 8. Implementação — E-mail (Resend)

### Configuração

```python
# app/core/email.py
import resend
import os

resend.api_key = os.getenv("RESEND_API_KEY")
FROM_EMAIL = "noreply@easyward.app"
```

### Envio de e-mail

```python
# app/modules/notifications/email_service.py
import resend
from app.core.email import FROM_EMAIL

async def send_email(
    to: list[str],
    subject: str,
    html: str,
) -> None:
    resend.Emails.send({
        "from": FROM_EMAIL,
        "to": to,
        "subject": subject,
        "html": html,
    })
```

### Templates de e-mail

Os templates são strings HTML simples. Manter em `app/modules/notifications/templates/`:

| Arquivo | Uso |
|---|---|
| `weekly_report.html` | Relatório semanal |
| `monthly_report.html` | Relatório mensal |
| `quarterly_report.html` | Relatório trimestral |
| `welcome.html` | Boas-vindas ao novo usuário |
| `job_failure.html` | Falha em job automático |

---

## 9. Implementação — Notificação em Tela

### Serviço centralizado

```python
# app/modules/notifications/service.py
async def notify(
    db: AsyncSession,
    user_ids: list[int],
    ward_id: int,
    type: str,
    title: str,
    body: str,
    action_url: str | None = None,
    send_push: bool = False,
    send_email: bool = False,
    email_subject: str | None = None,
    email_html: str | None = None,
) -> None:
    # 1. Persistir em tela para todos os usuários
    await notification_repository.create_many(
        db, user_ids, ward_id, type, title, body, action_url
    )

    # 2. Enviar push se solicitado
    if send_push:
        await fcm_service.send_push(user_ids, title, body, action_url, db)

    # 3. Enviar e-mail se solicitado
    if send_email and email_subject and email_html:
        emails = await user_repository.get_emails(user_ids, db)
        await email_service.send_email(emails, email_subject, email_html)
```

### No frontend — sino de notificações

```typescript
// src/components/domain/NotificationBell.tsx
// - Ícone de sino no header
// - Badge com contagem de não lidas
// - Dropdown com lista das últimas 10
// - Marcar como lida ao clicar
// - Link "Ver todas" para página completa
```

---

## 10. Configuração do PWA para Push

Para receber notificações push com o app fechado, o frontend precisa de um service worker registrado:

```typescript
// vite.config.ts — via vite-plugin-pwa
VitePWA({
  registerType: 'autoUpdate',
  manifest: { ... },
  workbox: {
    runtimeCaching: [...],
  },
})
```

```javascript
// public/firebase-messaging-sw.js
importScripts('https://www.gstatic.com/firebasejs/10.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.0.0/firebase-messaging-compat.js');

firebase.initializeApp({ /* config */ });
const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  self.registration.showNotification(payload.notification.title, {
    body: payload.notification.body,
    icon: '/icons/icon-192x192.png',
  });
});
```

---

## 11. Variáveis de Ambiente Necessárias

### Backend
| Variável | Descrição |
|---|---|
| `FIREBASE_CREDENTIALS` | JSON das credenciais do Firebase Admin SDK |
| `RESEND_API_KEY` | Chave da API do Resend |

### Frontend
| Variável | Descrição |
|---|---|
| `VITE_FIREBASE_API_KEY` | API key do projeto Firebase |
| `VITE_FIREBASE_PROJECT_ID` | ID do projeto Firebase |
| `VITE_FIREBASE_MESSAGING_SENDER_ID` | Sender ID do FCM |
| `VITE_FIREBASE_APP_ID` | App ID do Firebase |
| `VITE_FIREBASE_VAPID_KEY` | Chave VAPID para push web |

---

## 12. Retenção de Notificações

- Notificações em tela: manter por **60 dias**, remover automaticamente as mais antigas via job mensal
- Notificações lidas há mais de 30 dias podem ser removidas antes do prazo

---

*EasyWard v0.1*
