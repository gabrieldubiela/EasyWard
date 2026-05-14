# EasyWard — Decisões Técnicas

## Objetivo

Registrar as decisões de arquitetura e tecnologia tomadas durante o projeto, com o raciocínio por trás de cada escolha. Evita repetir discussões no futuro e serve de referência para novos desenvolvedores.

---

## DT-001 — PostgreSQL como banco de dados

**Decisão:** usar PostgreSQL em vez de um banco NoSQL (MongoDB) ou SQLite.

**Contexto:** o sistema gerencia entidades com muitos relacionamentos (membro → família → ala → organização → frequência). Relatórios exigem JOINs e agregações complexas.

**Razão:** PostgreSQL oferece integridade referencial via chaves estrangeiras, suporte nativo a JSONB para campos flexíveis (audit_logs), e é o único banco relacional suportado pelo Supabase Free.

---

## DT-002 — Supabase como hospedagem do banco

**Decisão:** usar Supabase Free em vez de Render Free Postgres.

**Contexto:** ambos são gratuitos, mas o Render Free Postgres exclui o banco automaticamente após 90 dias.

**Razão:** o Supabase apenas pausa o projeto por inatividade (sem perda de dados), oferece 500 MB de armazenamento e painel visual para administração. O banco pode ser reativado com um clique. Ver `docs/backup.md` para a estratégia de backup complementar.

---

## DT-003 — Supabase usado apenas como PostgreSQL puro

**Decisão:** não usar o SDK do Supabase, Auth do Supabase, Storage ou Realtime. Apenas o PostgreSQL via `DATABASE_URL`.

**Contexto:** o Supabase oferece muitos serviços além do banco.

**Razão:** acoplamento mínimo ao provedor garante portabilidade total. Se o Supabase mudar seus termos ou preços, o banco pode ser migrado para qualquer PostgreSQL sem alterar uma linha de código no backend.

---

## DT-004 — GitHub Actions como scheduler de jobs

**Decisão:** usar GitHub Actions com cron para disparar jobs, em vez de APScheduler interno ao FastAPI.

**Contexto:** o Render Free hiberna o backend após 15 minutos de inatividade. Um scheduler interno ao FastAPI simplesmente não dispara se o processo estiver dormindo.

**Razão:** o GitHub Actions é um processo externo que acorda o backend com uma requisição HTTP antes de processar o job. É gratuito, confiável e mantém histórico de execuções no próprio GitHub.

---

## DT-005 — JWT com refresh token em cookie httpOnly

**Decisão:** access token no header Authorization + refresh token em cookie httpOnly, em vez de ambos no localStorage.

**Contexto:** armazenar tokens no localStorage é simples, mas vulnerável a XSS — qualquer script injetado na página pode ler o token.

**Razão:** cookie httpOnly é inacessível ao JavaScript, eliminando o risco de XSS. O atributo `SameSite=Strict` previne CSRF. É a abordagem mais segura para aplicações web.

---

## DT-006 — Permissões granulares em vez de perfis fixos

**Decisão:** cada usuário recebe um conjunto individual de permissões, sem perfis fixos (admin, operacional, etc.).

**Contexto:** a versão inicial dos documentos definia 5 perfis fixos. Durante a discussão, ficou claro que os perfis não representavam bem a realidade — um secretário de registro tem permissões muito diferentes de um líder de organização.

**Razão:** permissões granulares são mais flexíveis e representam melhor a realidade da liderança eclesiástica, onde cada pessoa tem responsabilidades específicas. O custo é uma interface de configuração ligeiramente mais complexa.

---

## DT-007 — Soft delete para membros e usuários

**Decisão:** inativar registros (`ativo = false`) em vez de excluir permanentemente.

**Contexto:** membros podem ser transferidos, retornar à ala ou ter histórico de frequência que precisa ser preservado.

**Razão:** preservar o histórico de frequência, entrevistas e tarefas associadas ao membro. Dados históricos são essenciais para relatórios e acompanhamento pastoral. Exclusão permanente tornaria relatórios históricos inconsistentes.

---

## DT-008 — Hierarquia Estado → Estaca → Ala

**Decisão:** adicionar as entidades `estados` e `estacas` ao modelo, com estados como seed fixo e estacas criadas pelos usuários.

**Contexto:** o documento original tinha apenas `alas`. Durante a discussão, identificou-se que a tela de onboarding precisaria de filtros para localizar a ala correta entre potencialmente centenas.

**Razão:** a hierarquia real da Igreja (estado → estaca → ala) mapeia naturalmente para filtros em cascata na tela de onboarding. Estados são seed fixo (27 UFs) porque são estáveis. Estacas são criadas pelos usuários porque não há lista oficial acessível programaticamente e novas estacas são criadas periodicamente.

---

## DT-009 — Script SQL em MySQL convertido para PostgreSQL

**Decisão:** reescrever completamente o schema SQL original para PostgreSQL.

**Contexto:** o schema original foi escrito com sintaxe MySQL (`AUTO_INCREMENT`, `TINYINT`, `ENGINE=InnoDB`), incompatível com o Supabase (PostgreSQL).

**Razão:** compatibilidade com o banco de dados escolhido. Aproveitou-se a reescrita para adicionar melhorias: enums PostgreSQL, triggers de `updated_at`, timestamps em todas as tabelas, e tabelas ausentes (`refresh_tokens`, `audit_logs`, `job_execution_logs`, `system_config`).

---

## DT-010 — `reuniao_assuntos_estaca` como coluna, não tabela

**Decisão:** mover `tem_assuntos_estaca` para a tabela `reunioes_sacramentais` como coluna booleana, em vez de manter uma tabela separada.

**Contexto:** o schema original tinha uma tabela `reuniao_assuntos_estaca` com cardinalidade 1:1 com a reunião, contendo apenas uma flag booleana.

**Razão:** uma tabela com cardinalidade 1:1 e um único campo booleano adiciona complexidade sem benefício. Uma coluna na tabela principal é mais simples, mais eficiente e semanticamente mais clara.

---

## DT-011 — `tarefas_bispado.responsavel_id` referencia `usuarios`

**Decisão:** o responsável por uma tarefa é um usuário do sistema, não um membro.

**Contexto:** o schema original referenciava `membros.id`. Mas tarefas são acompanhadas via sistema — faz mais sentido atribuir a quem tem acesso ao sistema.

**Razão:** um membro sem conta no sistema não pode ser notificado nem acompanhar suas tarefas. Referenciar `usuarios` garante que o responsável sempre tenha acesso ao sistema.

---

## DT-012 — Google Drive como destino de backups

**Decisão:** usar Google Drive via rclone para armazenar os backups, em vez de GitHub Releases ou Backblaze B2.

**Contexto:** todas as opções são gratuitas para o volume esperado.

**Razão:** Google Drive oferece 15 GB gratuitos, interface visual familiar para o administrador não-técnico, e integra bem com GitHub Actions via rclone. GitHub Releases não foi projetado para armazenamento de backups. Backblaze B2 é tecnicamente superior mas menos acessível.

---

## DT-013 — UptimeRobot para anti-cold start

**Decisão:** usar UptimeRobot para pingar o backend a cada 5 minutos, em vez de um cron job interno ou GitHub Actions dedicado.

**Contexto:** o Render Free hiberna após 15 minutos de inatividade. Várias abordagens foram consideradas.

**Razão:** o UptimeRobot é gratuito, não consome minutos do GitHub Actions, funciona 24/7 independente do repositório, e tem a vantagem adicional de monitorar a disponibilidade e alertar por e-mail em caso de falha.

---

## DT-014 — Resend para e-mails transacionais

**Decisão:** usar Resend em vez de SendGrid, Mailgun ou SMTP próprio.

**Contexto:** o sistema precisa enviar e-mails de notificação e relatórios.

**Razão:** Resend oferece 3.000 e-mails/mês no plano gratuito sem cartão de crédito, SDK Python simples, e boa reputação de entrega. SendGrid e Mailgun têm limites menores ou exigem cartão para o plano gratuito.

---

## DT-015 — React + Vite em vez de Next.js

**Decisão:** usar React com Vite (SPA) em vez de Next.js (SSR/SSG).

**Contexto:** o frontend poderia ser construído com Next.js para aproveitar SSR.

**Razão:** o EasyWard é um sistema de gestão interno, não um site público — SSR e SEO não são requisitos. Vite é mais simples de configurar, mais rápido no desenvolvimento local e se integra naturalmente com o Vite PWA plugin. A Vercel hospeda SPAs sem nenhuma configuração especial.

---

## DT-016 — Zustand em vez de Redux

**Decisão:** usar Zustand para estado global em vez de Redux ou Context API.

**Contexto:** o frontend precisa gerenciar estado global de sessão e permissões.

**Razão:** Zustand é significativamente mais simples que Redux (sem boilerplate, sem actions/reducers), mais adequado para projetos de médio porte, e tem excelente performance. Context API foi descartada por causar re-renders desnecessários em árvores de componentes grandes.

---

## DT-017 — Monorepo único para backend e frontend

**Decisão:** manter backend e frontend no mesmo repositório GitHub.

**Contexto:** poderiam ser repositórios separados.

**Razão:** facilita a correlação entre mudanças de API e frontend, simplifica a gestão de issues e pull requests, e o GitHub Actions consegue disparar deploys de ambos a partir do mesmo evento de push.

---

## DT-018 — Design inspirado no LCR

**Decisão:** adotar paleta de cores e tipografia inspirada no LCR (Leader and Clerk Resources) da Igreja de Jesus Cristo dos Santos dos Últimos Dias.

**Contexto:** os usuários do EasyWard (bispos, conselheiros, secretários) já utilizam o LCR no dia a dia. Um visual familiar reduz a curva de aprendizado.

**Razão:** reutilizar a linguagem visual conhecida (teal escuro no header, teal médio para links e ações, fundo branco/cinza claro, tipografia Source Sans) cria familiaridade imediata. O EasyWard não replica o LCR — apenas se inspira nele para não criar dissonância visual para o usuário.

---

## DT-019 — Campos adicionais em discursos

**Decisão:** adicionar `orador_externo`, `material_apoio` e `tempo_minutos` à tabela `reuniao_mensagens`.

**Contexto:** o modelo original tinha apenas `membro_id`, `visitante_id`, `tema` e `ordem`. Na prática, líderes precisam registrar: quem fará o discurso (inclusive externos), o material de referência preparado e o tempo alocado para a programação.

**Razão:** esses campos tornam o módulo de ata útil tanto para **planejamento antecipado** (quem vai falar, sobre o quê, por quanto tempo) quanto para **registro posterior** (o que foi efetivamente falado). A constraint de orador garante que ao menos um dos três campos de identificação seja preenchido.

---

*EasyWard v0.1*

## DT-020 — Separação entre organizações e grupos de orçamento

**Decisão:** criar uma entidade `grupos_orcamento` separada de `organizacoes`, com uma tabela de junção `grupos_orcamento_organizacoes`.

**Contexto:** a versão original do modelo usava `organizacoes` diretamente na distribuição orçamentária, com um campo `peso` na própria tabela. Mas surgiu o requisito de que a frequência de Rapazes e Moças deveria ser somada em um único grupo ("Jovens") para fins de distribuição.

**Razão:** manter `organizacoes` como entidade de frequência pura e criar `grupos_orcamento` como entidade de distribuição financeira, com relação N:N entre eles. Isso permite:
- Grupos com uma organização (caso simples: Quórum de Élderes)
- Grupos com múltiplas organizações (caso composto: Jovens = Rapazes + Moças)
- Grupos customizados criados pela ala (ex: uma ala que queira separar jovens adultos)
- O `peso` migra para `grupos_orcamento`, onde semanticamente pertence

## DT-021 — Cálculo de idade por ano para atribuição de organização

**Decisão:** usar `ano_corrente - EXTRACT(YEAR FROM aniversario)` em vez da idade exata com mês e dia.

**Contexto:** a Igreja calcula a faixa etária dos membros pelo ano de nascimento, não pela data exata. Um jovem que completa 12 anos em dezembro já participa da organização de jovens desde 1º de janeiro daquele ano.

**Razão:** replicar fielmente a regra oficial da Igreja, que é o sistema de referência dos usuários (líderes e secretários). Usar a data exata causaria confusão: o sistema estaria em conflito com o que o líder observa na prática.

## DT-022 — Job anual separado do job mensal

**Decisão:** criar um job anual (1º de janeiro) para recalcular as organizações de todos os membros, em vez de fazer isso no job mensal.

**Contexto:** o recálculo de organizações só é relevante na virada de ano, quando os membros mudam de faixa etária.

**Razão:** executar o recálculo mensalmente seria ineficiente e poderia causar mudanças de organização no meio do ano (o que não é o comportamento esperado). O job anual é disparado no mesmo dia do job mensal de janeiro, mas antes dele, garantindo que os relatórios de janeiro já reflitam as organizações corretas do novo ano.
