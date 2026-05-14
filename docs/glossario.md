# EasyWard — Glossário

## Objetivo

Este glossário define os termos eclesiásticos e organizacionais usados no EasyWard. Destina-se a desenvolvedores sem familiaridade com a estrutura da Igreja de Jesus Cristo dos Santos dos Últimos Dias (SUD).

---

## Termos Eclesiásticos

### Ala
Unidade organizacional local da Igreja, equivalente a uma paróquia. Reúne os membros de uma região geográfica específica. Cada ala é presidida por um bispo. No sistema, é a entidade central — todos os dados pertencem a uma ala.

### Bispado
Grupo de liderança de uma ala, composto pelo bispo e seus dois conselheiros. O bispado conduz a administração pastoral da ala. No sistema, "bispado" é usado para designar tarefas e reuniões associadas a esse grupo de liderança.

### Estaca
Unidade organizacional acima das alas. Uma estaca agrupa várias alas de uma região. É presidida por um presidente de estaca. No sistema, serve como agrupamento geográfico entre estado e ala.

### Ramo
Unidade menor que uma ala, geralmente em regiões com poucos membros. Estrutura similar à ala, mas com liderança simplificada. O EasyWard não gerencia ramos na versão inicial.

### Distrito
Equivalente à estaca para regiões com menos membros. Agrupa ramos. Não está no escopo do sistema.

### Bispo
Líder principal da ala. Conduz as reuniões, realiza entrevistas pastorais e supervisiona as organizações auxiliares. No sistema, é representado como um membro com o chamado de "Bispo".

### Conselheiro
Membro do bispado que auxilia o bispo. Cada bispo tem dois conselheiros. No sistema, representados como membros com o chamado de "Conselheiro".

### Secretário Executivo
Membro do bispado responsável pela agenda e organização administrativa. Gerencia reuniões, tarefas e comunicações do bispado.

### Secretário de Registro (Secretário da Ala)
Responsável pelos registros oficiais dos membros: frequência, chamados, recomendações e relatórios. É o principal usuário administrativo do sistema.

### Chamado
Atribuição de serviço voluntário dada a um membro da ala. Exemplos: professor, líder de organização, pianista, pregador. Chamados podem ser locais (específicos de uma ala) ou globais (existem em qualquer ala).

### Recomendação do Templo
Documento que certifica a elegibilidade de um membro para entrar no templo. Possui prazo de validade (geralmente 2 anos). O sistema rastreia o mês de vencimento (`mes_recomendacao`) e identifica membros com recomendação próxima do vencimento.

### Organização Auxiliar
Subdivisão da ala com propósito específico. No sistema, se dividem em dois tipos:

**Organizações principais** (frequência — todo membro pertence a uma):
- **Quórum de Élderes** — homens com 18 anos ou mais (calculado pelo ano)
- **Sociedade de Socorro** — mulheres com 18 anos ou mais (calculado pelo ano)
- **Rapazes** — jovens do sexo masculino de 12 a 17 anos (calculado pelo ano)
- **Moças** — jovens do sexo feminino de 12 a 17 anos (calculado pelo ano)
- **Primária** — crianças de 0 a 11 anos (qualquer sexo, calculado pelo ano)

**Organizações auxiliares** (apenas para chamados — sem contagem de frequência):
- Missionários de Ala, Templo e História da Família, Escola Dominical, Bispado, Jovens Adultos Solteiros, Bem-estar e Autossuficiência, Instalações, Música

No sistema, as organizações se dividem em dois tipos:
- **Principais** (frequência): Quórum de Élderes, Sociedade de Socorro, Rapazes, Moças e Primária. Todo membro pertence a exatamente uma.
- **Auxiliares** (chamados): Missionários de Ala, Templo e História da Família, Escola Dominical, Bispado, Jovens Adultos Solteiros, Bem-estar e Autossuficiência, Instalações e Música. Existem apenas para fins de chamado.

A frequência é consolidada pelas organizações **principais**. Para fins de distribuição orçamentária, as organizações podem ser agrupadas em **grupos de orçamento** (ex: "Jovens" = Rapazes + Moças).

### Reunião Sacramental
Reunião semanal principal da ala, geralmente aos domingos. Inclui a ordenança da Santa Ceia (sacramento), discursos de membros, músicas e anúncios. É a reunião cujos dados são mais detalhados no sistema.

### Reunião de Bispado
Reunião periódica do bispo com seus conselheiros e o secretário executivo. Pauta assuntos administrativos e pastorais. O sistema registra data, participantes, assuntos e designações.

### Reunião de Conselho da Ala
Reunião mais ampla que inclui líderes das organizações auxiliares. Trata de assuntos que envolvem a ala como um todo.

### Frequência
Registro de presença na reunião sacramental. O sistema consolida a frequência por organização e identifica membros com ausência prolongada.

### Ausência Prolongada
Membro que não comparece à reunião sacramental por 2 ou 3 semanas consecutivas (configurável). O job semanal identifica esses membros para acompanhamento pastoral.

### Entrevista Pastoral
Conversa privada entre o bispo (ou líder autorizado) e um membro, para aconselhamento espiritual, renovação de recomendação, ou marcos como batismo e ordenação.

### Tipos de Entrevista
| Código | Descrição |
|---|---|
| `sacerdocio_14` | Ordenação ao sacerdócio — jovem de 14 anos |
| `sacerdocio_16` | Ordenação ao sacerdócio — jovem de 16 anos |
| `jovem_12` | Entrevista de ingresso à Primária avançada / Moças e Sacerdócio |
| `batismo` | Entrevista pré-batismo |
| `jovem_18` | Entrevista de transição para adultos |
| `renovacao` | Renovação da recomendação do templo |

### Cargo
Posição no sacerdócio ou organização. Exemplos no sacerdócio masculino: Diácono, Mestre, Padre, Élder, Sumo Sacerdote. Cargo é diferente de chamado: cargo é permanente, chamado é temporário.

### Pregador / Orador
Membro designado para discursar durante a reunião sacramental. O sistema registra quem pregou, o tema e a data.

### Hino / Hino Sacramental
Música cantada durante a reunião. O hino sacramental é específico: acompanha a ordenança da Santa Ceia. O sistema usa o hinário oficial como seed e permite hinos adicionais locais.

### Sacramento (Santa Ceia)
Ordenança semanal realizada durante a reunião sacramental, na qual pão e água são abençoados e distribuídos aos membros.

### Escala de Limpeza
Sistema de rotação de grupos de membros responsáveis pela limpeza do prédio da ala em determinadas semanas.

### Orçamento Trimestral
Verba recebida pela ala a cada trimestre para distribuição entre os **grupos de orçamento**. Cada grupo tem um peso e uma frequência média calculada a partir das organizações principais que o compõem. A distribuição considera peso e frequência de cada grupo. Exemplo: o grupo "Jovens" combina a frequência de Rapazes e Moças para chegar em um valor único distribuído a esses jovens.

### Peso da Organização
Fator numérico que representa a importância relativa de uma organização no cálculo de distribuição orçamentária. Organizações com mais atividades ou membros tendem a ter peso maior.

---

## Termos Técnicos do Sistema

### Soft Delete
Estratégia de exclusão lógica. Ao "excluir" um membro ou usuário, o registro não é removido do banco — apenas o campo `ativo` é definido como `false`. O histórico de frequência e outros dados permanecem preservados.

### Seed
Dados iniciais inseridos automaticamente no banco ao criar uma ala: hinos, organizações, chamados e tipos padrão. Seeds globais (`origem = 'global'`) não podem ser editados pelos usuários.

### Job
Rotina automática executada periodicamente (semanal, mensal, trimestral). Os jobs são disparados via GitHub Actions e processam dados para gerar relatórios, identificar pendências e enviar notificações.

### Idempotência
Propriedade de um job que garante que executá-lo múltiplas vezes produz o mesmo resultado que executá-lo uma vez. Evita duplicação de dados em caso de reexecução.

### Cold Start
Atraso na primeira resposta do backend após um período de inatividade, causado pela hibernação do servidor no Render Free. Pode levar até 60 segundos. O UptimeRobot pinga o backend a cada 5 minutos para evitar esse comportamento.

### Permissão Granular
Modelo de controle de acesso onde cada funcionalidade tem uma permissão específica (`manage_members`, `register_attendance`, etc.), sem perfis fixos. Cada usuário recebe um conjunto individual de permissões.

### Refresh Token
Token de longa duração (7 dias) armazenado em cookie httpOnly, usado para renovar o access token (30 minutos) sem exigir novo login.

### PWA (Progressive Web App)
Aplicação web que pode ser instalada no celular como se fosse um app nativo, com ícone na tela inicial e suporte a funcionamento offline básico.

### Audit Log
Registro imutável de operações críticas realizadas no sistema (quem fez o quê, quando e em qual registro). Armazenado na tabela `audit_logs`.

---

*EasyWard v0.1*
