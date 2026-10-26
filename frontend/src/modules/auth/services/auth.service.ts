import api from '@/lib/axios'
import type { NewWardForm, ExistingWardForm } from '../schemas/onboarding.schema'

export async function getStates() {
  const response = await api.get('/geo/states')
  return response.data.data
}

export async function getStakesByState(estadoId: number) {
  const response = await api.get(`/geo/states/${estadoId}/stakes`)
  return response.data.data
}

export async function getWardsByStake(estacaId: number) {
  const response = await api.get(`/geo/stakes/${estacaId}/wards`)
  return response.data.data
}

export async function registerNewWard(data: NewWardForm) {
  const response = await api.post('/auth/register/new-ward', data)
  return response.data.data
}

export async function registerExistingWard(data: ExistingWardForm) {
  const response = await api.post('/auth/register/existing-ward', data)
  return response.data.data
}