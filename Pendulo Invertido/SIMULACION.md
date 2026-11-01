# Simulacion del pendulo

Desde esta carpeta, ejecutar en MATLAB:

```matlab
resultado = simular_main;
```

La funcion carga `main.slx`, ejecuta `Pendulo_Invertido.m` y simula 30 s en
modo **Normal**. Las senales `theta` [rad], `x` [m], `F_virtual` [N],
`F_real` [N] e `i_cmd` [A] quedan en `resultado.logsout`.
El modelo tambien carga los parametros al abrirse. Si se edita el archivo de
parametros con el modelo ya abierto, volver a ejecutarlo antes de usar Run.
Los scopes de angulo (grados) y posicion (metros) estan conectados.

## Configuracion nominal

Todos los valores fisicos siguen siendo hipotesis pendientes de medicion.
La condicion inicial es 20 grados respecto de la vertical superior, con
velocidades nulas y referencia de posicion cero.

| Parametro | Valor nominal | Significado |
| --- | --- | --- |
| `omega_theta` | 4 rad/s | Frecuencia de diseno angular |
| `zeta_theta` | 0.9 | Amortiguamiento angular |
| `omega_x` | 0.4 rad/s | Frecuencia de diseno de posicion |
| `zeta_x` | 0.9 | Amortiguamiento de posicion |
| `Ts_medicion` | 0.001 s | Muestreo del estimador de velocidad angular |
| `kt` | 0.1 N m/A | Constante de torque provisional |
| `r` | 0.010 m | Radio provisional del pinon |
| `i_m_max` | 5 A | Limite provisional de corriente |

Las ganancias angulares se obtienen como `Kp_theta = omega_theta^2` y
`Kd_theta = 2*zeta_theta*omega_theta`. Las integrales estan desactivadas.
Se redujo la rapidez del lazo de posicion respecto del angular: el ajuste
anterior (`omega_x=6`, `Kp=2`, `Kd=1.2`) resulto inestable en la prueba de 30 s.
Estos ajustes tampoco garantizan estabilidad para cualquier masa, geometria
o limite de corriente: volver a validar al sustituir parametros.

El actuador representa una transmision directa ideal y un lazo de corriente
ideal: `i_cmd = sat(F_virtual*r/kt)` y `F_real = kt*i_cmd/r`.
El limite nominal resultante es de +/-50 N. El valor anterior de `kt=100`
permitia +/-50000 N con el mismo radio y corriente.

## Validacion

```matlab
verificar_main
```

Comprueba convergencia nominal en 30 s, equilibrio vertical sin perturbacion
y saturacion positiva y negativa del bloque Actuador en un modelo temporal.
Exporta `validacion_main.png` con las curvas nominales. No guarda el modelo
temporal ni los cambios de condiciones iniciales de las pruebas.

En la validacion nominal, el error angular final fue aproximadamente
`-2.67e-6 rad`, la posicion final `0.000222 m`, la fuerza maxima absoluta
`25.66 N` y la corriente maxima absoluta `2.57 A`. El desplazamiento maximo
del carrito fue `2.85 m`: el resultado es estable, pero exige comprobar el
recorrido disponible antes de trasladarlo a una maqueta.

## Error de Rapid Accelerator

Se reprodujo el error `Unable to resolve the name 'py.sys.base_prefix'` al
construir el ejecutable de Rapid Accelerator. En la instalacion comprobada,
`pyenv` selecciona Python 3.11 de Microsoft Store. MathWorks no admite esa
distribucion para la interfaz con Python en Windows:
https://www.mathworks.com/help/matlab/matlab_external/install-supported-python-implementation.html

La simulacion Normal funciona sin esa construccion. `simular_main` selecciona
explicitamente ese modo. La configuracion global de Python no se cambia.
Rapid Accelerator queda pendiente de configurar un Python compatible y de
verificar la cadena de compilacion. Normal y Rapid Accelerator no representan
por si mismos distintos grados de realismo fisico.

## Alcance fisico y futura implementacion

La planta conserva sus ecuaciones mecanicas y el rozamiento angular existente.
El lazo algebraico entre las aceleraciones representa ecuaciones acopladas;
Simulink lo resuelve numericamente. No se agregan retardos ficticios para
ocultar ese aviso.

Todavia no se modelan tension de alimentacion, resistencia e inductancia,
fuerza contraelectromotriz, dinamica del control de corriente, inercia del rotor,
reductora, holgura, rozamiento del carrito, topes del riel, cuantizacion o ruido
de sensores. Una trayectoria estable puede superar el recorrido de un riel
real: comprobar el maximo desplazamiento en la grafica y en el informe de
validacion. No hay garantia de recorrido mecanico admisible.

Para el microcontrolador, la salida de mando es `i_cmd`; la conversion posterior
de corriente a fuerza pertenece a la simulacion de la planta. El controlador
actual aun contiene integradores y un derivador continuos. Cambiar solo el
solver a paso fijo no los convierte en un controlador digital: antes de generar
C hay que definir el periodo de control, discretizar esos estados, representar
el lazo de corriente real y volver a validar saturacion y tiempos de ejecucion.
Con accion integral activa tambien se necesitara una estrategia anti-windup.
