export interface ApiResponse<T = unknown> {
  success: boolean
  message: string
  data: T | null
}

export interface ApiError {
  success: false
  message: string
  errors: Array<{
    field: string
    message: string
  }> | null
}

export interface PaginatedData<T> {
  items: T[]
  total: number
  page: number
  page_size: number
  total_pages: number
}