-- =========================================================
-- EASYWARD — SEEDS DE CHAMADOS POR ALA
-- =========================================================
--
-- Este script é executado pelo backend (ward_seed_service.py)
-- automaticamente ao criar uma nova ala.
-- Substituir :ala_id pelo ID real da ala criada.
--
-- Chamados com origem = 'global' são seeds do sistema.
-- O usuário pode criar chamados adicionais (origem = 'local').
-- Chamados globais podem ser inativados, mas não editados.
--
-- Fonte: estrutura oficial de chamados do LCR
-- (Leader and Clerk Resources) da Igreja de Jesus Cristo
-- dos Santos dos Últimos Dias — edição em português do Brasil.
-- =========================================================

INSERT INTO chamados (ala_id, nome, tipo, origem, ativo) VALUES

-- =========================================================
-- BISPADO
-- =========================================================

(:ala_id, 'Bispo',                                    'local', 'global', true),
(:ala_id, 'Primeiro Conselheiro no Bispado',          'local', 'global', true),
(:ala_id, 'Segundo Conselheiro no Bispado',           'local', 'global', true),
(:ala_id, 'Secretário Executivo da Ala',              'local', 'global', true),
(:ala_id, 'Secretário da Ala',                        'local', 'global', true),
(:ala_id, 'Secretário Adjunto da Ala',                'local', 'global', true),
(:ala_id, 'Secretário Adjunto da Ala – Registro de Membros', 'local', 'global', true),
(:ala_id, 'Secretário Adjunto Financeiro da Ala',     'local', 'global', true),

-- =========================================================
-- QUÓRUM DE ÉLDERES — Presidência
-- =========================================================

(:ala_id, 'Presidente do Quórum de Élderes',          'local', 'global', true),
(:ala_id, 'Primeiro Conselheiro no Quórum de Élderes','local', 'global', true),
(:ala_id, 'Segundo Conselheiro no Quórum de Élderes', 'local', 'global', true),
(:ala_id, 'Secretário do Quórum de Élderes',          'local', 'global', true),
(:ala_id, 'Assistente Secretário do Quórum de Élderes','local', 'global', true),

-- QUÓRUM DE ÉLDERES — Professores
(:ala_id, 'Professor do Quórum de Élderes',           'local', 'global', true),

-- QUÓRUM DE ÉLDERES — Ministrar como o Salvador
(:ala_id, 'Secretário de Ministração do Quórum de Élderes', 'local', 'global', true),

-- QUÓRUM DE ÉLDERES — Atividades
(:ala_id, 'Coordenador de Atividades do Quórum de Élderes',          'local', 'global', true),
(:ala_id, 'Coordenador Assistente de Atividades do Quórum de Élderes','local', 'global', true),
(:ala_id, 'Membro do Comitê de Atividades do Quórum de Élderes',     'local', 'global', true),

-- QUÓRUM DE ÉLDERES — Serviço
(:ala_id, 'Coordenador de Serviço do Quórum de Élderes',             'local', 'global', true),
(:ala_id, 'Coordenador Assistente de Serviço do Quórum de Élderes',  'local', 'global', true),
(:ala_id, 'Membro do Comitê de Serviço do Quórum de Élderes',        'local', 'global', true),

-- =========================================================
-- SOCIEDADE DE SOCORRO — Presidência
-- =========================================================

(:ala_id, 'Presidente da Sociedade de Socorro',               'local', 'global', true),
(:ala_id, 'Primeira Conselheira da Sociedade de Socorro',     'local', 'global', true),
(:ala_id, 'Segunda Conselheira da Sociedade de Socorro',      'local', 'global', true),
(:ala_id, 'Secretária da Sociedade de Socorro',               'local', 'global', true),
(:ala_id, 'Secretária Assistente da Sociedade de Socorro',    'local', 'global', true),

-- SOCIEDADE DE SOCORRO — Professoras
(:ala_id, 'Professora da Sociedade de Socorro',               'local', 'global', true),

-- SOCIEDADE DE SOCORRO — Ministrar como o Salvador
(:ala_id, 'Secretária de Ministração da Sociedade de Socorro','local', 'global', true),

-- SOCIEDADE DE SOCORRO — Atividades
(:ala_id, 'Coordenadora de Atividades da Sociedade de Socorro','local', 'global', true),

-- SOCIEDADE DE SOCORRO — Serviço
(:ala_id, 'Coordenadora de Serviço da Sociedade de Socorro',  'local', 'global', true),

-- =========================================================
-- QUÓRUNS DO SACERDÓCIO AARÔNICO — Quórum de Sacerdotes
-- =========================================================

-- Presidência do Quórum de Sacerdotes
(:ala_id, 'Primeiro Assistente do Quórum de Sacerdotes',      'local', 'global', true),
(:ala_id, 'Segundo Assistente do Quórum de Sacerdotes',       'local', 'global', true),
(:ala_id, 'Secretário do Quórum de Sacerdotes',               'local', 'global', true),

-- Líderes adultos — Quórum de Sacerdotes
(:ala_id, 'Consultor do Quórum de Sacerdotes',                'local', 'global', true),
(:ala_id, 'Especialista do Quórum de Sacerdotes',             'local', 'global', true),

-- =========================================================
-- QUÓRUNS DO SACERDÓCIO AARÔNICO — Quórum de Mestres
-- =========================================================

-- Presidência do Quórum de Mestres
(:ala_id, 'Presidente do Quórum de Mestres',                  'local', 'global', true),
(:ala_id, 'Primeiro Conselheiro no Quórum de Mestres',        'local', 'global', true),
(:ala_id, 'Segundo Conselheiro no Quórum de Mestres',         'local', 'global', true),
(:ala_id, 'Secretário do Quórum de Mestres',                  'local', 'global', true),

-- Líderes adultos — Quórum de Mestres
(:ala_id, 'Consultor do Quórum de Mestres',                   'local', 'global', true),
(:ala_id, 'Consultor Adjunto do Quórum de Mestres',           'local', 'global', true),

-- =========================================================
-- QUÓRUNS DO SACERDÓCIO AARÔNICO — Quórum de Diáconos
-- =========================================================

-- Presidência do Quórum de Diáconos
(:ala_id, 'Presidente do Quórum de Diáconos',                 'local', 'global', true),
(:ala_id, 'Primeiro Conselheiro no Quórum de Diáconos',       'local', 'global', true),
(:ala_id, 'Segundo Conselheiro no Quórum de Diáconos',        'local', 'global', true),
(:ala_id, 'Secretário do Quórum de Diáconos',                 'local', 'global', true),

-- Líderes adultos — Quórum de Diáconos
(:ala_id, 'Consultor do Quórum de Diáconos',                  'local', 'global', true),
(:ala_id, 'Especialista do Quórum de Diáconos',               'local', 'global', true),

-- =========================================================
-- QUÓRUNS DO SACERDÓCIO AARÔNICO — Chamados Adicionais
-- =========================================================

(:ala_id, 'Especialista dos Quóruns do Sacerdócio Aarônico — Diretor de Acampamento',   'local', 'global', true),
(:ala_id, 'Especialista dos Quóruns do Sacerdócio Aarônico — Diretor Adjunto de Acampamento', 'local', 'global', true),
(:ala_id, 'Membro do Comitê dos Rapazes da Estaca',           'local', 'global', true),
(:ala_id, 'Especialista dos Rapazes — Esportes',              'local', 'global', true),
(:ala_id, 'Especialista dos Rapazes — Assistente de Esportes','local', 'global', true),
(:ala_id, 'Especialista dos Quóruns do Sacerdócio Aarônico',  'local', 'global', true),

-- =========================================================
-- MOÇAS — Presidência
-- =========================================================

(:ala_id, 'Presidente das Moças',                             'local', 'global', true),
(:ala_id, 'Primeira Conselheira das Moças',                   'local', 'global', true),
(:ala_id, 'Segunda Conselheira das Moças',                    'local', 'global', true),
(:ala_id, 'Secretária das Moças',                             'local', 'global', true),
(:ala_id, 'Especialista das Moças',                           'local', 'global', true),

-- =========================================================
-- MOÇAS — Classe Guardiãs da Luz
-- =========================================================

-- Presidência da Classe das Guardiãs da Luz
(:ala_id, 'Presidente da Classe das Guardiãs da Luz',         'local', 'global', true),
(:ala_id, 'Primeira Conselheira da Classe das Guardiãs da Luz','local', 'global', true),
(:ala_id, 'Segunda Conselheira da Classe das Guardiãs da Luz','local', 'global', true),
(:ala_id, 'Secretária da Classe das Guardiãs da Luz',         'local', 'global', true),

-- Líderes adultas — Classe das Guardiãs da Luz
(:ala_id, 'Consultora da Classe das Guardiãs da Luz',                'local', 'global', true),
(:ala_id, 'Especialista da Classe das Guardiãs da Luz',             'local', 'global', true),

-- =========================================================
-- MOÇAS — Classe das Mensageiras da Esperança
-- =========================================================

-- Presidência da Classe das Mensageiras da Esperança
(:ala_id, 'Presidente da Classe das Mensageiras da Esperança',         'local', 'global', true),
(:ala_id, 'Primeira Conselheira da Classe das Mensageiras da Esperança','local', 'global', true),
(:ala_id, 'Segunda Conselheira da Classe das Mensageiras da Esperança','local', 'global', true),
(:ala_id, 'Secretária da Classe das Mensageiras da Esperança',         'local', 'global', true),

-- Líderes adultas — Classe das Mensageiras da Esperança
(:ala_id, 'Consultora da Classe das Mensageiras da Esperança',         'local', 'global', true),
(:ala_id, 'Especialista da Classe das Mensageiras da Esperança',       'local', 'global', true),

-- =========================================================
-- MOÇAS — Classe das Edificadoras da Fé
-- =========================================================

-- Presidência da Classe das Edificadoras da Fé
(:ala_id, 'Presidente da Classe das Edificadoras da Fé',         'local', 'global', true),
(:ala_id, 'Primeira Conselheira da Classe das Edificadoras da Fé','local', 'global', true),
(:ala_id, 'Segunda Conselheira da Classe das Edificadoras da Fé','local', 'global', true),
(:ala_id, 'Secretária da Classe das Edificadoras da Fé',         'local', 'global', true),

-- Líderes adultas — Classe das Edificadoras da Fé
(:ala_id, 'Consultora da Classe das Edificadoras da Fé',         'local', 'global', true),
(:ala_id, 'Especialista da Classe das Edificadoras da Fé',       'local', 'global', true),

-- MOÇAS — Outros chamados
(:ala_id, 'Especialista das Moças — Atividades',              'local', 'global', true),
(:ala_id, 'Especialista das Moças — Diretora de Acampamento', 'local', 'global', true),
(:ala_id, 'Especialista das Moças — Diretora Adjunta de Acampamento', 'local', 'global', true),
(:ala_id, 'Comitê das Moças da Estaca',                       'local', 'global', true),
(:ala_id, 'Especialista das Moças — Esportes',                'local', 'global', true),
(:ala_id, 'Especialista das Moças — Assistente de Esportes',  'local', 'global', true),

-- =========================================================
-- ESCOLA DOMINICAL — Presidência
-- =========================================================

(:ala_id, 'Presidente da Escola Dominical',                   'local', 'global', true),
(:ala_id, 'Primeiro Conselheiro da Escola Dominical',         'local', 'global', true),
(:ala_id, 'Segundo Conselheiro da Escola Dominical',          'local', 'global', true),
(:ala_id, 'Secretário da Escola Dominical',                   'local', 'global', true),

-- ESCOLA DOMINICAL — Professores
(:ala_id, 'Professor(a) da Escola Dominical — Doutrina do Evangelho', 'local', 'global', true),
(:ala_id, 'Professor(a) da Escola Dominical — Membros Novos',         'local', 'global', true),
(:ala_id, 'Professor(a) da Escola Dominical — Jovens',                'local', 'global', true),

-- ESCOLA DOMINICAL — Centro de Recursos
(:ala_id, 'Especialista do Centro de Recursos',               'local', 'global', true),

-- =========================================================
-- PRIMÁRIA — Presidência
-- =========================================================

(:ala_id, 'Presidente da Primária',                           'local', 'global', true),
(:ala_id, 'Primeira Conselheira da Primária',                 'local', 'global', true),
(:ala_id, 'Segunda Conselheira da Primária',                  'local', 'global', true),
(:ala_id, 'Secretária da Primária',                           'local', 'global', true),

-- PRIMÁRIA — Música
(:ala_id, 'Pianista da Primária',                             'local', 'global', true),
(:ala_id, 'Líder de Música da Primária',                      'local', 'global', true),

-- PRIMÁRIA — Classes
(:ala_id, 'Professor(a) da Primária — Valorosos',             'local', 'global', true),
(:ala_id, 'Professor(a) da Primária — CTR',                   'local', 'global', true),
(:ala_id, 'Professor(a) da Primária — Raios de Sol',          'local', 'global', true),
(:ala_id, 'Líder do Berçário',                                'local', 'global', true),

-- PRIMÁRIA — Atividades
(:ala_id, 'Líder de Atividades da Primária — Meninos',        'local', 'global', true),
(:ala_id, 'Líder de Atividades da Primária — Meninas',        'local', 'global', true),

-- =========================================================
-- MISSIONÁRIOS DE ALA
-- =========================================================

(:ala_id, 'Líder da Missão da Ala',                           'local', 'global', true),
(:ala_id, 'Assistente do Líder da Missão da Ala',             'local', 'global', true),
(:ala_id, 'Missionário da Ala',                               'local', 'global', true),

-- =========================================================
-- TEMPLO E HISTÓRIA DA FAMÍLIA
-- =========================================================

(:ala_id, 'Líder de Templo e História da Família da Ala',     'local', 'global', true),
(:ala_id, 'Consultor de Templo e História da Família da Ala', 'local', 'global', true),
(:ala_id, 'Indexador',                                        'local', 'global', true),
(:ala_id, 'Professor do Curso de Preparação para o Templo',   'local', 'global', true),

-- =========================================================
-- JOVENS ADULTOS SOLTEIROS
-- =========================================================

(:ala_id, 'Líder dos Jovens Adultos Solteiros',               'local', 'global', true),
(:ala_id, 'Consultor dos Jovens Adultos Solteiros',           'local', 'global', true),
(:ala_id, 'Consultora das Irmãs Jovens Adultas Solteiras da Sociedade de Socorro', 'local', 'global', true),
(:ala_id, 'Presidente do Comitê dos Jovens Adultos Solteiros','local', 'global', true),
(:ala_id, 'Membro do Comitê dos Jovens Adultos Solteiros',    'local', 'global', true),

-- =========================================================
-- BEM-ESTAR E AUTOSSUFICIÊNCIA
-- =========================================================

(:ala_id, 'Especialista de Bem-estar e Autossuficiência',     'local', 'global', true),
(:ala_id, 'Facilitador de Grupo de Autossuficiência',         'local', 'global', true),
(:ala_id, 'Líder de Atividades para Pessoas com Deficiências','local', 'global', true),
(:ala_id, 'Especialista em Pessoas com Necessidades Especiais','local', 'global', true),

-- =========================================================
-- INSTALAÇÕES
-- =========================================================

(:ala_id, 'Representante do Edifício',                        'local', 'global', true),
(:ala_id, 'Programador do Edifício',                          'local', 'global', true),

-- =========================================================
-- MÚSICA
-- =========================================================

(:ala_id, 'Coordenador de Música',                            'local', 'global', true),
(:ala_id, 'Regente da Ala',                                   'local', 'global', true),
(:ala_id, 'Líder de Música da Ala',                           'local', 'global', true),
(:ala_id, 'Organista da Ala',                                 'local', 'global', true),
(:ala_id, 'Pianista ou Organista do Sacerdócio',              'local', 'global', true),
(:ala_id, 'Regente do Sacerdócio',                            'local', 'global', true),
(:ala_id, 'Diretor de Coro',                                  'local', 'global', true),
(:ala_id, 'Pianista/Organista de Coro',                       'local', 'global', true),
(:ala_id, 'Consultor de Música',                              'local', 'global', true),

-- =========================================================
-- OUTROS CHAMADOS
-- =========================================================

-- História
(:ala_id, 'Especialista em História da Igreja',               'local', 'global', true),

-- Para o Vigor da Juventude
(:ala_id, 'Representante do FSY',                             'local', 'global', true),

-- Revistas da Igreja
(:ala_id, 'Representante de A Liahona',                       'local', 'global', true),

-- Tecnologia
(:ala_id, 'Especialista de Comunicações por E-mail',          'local', 'global', true),
(:ala_id, 'Especialista de Tecnologia',                       'local', 'global', true),
(:ala_id, 'Intérprete da Ala',                                'local', 'global', true),

-- Recepção
(:ala_id, 'Recepcionista da Ala',                             'local', 'global', true)

ON CONFLICT (ala_id, nome) DO NOTHING;

-- =========================================================
-- RESUMO
-- Total: 113 chamados padrão por ala
--
-- Agrupados por organização:
--   Bispado                             8
--   Quórum de Élderes                  13
--   Sociedade de Socorro               10
--   Quórum de Sacerdotes                5
--   Quórum de Mestres                   6
--   Quórum de Diáconos                  6
--   Sacerdócio Aarônico — Adicionais    6
--   Moças                              13
--   Escola Dominical                    8
--   Primária                           12
--   Missionários de Ala                 3
--   Templo e História da Família        4
--   Jovens Adultos Solteiros            5
--   Bem-estar e Autossuficiência        4
--   Instalações                         2
--   Música                              9
--   Outros                              8
-- =========================================================
