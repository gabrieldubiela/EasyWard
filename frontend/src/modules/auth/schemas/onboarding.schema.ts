import { z } from 'zod'

export const newWardSchema = z.object({
  estado_id: z.number().min(1, 'Selecione um estado'),
  estaca_id: z.number().optional(),
  estaca_nome: z.string().optional(),
  ala_nome: z.string().min(1, 'Nome da ala obrigatório'),
  nome_completo: z.string().min(3, 'Nome completo obrigatório'),
  email: z.string().email('E-mail inválido'),
  password: z.string().min(6, 'Mínimo 6 caracteres'),
}).refine(
  (data) => data.estaca_id || data.estaca_nome,
  {
    message: 'Selecione uma estaca ou digite o nome de uma nova',
    path: ['estaca_nome'],
  }
)

export const existingWardSchema = z.object({
  ala_id: z.number().min(1, 'Selecione uma ala'),
  nome_completo: z.string().min(3, 'Nome completo obrigatório'),
  email: z.string().email('E-mail inválido'),
  password: z.string().min(6, 'Mínimo 6 caracteres'),
})

export type NewWardForm = z.infer<typeof newWardSchema>
export type ExistingWardForm = z.infer<typeof existingWardSchema>