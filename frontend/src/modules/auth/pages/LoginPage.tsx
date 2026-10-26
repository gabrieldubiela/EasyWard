import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { useNavigate } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { useAuthStore } from '@/store/auth.store'
import api from '@/lib/axios'

const loginSchema = z.object({
  email: z.string().email('E-mail inválido'),
  password: z.string().min(1, 'Senha obrigatória'),
})

type LoginForm = z.infer<typeof loginSchema>

export default function LoginPage() {
  const navigate = useNavigate()
  const setAuth = useAuthStore((state) => state.setAuth)

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    setError,
  } = useForm<LoginForm>({
    resolver: zodResolver(loginSchema),
  })

  async function onSubmit(data: LoginForm) {
    try {
      const response = await api.post('/auth/login', data)
      const { access_token, user } = response.data.data
      setAuth(user, access_token)
      navigate('/')
    } catch {
      setError('root', { message: 'E-mail ou senha inválidos.' })
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-(--color-bg-app)">
      <div className="w-full max-w-sm bg-white rounded-lg shadow p-8 flex flex-col gap-6">

        {/* Logo */}
        <div className="text-center">
          <h1 className="text-2xl font-bold text-(--color-primary-800)">
            EasyWard
          </h1>
          <p className="text-sm text-gray-500 mt-1">
            Gestão de Ala
          </p>
        </div>

        {/* Formulário */}
        <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">

          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-gray-700)">
              E-mail
            </label>
            <Input
              type="email"
              placeholder="seu@email.com"
              {...register('email')}
            />
            {errors.email && (
              <span className="text-xs text-(--color-danger-600)">
                {errors.email.message}
              </span>
            )}
          </div>

          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-gray-700">
              Senha
            </label>
            <Input
              type="password"
              placeholder="••••••••"
              {...register('password')}
            />
            {errors.password && (
              <span className="text-xs text-(--color-danger-600)">
                {errors.password.message}
              </span>
            )}
          </div>

          {errors.root && (
            <span className="text-xs text-(--color-danger-600) text-center">
              {errors.root.message}
            </span>
          )}

          <Button type="submit" className="w-full" disabled={isSubmitting}>
            {isSubmitting ? 'Entrando...' : 'Entrar'}
          </Button>

        </form>

        {/* Links */}
        <div className="text-center text-sm text-gray-500 flex flex-col gap-1">
          <a href="/onboarding" className="text-(--color-primary-600) hover:underline">
            Criar nova ala
          </a>
          <a href="/onboarding" className="text-(--color-primary-600) hover:underline">
            Entrar em ala existente
          </a>
        </div>

      </div>
    </div>
  )
}