import { createBrowserRouter } from 'react-router-dom'
import PrivateRoute from '@/components/layout/PrivateRoute'

export const router = createBrowserRouter([
  {
    path: '/login',
    lazy: () => import('../modules/auth/pages/LoginPage.tsx').then(m => ({ Component: m.default })),
  },
  {
    path: '/onboarding',
    lazy: () => import('../modules/auth/pages/OnboardingPage.tsx').then(m => ({ Component: m.default })),
  },
  {
    path: '/',
    element: <PrivateRoute />,
    children: [
      {
        path: '/',
        lazy: () => import('../components/layout/AppShell.tsx').then(m => ({ Component: m.default })),
        HydrateFallback: () => null,
        children: [
          {
            index: true,
            lazy: () => import('../modules/dashboard/pages/DashboardPage.tsx').then(m => ({ Component: m.default })),
          },
        ],
      },
    ],
  },
])