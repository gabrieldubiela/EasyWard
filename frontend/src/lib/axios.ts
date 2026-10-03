import axios from 'axios'
import { useAuthStore } from '../store/auth.store'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  withCredentials: true,
})

// Interceptor de requisição — adiciona o token em cada chamada
api.interceptors.request.use((config) => {
  const token = useAuthStore.getState().accessToken
  if (token) {
    config.headers['Authorization'] = `Bearer ${token}`
  }
  return config
})

// Interceptor de resposta — renova token se expirado
api.interceptors.response.use(
  (response) => response,

  async (error) => {
    const originalRequest = error.config

    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true

      try {
        const { data } = await api.post('/auth/refresh')
        const newToken = data.data.access_token

        // Atualizar o store com o novo token
        const { user } = useAuthStore.getState()
        if (user) {
          useAuthStore.getState().setAuth(user, newToken)
        }

        originalRequest.headers['Authorization'] = `Bearer ${newToken}`
        return api(originalRequest)

      } catch {
        useAuthStore.getState().clearAuth()
        window.location.href = '/login'
        return Promise.reject(error)
      }
    }

    return Promise.reject(error)
  }
)

export default api