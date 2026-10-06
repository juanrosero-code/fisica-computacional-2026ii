program ajuste_pendulo
  ! ------------
  ! Variables
  ! ------------
  use, intrinsic :: iso_fortran_env, only: real64, iostat_end  ! Precisión y código de fin de archivo
  implicit none                                               ! Evita variables implícitas

  ! Control del archivo y campos enteros
  integer :: unidad, unidad_salida, estado, id, n_osc, n_datos
  
  ! Campos reales y variables transformadas x, y
  real(real64) :: longitud_cm, angulo_deg, tiempo_s, periodo_s
  real(real64) :: x, y
  ! Para el inciso 5, las sumatorias
  real(real64) :: sx, sy, sxx, sxy, syy
  !Para el inciso 6, pendiente e intercepto
  real(real64) :: m, b, den, g, r2
  real(real64), parameter :: PI = 3.14159265358979323846_real64

  ! ------------
  ! Ciclos y cálculos previos 
  ! ------------

  ! Inciso 1: Abre el archivo existente
  open(newunit=unidad, file='pendulo_limpio.dat', status='old', &
       action='read', iostat=estado)

  if (estado /= 0) error stop 'No fue posible abrir el archivo'  ! Verifica la apertura


  ! Dejo las variables en 0 para que no se acumulen en el inciso 5
  n_datos = 0
  sx  = 0.0_real64
  sy  = 0.0_real64
  sxx = 0.0_real64
  sxy = 0.0_real64
  syy = 0.0_real64

  write(*, '(A)') '  ID   L (m)      T (s)      x = L (m)   y = T² (s²)'

  ! Inciso 2: El número de filas es desconocido; se lee hasta encontrar el final
  do
     read(unidad, *, iostat=estado) id, longitud_cm, angulo_deg, &
          n_osc, tiempo_s

     if (estado == iostat_end) exit                         ! Fin normal del archivo
     if (estado /= 0) error stop 'Hay una fila mal formada'  ! Otro valor indica error

     ! Inciso 3: Conversión de longitud a metros y cálculo del período
     periodo_s = tiempo_s / real(n_osc, real64)

     ! Inciso 4: Definición de las variables linealizadas x = L, y = T²
     x = longitud_cm / 100.0_real64
     y = periodo_s**2

     ! Inciso 5: Acumular las sumatorias en cada paso del ciclo
     sx  = sx + x
     sy  = sy + y
     sxx = sxx + x**2
     sxy = sxy + x * y
     syy = syy + y**2

     n_datos = n_datos + 1  ! Cuenta la fila aceptada

     ! Muestra los primeros datos transformados en pantalla
     print '(I4, 4F12.4)', id, x, periodo_s, x, y
  end do

  close(unidad)  ! Libera el archivo

if (n_datos < 2) error stop 'Error: Se requieren al menos dos datos para realizar el ajuste.'
! 3. Denominador nulo en la fórmula de mínimos cuadrados

  ! ------------
  ! Cálculos
  ! ------------

  ! Inciso 6: Cálculo de la pendiente (m) e intercepto (b) por mínimos cuadrados
  den = real(n_datos, real64) * sxx - sx**2
  m = (real(n_datos, real64) * sxy - sx * sy) / den
  b = (sy * sxx - sx * sxy) / den

  ! Inciso 7: Cálculo de la aceleración de la gravedad g = 4*pi^2 / m
  g = (4.0_real64 * PI**2) / m

  ! Inciso 8: Coeficiente de determinación R^2
  r2 = ((real(n_datos, real64) * sxy - sx * sy)**2) / &
       ((real(n_datos, real64) * sxx - sx**2) * (real(n_datos, real64) * syy - sy**2))
  
  ! ------------
  ! Imprimiendo los resultados
  ! ------------

  
  print *, 'Sx  =', sx
  print *, 'Sy  =', sy
  print *, 'Sxx =', sxx
  print *, 'Sxy =', sxy

  print *, '==========================================='
  print *, '       RESULTADOS DEL AJUSTE LINEAL        '
  print *, '==========================================='
  print '(A, I0)',        'Número de datos aceptados (N) = ', n_datos
  print '(A, F12.6, A)', 'Pendiente (a)                 = ', m, ' s²/m'
  print '(A, F12.6, A)', 'Intercepto (b)                = ', b, ' s²'
  print '(A, F12.6)',    'Coeficiente R²                = ', r2
  print '(A, F12.6, A)', 'Gravedad estimada (g)         = ', g, ' m/s²'
  print *, '==========================================='

! Inciso 10: Escritura en archivo resultados_ajuste.dat
open(newunit=unidad_salida, file='resultados_ajuste.dat', &
      status='replace', action='write')
write(unidad_salida, *) n_datos, m, b, r2, g
close(unidad_salida)

end program ajuste_pendulo
