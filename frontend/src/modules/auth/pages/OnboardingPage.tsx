import { useForm } from 'react-hook-form'
import { useNavigate } from 'react-router-dom'
import { zodResolver } from '@hookform/resolvers/zod'
import { useAuthStore } from '@/store/auth.store'
import { useEffect, useState } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { newWardSchema, existingWardSchema } from '../schemas/onboarding.schema'
import type { NewWardForm, ExistingWardForm } from '../schemas/onboarding.schema'
import * as authService from '../services/auth.service'
import type { Estado, Estaca, Ala } from '@/types/common.types'
import type { NavigateFunction } from 'react-router-dom'
import type { User } from '@/types/user.types'

// ─── Escolha do fluxo ───────────────────────────────────────────
function EscolhaFluxo({ onEscolha }: { onEscolha: (f: 'nova-ala' | 'ala-existente') => void }) {
  return (
    <div className="flex flex-col gap-3">
      <p className="text-sm text-center text-gray-700">
        Como deseja continuar?
      </p>
      <Button className="w-full" onClick={() => onEscolha('nova-ala')}>
        Criar nova ala
      </Button>
      <Button className="w-full" variant="outline" onClick={() => onEscolha('ala-existente')}>
        Entrar em ala existente
      </Button>
    </div>
  )
}

// ─── Formulário: Nova Ala ────────────────────────────────────────
function NovaAlaForm({ 
  setAuth, 
  navigate 
}: { 
  setAuth: (user: User, token: string) => void
  navigate: NavigateFunction 
}) {
  const [estados, setEstados] = useState<Estado[]>([])
  const [estacas, setEstacas] = useState<Estaca[]>([])
  const [novaEstaca, setNovaEstaca] = useState(false)

  const {
    register,
    handleSubmit,
    watch,
    setValue,
    formState: { errors, isSubmitting },
    setError,
  } = useForm<NewWardForm>({ resolver: zodResolver(newWardSchema) })

  const estadoId = watch('estado_id')

  // Carregar estados ao montar
  useEffect(() => {
    authService.getStates().then(setEstados)
  }, [])

  // Carregar estacas quando estado mudar
  useEffect(() => {
    if (estadoId) {
      authService.getStakesByState(estadoId).then(setEstacas)
      setValue('estaca_id', undefined)
    }
  }, [estadoId, setValue])

  async function onSubmit(data: NewWardForm) {
    try {
      const result = await authService.registerNewWard(data)
      setAuth(result.user, result.access_token)
      navigate('/')
    } catch {
      setError('root', { message: 'Erro ao criar ala. Tente novamente.' })
    }
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
      <p className="text-sm font-semibold text-gray-700">
        Criar nova ala
      </p>

      {/* Estado */}
      <div className="flex flex-col gap-1">
        <label className="text-sm font-medium text-gray-700">Estado</label>
        <select
          className="h-8 w-full rounded-lg border border-input px-2.5 text-sm"
          {...register('estado_id', { valueAsNumber: true })}
        >
          <option value="">Selecione...</option>
          {estados.map(e => (
            <option key={e.id} value={e.id}>{e.nome}</option>
          ))}
        </select>
        {errors.estado_id && <span className="text-xs text-(--color-danger-600)">{errors.estado_id.message}</span>}
      </div>

      {/* Estaca */}
      <div className="flex flex-col gap-1">
        <label className="text-sm font-medium text-gray-700">Estaca</label>
        {!novaEstaca ? (
          <>
            <select
              className="h-8 w-full rounded-lg border border-input px-2.5 text-sm"
              {...register('estaca_id', { valueAsNumber: true })}
              disabled={!estadoId}
            >
              <option value="">Selecione...</option>
              {estacas.map(e => (
                <option key={e.id} value={e.id}>{e.nome}</option>
              ))}
            </select>
            <button
              type="button"
              className="text-xs text-(--color-primary-600) hover:underline text-left"
              onClick={() => setNovaEstaca(true)}
            >
              + Criar nova estaca
            </button>
          </>
        ) : (
          <>
            <Input placeholder="Nome da nova estaca" {...register('estaca_nome')} />
            <button
              type="button"
              className="text-xs text-(--color-primary-600) hover:underline text-left"
              onClick={() => setNovaEstaca(false)}
            >
              ← Selecionar estaca existente
            </button>
          </>
        )}
        {errors.estaca_nome && <span className="text-xs text-(--color-danger-600)">{errors.estaca_nome.message}</span>}
      </div>

      {/* Nome da ala */}
      <div className="flex flex-col gap-1">
        <label className="text-sm font-medium text-gray-700">Nome da Ala</label>
        <Input placeholder="Ex: Ala Orquidário" {...register('ala_nome')} />
        {errors.ala_nome && <span className="text-xs text-(--color-danger-600)">{errors.ala_nome.message}</span>}
      </div>

      {/* Dados pessoais */}
      <div className="flex flex-col gap-1">
        <label className="text-sm font-medium text-gray-700">Seu nome completo</label>
        <Input placeholder="Nome Sobrenome" {...register('nome_completo')} />
        {errors.nome_completo && <span className="text-xs text-(--color-danger-600)">{errors.nome_completo.message}</span>}
      </div>

      <div className="flex flex-col gap-1">
        <label className="text-sm font-medium text-gray-700">E-mail</label>
        <Input type="email" placeholder="seu@email.com" {...register('email')} />
        {errors.email && <span className="text-xs text-(--color-danger-600)">{errors.email.message}</span>}
      </div>

      <div className="flex flex-col gap-1">
        <label className="text-sm font-medium text-gray-700">Senha</label>
        <Input type="password" placeholder="••••••••" {...register('password')} />
        {errors.password && <span className="text-xs text-(--color-danger-600)">{errors.password.message}</span>}
      </div>

      {errors.root && (
        <span className="text-xs text-(--color-danger-600) text-center">{errors.root.message}</span>
      )}

      <Button type="submit" className="w-full" disabled={isSubmitting}>
        {isSubmitting ? 'Criando ala...' : 'Criar ala'}
      </Button>
    </form>
  )
}

// ─── Formulário: Ala Existente ───────────────────────────────────
function AlaExistenteForm({ 
  setAuth, 
  navigate 
}: { 
  setAuth: (user: User, token: string) => void
  navigate: NavigateFunction 
}) {
  const [estados, setEstados] = useState<Estado[]>([])
  const [estacas, setEstacas] = useState<Estaca[]>([])
  const [alas, setAlas] = useState<Ala[]>([])

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    setError,
  } = useForm<ExistingWardForm>({ resolver: zodResolver(existingWardSchema) })

  const [estadoId, setEstadoId] = useState<number | null>(null)
  const [estacaId, setEstacaId] = useState<number | null>(null)

  useEffect(() => {
    authService.getStates().then(setEstados)
  }, [])

  useEffect(() => {
    if (estadoId) {
      authService.getStakesByState(estadoId).then(setEstacas)
    }
  }, [estadoId])

  useEffect(() => {
    if (estacaId) {
      authService.getWardsByStake(estacaId).then(setAlas)
    }
  }, [estacaId])

  async function onSubmit(data: ExistingWardForm) {
    try {
      const result = await authService.registerExistingWard(data)
      setAuth(result.user, result.access_token)
      navigate('/')
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Erro ao cadastrar. Tente novamente.'
      setError('root', { message })
    }
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
      <p className="text-sm font-semibold text-gray-700">
        Entrar em ala existente
      </p>

      {/* Estado */}
      <div className="flex flex-col gap-1">
        <label className="text-sm font-medium text-gray-700">Estado</label>
        <select
          className="h-8 w-full rounded-lg border border-input px-2.5 text-sm"
          onChange={e => {
            setEstadoId(Number(e.target.value))
            setEstacaId(null)
            setAlas([])
          }}
        >
          <option value="">Selecione...</option>
          {estados.map(e => (
            <option key={e.id} value={e.id}>{e.nome}</option>
          ))}
        </select>
      </div>

      {/* Estaca */}
      <div className="flex flex-col gap-1">
        <label className="text-sm font-medium text-gray-700">Estaca</label>
        <select
          className="h-8 w-full rounded-lg border border-input px-2.5 text-sm"
          disabled={!estadoId}
          onChange={e => setEstacaId(Number(e.target.value))}
        >
          <option value="">Selecione...</option>
          {estacas.map(e => (
            <option key={e.id} value={e.id}>{e.nome}</option>
          ))}
        </select>
      </div>

      {/* Ala */}
      <div className="flex flex-col gap-1">
        <label className="text-sm font-medium text-gray-700">Ala</label>
        <select
          className="h-8 w-full rounded-lg border border-input px-2.5 text-sm"
          disabled={!estacaId}
          {...register('ala_id', { valueAsNumber: true })}
        >
          <option value="">Selecione...</option>
          {alas.map(a => (
            <option key={a.id} value={a.id}>{a.nome}</option>
          ))}
        </select>
        {errors.ala_id && <span className="text-xs text-(--color-danger-600)">{errors.ala_id.message}</span>}
      </div>

      {/* Dados pessoais */}
      <div className="flex flex-col gap-1">
        <label className="text-sm font-medium text-gray-700">Seu nome completo</label>
        <Input placeholder="Exatamente como está no cadastro da ala" {...register('nome_completo')} />
        {errors.nome_completo && <span className="text-xs text-(--color-danger-600)">{errors.nome_completo.message}</span>}
      </div>

      <div className="flex flex-col gap-1">
        <label className="text-sm font-medium text-gray-700">E-mail</label>
        <Input type="email" placeholder="seu@email.com" {...register('email')} />
        {errors.email && <span className="text-xs text-(--color-danger-600)">{errors.email.message}</span>}
      </div>

      <div className="flex flex-col gap-1">
        <label className="text-sm font-medium text-gray-700">Senha</label>
        <Input type="password" placeholder="••••••••" {...register('password')} />
        {errors.password && <span className="text-xs text-(--color-danger-600)">{errors.password.message}</span>}
      </div>

      {errors.root && (
        <span className="text-xs text-(--color-danger-600) text-center">{errors.root.message}</span>
      )}

      <Button type="submit" className="w-full" disabled={isSubmitting}>
        {isSubmitting ? 'Cadastrando...' : 'Cadastrar'}
      </Button>
    </form>
  )
}

type Fluxo = 'escolha' | 'nova-ala' | 'ala-existente'

export default function OnboardingPage() {
  const [fluxo, setFluxo] = useState<Fluxo>('escolha')
  const navigate = useNavigate()
  const setAuth = useAuthStore((state) => state.setAuth)

  return (
    <div className="min-h-screen flex items-center justify-center bg-(--color-bg-app)">
      <div className="w-full max-w-md bg-white rounded-lg shadow p-8 flex flex-col gap-6">

        {/* Logo */}
        <div className="text-center">
          <h1 className="text-2xl font-bold text-(--color-primary-800)">
            EasyWard
          </h1>
          <p className="text-sm text-gray-500 mt-1">
            Configuração inicial
          </p>
        </div>

        {/* Conteúdo muda conforme o fluxo */}
        {fluxo === 'escolha' && (
          <EscolhaFluxo onEscolha={setFluxo} />
        )}
        {fluxo === 'nova-ala' && (
          <NovaAlaForm setAuth={setAuth} navigate={navigate} />
        )}
        {fluxo === 'ala-existente' && (
          <AlaExistenteForm setAuth={setAuth} navigate={navigate} />
        )}

        {/* Link para voltar */}
        {fluxo !== 'escolha' && (
          <button
            className="text-sm text-gray-500 hover:underline text-center"
            onClick={() => setFluxo('escolha')}
          >
            ← Voltar
          </button>
        )}

        {/* Link para login */}
        <div className="text-center text-sm text-gray-500">
          Já tem conta?{' '}
          <a href="/login" className="text-(--color-primary-600) hover:underline">
            Entrar
          </a>
        </div>

      </div>
    </div>
  )
}