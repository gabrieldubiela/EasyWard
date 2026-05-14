# EasyWard — Backup e Recuperação

## 1. Objetivo

Definir a estratégia de cópia de segurança e recuperação dos dados, considerando as limitações do Supabase Free.

---

## 2. ⚠️ Limitação Crítica — Supabase Free

O plano gratuito do Supabase **não inclui backups automáticos**. Backups agendados e Point-in-Time Recovery (PITR) são exclusivos do plano Pro. Toda a responsabilidade de backup é do projeto.

Sem uma estratégia ativa, **erro humano ou falha pode resultar em perda permanente de dados.**

---

## 3. Estratégia

| Decisão | Escolha |
|---|---|
| Ferramenta | `pg_dump` (nativo do PostgreSQL) |
| Automação | GitHub Actions (cron diário) |
| Destino | Google Drive via `rclone` |
| Tipo | Backup completo (incremental inviável no plano gratuito) |

---

## 4. Frequência e Retenção

| Tipo | Frequência | Horário (BRT) | Retenção |
|---|---|---|---|
| Diário | Todo dia | 02:00 | 7 cópias (7 dias) |
| Semanal | Todo domingo | 02:30 | 4 cópias (1 mês) |
| Mensal | Dia 1 de cada mês | 03:00 | 3 cópias (3 meses) |
| Pré-deploy | Antes de qualquer deploy com risco | Manual | Indefinido |

---

## 5. Implementação via GitHub Actions

```yaml
# .github/workflows/backup.yml
name: Backup do Banco de Dados

on:
  schedule:
    - cron: '0 5 * * *'      # Diário às 02:00 BRT (UTC-3)
    - cron: '30 5 * * 0'     # Semanal domingo às 02:30 BRT
    - cron: '0 6 1 * *'      # Mensal dia 1 às 03:00 BRT
  workflow_dispatch:          # Disparo manual

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - name: Instalar cliente PostgreSQL e rclone
        run: |
          sudo apt-get install -y postgresql-client
          curl https://rclone.org/install.sh | sudo bash

      - name: Configurar rclone (Google Drive)
        env:
          RCLONE_CONFIG: ${{ secrets.RCLONE_CONFIG }}
        run: |
          mkdir -p ~/.config/rclone
          echo "$RCLONE_CONFIG" > ~/.config/rclone/rclone.conf

      - name: Gerar backup
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
        run: |
          FILENAME="backup_$(date +%Y%m%d_%H%M%S).sql"
          pg_dump "$DATABASE_URL" \
            --no-owner \
            --no-acl \
            --format=plain \
            --file="$FILENAME"
          echo "FILENAME=$FILENAME" >> $GITHUB_ENV

      - name: Enviar para Google Drive
        run: |
          rclone copy "$FILENAME" "gdrive:EasyWard/backups/$(date +%Y/%m)"

      - name: Remover arquivo local
        run: rm -f "$FILENAME"

      - name: Limpar backups antigos (diários > 7 dias)
        run: |
          rclone delete "gdrive:EasyWard/backups" \
            --min-age 7d \
            --include "backup_*.sql"
```

> A variável `RCLONE_CONFIG` deve ser gerada localmente com `rclone config` e armazenada como secret no GitHub. A `DATABASE_URL` também deve ser secret — nunca em texto claro.

---

## 6. Estrutura no Google Drive

```
EasyWard/
└── backups/
    └── 2025/
        ├── 01/
        │   ├── backup_20250101_030000.sql  ← mensal
        │   ├── backup_20250105_020000.sql  ← diário
        │   └── backup_20250112_023000.sql  ← semanal
        └── 02/
            └── ...
```

---

## 7. Procedimento de Restauração

1. Baixar o arquivo `.sql` mais recente do Google Drive
2. Criar banco temporário ou limpar o banco atual:
   ```sql
   DROP SCHEMA public CASCADE;
   CREATE SCHEMA public;
   ```
3. Restaurar o dump:
   ```bash
   psql "$DATABASE_URL" --file=backup_YYYYMMDD_HHMMSS.sql
   ```
4. Verificar integridade: contar registros nas tabelas principais
5. Registrar a ocorrência (data, causa, backup utilizado, responsável)

> ⚠️ Nunca teste a restauração diretamente no banco de produção. Use um banco temporário no Supabase (projeto separado) ou localmente via Docker.

---

## 8. Verificação Mensal

No primeiro dia útil de cada mês:

- [ ] Confirmar que os backups do mês anterior foram gerados (verificar pasta no Drive)
- [ ] Baixar o backup mais recente
- [ ] Restaurar em ambiente de teste
- [ ] Contar registros nas tabelas principais e comparar com o esperado
- [ ] Registrar resultado (data, sucesso/falha, observações)

---

## 9. Reativação do Supabase

O Supabase Free pausa projetos após 7 dias sem acesso. O UptimeRobot resolve isso mantendo o backend ativo. Se o projeto pausar mesmo assim:

1. Acessar o painel do Supabase
2. Reativar o projeto com um clique
3. Nenhum dado é perdido — o banco apenas estava suspenso

---

## 10. RPO e RTO

| Métrica | Valor | Significado |
|---|---|---|
| RPO (perda máxima de dados) | 24 horas | No pior caso, perde-se o dia atual |
| RTO (tempo máximo de recuperação) | 2 horas | Tempo estimado para restaurar e validar |

---

## 11. Segurança dos Backups

- `DATABASE_URL` armazenada exclusivamente como secret no GitHub
- Arquivos no Google Drive com acesso restrito à conta do responsável técnico
- Nenhum dado sensível no nome dos arquivos de backup

---

*EasyWard v0.1*
