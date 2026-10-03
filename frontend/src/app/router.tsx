import { createBrowserRouter } from 'react-router-dom'

export const router = createBrowserRouter([
  {
    path: '/login',
    lazy: () => import('../modules/auth/pages/LoginPage').then(m => ({ Component: m.default })),
  },
  {
    path: '/onboarding',
    lazy: () => import('../modules/auth/pages/OnboardingPage').then(m => ({ Component: m.default })),
  },
  {
    path: '/',
    lazy: () => import('../components/layout/AppShell').then(m => ({ Component: m.default })),
    HydrateFallback: () => null,
    children: [
      {
        index: true,
        lazy: () => import('../modules/dashboard/pages/DashboardPage').then(m => ({ Component: m.default })),
      },
    ],
  },
])