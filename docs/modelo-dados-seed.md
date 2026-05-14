# EasyWard — Seeds por Ala

## 1. Objetivo

Definir todos os dados inseridos automaticamente ao criar uma nova ala no sistema. Esses dados são o ponto de partida de cada ala e garantem que o sistema já esteja funcional desde o primeiro acesso.

---

## 2. Quando os Seeds São Inseridos

Os seeds são inseridos na seguinte ordem durante o onboarding de criação de nova ala:

```
1. Criar estaca (se não existir)
2. Criar ala
3. Inserir organizações padrão da ala       ← este documento
4. Inserir chamados padrão locais da ala    ← este documento
5. Criar membro (primeiro usuário)
6. Criar usuário com todas as permissões
```

Os seeds globais (estados, tipos de organização, tipos de hino, tipos de entrevista, chamados globais e hinos do hinário) já existem no banco antes de qualquer ala ser criada — são inseridos uma única vez pelo `schema.sql`.

---

## 3. Organizações Padrão por Ala

Ao criar uma ala, as seguintes organizações são criadas automaticamente com `origem = 'global'` (não editáveis, sempre visíveis):

Ver arquivo completo: [`docs/seeds-organizacoes.sql`](seeds-organizacoes.sql)

### Organizações Principais (frequência)

| Organização | Sexo | Faixa etária (por ano) | Tipo |
|---|---|---|---|
| Quórum de Élderes | Masculino | ≥ 18 anos | principal |
| Sociedade de Socorro | Feminino | ≥ 18 anos | principal |
| Rapazes | Masculino | 12 a 17 anos | principal |
| Moças | Feminino | 12 a 17 anos | principal |
| Primária | Qualquer | 0 a 11 anos | principal |

> Todo membro pertence a exatamente uma organização principal. A atribuição é automática por sexo e faixa etária calculada pelo **ano de nascimento** (não pela data exata). Ver RN-034 e RN-035.

### Organizações Auxiliares (chamados)

| Organização | Tipo |
|---|---|
| Missionários de Ala | auxiliar |
| Templo e História da Família | auxiliar |
| Escola Dominical | auxiliar |
| Bispado | auxiliar |
| Jovens Adultos Solteiros | auxiliar |
| Bem-estar e Autossuficiência | auxiliar |
| Instalações | auxiliar |
| Música | auxiliar |

> Organizações auxiliares existem apenas para fins de chamado. Não têm contagem de frequência nem restrição de faixa etária.

---

## 4. Chamados Padrão por Ala

Ver arquivo completo: [`docs/seeds-chamados.sql`](seeds-chamados.sql)

São **113 chamados padrão** inseridos automaticamente ao criar cada ala, organizados por grupo:

| Grupo | Chamados |
|---|---|
| Bispado | 8 |
| Quórum de Élderes | 13 |
| Sociedade de Socorro | 10 |
| Quórum de Sacerdotes | 5 |
| Quórum de Mestres | 6 |
| Quórum de Diáconos | 6 |
| Sacerdócio Aarônico — Adicionais | 6 |
| Moças | 13 |
| Escola Dominical | 8 |
| Primária | 12 |
| Missionários de Ala | 3 |
| Templo e História da Família | 4 |
| Jovens Adultos Solteiros | 5 |
| Bem-estar e Autossuficiência | 4 |
| Instalações | 2 |
| Música | 9 |
| Outros (História, FSY, Liahona, Tecnologia, Recepção) | 8 |
| **Total** | **113** |

Todos com `origem = 'global'` (seeds do sistema) e `tipo = 'local'` (pertencem à ala).
O usuário pode criar chamados adicionais (`origem = 'local'`) via interface.

---

## 5. Grupos de Orçamento Padrão por Ala

Ver arquivo completo: [`docs/seeds-organizacoes.sql`](seeds-organizacoes.sql) — seções 3 e 4.

| Grupo | Organizações incluídas | Peso inicial |
|---|---|---|
| Quórum de Élderes | Quórum de Élderes | 3.0 |
| Sociedade de Socorro | Sociedade de Socorro | 3.0 |
| **Jovens** | **Rapazes + Moças (frequências somadas)** | **2.0** |
| Primária | Primária | 2.0 |

> O peso dos grupos globais pode ser ajustado pela ala via interface. A ala também pode criar grupos customizados (`origem = 'local'`) combinando qualquer subconjunto das organizações principais.

---

## 6. Configurações Padrão por Ala

```sql
INSERT INTO system_config (ala_id, key, value)
VALUES
  (:ala_id, 'absence_threshold_weeks', '2');
  -- 2 semanas de ausência consecutiva para figurar no relatório semanal
```

---

## 7. Hinos por Ala

Os hinos globais (hinário completo com `ala_id = NULL`) **não são copiados** para cada ala — eles são consultados diretamente pela query de hinos disponíveis:

```sql
-- Query para listar hinos disponíveis para uma ala
SELECT * FROM hinos
WHERE ala_id IS NULL        -- hinos globais
   OR ala_id = :ala_id      -- hinos locais da ala
ORDER BY numero NULLS LAST, nome;
```

Hinos locais (adicionados pela ala) são inseridos com `ala_id = :ala_id` e `origem = 'local'`.

---

## 8. Implementação no Backend

O processo de seed por ala deve ser encapsulado em um serviço dedicado:

```python
# app/modules/geo/ward_seed_service.py

async def seed_new_ward(ward_id: int, db: AsyncSession) -> None:
    """
    Executa todos os seeds necessários ao criar uma nova ala.
    Chamado pelo auth service durante o onboarding.
    """
    await seed_organizations(ward_id, db)
    await seed_callings(ward_id, db)
    await seed_config(ward_id, db)
    await db.flush()
```

O serviço deve ser **idempotente**: se chamado duas vezes para a mesma ala (ex: falha parcial), não deve duplicar os registros. Usar `INSERT ... ON CONFLICT DO NOTHING` para garantir isso:

```sql
INSERT INTO organizacoes (ala_id, tipo_organizacao_id, nome, peso, origem, ativo)
VALUES (...)
ON CONFLICT (ala_id, nome) DO NOTHING;
```

---

## 9. Manutenção dos Seeds Globais

Quando um novo chamado ou organização padrão precisar ser adicionado ao sistema (para todas as alas existentes e futuras):

1. Adicionar ao script de seed deste documento
2. Criar uma migration Alembic que insere o novo item em todas as alas existentes:

```sql
-- Migração: adicionar novo chamado padrão a todas as alas existentes
INSERT INTO chamados (ala_id, nome, tipo, origem, ativo)
SELECT id, 'Novo Chamado', 'local', 'global', true
FROM alas
ON CONFLICT (ala_id, nome) DO NOTHING;
```

---

*EasyWard v0.1*
