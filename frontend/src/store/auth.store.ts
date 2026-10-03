import { create } from 'zustand'
import type { User } from '../types/user.types'

interface AuthState {
  // Estado
  user: User | null
  accessToken: string | null
  isAuthenticated: boolean

  // Ações
  setAuth: (user: User, accessToken: string) => void
  clearAuth: () => void
  hasPermission: (code: string) => boolean
}

export const useAuthStore = create<AuthState>((set, get) => ({
  // Valores iniciais
  user: null,
  accessToken: null,
  isAuthenticated: false,

  // Chamado após login bem-sucedido
  setAuth: (user, accessToken) => set({
    user,
    accessToken,
    isAuthenticated: true,
  }),

  // Chamado após logout
  clearAuth: () => set({
    user: null,
    accessToken: null,
    isAuthenticated: false,
  }),

  // Verifica se o usuário tem uma permissão específica
  hasPermission: (code) => {
    const { user } = get()
    return user?.permissions.includes(code) ?? false
  },
}))