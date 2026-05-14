# EasyWard — Fluxos de Tela

## 1. Objetivo

Descrever os fluxos de navegação e interação das telas mais complexas do sistema.

---

## 2. Fluxo 1 — Onboarding: Criar Nova Ala

```
[Tela inicial pública]
        │
        ├── "Criar nova ala"
        │         │
        │   [Passo 1 — Localização]
        │   Selecionar estado (dropdown)
        │   → Selecionar estaca existente OU "Criar nova estaca"
        │     → Se nova: campo de texto com nome da estaca
        │   → Informar nome da ala
        │         │
        │   [Passo 2 — Seus dados (primeiro membro)]
        │   Nome completo
        │   Sexo (opcional)
        │   Data de nascimento (opcional)
        │         │
        │   [Passo 3 — Credenciais]
        │   E-mail
        │   Senha
        │   Confirmar senha
        │         │
        │   [Botão: Criar Ala]
        │         │
        │   Sistema: cria estaca → ala → seeds → membro → usuário
        │   → Todas as permissões atribuídas automaticamente
        │         │
        │   [Dashboard] ← usuário autenticado com acesso total
        │
        └── "Entrar em ala existente"
                  │
            [Ver fluxo 3]
```

---

## 3. Fluxo 2 — Login

```
[Tela de Login]
    E-mail + Senha
    [Botão: Entrar]
        │
        ├── Credenciais inválidas
        │   → Mensagem de erro no formulário
        │   → Após 5 tentativas: bloqueio de 15 min com mensagem
        │
        └── Credenciais válidas
                │
            Sistema retorna: access_token + refresh_token (cookie)
                │
            Frontend carrega: dados do usuário + lista de permissões
                │
            [Dashboard] ← renderiza conforme permissões disponíveis
```

---

## 4. Fluxo 3 — Onboarding: Entrar em Ala Existente

```
[Tela inicial pública]
    "Criar conta em ala existente"
        │
    [Passo 1 — Localizar a ala]
    Selecionar estado
    → Lista de estacas do estado
    → Selecionar estaca
    → Lista de alas da estaca
    → Selecionar ala
        │
    [Passo 2 — Identificação]
    Nome completo (deve corresponder exatamente ao cadastro)
        │
        ├── Nome não encontrado na lista de membros
        │   → Erro: "Seu nome não foi encontrado. Solicite ao
        │     administrador da ala que cadastre você como membro."
        │
        └── Nome encontrado
                │
            [Passo 3 — Credenciais]
            E-mail
            Senha
            Confirmar senha
                │
            Sistema cria usuário SEM NENHUMA PERMISSÃO
                │
            [Dashboard vazio]
            Mensagem: "Sua conta foi criada. Aguarde um
            administrador conceder suas permissões de acesso."
```

---

## 5. Fluxo 4 — Lançamento de Frequência

```
[Menu: Frequência]
        │
    [Selecionar reunião]
    Lista de reuniões sacramentais ordenada por data (mais recente primeiro)
    → Selecionar a reunião do domingo
        │
    [Tela de lançamento de frequência]
    ┌─────────────────────────────────────────┐
    │  Reunião: 14/01/2024                    │
    │  ─────────────────────────────────────  │
    │  MEMBROS                    [+ Visitante]│
    │  ─────────────────────────────────────  │
    │  [✓] Ana Silva     Soc. de Socorro      │
    │  [✓] João Costa    Quórum de Élderes    │
    │  [ ] Maria Souza   Primária             │
    │  [ ] Thiago Lima   Rapazes              │
    │  ...                                    │
    │  ─────────────────────────────────────  │
    │  VISITANTES                             │
    │  [✓] Pedro Lima    (visitante)          │
    │  [+ Nome externo]                       │
    │  ─────────────────────────────────────  │
    │  Presentes: 87 / 128 (68%)             │
    │                          [Salvar]       │
    └─────────────────────────────────────────┘
        │
        ├── [+ Visitante] → Modal: buscar visitante cadastrado
        │                   ou digitar nome externo
        │
        ├── Marcar/desmarcar presença → atualiza contador em tempo real
        │
        └── [Salvar]
                │
            Sistema persiste todos os registros em lote
            → Mensagem de sucesso
            → Redireciona para tela de frequência (modo leitura)
```

---

## 6. Fluxo 5 — Ata da Reunião Sacramental

```
[Menu: Reuniões → Nova Reunião OU selecionar existente]
        │
    [Aba: Informações Gerais]
    Data da reunião
    Quem preside (busca de membro)
    Quem dirige (busca de membro)
    Prelúdio (busca de membro)
    Regente (busca de membro)
    Pianista (busca de membro)
    [Salvar informações gerais]
        │
    [Abas: Boas-vindas | Reconhecimentos | Anúncios |
           Assuntos | Músicas | Mensagens]
        │
    [Aba: Músicas]
    ┌─────────────────────────────────────────┐
    │  Abertura:     [Buscar hino] [Cantor]   │
    │  Sacramental:  [Buscar hino] [Cantor]   │
    │  Encerramento: [Buscar hino] [Cantor]   │
    │  [+ Adicionar outro hino]               │
    └─────────────────────────────────────────┘
        │
    [Aba: Mensagens / Discursos]
    ┌─────────────────────────────────────────┐
    │  [+ Adicionar discurso]                 │
    │  ─────────────────────────────────────  │
    │  1. João Costa                          │
    │     Tema: "A Fé em Cristo"              │
    │     Material: Moroni 10:3-5             │
    │     Tempo: 15 min                       │
    │     [Hino intermediário: sim/não]       │
    │     [↑] [↓] [✏️ Editar] [🗑️ Remover]  │
    │  ─────────────────────────────────────  │
    │  2. Ana Silva                           │
    │     Tema: "A Oração"                    │
    │     Material: —                         │
    │     Tempo: 10 min                       │
    │     [Hino intermediário: não]           │
    │     [↑] [↓] [✏️ Editar] [🗑️ Remover]  │
    │  ─────────────────────────────────────  │
    │  Tempo total alocado: 25 min            │
    └─────────────────────────────────────────┘

    [Modal: Adicionar/Editar Discurso]
    ┌─────────────────────────────────────────┐
    │  Orador                                 │
    │  ○ Membro  ○ Visitante  ○ Nome livre    │
    │  [Buscar membro...]                     │
    │                                         │
    │  Tema (opcional)                        │
    │  [__________________________________]   │
    │                                         │
    │  Material de apoio (opcional)           │
    │  [Escrituras, referências, links...]    │
    │                                         │
    │  Tempo alocado (min) (opcional)         │
    │  [____]                                 │
    │                                         │
    │  Tipo                                   │
    │  ● Mensagem  ○ Testemunho               │
    │                                         │
    │  Hino intermediário após o discurso?    │
    │  ○ Sim  ● Não                           │
    │                                         │
    │          [Cancelar] [Salvar]            │
    └─────────────────────────────────────────┘
        │
    [Botão: Finalizar Ata]
        │
        ├── Validação: ao menos 1 hino de abertura, sacramental e encerramento
        │   → Se faltar → alerta com o que está faltando
        │
        └── Ata salva e bloqueada para edição
```

---

## 7. Fluxo 6 — Gestão de Permissões de Usuário

```
[Menu: Administração → Usuários]
    Lista de usuários da ala
    → Selecionar usuário
        │
    [Tela de permissões do usuário]
    ┌─────────────────────────────────────────┐
    │  João Costa                             │
    │  joao@email.com  ● Ativo               │
    │  ─────────────────────────────────────  │
    │  USUÁRIOS E ACESSO                      │
    │  [✓] Visualizar usuários               │
    │  [ ] Gerenciar usuários                │
    │  [ ] Gerenciar permissões ⚠️           │
    │  ─────────────────────────────────────  │
    │  MEMBROS                                │
    │  [✓] Visualizar membros               │
    │  [✓] Gerenciar membros                │
    │  ...                                    │
    │                          [Salvar]       │
    └─────────────────────────────────────────┘
        │
        ├── Salvar permissões comuns → persiste imediatamente
        │   → Notificação em tela para o usuário afetado
        │
        └── Revogar "Gerenciar permissões" (⚠️)
                │
            Sistema verifica: há outro usuário com essa permissão?
                │
                ├── Não → Bloqueado
                │   Mensagem: "Não é possível revogar. Você é o único
                │   administrador de permissões da ala."
                │
                └── Sim → Modal de confirmação
                        "Essa ação requer aprovação de outro administrador.
                        Uma solicitação será enviada para [Nome]."
                        [Confirmar] [Cancelar]
                            │
                        Solicitação criada
                        Notificação push + em tela para o aprovador
                            │
                        [Tela do aprovador]
                        "João solicita revogar permissão de gestão
                        de permissões de Maria. Você aprova?"
                        [Aprovar] [Recusar]
                            │
                        → Aprovado: permissão revogada
                        → Recusado: solicitação encerrada
                        → Expirado (48h): solicitação cancelada automaticamente
```

---

## 8. Fluxo 7 — Geração Manual de Relatório

```
[Menu: Relatórios]
    Selecionar tipo: Semanal | Mensal | Trimestral
    Selecionar período (data / mês / trimestre)
    [Gerar Relatório]
        │
        ├── Relatório já existe para o período
        │   → Exibe o relatório existente (modo leitura)
        │   → Botão: "Regenerar" (substitui o existente)
        │
        └── Relatório não existe
                │
            Loading: "Gerando relatório..."
            (pode levar alguns segundos)
                │
            Relatório exibido na tela
            [Imprimir / Exportar PDF] ← versão futura
```

---

## 9. Fluxo 8 — Notificação de Bell

```
[Header — ícone de sino 🔔 com badge de contagem]
    → Clique no sino
        │
    [Dropdown de notificações]
    ┌─────────────────────────────────────────┐
    │  NOTIFICAÇÕES (3 não lidas)            │
    │  ─────────────────────────────────────  │
    │  🔵 Relatório semanal disponível       │
    │     Há 2 minutos                       │
    │  ─────────────────────────────────────  │
    │  🔵 Tarefa "Visitar família Silva"     │
    │     vence amanhã                        │
    │  ─────────────────────────────────────  │
    │  ○  Permissões atualizadas             │
    │     Há 3 dias                           │
    │  ─────────────────────────────────────  │
    │           [Ver todas]                   │
    └─────────────────────────────────────────┘
        │
        ├── Clique em uma notificação
        │   → Marca como lida
        │   → Navega para action_url (se houver)
        │
        └── [Ver todas] → Página completa de notificações
                          com paginação e filtro (lidas/não lidas)
```

---

## 10. Fluxo 9 — Atribuição Manual de Organização

```
[Menu: Membros → selecionar membro → Editar]
        │
    [Seção: Organização Principal]
    ┌─────────────────────────────────────────┐
    │  Organização atual: Rapazes             │
    │  (atribuída automaticamente)            │
    │                                         │
    │  Alterar organização:                   │
    │  [Quórum de Élderes          ▾]         │
    │                                         │
    │  ⚠️ Atenção: a organização é            │
    │  recalculada automaticamente na         │
    │  virada de cada ano. Alterações         │
    │  manuais podem ser sobrescritas.        │
    │                          [Salvar]       │
    └─────────────────────────────────────────┘
        │
    Sistema atualiza organizacao_id do membro
    → Registra no audit_log
    → Notificação de sucesso
```

> Este fluxo só aparece para usuários com permissão `manage_members`.
> Membros sem `aniversario` ou `sexo` preenchido precisam de atribuição manual.

---

## 11. Estados de Tela Globais

Toda tela do sistema deve tratar explicitamente:

| Estado | Comportamento |
|---|---|
| **Carregando** | Skeleton ou spinner centralizado |
| **Vazio** | EmptyState com ícone, mensagem e CTA |
| **Erro de rede** | Alert com mensagem e botão "Tentar novamente" |
| **Sem permissão** | Tela de "Acesso insuficiente" com instrução |
| **Cold start** | Banner sutil após 5s de espera: "Iniciando servidor..." |

---

*EasyWard v0.1*
