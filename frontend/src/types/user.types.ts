export interface User {
  id: number
  name: string
  ala_id: number
  permissions: string[]
}

export interface LoginResponse {
  access_token: string
  user: User
}