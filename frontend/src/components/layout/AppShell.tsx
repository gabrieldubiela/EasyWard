import { Outlet } from 'react-router-dom'
import Header from './Header'
import Sidebar from './Sidebar'
import BottomNav from './BottomNav'

export default function AppShell() {
  return (
    <div className="min-h-screen flex flex-col bg-[var(--color-bg-app)]">
      
      {/* Header fixo no topo */}
      <Header />

      <div className="flex flex-1">
        
        {/* Sidebar — só aparece no desktop */}
        <aside className="hidden md:block w-64 shrink-0">
          <Sidebar />
        </aside>

        {/* Conteúdo principal */}
        <main className="flex-1 p-6 overflow-auto">
          <Outlet />
        </main>

      </div>

      {/* BottomNav — só aparece no mobile */}
      <div className="md:hidden">
        <BottomNav />
      </div>

    </div>
  )
}