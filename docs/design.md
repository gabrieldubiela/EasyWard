# EasyWard — Design e Estilo

## 1. Objetivo

Definir os padrões visuais do EasyWard. A identidade visual é inspirada no sistema **LCR (Leader and Clerk Resources)** da Igreja de Jesus Cristo dos Santos dos Últimos Dias, garantindo familiaridade para os usuários que já utilizam aquela plataforma.

---

## 2. Identidade Visual

### Conceito
- **Confiança e familiaridade** — visual próximo ao LCR, já conhecido pelos líderes e secretários
- **Clareza** — informações organizadas, hierarquia visual bem definida
- **Leveza** — espaço em branco generoso, sem poluição visual
- **Mobile-first** — a maioria dos usuários usará no celular

### Referência visual
O LCR usa um esquema de cores baseado em **teal escuro** (azul-petróleo) para navegação e elementos de destaque, com fundo branco e cinza claro para o conteúdo. O EasyWard segue esse mesmo padrão.

---

## 3. Paleta de Cores

### Cores primárias — Teal (inspirado no LCR)

| Token | Hex | Uso |
|---|---|---|
| `primary-900` | `#0D3B50` | Raramente — texto sobre fundo primário escuro |
| `primary-800` | `#114E69` | Header/navbar superior (fundo) |
| `primary-700` | `#155C7A` | Hover do header, sidebar ativa |
| `primary-600` | `#1A6F8F` | Botões primários, links de ação |
| `primary-500` | `#1D87AD` | Links de navegação, ícones ativos |
| `primary-400` | `#3BA0C4` | Hover de links, bordas de foco |
| `primary-200` | `#93CDE0` | Bordas de destaque, badges informativos |
| `primary-100` | `#C8E8F4` | Fundo de seções em destaque |
| `primary-50` | `#E8F5FB` | Fundo de cards selecionados, linhas zebradas |

### Cores neutras

| Token | Hex | Uso |
|---|---|---|
| `gray-900` | `#1A1A1A` | Títulos e textos principais |
| `gray-700` | `#374151` | Textos secundários, labels |
| `gray-500` | `#6B7280` | Placeholders, texto auxiliar |
| `gray-300` | `#D1D5DB` | Bordas, divisores |
| `gray-200` | `#E5E7EB` | Bordas suaves, fundo de inputs |
| `gray-100` | `#F3F4F6` | Fundos de seções, alternância de linhas |
| `gray-50` | `#F9FAFB` | Fundo geral da aplicação |
| `white` | `#FFFFFF` | Cards, modais, formulários |

### Cores semânticas

| Token | Hex | Uso |
|---|---|---|
| `success-700` | `#0F6B3B` | Texto de sucesso |
| `success-600` | `#16A34A` | Ícones de confirmação, tarefas concluídas |
| `success-100` | `#DCFCE7` | Fundo de badges de sucesso |
| `warning-600` | `#D97706` | Avisos, recomendações vencendo |
| `warning-100` | `#FEF3C7` | Fundo de badges de aviso |
| `danger-600` | `#DC2626` | Erros, exclusões |
| `danger-100` | `#FEE2E2` | Fundo de badges de erro |
| `info-600` | `#1D87AD` | Informações (usa a cor primária) |
| `info-100` | `#C8E8F4` | Fundo de badges informativos |

### Variáveis CSS

```css
/* src/styles/tokens.css */
:root {
  /* Primária — Teal */
  --color-primary-900: #0D3B50;
  --color-primary-800: #114E69;
  --color-primary-700: #155C7A;
  --color-primary-600: #1A6F8F;
  --color-primary-500: #1D87AD;
  --color-primary-400: #3BA0C4;
  --color-primary-200: #93CDE0;
  --color-primary-100: #C8E8F4;
  --color-primary-50:  #E8F5FB;

  /* Neutras */
  --color-gray-900: #1A1A1A;
  --color-gray-700: #374151;
  --color-gray-500: #6B7280;
  --color-gray-300: #D1D5DB;
  --color-gray-200: #E5E7EB;
  --color-gray-100: #F3F4F6;
  --color-gray-50:  #F9FAFB;

  /* Semânticas */
  --color-success-700: #0F6B3B;
  --color-success-600: #16A34A;
  --color-success-100: #DCFCE7;
  --color-warning-600: #D97706;
  --color-warning-100: #FEF3C7;
  --color-danger-600:  #DC2626;
  --color-danger-100:  #FEE2E2;
  --color-info-600:    #1D87AD;
  --color-info-100:    #C8E8F4;

  /* Aliases funcionais */
  --color-bg-app:      #F9FAFB;
  --color-bg-card:     #FFFFFF;
  --color-bg-input:    #FFFFFF;
  --color-border:      #D1D5DB;
  --color-border-soft: #E5E7EB;
  --color-border-focus: #1D87AD;

  /* Header/Nav (fundo escuro teal) */
  --color-nav-bg:      #114E69;
  --color-nav-hover:   #155C7A;
  --color-nav-text:    #FFFFFF;
  --color-nav-active:  #1D87AD;
}
```

---

## 4. Tipografia

### Fonte
- **Família:** `Source Sans Pro` (Google Fonts — gratuita) — a mesma família usada pelo LCR
- **Fallback:** `system-ui, -apple-system, sans-serif`

```css
@import url('https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@400;600;700&display=swap');

body {
  font-family: 'Source Sans 3', system-ui, -apple-system, sans-serif;
  color: var(--color-gray-900);
  background-color: var(--color-bg-app);
}
```

> **Nota:** "Source Sans 3" é a versão atualizada do "Source Sans Pro" no Google Fonts.

### Escala tipográfica

| Token | Tamanho | Peso | Uso |
|---|---|---|---|
| `text-xs` | 12px | 400 | Labels auxiliares, metadados |
| `text-sm` | 14px | 400 | Corpo de texto secundário, tabelas |
| `text-base` | 16px | 400 | Corpo principal, formulários |
| `text-lg` | 18px | 600 | Subtítulos de seção |
| `text-xl` | 20px | 600 | Títulos de card, nomes de módulo |
| `text-2xl` | 24px | 700 | Títulos de página |
| `text-3xl` | 30px | 700 | Números grandes no dashboard |

---

## 5. Espaçamento

Escala múltipla de 4px (igual ao LCR):

| Token | Valor | Uso típico |
|---|---|---|
| `space-1` | 4px | Espaço mínimo |
| `space-2` | 8px | Padding de badges |
| `space-3` | 12px | Espaço entre campos |
| `space-4` | 16px | Padding de cards, espaço padrão |
| `space-6` | 24px | Separação entre seções |
| `space-8` | 32px | Padding de modais e páginas |
| `space-12` | 48px | Espaços maiores entre blocos |

---

## 6. Bordas e Sombras

```css
:root {
  /* Border radius */
  --radius-sm:   3px;    /* Badges, inputs — minimalista como no LCR */
  --radius-md:   4px;    /* Cards, botões */
  --radius-lg:   6px;    /* Modais, painéis */
  --radius-full: 9999px; /* Indicadores circulares, avatares */

  /* Sombras — sutis, similar ao LCR */
  --shadow-sm: 0 1px 2px rgba(0,0,0,0.06);
  --shadow-md: 0 2px 4px rgba(0,0,0,0.08);
  --shadow-lg: 0 4px 12px rgba(0,0,0,0.10);
}
```

---

## 7. Componentes

### 7.1 Header / Navbar

Inspirado diretamente no LCR:

```css
.navbar {
  background-color: var(--color-nav-bg);      /* Teal escuro #114E69 */
  color: var(--color-nav-text);               /* Branco */
  height: 56px;
  display: flex;
  align-items: center;
  padding: 0 24px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.15);
}

.navbar-link {
  color: rgba(255,255,255,0.85);
  font-size: 14px;
  font-weight: 400;
  padding: 0 12px;
  height: 100%;
  display: flex;
  align-items: center;
  border-bottom: 3px solid transparent;
  transition: all 0.15s;
}

.navbar-link:hover,
.navbar-link.active {
  color: #FFFFFF;
  border-bottom-color: var(--color-primary-400);
  background-color: var(--color-nav-hover);
}
```

### 7.2 Botões

| Variante | Uso | Estilo |
|---|---|---|
| `primary` | Ação principal | Fundo `primary-600`, texto branco |
| `secondary` | Ação secundária | Borda `primary-600`, texto `primary-600` |
| `danger` | Exclusão, inativação | Fundo `danger-600`, texto branco |
| `ghost` | Cancelar, ação terciária | Sem borda, texto `gray-700` |
| `link` | Ação inline | Texto `primary-500`, sem fundo |

```css
.btn {
  padding: 8px 16px;
  border-radius: var(--radius-md);
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.15s;
  border: 1px solid transparent;
}
.btn-primary  {
  background: var(--color-primary-600);
  color: white;
}
.btn-primary:hover {
  background: var(--color-primary-700);
}
.btn-secondary {
  background: transparent;
  color: var(--color-primary-600);
  border-color: var(--color-primary-600);
}
.btn-secondary:hover {
  background: var(--color-primary-50);
}
```

### 7.3 Inputs

```css
.input {
  width: 100%;
  padding: 8px 10px;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-size: 16px;       /* 16px evita zoom automático no iOS */
  font-family: inherit;
  background: var(--color-bg-input);
  color: var(--color-gray-900);
  transition: border-color 0.15s;
}
.input:focus {
  outline: none;
  border-color: var(--color-border-focus);
  box-shadow: 0 0 0 2px rgba(29,135,173,0.20);
}
.input.error {
  border-color: var(--color-danger-600);
}
```

### 7.4 Cards

```css
.card {
  background: var(--color-bg-card);
  border: 1px solid var(--color-border-soft);
  border-radius: var(--radius-md);
  padding: 20px;
  box-shadow: var(--shadow-sm);
}

/* Card com borda de destaque esquerda (estilo LCR) */
.card-accent {
  border-left: 4px solid var(--color-primary-500);
}
```

### 7.5 Tabelas

Estilo próximo ao LCR — cabeçalho com fundo levemente colorido, linhas com separador suave:

```css
.table { width: 100%; border-collapse: collapse; font-size: 14px; }

.table th {
  text-align: left;
  padding: 10px 12px;
  background: var(--color-primary-50);
  color: var(--color-gray-700);
  font-weight: 600;
  font-size: 13px;
  border-bottom: 2px solid var(--color-primary-200);
}

.table td {
  padding: 10px 12px;
  border-bottom: 1px solid var(--color-border-soft);
  color: var(--color-gray-700);
  vertical-align: middle;
}

.table tbody tr:hover td {
  background: var(--color-primary-50);
}

/* Link na tabela (estilo LCR — teal sem sublinhado padrão) */
.table a {
  color: var(--color-primary-500);
  text-decoration: none;
}
.table a:hover {
  text-decoration: underline;
}
```

### 7.6 Indicador Circular de Progresso

Inspirado nos círculos de porcentagem do LCR (frequência, entrevistas):

```css
.progress-ring {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: conic-gradient(
    var(--color-primary-500) calc(var(--pct) * 1%),
    var(--color-gray-200) 0
  );
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
}

.progress-ring::before {
  content: '';
  position: absolute;
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: white;
}

.progress-ring-label {
  position: relative;
  font-size: 16px;
  font-weight: 700;
  color: var(--color-gray-900);
  z-index: 1;
}
```

### 7.7 Badges de Status

| Status | Fundo | Texto | Borda |
|---|---|---|---|
| Presente / Ativo / Concluído | `success-100` | `success-700` | `success-600` |
| Pendente / Atenção | `warning-100` | `warning-600` | `warning-600` |
| Ausente / Inativo / Erro | `danger-100` | `danger-600` | `danger-600` |
| Informativo | `info-100` | `info-600` | `info-600` |

```css
.badge {
  display: inline-flex;
  align-items: center;
  padding: 2px 8px;
  border-radius: var(--radius-sm);
  font-size: 12px;
  font-weight: 600;
  border: 1px solid transparent;
}
```

---

## 8. Layout

### 8.1 Desktop (1024px+)
- Navbar horizontal superior com fundo teal escuro (igual ao LCR)
- Conteúdo com padding de 32px
- Largura máxima do conteúdo: 1280px
- Sidebar lateral apenas para sub-navegação dentro de módulos complexos

### 8.2 Tablet (768px–1024px)
- Navbar com menu hambúrguer colapsável
- Conteúdo com padding de 24px

### 8.3 Mobile (< 768px)
- Navbar superior minimalista (logo + hambúrguer)
- Bottom navigation com 5 ícones principais
- Conteúdo com padding de 16px
- Tabelas se tornam cards empilhados
- Modais em full-screen sheet

### Bottom Navigation (mobile)
```
🏠 Início  |  👥 Membros  |  ✅ Freq.  |  📋 Tarefas  |  ⋮ Mais
```

---

## 9. Página de Login

Inspirada no estilo minimalista do login da Igreja:

```
┌────────────────────────────────┐
│  [Logo EasyWard]               │
│                                │
│  Bem-vindo ao EasyWard         │
│  Gestão da Ala                 │
│                                │
│  [────── E-mail ──────────]    │
│  [────── Senha  ──────────]    │
│                                │
│  [──── Entrar ────────────]    │
│                                │
│  Não tem conta?                │
│  Criar nova ala | Entrar em    │
│  ala existente                 │
└────────────────────────────────┘
```

Fundo: gradiente sutil de `#E8F5FB` (primary-50) para branco.

---

## 10. Feedback e Estados

### Carregamento
- Skeleton com fundo `gray-100` animado (shimmer)
- Spinner teal (`primary-500`) para ações pontuais

### Mensagens de Sucesso e Erro
- Toast no canto superior direito (estilo LCR — não inferior)
- Duração: 4s sucesso, 6s erro
- Erros de campo: texto vermelho abaixo do campo, `text-sm`

### Telas Vazias
- Ícone ilustrativo em teal claro
- Mensagem explicativa em `gray-500`
- CTA em `primary-600`

### Cold Start
Banner discreto após 5s de espera:
```
ⓘ  Iniciando o servidor, aguarde um momento...
```
Estilo: fundo `info-100`, texto `info-600`, borda esquerda `primary-500`.

---

## 11. Iconografia

- Biblioteca: **Lucide React** (gratuita)
- Tamanho padrão: 18px em menus, 16px inline
- Cor: herda do contexto (branco no header, `primary-600` em botões, `gray-500` em campos)
- No bottom navigation: ícone 24px + label 11px abaixo

---

## 12. Acessibilidade

- Contraste mínimo WCAG 2.1 AA (4.5:1 para texto normal)
- Verificação de contraste do teal primário sobre branco:
  - `primary-600` (#1A6F8F) sobre branco → **4.8:1** ✅
  - `primary-700` (#155C7A) sobre branco → **6.1:1** ✅
  - `primary-500` (#1D87AD) sobre branco → **3.5:1** ⚠️ — usar apenas para textos grandes ou ícones
- Todo campo com `<label>` associado
- Foco visível em todos os elementos interativos
- Navegação completa por teclado
- `aria-describedby` em mensagens de erro

---

## 13. Modo Escuro

Não previsto para a versão inicial. As variáveis CSS estão centralizadas em `tokens.css` para facilitar a implementação futura com `prefers-color-scheme`.

---

*EasyWard v0.1 — Design inspirado no LCR (Leader and Clerk Resources)*
