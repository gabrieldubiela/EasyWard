# EasyWard — Permissões

## 1. Modelo de Permissões

O sistema utiliza **permissões granulares por função**, sem perfis fixos. Cada usuário recebe um conjunto individual de permissões, independente de perfil.

Princípios:
- Menor privilégio — usuário começa sem nenhuma permissão
- Segregação de responsabilidade — permissões de visualização e edição são separadas
- Restrição por ala — usuário só acessa dados da própria ala
- Validação no backend — o frontend oculta elementos, mas a segurança real é validada no servidor

---

## 2. Fluxo de Atribuição

- **Primeiro usuário da ala:** recebe todas as permissões automaticamente no onboarding
- **Demais usuários:** criados sem nenhuma permissão; recebem permissões de outro usuário autorizado
- A permissão `manage_user_permissions` só pode ser revogada se outro usuário da mesma ala também a possuir, e exige aprovação ativa desse usuário

---

## 3. Lista de Permissões

### 3.1 Usuários e Acesso
| Código | Descrição |
|---|---|
| `view_users` | Visualizar usuários da ala |
| `manage_users` | Criar, editar e inativar usuários |
| `manage_user_permissions` | Atribuir e revogar permissões de outros usuários |

### 3.2 Dados da Ala
| Código | Descrição |
|---|---|
| `edit_ward` | Editar dados da própria ala (nome e informações básicas) |

### 3.3 Estrutura da Ala
| Código | Descrição |
|---|---|
| `view_organizations` | Visualizar organizações |
| `manage_local_organizations` | Criar e editar organizações locais |
| `view_callings` | Visualizar chamados |
| `manage_local_callings` | Criar e editar chamados locais |
| `deactivate_callings` | Inativar chamados dentro da ala |
| `view_cleaning_groups` | Visualizar grupos de limpeza |
| `manage_cleaning_groups` | Criar e editar grupos de limpeza |

### 3.4 Membros
| Código | Descrição |
|---|---|
| `view_members` | Visualizar membros |
| `manage_members` | Criar e editar membros |
| `deactivate_members` | Inativar membros (soft delete) |
| `view_families` | Visualizar famílias |
| `manage_families` | Criar e editar famílias |
| `view_visitors` | Visualizar visitantes |
| `manage_visitors` | Criar e editar visitantes |

### 3.5 Reunião Sacramental
| Código | Descrição |
|---|---|
| `view_sacrament_meeting` | Visualizar ata da reunião sacramental |
| `manage_sacrament_meeting` | Criar e editar ata da reunião sacramental |
| `view_talks` | Visualizar discursos e mensagens |
| `manage_talks` | Registrar e editar discursos e mensagens |
| `view_attendance` | Visualizar frequência |
| `register_attendance` | Lançar frequência |

### 3.6 Reunião de Bispado
| Código | Descrição |
|---|---|
| `view_bishopric_meeting` | Visualizar ata de reunião de bispado |
| `manage_bishopric_meeting` | Criar e editar ata de reunião de bispado |

### 3.7 Reunião de Conselho da Ala
| Código | Descrição |
|---|---|
| `view_ward_council` | Visualizar ata de reunião de conselho da ala |
| `manage_ward_council` | Criar e editar ata de reunião de conselho da ala |

### 3.8 Entrevistas
| Código | Descrição |
|---|---|
| `view_interviews` | Visualizar entrevistas |
| `manage_interviews` | Criar e editar entrevistas |

### 3.9 Tarefas do Bispado
| Código | Descrição |
|---|---|
| `view_tasks` | Visualizar tarefas |
| `manage_tasks` | Criar e editar tarefas |
| `complete_tasks` | Marcar tarefas como concluídas |

### 3.10 Limpeza
| Código | Descrição |
|---|---|
| `view_cleaning` | Visualizar escala de limpeza |
| `manage_cleaning` | Criar e editar escala de limpeza |

### 3.11 Orçamento
| Código | Descrição |
|---|---|
| `view_budget` | Visualizar orçamento trimestral e distribuição por grupos |
| `manage_budget` | Criar e editar orçamento trimestral, grupos de orçamento e distribuições |

> `manage_budget` cobre tanto o orçamento trimestral quanto a gestão de grupos de orçamento (criar grupos locais, editar peso, definir organizações do grupo).

### 3.12 Relatórios
| Código | Descrição |
|---|---|
| `view_weekly_report` | Visualizar relatório semanal |
| `view_monthly_report` | Visualizar relatório mensal |
| `view_quarterly_report` | Visualizar relatório trimestral |
| `generate_reports` | Gerar relatórios manualmente |

### 3.13 Hinos
| Código | Descrição |
|---|---|
| `view_hymns` | Visualizar hinos |
| `manage_hymns` | Adicionar e editar hinos locais |

### 3.14 Automações
| Código | Descrição |
|---|---|
| `view_jobs` | Visualizar histórico de execução de jobs |
| `run_jobs` | Disparar jobs manualmente |

---

## 4. Total de Permissões

**42 permissões** no total. Cada usuário pode ter qualquer combinação delas.

---

## 5. Implementação no Backend

Cada requisição protegida deve verificar, nesta ordem:

1. Token JWT válido (autenticação)
2. Usuário ativo (`ativo = true`)
3. Usuário pertence à ala do recurso solicitado
4. Usuário possui a permissão específica para a operação

A tabela `user_permissions` armazena as permissões de cada usuário como um conjunto de registros (`user_id`, `permission_code`).

---

## 6. Implementação no Frontend

O frontend recebe a lista de permissões do usuário no login e pode:
- Ocultar menus e botões não autorizados
- Desabilitar campos de edição
- Exibir mensagem de acesso insuficiente

O frontend não substitui a validação do backend.

---

## 7. Proteção da Permissão Crítica

A permissão `manage_user_permissions` tem proteção especial:

1. Ao tentar revogar essa permissão de um usuário, o sistema verifica se há outro usuário na ala com a mesma permissão
2. Se não houver → operação bloqueada com mensagem de erro
3. Se houver → o sistema cria uma solicitação de aprovação
4. O outro usuário deve aprovar ativamente a revogação
5. Somente após a aprovação a permissão é revogada

---

## 8. Manutenção

Esta lista deve ser atualizada sempre que:
- Uma nova funcionalidade for adicionada ao sistema
- Uma permissão for renomeada ou removida
- O fluxo de autorização for alterado

---

*EasyWard v0.1*
