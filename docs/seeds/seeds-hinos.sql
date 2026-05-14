-- =========================================================
-- EASYWARD — SEEDS DO HINÁRIO SUD (Português do Brasil)
-- =========================================================
--
-- Fonte: Hinário oficial da Igreja de Jesus Cristo dos
-- Santos dos Últimos Dias — edição em português do Brasil.
--
-- Numeração original preservada, incluindo o salto
-- intencional de 204 para 1001 e de 1062 para 1201.
--
-- Hinos são seeds globais (ala_id = NULL, origem = 'global').
-- Ao criar uma ala, esses hinos ficam disponíveis para uso.
-- Hinos adicionados pela ala usam ala_id = :ala_id e origem = 'local'.
-- =========================================================

INSERT INTO hinos (ala_id, numero, nome, origem) VALUES

-- =========================================================
-- RESTAURAÇÃO (1–28)
-- =========================================================
(NULL, 1,   'A Alva Rompe',                          'global'),
(NULL, 2,   'Tal Como um Facho',                     'global'),
(NULL, 3,   'Alegres Cantemos',                      'global'),
(NULL, 4,   'No Monte a Bandeira',                   'global'),
(NULL, 5,   'Israel, Jesus Te Chama',                'global'),
(NULL, 6,   'Um Anjo Lá do Céu',                     'global'),
(NULL, 7,   'O Que Vimos Lá nos Céus',               'global'),
(NULL, 8,   'Oração pelo Profeta',                   'global'),
(NULL, 9,   'Graças Damos, Ó Deus, Por um Profeta',  'global'),
(NULL, 10,  'Vinde ao Profeta Escutar',              'global'),
(NULL, 11,  'Abençoa Nosso Profeta',                 'global'),
(NULL, 12,  'Que Manhã Maravilhosa!',                'global'),
(NULL, 13,  'Rejubilai-vos, Ó Nações',              'global'),
(NULL, 14,  'Hoje, ao Profeta Louvemos',             'global'),
(NULL, 15,  'Um Pobre e Aflito Viajor',              'global'),
(NULL, 16,  'Ó Montanhas Mil',                       'global'),
(NULL, 17,  'Por Teus Dons',                         'global'),
(NULL, 18,  'Vede, Ó Santos',                        'global'),
(NULL, 19,  'Sereno Finda o Dia',                    'global'),
(NULL, 20,  'Vinde, Ó Santos',                       'global'),
(NULL, 21,  'Ao Salvador Louvemos',                  'global'),
(NULL, 22,  'Em Glória Resplandesce',                'global'),
(NULL, 23,  'Lá nos Cumes',                          'global'),
(NULL, 24,  'Vem, Ó Dia Prometido',                  'global'),
(NULL, 25,  'Bela Sião',                             'global'),
(NULL, 26,  'O Mundo Desperta',                      'global'),
(NULL, 27,  'Vinde, Ó Filhos do Senhor',             'global'),
(NULL, 28,  'Ó Vem, Supremo Rei',                    'global'),

-- =========================================================
-- LOUVOR E GRAÇAS (29–59)
-- =========================================================
(NULL, 29,  'Ó Criaturas do Senhor',                 'global'),
(NULL, 30,  'Ó Santos, Que na Terra Habitais',       'global'),
(NULL, 31,  'Com Braço Forte',                       'global'),
(NULL, 32,  'Castelo Forte',                         'global'),
(NULL, 33,  'Glória a Deus Cantai',                  'global'),
(NULL, 34,  'Louvai a Deus',                         'global'),
(NULL, 35,  'A Deus, Senhor e Rei',                  'global'),
(NULL, 36,  'Deus É Amor',                           'global'),
(NULL, 37,  'O Senhor Meu Pastor É',                 'global'),
(NULL, 38,  'Que Toda Honra e Glória',               'global'),
(NULL, 39,  'Corações, Pois, Exultai',               'global'),
(NULL, 40,  'Jeová, Sê Nosso Guia',                  'global'),
(NULL, 41,  'Firmes Segui',                          'global'),
(NULL, 42,  'Que Firme Alicerce',                    'global'),
(NULL, 43,  'Grandioso És Tu',                       'global'),
(NULL, 44,  'Jesus, Minha Luz',                      'global'),
(NULL, 45,  'Ó Vós Que Amais ao Senhor',             'global'),
(NULL, 46,  'Nossas Vozes Elevemos',                 'global'),
(NULL, 47,  'Deus nos Rege com Amor',                'global'),
(NULL, 48,  'Ó Pai Bendito',                         'global'),
(NULL, 49,  'Pela Beleza do Mundo',                  'global'),
(NULL, 50,  'Cantando Louvamos',                     'global'),
(NULL, 51,  'Oração de Graças',                      'global'),
(NULL, 52,  'Vinde, Ó Povos, Graças Dar',            'global'),
(NULL, 53,  'Se Tenho Fé',                           'global'),
(NULL, 54,  'Doce É o Trabalho',                     'global'),
(NULL, 55,  'Santo! Santo! Santo!',                  'global'),
(NULL, 56,  'Os Céus Proclamam',                     'global'),
(NULL, 57,  'Conta as Bênçãos',                      'global'),
(NULL, 58,  'Ao Deus de Abraão Louvai',              'global'),
(NULL, 59,  'Louvai o Eterno Criador',               'global'),

-- =========================================================
-- ORAÇÃO E SÚPLICA (60–97)
-- =========================================================
(NULL, 60,  'Brilha, Meiga Luz',                     'global'),
(NULL, 61,  'Careço de Jesus',                       'global'),
(NULL, 62,  'Mais Perto Quero Estar',                'global'),
(NULL, 63,  'Guia-me a Ti',                          'global'),
(NULL, 64,  'Ó Pai Celeste',                         'global'),
(NULL, 65,  'Jesus Cristo É Meu Senhor',             'global'),
(NULL, 66,  'Creio em Cristo',                       'global'),
(NULL, 67,  'Vive o Redentor',                       'global'),
(NULL, 68,  'Vinde a Mim',                           'global'),
(NULL, 69,  'Vinde a Cristo',                        'global'),
(NULL, 70,  'Eu Sei Que Vive Meu Senhor',            'global'),
(NULL, 71,  'Testemunho',                            'global'),
(NULL, 72,  'Mestre, o Mar Se Revolta',              'global'),
(NULL, 73,  'Onde Encontrar a Paz?',                 'global'),
(NULL, 74,  'Sê Humilde',                            'global'),
(NULL, 75,  'Mais Vontade Dá-me',                    'global'),
(NULL, 76,  'Rocha Eterna',                          'global'),
(NULL, 77,  'A Luz de Deus',                         'global'),
(NULL, 78,  'Embora Cheios de Pesar',                'global'),
(NULL, 79,  'Ó Doce, Grata Oração',                  'global'),
(NULL, 80,  'Santo Espírito de Deus',                'global'),
(NULL, 81,  'Secreta Oração',                        'global'),
(NULL, 82,  'Eis-nos Agora Aqui',                    'global'),
(NULL, 83,  'Com Fervor Fizeste a Prece?',           'global'),
(NULL, 84,  'Só por em Ti, Jesus, Pensar',           'global'),
(NULL, 85,  'Deus Vos Guarde',                       'global'),
(NULL, 86,  'Nós Pedimos-te, Senhor',                'global'),
(NULL, 87,  'Ó Bondoso Pai Eterno',                  'global'),
(NULL, 88,  'Dá-nos, Tu, ó Pai Bondoso',             'global'),
(NULL, 89,  'Ao Partir Cantemos',                    'global'),
(NULL, 90,  'Teu Santo Espírito, Senhor',            'global'),
(NULL, 91,  'Qual Orvalho Que Cintila',              'global'),
(NULL, 92,  'Vai Fugindo o Dia',                     'global'),
(NULL, 93,  'Suavemente a Noite Cai',                'global'),
(NULL, 94,  'Oração para a Noite',                   'global'),
(NULL, 95,  'Eis-nos, Hoje, a Teus Pés',             'global'),
(NULL, 96,  'É Tarde, a Noite Logo Vem',             'global'),
(NULL, 97,  'Comigo Habita',                         'global'),

-- =========================================================
-- HINOS SACRAMENTAIS (98–117)
-- =========================================================
(NULL, 98,  'Ó Deus, Senhor Eterno',                 'global'),
(NULL, 99,  'Ao Partilhar de Teu Amor',              'global'),
(NULL, 100, 'Entoai a Deus Louvor',                  'global'),
(NULL, 101, 'Deus, Escuta-nos Orar',                 'global'),
(NULL, 102, 'Nossa Humilde Prece Atende',            'global'),
(NULL, 103, 'Enquanto unidos em Amor',               'global'),
(NULL, 104, 'Quão Grato É Cantar Louvor',            'global'),
(NULL, 105, 'Cantemos Todos a Jesus',                'global'),
(NULL, 106, 'Jesus de Nazaré, Mestre e Rei',         'global'),
(NULL, 107, 'Deus Tal Amor por Nós Mostrou',         'global'),
(NULL, 108, 'Eis-nos à Mesa do Senhor',              'global'),
(NULL, 109, 'Em uma Cruz Jesus Morreu',              'global'),
(NULL, 110, 'Vede, Morreu o Redentor',               'global'),
(NULL, 111, 'Lembrando a Morte de Jesus',            'global'),
(NULL, 112, 'Assombro me Causa',                     'global'),
(NULL, 113, 'No Monte do Calvário',                  'global'),
(NULL, 114, 'Da Corte Celestial',                    'global'),
(NULL, 115, 'Tão Humilde ao Nascer',                 'global'),
(NULL, 116, 'Sobre o Calvário',                      'global'),
(NULL, 117, 'Com Irmãos Nós Reunidos',               'global'),

-- =========================================================
-- PÁSCOA (118–120)
-- =========================================================
(NULL, 118, 'Manhã da Ressurreição',                 'global'),
(NULL, 119, 'Cristo É Já Ressuscitado',              'global'),
(NULL, 120, 'Cristo Já Ressuscitou',                 'global'),

-- =========================================================
-- NATAL (121–133)
-- =========================================================
(NULL, 121, 'Mundo Feliz, Nasceu Jesus',             'global'),
(NULL, 122, 'Erguei-vos Cantando',                   'global'),
(NULL, 123, 'Lá na Judéia, Onde Cristo Nasceu',      'global'),
(NULL, 124, 'Anjos Descem a Cantar',                 'global'),
(NULL, 125, 'Ouvi os Sinos do Natal',                'global'),
(NULL, 126, 'Noite Feliz',                           'global'),
(NULL, 127, 'Jesus num Presépio',                    'global'),
(NULL, 128, 'Na Bela Noite Se Ouviu',                'global'),
(NULL, 129, 'Pequena Vila de Belém',                 'global'),
(NULL, 130, 'No Céu Desponta Nova Luz',              'global'),
(NULL, 131, 'No Dia de Natal',                       'global'),
(NULL, 132, 'Eis dos Anjos a Harmonia',              'global'),
(NULL, 133, 'Quando o Anjo Proclamou',               'global'),

-- =========================================================
-- TEMAS ESPECIAIS (134–204)
-- =========================================================
(NULL, 134, 'Sim, Eu Te Seguirei',                   'global'),
(NULL, 135, 'Eu Devo Partilhar',                     'global'),
(NULL, 136, 'Neste mundo',                           'global'),
(NULL, 137, 'Oh! Falemos Palavras Amáveis',          'global'),
(NULL, 138, 'Não Deixeis Palavras Duras',            'global'),
(NULL, 139, 'Deus É Consolador Sem Par',             'global'),
(NULL, 140, 'Ama o Pastor Seu Rebanho',              'global'),
(NULL, 141, 'Trabalhemos Hoje',                      'global'),
(NULL, 142, 'Nossa Lei É Trabalhar',                 'global'),
(NULL, 143, 'Pai, Inspira-me ao Ensinar',            'global'),
(NULL, 144, 'Mãos ao Trabalho',                      'global'),
(NULL, 145, 'Sempre Que Alguém Nos Faz o Bem',       'global'),
(NULL, 146, 'Se a Vida É Penosa',                    'global'),
(NULL, 147, 'Faze o Bem',                            'global'),
(NULL, 148, 'Faze o Bem, Escolhendo o Que É Certo',  'global'),
(NULL, 149, 'A Alma É Livre',                        'global'),
(NULL, 150, 'Quem Segue ao Senhor?',                 'global'),
(NULL, 151, 'Minha Alma Hoje Tem a luz',             'global'),
(NULL, 152, 'Prolongue os Bons Momentos',            'global'),
(NULL, 153, 'Deixa a Luz do Sol Entrar',             'global'),
(NULL, 154, 'Enquanto o Sol Brilha',                 'global'),
(NULL, 155, 'Luz Espalhai',                          'global'),
(NULL, 156, 'Agora Não, mas Logo Mais',              'global'),
(NULL, 157, 'Amor que Cristo Demonstrou',            'global'),
(NULL, 158, 'Tu Jesus, Ó Rocha Eterna',              'global'),
(NULL, 159, 'À Glória Nós Iremos',                   'global'),
(NULL, 160, 'Somos os Soldados',                     'global'),
(NULL, 161, 'As Hostes do Eterno',                   'global'),
(NULL, 162, 'Com Valor Marchemos',                   'global'),
(NULL, 163, 'Ide por Todo o Mundo',                  'global'),
(NULL, 164, 'De Um a Outro Pólo',                    'global'),
(NULL, 165, 'Semeando',                              'global'),
(NULL, 166, 'Chamados a Servir',                     'global'),
(NULL, 167, 'Aonde Mandares Irei',                   'global'),
(NULL, 168, 'Povos da Terra, Vinde, Escutai!',       'global'),
(NULL, 169, 'Eis os Teus Filhos, Ó Senhor',          'global'),
(NULL, 170, 'Avante, ao Mundo Proclamai',            'global'),
(NULL, 171, 'A Verdade o Que É?',                    'global'),
(NULL, 172, 'A Verdade É Nosso Guia',                'global'),
(NULL, 173, 'Ao Raiar o Novo Dia',                   'global'),
(NULL, 174, 'Sê Bem-vindo, Dia Santo',               'global'),
(NULL, 175, 'Do Pó Nos Fala uma Voz',                'global'),
(NULL, 176, 'Estudando as Escrituras',               'global'),
(NULL, 177, 'Ó Meu Pai',                             'global'),
(NULL, 178, 'Ó Quão Majestosa É a Obra de Deus',     'global'),
(NULL, 179, 'Ó Jeová, Senhor do Céu',                'global'),
(NULL, 180, 'Já Refulge a Glória Eterna',            'global'),
(NULL, 181, 'O Fim Se Aproxima',                     'global'),
(NULL, 182, 'Juventude da Promessa',                 'global'),
(NULL, 183, 'Deve Sião Fugir à Luta?',               'global'),
(NULL, 184, 'Constantes Qual Firmes Montanhas',      'global'),
(NULL, 185, 'Quão Belos São',                        'global'),
(NULL, 186, 'Levantai-vos, Ide ao Templo',           'global'),
(NULL, 187, 'Nós Dedicamos Esta Casa',               'global'),
(NULL, 188, 'Com Amor no Lar',                       'global'),
(NULL, 189, 'Pode o Lar Ser Como o Céu',             'global'),
(NULL, 190, 'Os Teus Filhos, Pai Celeste',           'global'),
(NULL, 191, 'As Famílias Poderão Ser Eternas',       'global'),
(NULL, 192, 'Ó Crianças, Deus Vos Ama',              'global'),
(NULL, 193, 'Sou um Filho de Deus',                  'global'),
(NULL, 194, 'Guarda os Mandamentos',                 'global'),
(NULL, 195, 'Eu Sei que Deus Vive',                  'global'),
(NULL, 196, 'Nas Montanhas de Sião',                 'global'),
(NULL, 197, 'Amai-vos Uns aos Outros',               'global'),
(NULL, 198, 'Quando Vejo o Sol Raiar',               'global'),
(NULL, 199, 'Faz-me Andar Só na Luz',                'global'),
(NULL, 200, 'Irmãs em Sião',                         'global'),  -- Vozes Femininas
(NULL, 201, 'Ó Filhos do Senhor',                    'global'),  -- Vozes Masculinas
(NULL, 202, 'Brilham Raios de Clemência',            'global'),  -- Vozes Masculinas
(NULL, 203, 'Ó Élderes de Israel',                   'global'),
(NULL, 204, 'Ó Vós, Que Sois Chamados',              'global'),

-- =========================================================
-- DIA DO SENHOR E DIAS DA SEMANA (1001–1062)
-- Nota: salto intencional de 204 para 1001 no hinário oficial
-- =========================================================
(NULL, 1001, 'Ó Senhor de toda bênção',              'global'),
(NULL, 1002, 'Quando o Salvador voltar',             'global'),
(NULL, 1003, 'Minha alma tem paz',                   'global'),
(NULL, 1004, 'Quero andar com Cristo',               'global'),
(NULL, 1005, 'Do passarinho cuida',                  'global'),
(NULL, 1006, 'Pense na canção',                      'global'),
(NULL, 1007, 'Partido o pão',                        'global'),
(NULL, 1008, 'Pão do Céu, Água Viva',                'global'),
(NULL, 1009, 'Getsêmani',                            'global'),
(NULL, 1010, 'Sublime graça',                        'global'),
(NULL, 1011, 'De mãos dadas em união',               'global'),
(NULL, 1012, 'A qualquer hora ou lugar',             'global'),
(NULL, 1013, 'O amor de Deus',                       'global'),
(NULL, 1014, 'O meu Pastor vai me amparar',          'global'),
(NULL, 1015, 'O profundo amor de Cristo',            'global'),
(NULL, 1016, 'Olhai as mãos do Redentor',            'global'),
(NULL, 1017, 'Este é o Cristo',                      'global'),
(NULL, 1018, 'Vem, ó Jesus! Vem!',                   'global'),
(NULL, 1019, 'Desejo me tornar como Cristo',         'global'),
(NULL, 1020, 'O Salvador ternamente nos chama',      'global'),
(NULL, 1021, 'Que Cristo me ama eu sei',             'global'),
(NULL, 1022, 'Fé a cada passo',                      'global'),
(NULL, 1023, 'Firme nas promessas',                  'global'),
(NULL, 1024, 'Tenho fé em Jesus, meu Senhor',        'global'),
(NULL, 1025, 'Consagro meu coração em retidão',      'global'),
(NULL, 1026, 'Lugares santos',                       'global'),
(NULL, 1027, 'Ao virmos, hoje, adorar',              'global'),
(NULL, 1028, 'Tenho uma luz em mim',                 'global'),
(NULL, 1029, 'Muitas bênçãos recebo',                'global'),
(NULL, 1030, 'Tão perto ao orar',                    'global'),
(NULL, 1031, 'Ó, vinde, ouvi a voz divina',          'global'),
(NULL, 1032, 'Buscai a Cristo',                      'global'),
(NULL, 1033, 'Oh, que grande alegria é servir',      'global'),
(NULL, 1034, 'Pioneiros como eu',                    'global'),
(NULL, 1035, 'Neste Dia do Senhor',                  'global'),
(NULL, 1036, 'O Livro de Mórmon vou ler',            'global'),
(NULL, 1037, 'Vou viver para a Deus servir',         'global'),
(NULL, 1038, 'O meu Senhor é meu Pastor',            'global'),
(NULL, 1039, 'Porque',                               'global'),
(NULL, 1040, 'Sua voz a soar',                       'global'),
(NULL, 1041, 'Meu coração é Teu, Jesus',             'global'),
(NULL, 1042, 'Bondoso Deus, que nos conduz',         'global'),
(NULL, 1043, 'Faz-nos lembrar',                      'global'),
(NULL, 1044, 'Cristo a todos ministrou',             'global'),
(NULL, 1045, '"Vinde a Mim", diz Jesus',             'global'),
(NULL, 1046, 'Há no céu muitas estrelas',            'global'),
(NULL, 1047, 'Ele me conhece bem',                   'global'),
(NULL, 1048, 'A Ti oramos, Pai Celeste',             'global'),
(NULL, 1049, 'Posso orar como Joseph orou',          'global'),
(NULL, 1050, 'Oh, que estejas junto a mim',          'global'),
(NULL, 1051, 'Senhor, oh, que dia bom!',             'global'),
(NULL, 1052, 'Com eterna alegria e paz',             'global'),
(NULL, 1053, 'Meus convênios',                       'global'),
(NULL, 1054, 'Quando eu for batizado',               'global'),
(NULL, 1055, 'O Espírito vem testificar',            'global'),
(NULL, 1056, 'Elias e a mansa voz',                  'global'),
(NULL, 1057, 'Meu pastor é Jesus Cristo',            'global'),
(NULL, 1058, 'Na noite, és minha canção',            'global'),
(NULL, 1059, 'O mundo Deus criou',                   'global'),
(NULL, 1060, 'Uma arca hoje eu construirei',         'global'),
(NULL, 1061, 'Nosso lar tem amor',                   'global'),
(NULL, 1062, 'Que meu jejum venhas aceitar',         'global'),

-- =========================================================
-- PÁSCOA E NATAL (1201–1210)
-- Nota: salto intencional de 1062 para 1201 no hinário oficial
-- =========================================================
(NULL, 1201, 'Eis a Páscoa do Senhor',               'global'),
(NULL, 1202, 'O menino Jesus nasceu',                'global'),
(NULL, 1203, 'Quem é o menino?',                     'global'),
(NULL, 1204, 'Estrela brilhante e bela',             'global'),
(NULL, 1205, 'Na Páscoa do Senhor',                  'global'),
(NULL, 1206, 'Você viu?',                            'global'),
(NULL, 1207, 'Noite de paz',                         'global'),
(NULL, 1208, 'Ao mundo proclamai',                   'global'),
(NULL, 1209, 'Bebezinho no presépio',                'global'),
(NULL, 1210, 'Os jardins',                           'global');

-- =========================================================
-- RESUMO
-- Total: 204 hinos numerados (1–204) +
--        62 hinos (1001–1062) +
--        10 hinos (1201–1210)
--        = 276 hinos no total
--
-- Os saltos numéricos (204→1001 e 1062→1201) são
-- intencionais e refletem a estrutura do hinário oficial.
-- =========================================================
