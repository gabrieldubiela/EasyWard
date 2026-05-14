-- =========================================================
-- EASYWARD — SEEDS DE ORGANIZAÇÕES POR ALA
-- =========================================================
--
-- Este script é executado pelo backend (ward_seed_service.py)
-- automaticamente ao criar uma nova ala.
-- Substituir :ala_id pelo ID real da ala criada.
--
-- Estrutura:
--   1. Organizações principais (frequência)
--   2. Organizações auxiliares (chamados)
--   3. Grupos de orçamento padrão
--   4. Vínculos grupo ↔ organização
-- =========================================================


-- =========================================================
-- 1. ORGANIZAÇÕES PRINCIPAIS
-- Todo membro pertence a exatamente uma delas.
-- A frequência é contabilizada por essas organizações.
-- A atribuição é automática por sexo e faixa etária (por ano).
--
-- Regra de idade: usa-se o ANO de nascimento, não a data exata.
-- Ex: quem completa 12 anos em dezembro/2026 já é dos Rapazes
-- desde 01/01/2026. Cálculo: currentYear - EXTRACT(YEAR FROM aniversario)
-- =========================================================

INSERT INTO organizacoes (
  ala_id, tipo_organizacao_id, nome, origem, ativo,
  sexo_alvo, idade_min, idade_max
)
SELECT
  :ala_id,
  (SELECT id FROM tipos_organizacao WHERE nome = 'principal'),
  org.nome,
  'global',
  true,
  org.sexo_alvo,
  org.idade_min,
  org.idade_max
FROM (VALUES
  --  nome                    sexo_alvo    idade_min  idade_max
  ('Quórum de Élderes',      'masculino',  18,        NULL),
  ('Sociedade de Socorro',   'feminino',   18,        NULL),
  ('Rapazes',                'masculino',  12,        17),
  ('Moças',                  'feminino',   12,        17),
  ('Primária',               NULL,         0,         11)
) AS org(nome, sexo_alvo, idade_min, idade_max)
ON CONFLICT (ala_id, nome) DO NOTHING;


-- =========================================================
-- 2. ORGANIZAÇÕES AUXILIARES
-- Existem apenas para fins de chamado.
-- Não participam da contagem de frequência.
-- Não têm restrição de sexo ou faixa etária.
-- =========================================================

INSERT INTO organizacoes (
  ala_id, tipo_organizacao_id, nome, origem, ativo,
  sexo_alvo, idade_min, idade_max
)
SELECT
  :ala_id,
  (SELECT id FROM tipos_organizacao WHERE nome = 'auxiliar'),
  org.nome,
  'global',
  true,
  NULL, NULL, NULL
FROM (VALUES
  ('Missionários de Ala'),
  ('Templo e História da Família'),
  ('Escola Dominical'),
  ('Bispado'),
  ('Jovens Adultos Solteiros'),
  ('Bem-estar e Autossuficiência'),
  ('Instalações'),
  ('Música')
) AS org(nome)
ON CONFLICT (ala_id, nome) DO NOTHING;


-- =========================================================
-- 3. GRUPOS DE ORÇAMENTO PADRÃO
-- Agrupam organizações principais para fins de distribuição.
-- O grupo "Jovens" combina Rapazes + Moças.
-- Usuários podem criar grupos customizados por ala.
-- =========================================================

INSERT INTO grupos_orcamento (ala_id, nome, peso, ativo, origem)
VALUES
  (:ala_id, 'Quórum de Élderes',    3.0, true, 'global'),
  (:ala_id, 'Sociedade de Socorro', 3.0, true, 'global'),
  (:ala_id, 'Jovens',               2.0, true, 'global'),  -- Rapazes + Moças combinados
  (:ala_id, 'Primária',             2.0, true, 'global')
ON CONFLICT (ala_id, nome) DO NOTHING;


-- =========================================================
-- 4. VÍNCULOS GRUPO ↔ ORGANIZAÇÃO
-- Define quais organizações compõem cada grupo de orçamento.
-- Rapazes e Moças somam suas frequências no grupo "Jovens".
-- =========================================================

INSERT INTO grupos_orcamento_organizacoes (grupo_id, organizacao_id)
SELECT g.id, o.id
FROM grupos_orcamento g, organizacoes o
WHERE g.ala_id = :ala_id
  AND o.ala_id = :ala_id
  AND (
    (g.nome = 'Quórum de Élderes'    AND o.nome = 'Quórum de Élderes')    OR
    (g.nome = 'Sociedade de Socorro' AND o.nome = 'Sociedade de Socorro')  OR
    (g.nome = 'Jovens'               AND o.nome IN ('Rapazes', 'Moças'))   OR
    (g.nome = 'Primária'             AND o.nome = 'Primária')
  )
ON CONFLICT (grupo_id, organizacao_id) DO NOTHING;


-- =========================================================
-- RESUMO DOS SEEDS POR ALA
-- =========================================================
--
-- Organizações principais (5):
--   Quórum de Élderes  → homens com idade_min 18 (por ano)
--   Sociedade de Socorro → mulheres com idade_min 18 (por ano)
--   Rapazes            → homens 12–17 anos (por ano)
--   Moças              → mulheres 12–17 anos (por ano)
--   Primária           → todos 0–11 anos (por ano)
--
-- Organizações auxiliares (8):
--   Missionários de Ala, Templo e História da Família,
--   Escola Dominical, Bispado, Jovens Adultos Solteiros,
--   Bem-estar e Autossuficiência, Instalações, Música
--
-- Grupos de orçamento padrão (4):
--   Quórum de Élderes  → [Quórum de Élderes]
--   Sociedade de Socorro → [Sociedade de Socorro]
--   Jovens             → [Rapazes + Moças]   ← frequências somadas
--   Primária           → [Primária]
-- =========================================================
