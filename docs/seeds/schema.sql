-- =========================================================
-- EASYWARD — SCHEMA POSTGRESQL
-- Compatível com Supabase Free (PostgreSQL)
-- =========================================================

-- =========================================================
-- TIPOS ENUM
-- =========================================================

CREATE TYPE sexo_tipo AS ENUM ('masculino', 'feminino', 'outro');
CREATE TYPE origem_tipo AS ENUM ('global', 'local');
CREATE TYPE chamado_tipo AS ENUM ('global', 'local');
CREATE TYPE tipo_reuniao AS ENUM ('bispado', 'conselho');
CREATE TYPE tipo_item_mensagem AS ENUM ('mensagem', 'testemunho', 'hino_intermediario');
CREATE TYPE status_entrevista AS ENUM ('pendente', 'realizada', 'cancelada');
CREATE TYPE status_job AS ENUM ('success', 'failure');
CREATE TYPE tipo_assunto_ala AS ENUM ('batismo', 'ordenacao', 'liberacao', 'outro');

-- =========================================================
-- FUNÇÃO UTILITÁRIA: atualizar updated_at automaticamente
-- =========================================================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Macro para criar o trigger em cada tabela:
-- CREATE TRIGGER trg_updated_at BEFORE UPDATE ON {tabela}
--   FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- HIERARQUIA GEOGRÁFICA
-- =========================================================

CREATE TABLE estados (
  id          SERIAL PRIMARY KEY,
  nome        VARCHAR(80)  NOT NULL,
  sigla       CHAR(2)      NOT NULL,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT uk_estados_sigla UNIQUE (sigla),
  CONSTRAINT uk_estados_nome  UNIQUE (nome)
);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON estados
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE estacas (
  id          SERIAL PRIMARY KEY,
  estado_id   INT          NOT NULL,
  nome        VARCHAR(120) NOT NULL,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_estacas_estado  FOREIGN KEY (estado_id) REFERENCES estados(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT uk_estacas_estado_nome UNIQUE (estado_id, nome)
);
CREATE INDEX idx_estacas_estado ON estacas(estado_id);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON estacas
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE alas (
  id          SERIAL PRIMARY KEY,
  estaca_id   INT          NOT NULL,
  nome        VARCHAR(120) NOT NULL,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_alas_estaca FOREIGN KEY (estaca_id) REFERENCES estacas(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT uk_alas_estaca_nome UNIQUE (estaca_id, nome)
);
CREATE INDEX idx_alas_estaca ON alas(estaca_id);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON alas
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- CADASTRO BASE
-- =========================================================

CREATE TABLE familias (
  id           SERIAL PRIMARY KEY,
  ala_id       INT          NOT NULL,
  nome_familia VARCHAR(120) NOT NULL,
  ativo        BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_familias_ala FOREIGN KEY (ala_id) REFERENCES alas(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT uk_familias_ala_nome UNIQUE (ala_id, nome_familia)
);
CREATE INDEX idx_familias_ala ON familias(ala_id);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON familias
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE grupos_limpeza (
  id         SERIAL PRIMARY KEY,
  ala_id     INT         NOT NULL,
  nome       VARCHAR(80) NOT NULL,
  ordem      INT         NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_grupos_limpeza_ala FOREIGN KEY (ala_id) REFERENCES alas(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT uk_grupos_limpeza_ala_nome UNIQUE (ala_id, nome)
);
CREATE INDEX idx_grupos_limpeza_ala ON grupos_limpeza(ala_id);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON grupos_limpeza
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE tipos_organizacao (
  id         SERIAL PRIMARY KEY,
  nome       VARCHAR(50) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uk_tipos_organizacao_nome UNIQUE (nome)
);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON tipos_organizacao
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE organizacoes (
  id                  SERIAL PRIMARY KEY,
  ala_id              INT            NOT NULL,
  tipo_organizacao_id INT            NOT NULL,
  nome                VARCHAR(120)   NOT NULL,
  -- Campos de atribuição automática (apenas organizações principais)
  sexo_alvo           VARCHAR(20)    NULL,         -- 'masculino', 'feminino' ou NULL (ambos)
  idade_min           SMALLINT       NULL,          -- idade mínima (calculada por ano)
  idade_max           SMALLINT       NULL,          -- idade máxima (calculada por ano)
  origem              origem_tipo    NOT NULL DEFAULT 'local',
  ativo               BOOLEAN        NOT NULL DEFAULT TRUE,
  created_at          TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_organizacoes_ala  FOREIGN KEY (ala_id) REFERENCES alas(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_organizacoes_tipo FOREIGN KEY (tipo_organizacao_id) REFERENCES tipos_organizacao(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT uk_organizacoes_ala_nome UNIQUE (ala_id, nome),
  CONSTRAINT chk_organizacoes_sexo CHECK (sexo_alvo IN ('masculino', 'feminino') OR sexo_alvo IS NULL),
  CONSTRAINT chk_organizacoes_idade CHECK (
    (idade_min IS NULL OR idade_max IS NULL OR idade_min <= idade_max)
  )
);
CREATE INDEX idx_organizacoes_ala  ON organizacoes(ala_id);
CREATE INDEX idx_organizacoes_tipo ON organizacoes(tipo_organizacao_id);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON organizacoes
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE chamados (
  id         SERIAL PRIMARY KEY,
  ala_id     INT          NULL,
  nome       VARCHAR(120) NOT NULL,
  tipo       chamado_tipo NOT NULL DEFAULT 'local',
  origem     origem_tipo  NOT NULL DEFAULT 'local',
  ativo      BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_chamados_ala FOREIGN KEY (ala_id) REFERENCES alas(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX idx_chamados_ala  ON chamados(ala_id);
CREATE INDEX idx_chamados_tipo ON chamados(tipo);
CREATE INDEX idx_chamados_nome ON chamados(nome);
-- Unicidade: (ala_id, nome) — NULLs são distintos por padrão no PostgreSQL (chamados globais ok)
CREATE UNIQUE INDEX uk_chamados_ala_nome ON chamados(COALESCE(ala_id, 0), nome);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON chamados
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE membros (
  id                   SERIAL PRIMARY KEY,
  ala_id               INT          NOT NULL,
  familia_id           INT          NULL,
  organizacao_id       INT          NULL,         -- organização principal atual (atribuída automaticamente ou manual)
  grupo_limpeza_id     INT          NULL,
  nome_completo        VARCHAR(150) NOT NULL,
  sexo                 sexo_tipo    NULL,
  cargo                VARCHAR(120) NULL,
  aniversario          DATE         NULL,
  chamado_id           INT          NULL,
  data_inicio_chamado  DATE         NULL,
  apto_trocar_chamado  BOOLEAN      NOT NULL DEFAULT FALSE,
  data_ultimo_discurso DATE         NULL,
  mes_recomendacao     SMALLINT     NULL CHECK (mes_recomendacao BETWEEN 1 AND 12),
  apto_recomendacao    BOOLEAN      NOT NULL DEFAULT FALSE,
  ativo                BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_membros_ala           FOREIGN KEY (ala_id)           REFERENCES alas(id)           ON DELETE CASCADE  ON UPDATE CASCADE,
  CONSTRAINT fk_membros_organizacao   FOREIGN KEY (organizacao_id)   REFERENCES organizacoes(id)   ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_membros_familia       FOREIGN KEY (familia_id)       REFERENCES familias(id)       ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_membros_grupo_limpeza FOREIGN KEY (grupo_limpeza_id) REFERENCES grupos_limpeza(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_membros_chamado       FOREIGN KEY (chamado_id)       REFERENCES chamados(id)       ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE INDEX idx_membros_ala           ON membros(ala_id);
CREATE INDEX idx_membros_organizacao   ON membros(organizacao_id);
CREATE INDEX idx_membros_familia       ON membros(familia_id);
CREATE INDEX idx_membros_grupo_limpeza ON membros(grupo_limpeza_id);
CREATE INDEX idx_membros_chamado       ON membros(chamado_id);
CREATE INDEX idx_membros_ala_nome      ON membros(ala_id, nome_completo);
CREATE INDEX idx_membros_ativo         ON membros(ativo);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON membros
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE visitantes (
  id             SERIAL PRIMARY KEY,
  ala_id         INT          NOT NULL,
  nome_completo  VARCHAR(150) NOT NULL,
  sexo           sexo_tipo    NULL,
  cargo          VARCHAR(120) NULL,
  organizacao_id INT          NULL,
  frequente      BOOLEAN      NOT NULL DEFAULT FALSE,
  created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_visitantes_ala         FOREIGN KEY (ala_id)         REFERENCES alas(id)         ON DELETE CASCADE  ON UPDATE CASCADE,
  CONSTRAINT fk_visitantes_organizacao FOREIGN KEY (organizacao_id) REFERENCES organizacoes(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE INDEX idx_visitantes_ala         ON visitantes(ala_id);
CREATE INDEX idx_visitantes_organizacao ON visitantes(organizacao_id);
CREATE INDEX idx_visitantes_frequente   ON visitantes(frequente);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON visitantes
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- HINOS
-- =========================================================

CREATE TABLE hinos (
  id         SERIAL PRIMARY KEY,
  ala_id     INT          NULL,
  numero     INT          NULL,
  nome       VARCHAR(150) NOT NULL,
  origem     origem_tipo  NOT NULL DEFAULT 'local',
  created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_hinos_ala FOREIGN KEY (ala_id) REFERENCES alas(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE UNIQUE INDEX uk_hinos_numero ON hinos(numero) WHERE numero IS NOT NULL AND ala_id IS NULL;
CREATE INDEX idx_hinos_nome   ON hinos(nome);
CREATE INDEX idx_hinos_ala    ON hinos(ala_id);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON hinos
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE tipos_hino (
  id         SERIAL PRIMARY KEY,
  nome       VARCHAR(50) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uk_tipos_hino_nome UNIQUE (nome)
);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON tipos_hino
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE tipos_cantor (
  id         SERIAL PRIMARY KEY,
  nome       VARCHAR(50) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uk_tipos_cantor_nome UNIQUE (nome)
);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON tipos_cantor
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- USUÁRIOS E AUTENTICAÇÃO
-- =========================================================

CREATE TABLE usuarios (
  id         SERIAL PRIMARY KEY,
  membro_id  INT          NOT NULL,
  ala_id     INT          NOT NULL,
  email      VARCHAR(150) NOT NULL,
  senha      VARCHAR(255) NOT NULL,
  ativo      BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_usuarios_membro FOREIGN KEY (membro_id) REFERENCES membros(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_usuarios_ala    FOREIGN KEY (ala_id)    REFERENCES alas(id)    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT uk_usuarios_email  UNIQUE (email)
);
CREATE INDEX idx_usuarios_ala    ON usuarios(ala_id);
CREATE INDEX idx_usuarios_ativo  ON usuarios(ativo);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON usuarios
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE user_permissions (
  user_id         INT         NOT NULL,
  permission_code VARCHAR(60) NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, permission_code),
  CONSTRAINT fk_user_permissions_user FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX idx_user_permissions_user ON user_permissions(user_id);

CREATE TABLE refresh_tokens (
  id          SERIAL PRIMARY KEY,
  user_id     INT          NOT NULL,
  token_hash  VARCHAR(255) NOT NULL,
  expires_at  TIMESTAMPTZ  NOT NULL,
  revoked     BOOLEAN      NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_refresh_tokens_user FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX idx_refresh_tokens_user    ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_lookup  ON refresh_tokens(user_id, revoked, expires_at);

-- =========================================================
-- REUNIÃO SACRAMENTAL
-- =========================================================

CREATE TABLE reunioes_sacramentais (
  id                   SERIAL PRIMARY KEY,
  ala_id               INT         NOT NULL,
  data                 DATE        NOT NULL,
  preside_id           INT         NULL,
  dirige_id            INT         NULL,
  preludio_id          INT         NULL,
  regente_id           INT         NULL,
  pianista_id          INT         NULL,
  tem_assuntos_estaca  BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_reunioes_ala      FOREIGN KEY (ala_id)      REFERENCES alas(id)    ON DELETE CASCADE  ON UPDATE CASCADE,
  CONSTRAINT fk_reunioes_preside  FOREIGN KEY (preside_id)  REFERENCES membros(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_reunioes_dirige   FOREIGN KEY (dirige_id)   REFERENCES membros(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_reunioes_preludio FOREIGN KEY (preludio_id) REFERENCES membros(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_reunioes_regente  FOREIGN KEY (regente_id)  REFERENCES membros(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_reunioes_pianista FOREIGN KEY (pianista_id) REFERENCES membros(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE INDEX idx_reunioes_ala_data ON reunioes_sacramentais(ala_id, data);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON reunioes_sacramentais
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE reuniao_boas_vindas (
  id          SERIAL PRIMARY KEY,
  reuniao_id  INT         NOT NULL,
  texto       TEXT        NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_boas_vindas_reuniao FOREIGN KEY (reuniao_id) REFERENCES reunioes_sacramentais(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX idx_boas_vindas_reuniao ON reuniao_boas_vindas(reuniao_id);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON reuniao_boas_vindas
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE reuniao_reconhecimentos (
  id          SERIAL PRIMARY KEY,
  reuniao_id  INT          NOT NULL,
  nome        VARCHAR(150) NOT NULL,
  chamado     VARCHAR(120) NULL,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_reconhecimentos_reuniao FOREIGN KEY (reuniao_id) REFERENCES reunioes_sacramentais(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX idx_reconhecimentos_reuniao ON reuniao_reconhecimentos(reuniao_id);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON reuniao_reconhecimentos
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE reuniao_anuncios (
  id          SERIAL PRIMARY KEY,
  reuniao_id  INT         NOT NULL,
  descricao   TEXT        NOT NULL,
  data_texto  VARCHAR(50) NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_anuncios_reuniao FOREIGN KEY (reuniao_id) REFERENCES reunioes_sacramentais(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX idx_anuncios_reuniao ON reuniao_anuncios(reuniao_id);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON reuniao_anuncios
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE reuniao_assuntos_ala (
  id           SERIAL PRIMARY KEY,
  reuniao_id   INT                 NOT NULL,
  tipo_assunto tipo_assunto_ala    NOT NULL,
  prenome      VARCHAR(80)         NULL,
  nome         VARCHAR(150)        NULL,
  chamado      VARCHAR(120)        NULL,
  organizacao  VARCHAR(120)        NULL,
  oficio       VARCHAR(120)        NULL,
  created_at   TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_assuntos_ala_reuniao FOREIGN KEY (reuniao_id) REFERENCES reunioes_sacramentais(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX idx_assuntos_ala_reuniao ON reuniao_assuntos_ala(reuniao_id);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON reuniao_assuntos_ala
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE reuniao_musicas (
  id              SERIAL PRIMARY KEY,
  reuniao_id      INT          NOT NULL,
  tipo_hino_id    INT          NOT NULL,
  hino_id         INT          NULL,
  cantor_tipo_id  INT          NOT NULL,
  cantor_texto    VARCHAR(150) NULL,
  created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_musicas_reuniao     FOREIGN KEY (reuniao_id)     REFERENCES reunioes_sacramentais(id) ON DELETE CASCADE  ON UPDATE CASCADE,
  CONSTRAINT fk_musicas_tipo        FOREIGN KEY (tipo_hino_id)   REFERENCES tipos_hino(id)            ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_musicas_hino        FOREIGN KEY (hino_id)        REFERENCES hinos(id)                 ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_musicas_cantor_tipo FOREIGN KEY (cantor_tipo_id) REFERENCES tipos_cantor(id)          ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_musicas_reuniao ON reuniao_musicas(reuniao_id);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON reuniao_musicas
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE reuniao_mensagens (
  id                      SERIAL PRIMARY KEY,
  reuniao_id              INT                  NOT NULL,
  tipo_item               tipo_item_mensagem   NOT NULL,
  membro_id               INT                  NULL,
  visitante_id            INT                  NULL,
  orador_externo          VARCHAR(150)         NULL,   -- nome quando não é membro nem visitante cadastrado
  tema                    VARCHAR(255)         NULL,   -- tema/título do discurso (ampliado para 255)
  material_apoio          TEXT                 NULL,   -- referências, escrituras, materiais de apoio
  tempo_minutos           SMALLINT             NULL,   -- tempo alocado em minutos
  ordem                   INT                  NULL,   -- posição na programação (1º, 2º, último, etc.)
  hino_id                 INT                  NULL,
  cantor_tipo_id          INT                  NULL,
  cantor_texto            VARCHAR(150)         NULL,
  tem_hino_intermediario  BOOLEAN              NOT NULL DEFAULT FALSE,
  created_at              TIMESTAMPTZ          NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ          NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_mensagens_reuniao      FOREIGN KEY (reuniao_id)     REFERENCES reunioes_sacramentais(id) ON DELETE CASCADE  ON UPDATE CASCADE,
  CONSTRAINT fk_mensagens_membro       FOREIGN KEY (membro_id)      REFERENCES membros(id)               ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_mensagens_visitante    FOREIGN KEY (visitante_id)   REFERENCES visitantes(id)            ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_mensagens_hino         FOREIGN KEY (hino_id)        REFERENCES hinos(id)                 ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_mensagens_cantor_tipo  FOREIGN KEY (cantor_tipo_id) REFERENCES tipos_cantor(id)          ON DELETE SET NULL ON UPDATE CASCADE,
  -- Para discursos: ao menos um dos campos de orador deve ser preenchido
  CONSTRAINT chk_mensagens_orador CHECK (
    tipo_item = 'hino_intermediario'
    OR membro_id IS NOT NULL
    OR visitante_id IS NOT NULL
    OR orador_externo IS NOT NULL
  ),
  -- Tempo deve ser positivo quando informado
  CONSTRAINT chk_mensagens_tempo CHECK (tempo_minutos IS NULL OR tempo_minutos > 0)
);
CREATE INDEX idx_mensagens_reuniao ON reuniao_mensagens(reuniao_id);
CREATE INDEX idx_mensagens_ordem   ON reuniao_mensagens(ordem);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON reuniao_mensagens
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- REUNIÃO DE BISPADO E CONSELHO DA ALA
-- =========================================================

CREATE TABLE reunioes_bispado (
  id           SERIAL PRIMARY KEY,
  ala_id       INT         NOT NULL,
  data         DATE        NOT NULL,
  observacoes  TEXT        NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_reunioes_bispado_ala FOREIGN KEY (ala_id) REFERENCES alas(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX idx_reunioes_bispado_ala ON reunioes_bispado(ala_id, data);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON reunioes_bispado
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE reunioes_conselho_ala (
  id           SERIAL PRIMARY KEY,
  ala_id       INT         NOT NULL,
  data         DATE        NOT NULL,
  observacoes  TEXT        NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_reunioes_conselho_ala FOREIGN KEY (ala_id) REFERENCES alas(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX idx_reunioes_conselho_ala ON reunioes_conselho_ala(ala_id, data);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON reunioes_conselho_ala
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE reuniao_participantes (
  id            SERIAL PRIMARY KEY,
  reuniao_tipo  tipo_reuniao NOT NULL,
  reuniao_id    INT          NOT NULL,
  membro_id     INT          NOT NULL,
  created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_participantes_membro FOREIGN KEY (membro_id) REFERENCES membros(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX idx_participantes_reuniao ON reuniao_participantes(reuniao_tipo, reuniao_id);

CREATE TABLE reuniao_assuntos (
  id            SERIAL PRIMARY KEY,
  reuniao_tipo  tipo_reuniao NOT NULL,
  reuniao_id    INT          NOT NULL,
  descricao     TEXT         NOT NULL,
  created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_assuntos_reuniao ON reuniao_assuntos(reuniao_tipo, reuniao_id);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON reuniao_assuntos
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE reuniao_designacoes (
  id              SERIAL PRIMARY KEY,
  reuniao_tipo    tipo_reuniao NOT NULL,
  reuniao_id      INT          NOT NULL,
  responsavel_id  INT          NOT NULL,
  descricao       TEXT         NOT NULL,
  data_limite     DATE         NULL,
  concluida       BOOLEAN      NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_designacoes_responsavel FOREIGN KEY (responsavel_id) REFERENCES membros(id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_designacoes_reuniao      ON reuniao_designacoes(reuniao_tipo, reuniao_id);
CREATE INDEX idx_designacoes_responsavel  ON reuniao_designacoes(responsavel_id);
CREATE INDEX idx_designacoes_concluida    ON reuniao_designacoes(concluida);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON reuniao_designacoes
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- FREQUÊNCIA
-- =========================================================

CREATE TABLE frequencias (
  id              SERIAL PRIMARY KEY,
  ala_id          INT         NOT NULL,
  reuniao_id      INT         NOT NULL,
  membro_id       INT         NULL,
  visitante_id    INT         NULL,
  nome_externo    VARCHAR(150) NULL,
  organizacao_id  INT         NULL,
  presente        BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_frequencias_ala         FOREIGN KEY (ala_id)         REFERENCES alas(id)                  ON DELETE CASCADE  ON UPDATE CASCADE,
  CONSTRAINT fk_frequencias_reuniao     FOREIGN KEY (reuniao_id)     REFERENCES reunioes_sacramentais(id) ON DELETE CASCADE  ON UPDATE CASCADE,
  CONSTRAINT fk_frequencias_membro      FOREIGN KEY (membro_id)      REFERENCES membros(id)               ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_frequencias_visitante   FOREIGN KEY (visitante_id)   REFERENCES visitantes(id)            ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_frequencias_organizacao FOREIGN KEY (organizacao_id) REFERENCES organizacoes(id)          ON DELETE SET NULL ON UPDATE CASCADE,
  -- Exatamente um dos três campos de pessoa deve ser preenchido
  CONSTRAINT chk_frequencias_pessoa CHECK (
    (membro_id IS NOT NULL)::INT +
    (visitante_id IS NOT NULL)::INT +
    (nome_externo IS NOT NULL)::INT = 1
  )
);
CREATE INDEX idx_frequencias_ala         ON frequencias(ala_id);
CREATE INDEX idx_frequencias_reuniao     ON frequencias(reuniao_id);
CREATE INDEX idx_frequencias_membro      ON frequencias(membro_id);
CREATE INDEX idx_frequencias_organizacao ON frequencias(organizacao_id);
CREATE INDEX idx_frequencias_presente    ON frequencias(presente);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON frequencias
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- ENTREVISTAS
-- =========================================================

CREATE TABLE tipos_entrevista (
  id         SERIAL PRIMARY KEY,
  nome       VARCHAR(80) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uk_tipos_entrevista_nome UNIQUE (nome)
);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON tipos_entrevista
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE entrevistas (
  id                  SERIAL PRIMARY KEY,
  ala_id              INT               NOT NULL,
  membro_id           INT               NOT NULL,
  tipo_entrevista_id  INT               NOT NULL,
  data                DATE              NULL,
  status              status_entrevista NOT NULL DEFAULT 'pendente',
  entrevistador_id    INT               NULL,
  observacoes         TEXT              NULL,
  created_at          TIMESTAMPTZ       NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ       NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_entrevistas_ala           FOREIGN KEY (ala_id)             REFERENCES alas(id)            ON DELETE CASCADE  ON UPDATE CASCADE,
  CONSTRAINT fk_entrevistas_membro        FOREIGN KEY (membro_id)          REFERENCES membros(id)         ON DELETE CASCADE  ON UPDATE CASCADE,
  CONSTRAINT fk_entrevistas_tipo          FOREIGN KEY (tipo_entrevista_id) REFERENCES tipos_entrevista(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_entrevistas_entrevistador FOREIGN KEY (entrevistador_id)   REFERENCES membros(id)         ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE INDEX idx_entrevistas_ala    ON entrevistas(ala_id);
CREATE INDEX idx_entrevistas_membro ON entrevistas(membro_id);
CREATE INDEX idx_entrevistas_status ON entrevistas(ala_id, status);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON entrevistas
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- TAREFAS DO BISPADO
-- =========================================================

CREATE TABLE tarefas_bispado (
  id              SERIAL PRIMARY KEY,
  ala_id          INT         NOT NULL,
  texto           TEXT        NOT NULL,
  data_limite     DATE        NOT NULL,
  responsavel_id  INT         NOT NULL,
  concluida       BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_tarefas_ala          FOREIGN KEY (ala_id)         REFERENCES alas(id)    ON DELETE CASCADE  ON UPDATE CASCADE,
  CONSTRAINT fk_tarefas_responsavel  FOREIGN KEY (responsavel_id) REFERENCES usuarios(id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_tarefas_ala       ON tarefas_bispado(ala_id);
CREATE INDEX idx_tarefas_responsavel ON tarefas_bispado(responsavel_id);
CREATE INDEX idx_tarefas_status    ON tarefas_bispado(ala_id, concluida, data_limite);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON tarefas_bispado
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- GRUPOS DE ORÇAMENTO
-- Agrupam organizações principais para fins de distribuição.
-- Ex: grupo "Jovens" = Rapazes + Moças (frequências somadas).
-- =========================================================

CREATE TABLE grupos_orcamento (
  id         SERIAL PRIMARY KEY,
  ala_id     INT           NOT NULL,
  nome       VARCHAR(120)  NOT NULL,
  peso       DECIMAL(10,2) NOT NULL DEFAULT 1.0,
  ativo      BOOLEAN       NOT NULL DEFAULT TRUE,
  origem     origem_tipo   NOT NULL DEFAULT 'local',
  created_at TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_grupos_orcamento_ala FOREIGN KEY (ala_id) REFERENCES alas(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT uk_grupos_orcamento_ala_nome UNIQUE (ala_id, nome)
);
CREATE INDEX idx_grupos_orcamento_ala ON grupos_orcamento(ala_id);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON grupos_orcamento
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE grupos_orcamento_organizacoes (
  grupo_id       INT NOT NULL,
  organizacao_id INT NOT NULL,
  PRIMARY KEY (grupo_id, organizacao_id),
  CONSTRAINT fk_go_grupo   FOREIGN KEY (grupo_id)       REFERENCES grupos_orcamento(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_go_org     FOREIGN KEY (organizacao_id) REFERENCES organizacoes(id)     ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX idx_go_grupo ON grupos_orcamento_organizacoes(grupo_id);
CREATE INDEX idx_go_org   ON grupos_orcamento_organizacoes(organizacao_id);

-- =========================================================
-- ORÇAMENTO
-- =========================================================

CREATE TABLE orcamentos_trimestrais (
  id              SERIAL PRIMARY KEY,
  ala_id          INT           NOT NULL,
  ano             INT           NOT NULL,
  trimestre       SMALLINT      NOT NULL CHECK (trimestre BETWEEN 1 AND 4),
  valor_recebido  DECIMAL(12,2) NOT NULL DEFAULT 0,
  acumulado_ano   DECIMAL(12,2) NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_orcamentos_ala FOREIGN KEY (ala_id) REFERENCES alas(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT uk_orcamentos_ala_ano_tri UNIQUE (ala_id, ano, trimestre)
);
CREATE INDEX idx_orcamentos_ala_ano_tri ON orcamentos_trimestrais(ala_id, ano, trimestre);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON orcamentos_trimestrais
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE orcamento_distribuicoes (
  id                      SERIAL PRIMARY KEY,
  orcamento_trimestral_id INT           NOT NULL,
  grupo_orcamento_id      INT           NOT NULL,   -- grupo de orçamento (pode combinar múltiplas orgs)
  frequencia              DECIMAL(10,2) NOT NULL DEFAULT 0,  -- frequência média do grupo no trimestre
  fator_calculo           DECIMAL(10,4) NOT NULL DEFAULT 0,  -- peso × frequência
  percentual              DECIMAL(6,2)  NOT NULL DEFAULT 0,
  valor_distribuido       DECIMAL(12,2) NOT NULL DEFAULT 0,
  created_at              TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_orc_dist_orcamento FOREIGN KEY (orcamento_trimestral_id) REFERENCES orcamentos_trimestrais(id) ON DELETE CASCADE  ON UPDATE CASCADE,
  CONSTRAINT fk_orc_dist_grupo     FOREIGN KEY (grupo_orcamento_id)      REFERENCES grupos_orcamento(id)       ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT uk_orc_dist UNIQUE (orcamento_trimestral_id, grupo_orcamento_id)
);
CREATE INDEX idx_orc_dist_orcamento ON orcamento_distribuicoes(orcamento_trimestral_id);
CREATE INDEX idx_orc_dist_grupo     ON orcamento_distribuicoes(grupo_orcamento_id);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON orcamento_distribuicoes
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- MONITORAMENTO E AUTOMAÇÃO
-- =========================================================

CREATE TABLE audit_logs (
  id          SERIAL PRIMARY KEY,
  user_id     INT          NULL,
  ward_id     INT          NULL,
  action      VARCHAR(80)  NOT NULL,
  entity      VARCHAR(50)  NOT NULL,
  entity_id   INT          NULL,
  before      JSONB        NULL,
  after       JSONB        NULL,
  ip_address  VARCHAR(45)  NULL,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_audit_ward FOREIGN KEY (ward_id) REFERENCES alas(id)     ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE INDEX idx_audit_ward_date ON audit_logs(ward_id, created_at);
CREATE INDEX idx_audit_user      ON audit_logs(user_id);
CREATE INDEX idx_audit_entity    ON audit_logs(entity, entity_id);

CREATE TABLE job_execution_logs (
  id               SERIAL PRIMARY KEY,
  job_name         VARCHAR(30) NOT NULL,
  triggered_by     VARCHAR(50) NOT NULL,
  started_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finished_at      TIMESTAMPTZ NULL,
  duration_ms      INT         NULL,
  wards_processed  INT         NULL,
  status           status_job  NOT NULL DEFAULT 'failure',
  error_message    TEXT        NULL
);
CREATE INDEX idx_job_logs_name_date ON job_execution_logs(job_name, started_at);

CREATE TABLE system_config (
  id          SERIAL PRIMARY KEY,
  ala_id      INT          NULL,
  key         VARCHAR(80)  NOT NULL,
  value       VARCHAR(255) NOT NULL,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_system_config_ala FOREIGN KEY (ala_id) REFERENCES alas(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT uk_system_config_ala_key UNIQUE (COALESCE(ala_id, 0), key)
);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON system_config
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- RELATÓRIOS
-- =========================================================

CREATE TABLE relatorios (
  id           SERIAL PRIMARY KEY,
  ala_id       INT          NOT NULL,
  tipo         VARCHAR(20)  NOT NULL CHECK (tipo IN ('weekly','monthly','quarterly')),
  periodo_ref  DATE         NOT NULL,
  conteudo     JSONB        NOT NULL,
  gerado_por   VARCHAR(50)  NOT NULL,
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_relatorios_ala FOREIGN KEY (ala_id) REFERENCES alas(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT uk_relatorios_ala_tipo_periodo UNIQUE (ala_id, tipo, periodo_ref)
);
CREATE INDEX idx_relatorios_ala_tipo ON relatorios(ala_id, tipo, periodo_ref DESC);

-- =========================================================
-- NOTIFICAÇÕES
-- =========================================================

CREATE TABLE notifications (
  id          SERIAL PRIMARY KEY,
  user_id     INT          NOT NULL,
  ward_id     INT          NOT NULL,
  type        VARCHAR(60)  NOT NULL,
  title       VARCHAR(120) NOT NULL,
  body        TEXT         NOT NULL,
  read        BOOLEAN      NOT NULL DEFAULT FALSE,
  action_url  VARCHAR(255) NULL,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_notifications_ward FOREIGN KEY (ward_id) REFERENCES alas(id)    ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX idx_notifications_user_read ON notifications(user_id, read, created_at DESC);

CREATE TABLE fcm_tokens (
  id          SERIAL PRIMARY KEY,
  user_id     INT          NOT NULL,
  token       VARCHAR(255) NOT NULL,
  device_info VARCHAR(120) NULL,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_fcm_tokens_user FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT uk_fcm_token UNIQUE (token)
);
CREATE INDEX idx_fcm_tokens_user ON fcm_tokens(user_id);
CREATE TRIGGER trg_updated_at BEFORE UPDATE ON fcm_tokens
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- SEEDS
-- =========================================================

-- Estados brasileiros
INSERT INTO estados (nome, sigla) VALUES
('Acre', 'AC'), ('Alagoas', 'AL'), ('Amapá', 'AP'), ('Amazonas', 'AM'),
('Bahia', 'BA'), ('Ceará', 'CE'), ('Distrito Federal', 'DF'),
('Espírito Santo', 'ES'), ('Goiás', 'GO'), ('Maranhão', 'MA'),
('Mato Grosso', 'MT'), ('Mato Grosso do Sul', 'MS'), ('Minas Gerais', 'MG'),
('Pará', 'PA'), ('Paraíba', 'PB'), ('Paraná', 'PR'), ('Pernambuco', 'PE'),
('Piauí', 'PI'), ('Rio de Janeiro', 'RJ'), ('Rio Grande do Norte', 'RN'),
('Rio Grande do Sul', 'RS'), ('Rondônia', 'RO'), ('Roraima', 'RR'),
('Santa Catarina', 'SC'), ('São Paulo', 'SP'), ('Sergipe', 'SE'),
('Tocantins', 'TO');

-- Tipos de organização
-- Tipos de organização
-- 'principal' = frequência + chamados (todo membro pertence a uma)
-- 'auxiliar'  = apenas chamados (sem contagem de frequência)
INSERT INTO tipos_organizacao (nome) VALUES ('principal'), ('auxiliar');

-- Tipos de hino
INSERT INTO tipos_hino (nome) VALUES
('abertura'), ('intermediario'), ('sacramental'), ('encerramento');

-- Tipos de cantor
INSERT INTO tipos_cantor (nome) VALUES
('congregacao'), ('organizacao_estrutural'), ('texto_livre');

-- Tipos de entrevista
INSERT INTO tipos_entrevista (nome) VALUES
('sacerdocio_14'), ('sacerdocio_16'), ('jovem_12'),
('batismo'), ('jovem_18'), ('renovacao');

-- Chamados: não há seeds globais aqui.
-- Os 113 chamados padrão por ala são inseridos pelo backend (ward_seed_service.py)
-- ao criar cada ala, usando o arquivo docs/seeds-chamados.sql como referência.

-- Configuração global padrão: ausência prolongada = 2 semanas
INSERT INTO system_config (ala_id, key, value) VALUES
(NULL, 'absence_threshold_weeks', '2');
