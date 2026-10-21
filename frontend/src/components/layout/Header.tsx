import { Menu } from 'lucide-react'
import { useAuthStore } from '@/store/auth.store'

interface HeaderProps {
  onMenuClick?: () => void
}

export default function Header({ onMenuClick }: HeaderProps) {
  const user = useAuthStore((state) => state.user)

  return (
    <header className="h-14 bg-[var(--color-nav-bg)] text-white flex items-center px-4 shrink-0 gap-4">
      
      {/* Botão hambúrguer — só no mobile */}
      <button
        className="md:hidden p-1 rounded hover:bg-[var(--color-nav-hover)]"
        onClick={onMenuClick}
      >
        <Menu size={20} />
      </button>

      {/* Logo */}
      <span className="font-semibold text-lg">EasyWard</span>

      {/* Espaço */}
      <div className="flex-1" />

      {/* Nome do usuário */}
      {user && (
        <span className="text-sm text-white/80 hidden sm:block">
          {user.name}
        </span>
      )}

    </header>
  )
}