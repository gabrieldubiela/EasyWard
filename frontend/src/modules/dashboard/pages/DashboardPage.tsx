import { Button } from '@/components/ui/button'
// import { Input } from '@/components/ui/input' importação declarada e não utilizada, dando erro no vercel
import { Badge } from '@/components/ui/badge'
// import { Alert, AlertDescription } from '@/components/ui/alert' importação declarada e não utilizada, dando erro no vercel
import { Skeleton } from '@/components/ui/skeleton'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog'
import Loader from '@/components/ui/loader'

export default function DashboardPage() {
  return (
    <div className="p-8 flex flex-col gap-6 max-w-2xl">

      {/* Loader */}
      <div className="flex gap-4 items-center">
        <Loader size="sm" />
        <Loader size="md" />
        <Loader size="lg" />
      </div>

      {/* Skeleton */}
      <div className="flex flex-col gap-2">
        <Skeleton className="h-4 w-48" />
        <Skeleton className="h-4 w-64" />
        <Skeleton className="h-4 w-32" />
      </div>

      {/* Table */}
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Nome</TableHead>
            <TableHead>Organização</TableHead>
            <TableHead>Status</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow>
            <TableCell>João Silva</TableCell>
            <TableCell>Quórum de Élderes</TableCell>
            <TableCell><Badge>Ativo</Badge></TableCell>
          </TableRow>
          <TableRow>
            <TableCell>Maria Santos</TableCell>
            <TableCell>Sociedade de Socorro</TableCell>
            <TableCell><Badge variant="outline">Inativo</Badge></TableCell>
          </TableRow>
        </TableBody>
      </Table>

      {/* Modal */}
      <Dialog>
        <DialogTrigger asChild>
          <Button variant="outline">Abrir Modal</Button>
        </DialogTrigger>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Exemplo de Modal</DialogTitle>
          </DialogHeader>
          <p className="text-sm text-muted-foreground">
            Conteúdo do modal aqui.
          </p>
        </DialogContent>
      </Dialog>

    </div>
  )
}