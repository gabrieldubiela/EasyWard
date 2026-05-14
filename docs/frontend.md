# EasyWard — Frontend

## 1. Objetivo

Definir a estrutura funcional e técnica da camada de apresentação do EasyWard.

---

## 2. Stack

| Tecnologia | Uso |
|---|---|
| React + TypeScript | Base do frontend |
| Vite | Bundler e servidor de desenvolvimento |
| React Router v6 | Navegação e rotas protegidas |
| Zustand | Estado global (sessão, permissões, contexto da ala) |
| React Hook Form + Zod | Formulários com validação de esquema |
| Axios | Cliente HTTP com interceptor de refresh token |
| PWA (Vite PWA plugin) | Instalação no celular e cache offline |
| Lucide React | Iconografia (18px menus, 16px inline) |
| Source Sans 3 | Tipografia principal (Google Fonts — mesma família do LCR) |

---

## 3. Organização de Pastas

```
frontend/
├── public/
│   └── icons/                  # Ícones PWA
├── src/
│   ├── app/
│   │   ├── router.tsx           # Definição de rotas
│   │   └── App.tsx
│   ├── modules/                 # Um diretório por domínio
│   │   ├── auth/
│   │   ├── members/
│   │   ├── families/
│   │   ├── visitors/
│   │   ├── attendance/
│   │   ├── meetings/
│   │   ├── bishopric-meetings/
│   │   ├── ward-council/
│   │   ├── tasks/
│   │   ├── interviews/
│   │   ├── cleaning/
│   │   ├── budget/
│   │   ├── reports/
│   │   ├── users/
│   │   └── settings/
│   ├── components/              # Componentes reutilizáveis
│   │   ├── ui/                  # Botão, Input, Modal, Table, etc.
│   │   └── domain/              # CardMembro, CardTarefa, etc.
│   ├── services/                # Camada de consumo da API (Axios)
│   ├── store/                   # Stores Zustand
│   ├── hooks/                   # Hooks customizados
│   ├── lib/
│   │   ├── axios.ts             # Instância Axios com interceptors
│   │   └── zod-schemas.ts       # Esquemas de validação globais
│   └── types/                   # Tipos TypeScript globais
```

Cada módulo contém:
```
modules/members/
├── pages/
│   ├── MemberListPage.tsx
│   └── MemberFormPage.tsx
├── components/
│   └── MemberCard.tsx
├── services/
│   └── members.service.ts
└── schemas/
    └── member.schema.ts
```

---

## 4. Autenticação e Sessão

### Fluxo de tokens
- Login → `access_token` no estado Zustand + `refresh_token` em cookie `httpOnly`
- Axios interceptor detecta resposta `401` → chama `POST /api/v1/auth/refresh` automaticamente → retenta a requisição original
- Logout → limpa estado Zustand + chama `POST /api/v1/auth/logout` (invalida refresh token no servidor)

### Instância Axios com interceptor
```typescript
// src/lib/axios.ts
import axios from 'axios';
import { useAuthStore } from '@/store/auth.store';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  withCredentials: true, // envia o cookie httpOnly
});

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401 && !error.config._retry) {
      error.config._retry = true;
      await api.post('/auth/refresh');
      return api(error.config);
    }
    return Promise.reject(error);
  }
);

export default api;
```

### Store de autenticação (Zustand)
```typescript
// src/store/auth.store.ts
interface AuthState {
  user: User | null;
  permissions: string[];
  isAuthenticated: boolean;
  setUser: (user: User, permissions: string[]) => void;
  clearUser: () => void;
  hasPermission: (code: string) => boolean;
}
```

---

## 5. Rotas e Proteção

```typescript
// src/app/router.tsx
<Routes>
  {/* Públicas */}
  <Route path="/login" element={<LoginPage />} />
  <Route path="/onboarding" element={<OnboardingPage />} />

  {/* Protegidas */}
  <Route element={<PrivateLayout />}>
    <Route path="/" element={<DashboardPage />} />
    <Route path="/members" element={<RequirePermission code="view_members"><MemberListPage /></RequirePermission>} />
    <Route path="/members/new" element={<RequirePermission code="manage_members"><MemberFormPage /></RequirePermission>} />
    {/* ... demais rotas */}
  </Route>
</Routes>
```

O componente `RequirePermission` verifica o store e redireciona para uma tela de "acesso insuficiente" se o usuário não possuir a permissão necessária.

---

## 6. Módulos e Telas

### 6.1 Onboarding
- Seleção: criar nova ala ou entrar em ala existente
- Criar nova ala: estado → estaca (existente ou nova) → nome da ala → dados pessoais
- Entrar em ala existente: estado → estaca → ala → nome completo + credenciais

### 6.2 Dashboard
Exibe atalhos e indicadores operacionais conforme permissões:
- Frequência da última reunião
- Tarefas pendentes
- Entrevistas pendentes
- Membros ausentes há 2+ semanas
- Aviso de limpeza da semana
- Notificações recentes

### 6.3 Membros
- Listagem com filtros (organização principal, chamado, grupo de limpeza, sexo, status)
- Busca por nome
- Cadastro e edição
- Atribuição manual de organização principal (com aviso sobre recálculo automático no job anual)
- Inativação (soft delete)
- Visualização de detalhes (organização principal, chamado, família, grupo de limpeza, recomendação)
- Alerta visual para membros sem organização atribuída (`organizacao_id = NULL`)

### 6.4 Famílias
- Listagem e busca
- Cadastro e edição
- Visualização de membros da família

### 6.5 Visitantes
- Listagem com filtro de frequentes
- Cadastro e edição

### 6.6 Reunião Sacramental
- Criação da reunião com papéis (preside, dirige, regente, pianista, prelúdio)
- Lançamento de blocos: boas-vindas, reconhecimentos, anúncios, assuntos, músicas, mensagens
- Discursos com: orador (membro, visitante ou externo), tema, material de apoio, tempo alocado, ordem e hino intermediário
- Reordenação de discursos via drag-and-drop ou setas
- Soma do tempo total alocado exibida na tela
- Lançamento de frequência vinculado à reunião
- Histórico de reuniões

### 6.7 Reunião de Bispado
- Criação com data e participantes
- Registro de assuntos discutidos
- Registro de designações (responsável + data)
- Histórico

### 6.8 Reunião de Conselho da Ala
- Mesma estrutura da reunião de bispado
- Histórico

### 6.9 Frequência
- Seleção de reunião
- Lista de membros com marcação de presença/ausência
- Lista de visitantes
- Campo para nome externo
- Consolidação por organização
- Salvar em lote

### 6.10 Tarefas do Bispado
- Listagem com filtros (pendente/concluída, responsável, prazo)
- Cadastro com texto, data limite e responsável
- Conclusão de tarefa

### 6.11 Entrevistas
- Listagem com filtros (tipo, status, pendentes)
- Cadastro com membro, tipo, data, entrevistador e observações
- Marcação de status

### 6.12 Limpeza
- Gestão de grupos e membros de cada grupo
- Visualização do aviso da semana (qual grupo é responsável)

### 6.13 Orçamento
- Listagem de orçamentos trimestrais
- Cadastro de valor recebido e acumulado do ano
- Visualização da distribuição por **grupo de orçamento** (não por organização diretamente)
- Gestão de grupos de orçamento: criar, editar, definir organizações e peso
- Grupos padrão (Quórum de Élderes, Sociedade de Socorro, Jovens, Primária) com peso editável
- Cálculo automático de distribuição com base na frequência do trimestre
- Indicação visual de quais organizações compõem cada grupo (ex: Jovens = Rapazes + Moças)

### 6.14 Relatórios
- Semanal: frequência + ausências prolongadas + aviso de limpeza + tarefas + entrevistas
- Mensal: frequência consolidada + membros para troca de chamado + recomendações
- Trimestral: frequência acumulada por organização
- Filtros por período

### 6.15 Usuários e Permissões
- Listagem de usuários da ala
- Edição de permissões (checkboxes por permissão)
- Ativação/inativação de usuário
- Fluxo de aprovação para revogar `manage_user_permissions`

### 6.16 Configurações da Ala
- Edição de nome e dados básicos da ala
- Gestão de organizações locais (tipo auxiliar — para chamados)
- Gestão de chamados locais
- Gestão de hinos locais
- Gestão de grupos de orçamento locais (criar grupos customizados combinando organizações)
- Parâmetro de ausência prolongada (2 ou 3 semanas)

---

## 7. Componentes Reutilizáveis

### UI base
- `Button` — variantes: primary, secondary, danger, ghost
- `Input`, `Select`, `Textarea`, `Checkbox`, `DatePicker`
- `Modal` — com confirmação e formulário
- `Table` — com paginação, ordenação e filtros
- `Badge` — status de registros
- `Alert` — sucesso, erro, aviso, info
- `Loader` — spinner e skeleton
- `Breadcrumb`
- `Pagination`
- `EmptyState` — tela vazia com ação sugerida

### Domínio
- `MemberCard`
- `TaskCard`
- `InterviewCard`
- `AttendanceRow`
- `ReportSummary`
- `NotificationBell`

---

## 8. Tratamento de Erros e Estados

Cada requisição deve tratar três estados explicitamente:

| Estado | Comportamento |
|---|---|
| Carregando | Exibir `Loader` / skeleton |
| Sucesso | Exibir dados ou mensagem de confirmação |
| Erro | Exibir `Alert` com mensagem amigável |

Erros HTTP mapeados:
- `401` → redirecionar para login (após tentativa de refresh)
- `403` → exibir tela de "acesso insuficiente"
- `404` → exibir tela de "não encontrado"
- `422` / `400` → exibir erros de campo no formulário
- `500` → exibir mensagem genérica de erro

---

## 9. PWA

Configurar via `vite-plugin-pwa`:

- `manifest.json` com nome, ícones, cores e `display: standalone`
- Service worker com estratégia de cache `NetworkFirst` para chamadas de API
- Cache offline para assets estáticos (CSS, JS, fontes)
- Telas já visitadas ficam disponíveis offline em modo leitura

---

## 10. Cold Start — UX

Na primeira requisição após hibernação do Render, o backend pode levar até 60 segundos para responder. O frontend deve:

1. Detectar que a requisição está demorando mais de 5 segundos
2. Exibir mensagem discreta: "Iniciando o servidor, aguarde um momento..."
3. Manter o loader ativo até a resposta chegar

---

## 11. Responsividade

Todas as telas devem funcionar bem em:
- Mobile (320px–768px) — prioridade, pois o app será usado no celular
- Tablet (768px–1024px)
- Desktop (1024px+)

O menu principal em mobile deve ser um menu inferior fixo (bottom navigation) ou gaveta lateral (drawer).

---

## 12. Acessibilidade

- Contraste mínimo WCAG 2.1 AA
- Campos com `label` associado explicitamente
- Botões com texto descritivo (não apenas ícones)
- Navegação por teclado funcional
- Mensagens de erro associadas ao campo pelo atributo `aria-describedby`

---

*EasyWard v0.1*
