import type { ButtonHTMLAttributes } from 'react'

type Variant = 'primary' | 'secondary' | 'danger' | 'ghost'
type Size = 'sm' | 'md' | 'lg'

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant
  size?: Size
  loading?: boolean
}

const base = `
  inline-flex items-center justify-center
  font-semibold cursor-pointer
  border rounded transition-all duration-150
  disabled:opacity-50 disabled:cursor-not-allowed
`

const variants: Record<Variant, string> = {
  primary:   'bg-[var(--color-primary-600)] text-white border-transparent hover:bg-[var(--color-primary-700)]',
  secondary: 'bg-transparent text-[var(--color-primary-600)] border-[var(--color-primary-600)] hover:bg-[var(--color-primary-50)]',
  danger:    'bg-[var(--color-danger-600)] text-white border-transparent hover:opacity-90',
  ghost:     'bg-transparent text-[var(--color-gray-700)] border-transparent hover:bg-[var(--color-gray-100)]',
}

const sizes: Record<Size, string> = {
  sm: 'text-sm px-3 py-1.5',
  md: 'text-sm px-4 py-2',
  lg: 'text-base px-6 py-2.5',
}

export default function Button({
  variant = 'primary',
  size = 'md',
  loading = false,
  disabled,
  children,
  className = '',
  ...props
}: ButtonProps) {
  return (
    <button
      className={`${base} ${variants[variant]} ${sizes[size]} ${className}`}
      disabled={disabled || loading}
      {...props}
    >
      {loading ? 'Carregando...' : children}
    </button>
  )
}