import { NavLink } from 'react-router-dom'
import {
  Home,
  Users,
  CheckSquare,
  Calendar,
  ClipboardList,
  Settings,
} from 'lucide-react'

const navItems = [
  { to: '/',         icon: Home,          label: 'Início' },
  { to: '/members',  icon: Users,         label: 'Membros' },
  { to: '/attendance', icon: CheckSquare, label: 'Frequência' },
  { to: '/meetings', icon: Calendar,      label: 'Reuniões' },
  { to: '/tasks',    icon: ClipboardList, label: 'Tarefas' },
  { to: '/settings', icon: Settings,      label: 'Configurações' },
]

export default function Sidebar() {
  return (
    <div className="h-full bg-white border-r border-[var(--color-border)] flex flex-col">
      <nav className="flex-1 py-4">
        {navItems.map(({ to, icon: Icon, label }) => (
          <NavLink
            key={to}
            to={to}
            end={to === '/'}
            className={({ isActive }) => `
              flex items-center gap-3 px-4 py-2.5 text-sm
              transition-colors duration-150
              ${isActive
                ? 'bg-[var(--color-primary-50)] text-[var(--color-primary-600)] font-semibold border-r-2 border-[var(--color-primary-600)]'
                : 'text-[var(--color-gray-700)] hover:bg-[var(--color-gray-100)]'
              }
            `}
          >
            <Icon size={18} />
            {label}
          </NavLink>
        ))}
      </nav>
    </div>
  )
}