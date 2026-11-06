! Taller 6 -- Programa principal
program programa_nucleo
  use modulo_nucleo, only: dp, energia_enlace, masa_atomica, Z_estable, &
                           termino_volumen, termino_superficie, &
                           termino_coulomb, termino_asimetria

  implicit none

  integer :: u_nucleos, u_valle, u_maximo
  integer :: A, Z
  real(dp) :: eb
  real(dp) :: min_eb_global
  integer :: A_max_global, Z_max_global

  !--- 1. Los ocho nucleos, en el orden del enunciado---
  open(newunit=u_nucleos, file='nucleos.dat', status='replace')
  
  call escribir_nucleo(u_nucleos, 94, 244)  !Plutonio-244
  call escribir_nucleo(u_nucleos, 32,  70)  !Germanio-70
  call escribir_nucleo(u_nucleos, 72, 179)  !Hafnio-179
  call escribir_nucleo(u_nucleos, 18,  38)  !Argón-38
  call escribir_nucleo(u_nucleos, 26,  56)  !Hierro-56
  call escribir_nucleo(u_nucleos, 20,  40)  !Calcio-40
  call escribir_nucleo(u_nucleos, 92, 235)  !Uranio-235
  call escribir_nucleo(u_nucleos, 92, 238)  !Uranio-238
  
  close(u_nucleos)

  !---2. Para cada A, encontrar el Z de menor EB (mayor B/A)---
  open(newunit=u_valle, file='valle.dat', status='replace', action='write')
  
  min_eb_global = huge(1.0_dp)  ! inicializar antes del ciclo con el mayor número posible
  A_max_global = 0
  Z_max_global = 0

  do A = 4, 260
     call Z_estable(A, Z, eb)   ! Usamos 'eb' correctamente
     write(u_valle, '(2(i5,1x),f20.10)') A, Z, eb
     
     ! Identificar el núcleo más ligado de toda la curva
     if (eb < min_eb_global) then
        min_eb_global = eb
        A_max_global = A
        Z_max_global = Z
     end if
  end do
  close(u_valle)

  !--- 3. Registrar el maximo global con el mismo orden A, Z, EB---
  open(newunit=u_maximo, file='maximo.dat', status='replace', action='write')
  write(u_maximo, '(2(i5,1x),f20.10)') A_max_global, Z_max_global, min_eb_global
  close(u_maximo)

  print '(a)', 'Taller 6: archivos nucleos.dat, valle.dat y maximo.dat creados.'

contains

  !Escribe: entrada unidad, Z_val, A_val; salida de los términos y propiedades
  subroutine escribir_nucleo(unidad, Z_val, A_val)
    integer, intent(in) :: unidad, Z_val, A_val
    real(dp) :: rZ, rA
    real(dp) :: e_vol, e_sup, e_coul, e_asim, eb_nuc, m

    rZ = real(Z_val, dp)
    rA = real(A_val, dp)
    
    e_vol  = termino_volumen()
    e_sup  = termino_superficie(rA)
    e_coul = termino_coulomb(rZ, rA)
    e_asim = termino_asimetria(rZ, rA)
    eb_nuc = energia_enlace(rZ, rA)
    m      = masa_atomica(rZ, rA)
    
    write(unidad, '(2(i5,1x),6(f20.10,1x))') Z_val, A_val, e_vol, e_sup, e_coul, e_asim, eb_nuc, m
  end subroutine escribir_nucleo

end program programa_nucleo
