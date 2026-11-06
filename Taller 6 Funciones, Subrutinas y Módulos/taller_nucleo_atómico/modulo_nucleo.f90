! Taller 6 -- Módulo de la fórmula semiempírica
module modulo_nucleo
  implicit none
  integer, parameter :: dp = kind(1.0d0)

  !Constantes :D 
  real(dp), parameter :: a_V = 15.8_dp  !Coeficiente de Volumen [MeV]
  real(dp), parameter :: a_S = 18.3_dp  !Coeficiente de superficie [MeV]
  real(dp), parameter :: a_C = 0.71_dp  !Coeficiente de Coulomb [MeV]
  real(dp), parameter :: a_A = 92.7_dp  !Coeficiente de Asimetría [MeV]
  real(dp), parameter :: M_n = 939.57_dp  !Masa del Neutrón [MeV]
  real(dp), parameter :: M_H = 938.78_dp  !Masa del Hidrógeno [MeV]

contains
  !Término de volumen (-a_V)
  real(dp) function termino_volumen()
    termino_volumen = -a_V
  end function termino_volumen

  !Término de superficie (a_S * A^(-1/3))
  real(dp) function termino_superficie(A)
    real(dp), intent(in) :: A
    termino_superficie = a_S * A**(-1.0_dp/3.0_dp)
  end function termino_superficie

  !Término de Coulomb (a_C * Z^2 * A^(-4/3))
  real(dp) function termino_coulomb(Z, A)
    real(dp), intent(in) :: Z, A
    termino_coulomb = a_C * Z**2 * A**(-4.0_dp/3.0_dp)
  end function termino_coulomb

  !Término de asimetría (a_A * (Z - A/2)^2 / A^2)
  real(dp) function termino_asimetria(Z, A)
    real(dp), intent(in) :: Z, A
    termino_asimetria = a_A * (Z - 0.5_dp*A)**2 / A**2
  end function termino_asimetria

  !Energía de enlace por nucleón (suma de los cuatro términos)
  real(dp) function energia_enlace(Z, A)
    real(dp), intent(in) :: Z, A
    real(dp) :: rZ, rA
    rZ = Z
    rA = A
    energia_enlace = termino_volumen() + termino_superficie(rA) + termino_coulomb(rZ, rA) + termino_asimetria(rZ, rA)
  end function energia_enlace

  !Masa atómica M(Z, A)
  real(dp) function masa_atomica(Z, A)
    real(dp), intent(in) :: Z, A
    real(dp) :: rZ, rA
    rZ = Z
    rA = A
    masa_atomica = rZ * M_H + (rA - rZ) * M_n + rA * energia_enlace(rZ, rA)
  end function masa_atomica

  !Subrutina que encuentra el Z de máximo enlace para un A dado
  subroutine Z_estable(A_int, z_optimo, m_Eb)
    integer, intent(in) :: A_int
    integer, intent(out) :: z_optimo
    real(dp), intent(out) :: m_Eb

    integer :: z
    real(dp) :: rA, eb_actual
    
    rA = real(A_int, dp)
    m_Eb = 1.0e33_dp
    z_optimo = 1
    
    do z = 1, A_int
       eb_actual = energia_enlace(real(z, dp), rA)
       if (eb_actual < m_Eb) then
          m_Eb = eb_actual
          z_optimo = z
       end if
    end do
  end subroutine Z_estable

end module modulo_nucleo
