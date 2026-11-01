# Exploración de ajuste para recuperación desde 20° — 1/11/2026

Objetivo conservado: carrito centrado y quieto, corriente inicial nula,
péndulo con desviación angular inicial discernible y velocidad angular nula.
Se investigó 20° como ángulo del intervalo solicitado de 20° a 45°.
No se implementó swing-up ni se redujo la desviación inicial del objetivo.

Se probaron ajustes en memoria de `main.slx` con `SimulationInput`, conservando
la planta nominal, el PI de corriente, los estimadores y los límites de 5 A y 24 V.
No se guardaron cambios en los SLX ni en `Pendulo_Invertido.m`.
El arnés temporal detiene un ensayo si |x| supera 0.55 m o si la desviación
angular supera 1.3 rad para evitar continuar pruebas fallidas hacia singularidades.
Ese arnés de prueba no constituye una protección implementada en el diseño.

## Ajustes comparados

| Ajuste | omega_theta | zeta_theta | omega_x | zeta_x | Pico de recorrido desde 20° |
|---|---:|---:|---:|---:|---:|
| Guardado | 4 | 0.9 | 0.4 | 0.9 | 2.04023 m |
| Exploración inicial | 10 | 0.9 | 1.2 | 0.9 | 0.406716 m |
| Refinamiento sin saturación inicial de consigna | 11 | 0.9 | 1.2 | 0.9 | 0.377208 m (ensayo de 8 s) |
| Mejor pico encontrado en esta exploración | 12 | 0.7 | 1.0 | 0.9 | 0.339932 m (verificado durante 30 s) |

Las frecuencias están expresadas en rad/s. Los nombres omega representan los
parámetros de las fórmulas existentes, no los polos exactos de la cascada completa.
La búsqueda fue finita: no es una optimización global ni identifica el mejor
controlador posible.

El último ajuste equivale a:

```matlab
% Propuesta examinada; NO aplicada al archivo de parámetros.
omega_theta = 12;
zeta_theta = 0.7;
Kp_theta = 144;
Kd_theta = 16.8;
Ki_theta = 0;
omega_x = 1.0;
zeta_x = 0.9;
Kpx = 1/9.80665;
Kdx = 1.8/9.80665;
Kix = 0;
```

## Verificación del ajuste 12 / 0.7 / 1.0 / 0.9

Condición inicial: theta=pi-20*pi/180; x=0, dx=0, dtheta=0, i=0.

- Tiempo simulado: 30 s.
- Máximo |x|: 0.339931708 m.
- x final: 5.61e-10 m.
- Error angular final: 9.41e-10 rad.
- Máxima corriente real absoluta: 4.788719 A.
- Máxima tensión aplicada absoluta: 4.652851 V.
- La consigna inicial ideal de corriente es aproximadamente 5.69 A; el límite
  existente la recorta a 5 A. No hay saturación de tensión en este ensayo.

Este ensayo nominal cumple ±0.40 m operativos y ±0.50 m físicos. No valida
robustez, el arranque desde el lado opuesto, otros estados iniciales, funcionamiento
digital ni hardware. Las protecciones de recorrido siguen pendientes.

El mismo ajuste se probó desde 30° y 45° con velocidad angular nula: ambos casos
alcanzaron 0.55 m y se detuvieron, por lo que no cumplen el recorrido. No se
concluye que esos ángulos sean físicamente imposibles; este ajuste no los resuelve.

## Interpretación y próximos cambios de diseño posibles

La mejora de 20° se obtiene haciendo más rápida la recuperación angular y
coordinándola con una regulación de posición más rápida. El menor amortiguamiento
angular de este candidato permite un transitorio con mayor sobrepaso, que también
debe evaluarse. No basta con aumentar solo la ganancia exterior: varios ajustes
de la búsqueda excedieron el recorrido o no convergieron adecuadamente.

Antes de adoptar el ajuste: probar ambos sentidos, incertidumbre con compensación
nominal fija, perturbaciones y retardos; examinar saturación y anti-windup; incorporar
supervisión de recorrido y frenado. Si se exige llegar hasta 45°, ampliar el estudio
a ganancias coordinadas/programadas o a una estrategia de captura y regulación,
manteniendo la condición inicial de ángulo y velocidad angular nula.

Al inicio, con theta=pi-delta y velocidades nulas, la ecuación del péndulo da:

    Jp*ddtheta = k*cos(delta)*ddx - k*g*sin(delta)

Para que la aceleración angular inicial apunte hacia la vertical:

    ddx > g*tan(delta)

Esto equivale a 3.57 m/s² desde 20° y 9.81 m/s² desde 45°. Es una condición
instantánea, no una condición suficiente para recuperar y frenar dentro del riel.

La información aportada sobre la maqueta anterior es de segunda mano: arrancaría
desde abajo y realizaría swing-up. Eso sugiere una estrategia distinta o más amplia
que el regulador local actual, pero no permite identificar qué control usaba.
Un sistema que realiza swing-up no está obligado a capturar todo estado con
desviación de 20° a 45°, velocidad nula y carrito centrado; su trayectoria puede
entrar en la región de equilibrio con otras velocidades y posiciones.

Fuentes de contexto:
- https://underactuated.mit.edu/acrobot.html (energía y conmutación a regulación).
- https://www.mathworks.com/help/control/ug/control-of-an-inverted-pendulum-on-a-cart.html
  (ajuste coordinado de lazos con objetivos y márgenes).

Datos: `exploracion_ajuste.json`, `refinamiento_ajuste.json` y sus archivos MAT/log.
El script `explorar_ajuste.m` reproduce el refinamiento; los resultados de la
exploración inicial se conservan en archivos separados.
