interface LoaderProps {
  size?: 'sm' | 'md' | 'lg'
  className?: string
}

const sizes = {
  sm: 'w-4 h-4',
  md: 'w-8 h-8',
  lg: 'w-12 h-12',
}

export default function Loader({ size = 'md', className = '' }: LoaderProps) {
  return (
    <div
      className={`
        ${sizes[size]}
        border-2 border-gray-200
        border-t-(--color-primary-500)
        rounded-full animate-spin
        ${className}
      `}
    />
  )
}