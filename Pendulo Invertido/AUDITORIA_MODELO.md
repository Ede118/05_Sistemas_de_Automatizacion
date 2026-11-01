# Auditoría del modelo — 1 de noviembre de 2026

Se revisaron los archivos guardados, y se simuló con MATLAB R2026b en modo Normal.
Los parámetros nominales son hipótesis didácticas; no identifican una maqueta real.

## Cambios realizados

- `Pendulo_Invertido.m`: parámetros físicos coherentes, unidades SI y comentarios
  sobre sus hipótesis. Se conservaron condiciones iniciales, límites, frecuencias
  de diseño, filtros, estructura de los controladores y fórmulas de ganancias.
- `main.slx`: únicamente dos etiquetas de registro: la corriente que estaba
  registrada como `theta` ahora es `i_medida`; la tensión que estaba registrada
  como `F_virtual` ahora es `v_control`.
- Se agregó `auditar_modelo_actual.m` para instrumentar temporalmente las señales,
  verificar convergencia nominal y equilibrio, y ensayar dos desajustes físicos.
  La instrumentación y la compensación congelada de las pruebas no se guardan.

## Parámetros nominales

Motor PMDC de 24 V con transmisión directa ideal y radio primitivo de 10 mm.
La escala eléctrica y la inercia del rotor toman como referencia el devanado
323890 del maxon RE 35, 90 W:
https://www.maxongroup.com/medias/sys_master/root/9398013263902/Cataloge-Page-EN-161.pdf
Esta referencia no constituye una selección de componentes para comprar.

| Parámetro | Valor | Unidad / hipótesis |
|---|---:|---|
| `Ra` | 0.577 | ohm; catálogo |
| `La` | 0.000191 | H; catálogo |
| `kt` | 0.0292 | N m/A; catálogo |
| `ke` | 0.0292 | V s/rad; igualdad ideal en SI |
| `Jm` | 0.0000079 | kg m²; 79 g cm², catálogo |
| `b_m` | 0.000002 | N m s/rad; estimación viscosa |
| `m1` | 0.50 | kg; carrito y conjunto trasladado |
| `m2` | 0.20 | kg; barra uniforme idealizada |
| `l` | 0.30 | m; pivote al centro de masa; barra de 0.60 m |
| `I` | 0.006 | kg m²; `m2*(2*l)^2/12`, respecto al CM |
| `b_theta` | 0.001 | N m s/rad; estimación |
| `b_x` | 0.10 | N s/m; estimación |

Se mantienen 24 V de tensión máxima y 5 A de consigna máxima. El límite de 5 A
es una hipótesis de ensayo, no una corriente continua certificada para el motor.
La fuerza generalizada máxima ideal es 14.6 N. La masa equivalente resulta
0.779 kg y el rozamiento translacional equivalente 0.12 N s/m.

Se conserva `omega_i=500 rad/s`; por las fórmulas existentes, las ganancias
eléctricas se recalculan a `Kp_i=0.0955 V/A` y `Ki_i=288.5 V/(A s)`.
No se reajustaron las frecuencias angular ni de posición.

## Comprobaciones y resultado nominal

Las correcciones anteriores ya estaban incorporadas por el usuario: caída `Ra*i`,
inicialización de corriente con `i_init`, uso de `dx_v` en la compensación y
coeficiente correcto del rozamiento angular. El PI recibe el error con el signo
correcto y su salida de tensión está conectada. El selector habilita el control.

Ensayo de 30 s, desde 20 grados respecto de la vertical superior, con el
controlador y los estimadores existentes:

| Medida | Resultado |
|---|---:|
| Error angular final, `theta-pi` | -3.5654e-6 rad |
| Posición final | 0.000350 m |
| Máximo desplazamiento absoluto | 2.04023 m |
| Máxima corriente real absoluta | 1.41900 A |
| Máxima tensión aplicada absoluta | 4.61510 V |

No hubo saturación de corriente ni de tensión en este ensayo. La prueba de
equilibrio de 2 s conservó `theta=pi` y posición nula hasta precisión numérica.
La gráfica está en `auditoria_actual_nominal.png`.

La trayectoria nominal NO cabe en el recorrido declarado de ±0.75 m, ni en el
intervalo operativo de ±0.60 m. Los parámetros de recorrido no imponen por sí
solos un límite físico al modelo. No se agregó lógica de topes ni se cambió la
estrategia de regulación de posición: corresponde a una decisión de diseño.

## Límites del diseño conservado

- El PI de corriente tiene saturación de tensión, pero no anti-windup. La prueba
  nominal no valida su comportamiento durante saturaciones prolongadas.
- Sigue existiendo el lazo algebraico mecánico. Estas simulaciones lo resolvieron;
  no se sustituyó la formulación ni se agregaron retardos artificiales.
- Se registraron avisos de cuantización a `single` en la compensación y de
  desbordamiento con wrap en `Speed Measurement/SpeedCount`. No se cambió el
  estimador ni se desactivaron esos diagnósticos. El aviso por sí solo no establece
  que la velocidad estimada sea errónea; su comportamiento requiere validación
  específica para hardware.
- `SIMULACION.md` y `verificar_main.m` corresponden al actuador ideal anterior;
  sus señales esperadas y validaciones no describen esta versión del modelo.

## Incertidumbre del modelo

Un controlador con parámetros fijos no es un controlador adaptativo. Puede
tolerar incertidumbre dentro de un margen que debe comprobarse. Si el controlador
usa h_hat y w_hat, y entrega i_ref=(alpha-h_hat)/w_hat, entonces:

    ddtheta = alpha + (h-h_hat) + (w-w_hat)*i_ref + w*(i-i_ref)

El error afecta tanto la compensación como la estabilidad de la cascada, el
seguimiento de corriente, los límites de tensión/corriente y el recorrido.
Cambiar una variable compartida por planta y controlador no es una prueba de
robustez: ambos modelos deben poder diferir.

El script congela la compensación en los valores nominales y conserva las
ganancias del controlador. Ensaya dos casos opuestos: carrito, rotor, pérdidas,
Ra y La escalados por 0.8 o 1.2; masa e inercia del péndulo y kt/ke escalados
por el factor contrario. La longitud y el radio permanecen constantes.
Estos dos casos no constituyen una garantía para todas las combinaciones de
incertidumbre dentro del 20 %. Las métricas se exportan en
`auditoria_actual_metricas.json`, y las señales en `auditoria_actual_resultado.mat`.

| Caso | Error angular final [rad] | Máximo desplazamiento [m] | Máxima corriente [A] | Máxima tensión [V] |
|---|---:|---:|---:|---:|
| Nominal | -3.5654e-6 | 2.0402 | 1.4190 | 4.6151 |
| Carro/rotor/pérdidas/R/L -20 %, péndulo/kt/ke +20 % | -1.0796e-6 | 1.5534 | 1.3784 | 4.2046 |
| Carro/rotor/pérdidas/R/L +20 %, péndulo/kt/ke -20 % | -3.1551 | 87.6143 | 4.9073 | 24.0000 |

El último caso pierde el equilibrio y alcanza saturación de tensión. El recorrido
posterior a exceder el riel solo describe el modelo de traslación ilimitada; no
representa una trayectoria físicamente realizable en la maqueta. El resultado
refuta una garantía general de tolerancia a desajustes combinados del 20 % para
este controlador y esta condición inicial. No identifica por sí solo cuál de
los desajustes ni qué mecanismo causó primero la pérdida del equilibrio.

Para reproducir, desde esta carpeta en una sesión de MATLAB sin cambios abiertos
que se quieran conservar:

```matlab
auditar_modelo_actual
```

El script cierra los modelos sin guardar la instrumentación de prueba al terminar.
