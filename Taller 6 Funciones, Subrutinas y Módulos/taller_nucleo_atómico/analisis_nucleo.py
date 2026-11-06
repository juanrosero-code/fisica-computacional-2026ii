"""Taller 6 - Analisis de la energia nuclear en Python.

Solo se analizan las tablas creadas por Fortran; no se repite el modelo.
"""

import numpy as np
import matplotlib.pyplot as plt


def leer_valle(archivo):
    """Entrada: ruta de valle.dat. Salida: tres columnas A, Z, EB (arrays)."""
    datos = np.loadtxt(archivo)
    if datos.ndim != 2 or datos.shape[1] != 3:
        raise ValueError("valle.dat debe tener tres columnas: A, Z, EB")
    return datos[:, 0], datos[:, 1], datos[:, 2]


def buscar_maximo(a, z, eb):
    """Entradas: columnas A, Z, EB. Salida: (A, Z, EB) del menor EB.

    Recorre cada fila con ciclo y condicional, sin min ni argmin.
    """
    if len(eb) == 0 or len(a) != len(eb) or len(z) != len(eb):
        raise ValueError("Las tres columnas deben tener la misma longitud no vacia")
    a_mejor = int(a[0])
    z_mejor = int(z[0])
    eb_mejor = float(eb[0])
    for i in range(1, len(eb)):
        if float(eb[i]) < eb_mejor:
            a_mejor = int(a[i])
            z_mejor = int(z[i])
            eb_mejor = float(eb[i])
    return a_mejor, z_mejor, eb_mejor


def guardar_maximo(archivo, a, z, eb):
    """Entradas: ruta, A, Z, EB. Salida: maximo_python.dat (A Z EB)."""
    with open(archivo, "w", encoding="utf-8") as salida:
        salida.write(f"{int(a):5d} {int(z):5d} {float(eb):20.10f}\n")


def graficar_curva(a, z, eb, experimentales, archivo):
    """Entradas: columnas del valle, datos experimentales y ruta PNG.

    Salida: grafica B/A=-EB vs. A del modelo y diez puntos experimentales,
    guardando la imagen y mostrándola en pantalla.
    """
    a_exp = [dato[2] for dato in experimentales]
    b_exp = [dato[3] for dato in experimentales]

    fig, ax = plt.subplots(figsize=(9, 5.2))
    # Se usa -eb para corregir la orientación del modelo de Fortran y mostrar el pico hacia arriba
    ax.plot(a, -eb, linewidth=2.1, label="Modelo: máximo enlace por A")
    ax.scatter(a_exp, b_exp, s=45, marker="o", zorder=3, label="Núclidos medidos")

    offsets = {"He-4": (4, 8), "Fe-56": (-28, 10), "Ni-62": (8, -13),
               "Pb-208": (-26, 9), "U-238": (4, -12)}
    for nombre, _, masa_a, energia in experimentales:
        if nombre in offsets:
            ax.annotate(nombre, (masa_a, energia), xytext=offsets[nombre],
                        textcoords="offset points", fontsize=8)
            
    ax.set_xlabel("Número de nucleones A")
    ax.set_ylabel("Energía de enlace por nucleón B/A [MeV]")
    ax.set_title("Taller 6: fórmula semiempírica de masa nuclear")
    ax.grid(alpha=0.22)
    ax.legend(loc="lower right")
    ax.set_xlim(0, 265)
    fig.tight_layout()
    
    # Guarda la imagen requerida y además la muestra en el Colab
    fig.savefig(archivo, dpi=190)
    plt.show()
    plt.close(fig)
