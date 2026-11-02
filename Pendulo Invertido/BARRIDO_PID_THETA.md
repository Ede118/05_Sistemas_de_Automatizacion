# Barrido nominal del PID angular

`barrer_pid_theta.m` ejecuta el `main.slx` guardado para una grilla cartesiana de
ganancias angulares independientes. No cambia el diseño original. Se simulan
copias de todos los SLX en una carpeta de resultados con fecha y hora.

## Uso

### Tutorial: primera ejecucion con un solo punto

`barrer_pid_theta.m` es una **funcion**, no un script que deba ejecutarse por
partes. Los ejemplos se escriben en la **Command Window** de MATLAB. Tambien
se pueden poner en otro script que llame a esta funcion.

1. Guardar y cerrar los modelos Simulink de esta carpeta, o usar otra sesion.
2. Abrir esta carpeta como Current Folder o ejecutar el `cd` del ejemplo.
3. Probar primero una sola terna conocida. Esta llamada hace **un ensayo**:

```matlab
[T, carpeta] = barrer_pid_theta(Kp=144, Kd=16.8, Ki=0);
disp(T)
```

`T` y `carpeta` son nombres elegidos por quien llama a la funcion: se pueden
llamar de otro modo. La primera salida es una tabla y la segunda es la ruta
absoluta de los archivos exportados. El ejemplo no aplica esas ganancias al
controlador original: solo configura la simulacion de prueba.

Para abrir el mapa y las curvas de ese ensayo:

```matlab
openfig(fullfile(carpeta, 'mapa_pid_theta.fig'))
figure
image(imread(fullfile(carpeta, 'mejor_ensayo.png')))
axis image off
```

El archivo `mejor_ensayo.png` solo existe si al menos una combinacion aprobo.
Para consultar la ayuda desde MATLAB:

```matlab
help barrer_pid_theta
edit barrer_pid_theta
```

### Segundo paso: una grilla pequena

```matlab
valoresKp = [144 196];
valoresKd = [16 20];
valoresKi = [0 20];

numeroEnsayos = numel(valoresKp)*numel(valoresKd)*numel(valoresKi) % 8

[T, carpeta] = barrer_pid_theta( ...
    Kp=valoresKp, Kd=valoresKd, Ki=valoresKi);
```

Se prueban las ocho ternas del producto cartesiano. No se empareja el primer Kp
con el primer Kd y el primer Ki para hacer solo dos casos. Los nombres a la
izquierda de `=` (`Kp`, `Kd`, `Ki`) son las opciones de la funcion; las variables
a la derecha son las listas elegidas por el usuario.

**Crear variables Kp/Kd/Ki en el Workspace no cambia por si solo la grilla**:
hay que pasarlas en la llamada, por ejemplo `barrer_pid_theta(Kp=miListaKp)`.
Las opciones omitidas usan sus listas predeterminadas. Si se quiere fijar una
ganancia, pasar un escalar: `Ki=0` mantiene la integral anulada en todos los casos.

### Como leer y filtrar la tabla

```matlab
% Tabla compacta de todos los ensayos:
T(:, {'Kp','Kd','Ki','Cumple','Estado','Xmax','TAsentamiento'})

% Solo los admisibles, ordenados por menor recorrido:
admisibles = sortrows(T(T.Cumple,:), 'Xmax');
disp(admisibles)

% Admisibles PD y con pico menor que 35 cm:
T(T.Cumple & T.Ki==0 & T.Xmax<0.35,:)

% Ensayos rechazados y su motivo:
T(~T.Cumple, {'Kp','Kd','Ki','Estado','Detalle'})

% Para el mismo Ki, comparar rapidez y recorrido entre admisibles:
sortrows(T(T.Cumple & T.Ki==20,:), 'TAsentamiento')
```

`T.Cumple` es una columna logica: `T(T.Cumple,:)` selecciona todas las columnas
de las filas donde esa condicion es verdadera. `Xmax` esta en metros y
`TAsentamiento`, en segundos. Una comparacion con NaN no aprueba un ensayo:
consultar siempre `Cumple`, `Estado` y `Detalle`, no solo una metrica aislada.

### Cambiar requisitos sin editar la funcion

Todas las opciones se pasan con el mismo formato `Nombre=valor`:

```matlab
[T, carpeta] = barrer_pid_theta( ...
    Kp=[144 196], Kd=[16 20], Ki=[0 20], ...
    Tfinal=40, VentanaFinal=3, ...
    LimiteX=0.40, ...
    TolThetaGrados=0.5, TolOmegaGrados=1, ...
    TolX=0.01, TolVelocidad=0.01, ...
    PasoMaximo=0.001);
```

En ese ejemplo se mantienen los limites y tolerancias, pero se evalua la
convergencia durante los ultimos 3 s de un ensayo de 40 s, es decir [37,40].
Las tolerancias en posicion y velocidad se expresan en m y m/s; las angulares,
en grados y grados/s. `Tfinal`, `VentanaFinal` y `PasoMaximo` estan en segundos.
`FastRestart=false` sirve para diagnosticar problemas de reinicializacion o de
parametros no ajustables; normalmente se deja en true.

Por defecto, las condiciones iniciales de 20 grados y reposo prevalecen sobre
el archivo de parametros. Para usar las cinco condiciones iniciales guardadas:

```matlab
[T, carpeta] = barrer_pid_theta( ...
    Kp=[144 196], Kd=[16 20], Ki=[0 20], ...
    InicialesDelArchivo=true);
```

Se leen `theta_init`, `x_init`, `dx_init`, `dtheta_init` e `i_init` desde la copia
de `Pendulo_Invertido.m` creada al comenzar. No se leen modificaciones manuales
del Base Workspace ni ediciones del archivo posteriores al inicio del barrido.
`InicialesDelArchivo=false` mantiene el ensayo original y sigue siendo el valor
predeterminado. Los parametros fisicos y los otros lazos SI se leen del archivo
en ambos modos; Kp_theta/Kd_theta/Ki_theta son sustituidos por la grilla.

`LimiteX` se aplica a la **posicion absoluta respecto del origen**, no a la
distancia viajada desde x_init. Con x_init=-0.50 m y LimiteX=0.40, se incumple
el criterio desde t=0. La funcion advierte y los ensayos se rechazan; no desplaza
el origen ni aumenta el limite automaticamente.

### Uso de Parallel Computing Toolbox

```matlab
[T, carpeta] = barrer_pid_theta( ...
    Kp=[144 196], Kd=[16 20], Ki=[0 20], ...
    Paralelo=true, Workers=2);
```

Para el barrido predeterminado completo:

```matlab
[T, carpeta] = barrer_pid_theta(Paralelo=true, Workers=4);
```

El modo paralelo usa `parsim` y un pool **Processes**, no Threads. `Workers=0`
reutiliza el pool abierto; si no hay uno, crea un pool local de hasta cuatro
workers segun el limite del perfil. Con Workers>0 se solicita ese numero.
Si ya hay un pool de otro tamano, la funcion informa el conflicto y no lo cierra
silenciosamente. El pool queda abierto al terminar para reutilizar su arranque.

Se procesan lotes de hasta `LoteParalelo=20` simulaciones. Se puede ajustar:

```matlab
[T, carpeta] = barrer_pid_theta( ...
    Paralelo=true, Workers=4, LoteParalelo=40);
```

Lotes grandes amortizan inicializacion y compilacion, pero retienen mas trazas
en memoria. Cada worker tiene su propio proceso de MATLAB/Simulink y necesita
RAM. Mas workers no garantizan menor tiempo; medir el barrido real y considerar
el costo inicial de abrir el pool. Para pocos ensayos puede convenir el modo
secuencial con Fast Restart.

En paralelo se guardan el arnes de pruebas y el logging SOLO en los SLX copiados
de `modelo_ensayo`, para que sean visibles en los workers. Los originales siguen
intactos. Todos los parametros se envian por SimulationInput; no se transfiere
el Base Workspace completo. `parsim` gestiona las caches de los workers.
Esta implementacion esta pensada para procesos locales que comparten la ruta de
trabajo; no se presenta como configuracion de un cluster remoto.

El progreso de parsim aparece durante cada lote; la tabla y sus checkpoints se
actualizan cuando el lote vuelve al cliente y se evalua con los mismos assert
del modo secuencial. Una interrupcion a mitad de lote puede perder ese lote,
aunque los checkpoints de lotes anteriores permanezcan guardados.

### Recuperar resultados sin simular otra vez

```matlab
% Si se conserva la variable carpeta de la ejecucion:
guardado = load(fullfile(carpeta, 'resultados.mat'), 'resultados');
T = guardado.resultados;

% Tambien se puede seleccionar manualmente un archivo resultados.mat:
[archivoElegido, rutaElegida] = uigetfile('*.mat', 'Elegir resultados.mat');
if ~isequal(archivoElegido, 0)
    guardado = load(fullfile(rutaElegida, archivoElegido), 'resultados');
    T = guardado.resultados;
end
```

El MAT conserva los tipos de la tabla. El CSV es util para intercambiar datos;
si se lo vuelve a importar con `readtable`, revisar los tipos de `Cumple` y
`Estado` antes de reutilizar filtros logicos.

### Como esta organizado el codigo para reutilizarlo

Los comentarios numerados de la funcion principal siguen este recorrido:

1. Leer y validar las opciones.
2. Crear copias aisladas y cargar parametros locales.
3. Comprobar conexiones y registrar senales.
4. Agregar condiciones de parada a la copia.
5. Construir una plantilla `SimulationInput` y la grilla con `ndgrid`.
6. Recorrer cada terna, ejecutar `sim`, evaluar y guardar una fila.
7. Exportar tablas y figuras.

La funcion local `evaluar` contiene los criterios de aceptacion y los `assert`.
`registrar` vincula rutas de bloques con nombres estables de logging.
`dibujarMapa` convierte estados de la tabla en colores. `restaurar` descarta los
cambios de las copias al terminar. Si se renombran bloques del modelo, hay que
actualizar las rutas de `registrar` y las conexiones temporales de la seccion 4.
`cargarParametros` solo importa escalares double del script: ampliar ese helper
si en el futuro el modelo necesita estructuras, buses o parametros vectoriales.

### Ejecucion predeterminada completa

Desde una sesión de MATLAB sin los modelos del proyecto abiertos:

```matlab
cd('C:/Users/fedeb/Documents/Github/05_Sistemas_de_Automatizacion/Pendulo Invertido')
[T, carpeta] = barrer_pid_theta;
admisibles = T(T.Cumple,:);
sortrows(admisibles, 'Xmax')
```

La función se niega a utilizar modelos ya abiertos para no cerrar ni modificar
trabajo del usuario en memoria. Guarde/cierre esos modelos o use otra sesión.
El modo secuencial no requiere Parallel Computing Toolbox. Utiliza SimulationInput y Fast Restart;
se puede desactivar este último con `FastRestart=false` para diagnóstico.

Grilla predeterminada: 7 × 7 × 4 = **196 combinaciones**.

```matlab
Kp = [64 100 144 196 256 324 400];
Kd = [8 12 16 20 24 28 36];
Ki = [0 5 20 50];
```

Para elegir o refinar la grilla:

```matlab
[T, carpeta] = barrer_pid_theta( ...
    Kp=120:20:240, Kd=12:2:24, Ki=[0 2 5 10 20]);
```

El costo crece con `numel(Kp)*numel(Kd)*numel(Ki)` y con el tiempo simulado.
No se aplican automáticamente las ganancias de ningún ensayo al diseño.

## Condiciones y criterios de aceptación

Se leen los parámetros físicos y los demás controladores del archivo actual
`Pendulo_Invertido.m`. Se mantienen fijos durante el barrido. La copia de ese
archivo y `configuracion.mat` identifican exactamente el contexto del mapa.

Se impone en cada ensayo:

- `theta_init = pi - 20*pi/180` (160° absolutos).
- `x_init = dx_init = dtheta_init = i_init = 0`.
- Referencia de posición del modelo conservada en cero.
- Simulación de 30 s, modo Normal, paso máximo de 1 ms.

Una combinación **cumple** únicamente si:

1. No aparecen estados no finitos ni error de simulación.
2. **Todas las muestras** cumplen `abs(x) < 0.40 m` (desigualdad estricta).
3. Completa los 30 s sin alcanzar la condición de parada por pérdida angular.
4. Durante toda la ventana final de 2 s se cumplen simultáneamente:
   - `abs(theta-pi) <= 0.5°`.
   - `abs(dtheta) <= 1°/s`.
   - `abs(x) <= 0.01 m`.
   - `abs(dx) <= 0.01 m/s`.

El centrado y el reposo del carrito son criterios adicionales explícitos: evitan
considerar aceptable un péndulo vertical con el carro aún desplazándose. Se pueden
ajustar mediante `TolX` y `TolVelocidad`, al igual que las tolerancias angulares,
`Tfinal` y `VentanaFinal`. Cambiar estos criterios cambia el mapa.

Los `assert` de recorrido y convergencia se capturan por ensayo para clasificar
el resultado y continuar con la siguiente combinación. No se usa un único assert
que termine todo el barrido al encontrar el primer caso fallido.

## Parada temprana de casos fallidos

Solo en las copias de prueba se añade un arnés que detiene la simulación cuando:

- `abs(x) >= 0.40 m`, o
- `abs(theta-pi) >= 1.3 rad` (antes de aproximarse más a la singularidad horizontal).

Ese arnés **no limita la posición ni frena el carro**. No es un control de
protección: solo ahorra tiempo en un caso que ya no cumple o perdió el equilibrio.
Para un ensayo detenido temprano, `Xmax` es el máximo registrado hasta detenerse,
no el pico que habría alcanzado la trayectoria libre.

## Archivos generados

Cada ejecución crea `resultados_barrido_theta/FECHA_HORA/` con:

- `resultados.csv`: todos los puntos y sus métricas; checkpoint cada 10 ensayos.
- `ganancias_admisibles.csv`: únicamente los puntos que cumplen.
- `resultados.mat` y `configuracion.mat`: tabla, criterios, grilla y parámetros.
- `mapa_pid_theta.png` y `.fig`: una sección Kp/Kd por cada valor de Ki.
- `mejor_ensayo.mat` y `.png`: señales del ensayo admisible con menor pico de x.
- `modelo_ensayo/`: copia de los modelos y del script de parámetros usados.

Estados del mapa:

- Verde: cumple recorrido y convergencia.
- Rojo: excede el recorrido.
- Amarillo: respeta recorrido pero no satisface todas las bandas de convergencia.
- Gris: error de simulación, estado no finito o parada por pérdida angular.

Las celdas representan **puntos muestreados**, no regiones interpoladas. Los ejes
usan etiquetas con las ganancias reales, aunque los puntos estén espaciados de
forma no uniforme. No deben tomarse mínimos/máximos marginales de Kp, Kd y Ki
como una caja de combinaciones admisibles: las tres ganancias interactúan.

`SaturaConsigna` indica si la corriente pedida por la compensación fue recortada.
No excluye automáticamente el punto: el objetivo se evalúa con los límites del
actuador existentes. `Imax` y `Vmax` registran la actuación efectivamente simulada.
`TAsentamiento` es el tiempo a partir del cual las cuatro bandas se satisfacen
hasta el final del ensayo. No es una prueba de estabilidad asintótica.

`RouthIdeal` solo informa la condición del PID angular ideal compensado
(`Kp>0`, `Kd>0`, `Ki>=0`, y `Kd*Kp>Ki` si Ki>0). No filtra puntos ni sustituye
la simulación de la cascada con estimadores, saturaciones y corriente real.

## Alcance

El mapa es nominal para este mecanismo, estos lazos de posición/corriente, estos
estimadores, este ángulo inicial y este horizonte. No garantiza robustez frente a
otras masas, ruido, retardo, ángulo del lado contrario o velocidades iniciales.
La restricción se verifica numéricamente con el solver y el paso indicados; no
constituye una demostración de cumplimiento en tiempo continuo ni en hardware.

Documentación de las APIs empleadas:

- https://www.mathworks.com/help/simulink/slref/simulink.simulationinput.setvariable.html
- https://www.mathworks.com/help/simulink/ug/write-matlab-scripts-to-run-fast-restart-simulations.html
- https://www.mathworks.com/help/simulink/slref/parsim.html

## Verificacion de las opciones nuevas

El 1/11/2026 se verifico en MATLAB R2026b con Parallel Computing Toolbox 26.2:

- Grilla de cuatro casos: Kp=[64 144], Kd=16.8, Ki=[0 20].
- Modo secuencial y modo paralelo con dos workers de Processes: mismos estados
  (dos admisibles y dos fuera del recorrido), con diferencia de Xmax inferior
  a 1e-6 m entre modos.
- Con InicialesDelArchivo=false ambos usaron x_init=0, aunque el archivo tenia
  x_init=-0.50 m. Con InicialesDelArchivo=true se verifico x_init=-0.50 m y el
  rechazo inmediato por recorrido del ensayo 144/16.8/0.
- El bucle secuencial tardo 12.3 s y la fase paralela 34.4 s, sin contar el
  arranque del pool. Son tiempos de una prueba pequena, no una aceleracion
  medida para el barrido de 196 puntos. La inicializacion y transferencia
  de modelos domina esos cuatro casos.

El log es `verificacion_paralela.log`; las tablas y rutas se conservaron en
`resultados_barrido_theta/verificacion_paralela.mat`. Los modelos originales
y el script de parametros no se modificaron en esta verificacion.

## Primera ejecución completa: 1 de noviembre de 2026

Resultados en `resultados_barrido_theta/20261101_165209_092/`.
Se completaron los 196 puntos en unos 265 s de simulaciones, más la inicialización
de MATLAB y la exportación de las figuras. Cumplieron 107 puntos; 89 excedieron
el recorrido. No hubo errores de simulación ni casos clasificados como no convergentes.

| Ki | Cumplen | Exceden recorrido |
|---:|---:|---:|
| 0 | 27 | 22 |
| 5 | 27 | 22 |
| 20 | 27 | 22 |
| 50 | 26 | 23 |

El control exterior usado fue `Kpx=0.10197162`, `Kdx=0.18354892`, `Kix=0`.
Los límites de consigna de corriente y tensión fueron ±5 A y ±24 V.

| Kp | Kd | Ki | Pico de x [m] | Asentamiento [s] | Pico de tensión [V] |
|---:|---:|---:|---:|---:|---:|
| 144 | 16 | 0 | 0.340122 | 4.620 | 4.741 |
| 196 | 20 | 0 | 0.324478 | 4.660 | 5.520 |
| 400 | 36 | 0 | 0.304076 | 4.852 | 7.115 |
| 144 | 16 | 20 | 0.342819 | 14.094 | 4.771 |
| 196 | 20 | 20 | 0.326560 | 15.398 | 5.542 |
| 400 | 36 | 20 | 0.305065 | 16.641 | 7.130 |

El punto 400/36/0 minimizó el pico entre los puntos muestreados. No es una
recomendación automática de diseño ni un óptimo global. La integral cambia el
transitorio y los tiempos; no es necesaria para el error estacionario nominal
en estos ejemplos PD. Su utilidad ante perturbaciones persistentes requiere otro
ensayo, que este mapa no sustituye.

La prueba inicial de 18 casos, conservada en `20261101_165038_910/`, reprodujo
el caso de referencia 144/16.8/0 con pico de 0.339932 m. También verificó el punto
actual del script, 196/19.6/0: pico de 0.324944 m y asentamiento de 4.626 s.
