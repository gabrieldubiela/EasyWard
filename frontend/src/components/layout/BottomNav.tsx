import { NavLink } from 'react-router-dom'
import { Home, Users, CheckSquare, Calendar, MoreHorizontal } from 'lucide-react'

const navItems = [
  { to: '/',           icon: Home,          label: 'Início' },
  { to: '/members',    icon: Users,         label: 'Membros' },
  { to: '/attendance', icon: CheckSquare,   label: 'Frequência' },
  { to: '/meetings',   icon: Calendar,      label: 'Reuniões' },
  { to: '/more',       icon: MoreHorizontal, label: 'Mais' },
]

export default function BottomNav() {
  return (
    <nav className="h-16 bg-white border-t border-[var(--color-border)] flex items-center justify-around px-2 shrink-0">
      {navItems.map(({ to, icon: Icon, label }) => (
        <NavLink
          key={to}
          to={to}
          end={to === '/'}
          className={({ isActive }) => `
            flex flex-col items-center gap-1 px-3 py-1 rounded-lg
            text-xs transition-colors duration-150
            ${isActive
              ? 'text-[var(--color-primary-600)]'
              : 'text-[var(--color-gray-500)]'
            }
          `}
        >
          <Icon size={22} />
          {label}
        </NavLink>
      ))}
    </nav>
  )
}