function [resultados, carpetaSalida] = barrer_pid_theta(opciones)
%BARRER_PID_THETA Mapa nominal de ganancias del PID angular de main.slx.
%
% USO INICIAL: escribir en la Command Window de MATLAB, desde esta carpeta:
%   [T, carpeta] = barrer_pid_theta(Kp=144, Kd=16.8, Ki=0);
% Esto ejecuta UNA combinacion. Para el mapa predeterminado de 196 puntos:
%   [T, carpeta] = barrer_pid_theta;
%
% GRILLA PERSONALIZADA (2*2*2 = 8 ensayos, todas las combinaciones):
%   [T, carpeta] = barrer_pid_theta(Kp=[144 196],Kd=[16 20],Ki=[0 20]);
% Para usar PCT: Paralelo=true, Workers=2. Para respetar los valores iniciales
% del archivo: InicialesDelArchivo=true. Ambas opciones son false por defecto.
% Los argumentos Kp, Kd y Ki son listas de valores INDEPENDIENTES. No son
% tres listas de parejas: ndgrid construye el producto cartesiano completo.
%
% SALIDAS:
%   T       : tabla; una fila por combinacion, incluidas las que fallan.
%   carpeta : ruta absoluta con CSV, MAT, mapas PNG/FIG y copias del modelo.
% Ejemplos para consultar la tabla, sin volver a simular:
%   T(T.Cumple,:)                        % Filtrar las filas admisibles.
%   sortrows(T(T.Cumple,:), 'Xmax')       % Menor recorrido primero.
%   T(T.Ki==0 & T.Cumple,:)              % Solo los PD admisibles.
%
% CONDICION INICIAL PREDETERMINADA: theta=pi-20*pi/180; las demas nulas.
% Se mantienen los parametros fisicos y los otros lazos del archivo guardado
% Pendulo_Invertido.m. Las ganancias angulares se reemplazan solo por ensayo.
%
% ACEPTACION PREDETERMINADA: |x|<0.40 m durante todo el ensayo y, durante
% los ultimos 2 de los 30 s: error angular<=0.5 grados, velocidad angular
% <=1 grado/s, |x|<=0.01 m y |dx|<=0.01 m/s. Cambiar tolerancias cambia el mapa.
%
% Ejecutar sin los modelos del proyecto abiertos: guardar/cerrar el trabajo
% o utilizar otra sesion de MATLAB. Se simulan COPIAS de los SLX; nunca se
% guardan cambios en el diseno original. El modo secuencial no requiere PCT;
% Paralelo=true requiere Parallel Computing Toolbox y workers de procesos.
% El resultado es nominal y muestreado; no prueba robustez ni estabilidad global.
% Ver BARRIDO_PID_THETA.md para el tutorial y la descripcion de las columnas.

% 1) Opciones de entrada. MATLAB construye la estructura "opciones" a partir
% de argumentos con nombre: Kp=[...], LimiteX=0.40, Tfinal=30, etc.
% (1,:) acepta un vector fila, incluso un solo valor; (1,1), un escalar.
% Si no se proporciona una opcion, se usa el valor a la derecha del signo =.
arguments
 opciones.Kp (1,:) double {mustBeFinite,mustBeNonnegative} = [64 100 144 196 256 324 400]
 opciones.Kd (1,:) double {mustBeFinite,mustBeNonnegative} = [8 12 16 20 24 28 36]
 opciones.Ki (1,:) double {mustBeFinite,mustBeNonnegative} = [0 5 20 50]
 opciones.Tfinal (1,1) double {mustBePositive} = 30
 opciones.VentanaFinal (1,1) double {mustBePositive} = 2
 opciones.LimiteX (1,1) double {mustBePositive} = 0.40
 opciones.TolThetaGrados (1,1) double {mustBePositive} = 0.5
 opciones.TolOmegaGrados (1,1) double {mustBePositive} = 1
 opciones.TolX (1,1) double {mustBePositive} = 0.01
 opciones.TolVelocidad (1,1) double {mustBePositive} = 0.01
 opciones.PasoMaximo (1,1) double {mustBePositive} = 0.001
 opciones.FastRestart (1,1) logical = true
 opciones.InicialesDelArchivo (1,1) logical = false
 opciones.Paralelo (1,1) logical = false
 opciones.Workers (1,1) double {mustBeInteger,mustBeNonnegative} = 0
 opciones.LoteParalelo (1,1) double {mustBeInteger,mustBePositive} = 20
end
% Comprobaciones de configuracion: estos assert SI detienen la funcion porque
% una configuracion invalida no permite interpretar ningun ensayo de la grilla.
assert(opciones.Tfinal>opciones.VentanaFinal,'Tfinal debe superar VentanaFinal.');
assert(~isempty(opciones.Kp)&&~isempty(opciones.Kd)&&~isempty(opciones.Ki),'La grilla no puede estar vacia.');
origen=fileparts(mfilename('fullpath'));
archivos=dir(fullfile(origen,'*.slx'));
% No cerrar automaticamente modelos del usuario: podrian tener cambios sin guardar.
for j=1:numel(archivos)
 [~,nombre]=fileparts(archivos(j).name);
 assert(~bdIsLoaded(nombre),'barrido:ModeloAbierto', ...
  'El modelo %s esta abierto. Guarde su trabajo y cierrelo, o use otra sesion de MATLAB.',nombre);
end
% 2) Crear una carpeta unica por ejecucion y copiar el modelo guardado.
% La copia de Pendulo_Invertido.m permite saber con que planta se genero el mapa.
carpetaSalida=fullfile(origen,'resultados_barrido_theta',char(datetime('now','Format','yyyyMMdd_HHmmss_SSS')));
trabajo=fullfile(carpetaSalida,'modelo_ensayo'); mkdir(trabajo);
for j=1:numel(archivos), copyfile(fullfile(origen,archivos(j).name),trabajo); end
copyfile(fullfile(origen,'Pendulo_Invertido.m'),trabajo);
anterior=pwd; rutaAnterior=path;
% onCleanup ejecuta restaurar al salir, tambien si ocurre un error inesperado.
% Se recuperan la carpeta y el path originales, y se cierran solo las copias.
limpiar=onCleanup(@() restaurar(anterior,rutaAnterior,trabajo,archivos)); %#ok<NASGU>
cd(trabajo); addpath(trabajo,'-begin');
parametros=cargarParametros(fullfile(trabajo,'Pendulo_Invertido.m'));
% Por defecto prevalece el ensayo original. Con InicialesDelArchivo=true se
% conservan theta_init, x_init, dx_init, dtheta_init e i_init del archivo copiado.
if ~opciones.InicialesDelArchivo
 parametros.theta_init=pi-20*pi/180;
 parametros.x_init=0; parametros.dx_init=0; parametros.dtheta_init=0; parametros.i_init=0;
end
if abs(parametros.x_init)>=opciones.LimiteX
 warning('barrido:InicialFueraLimite', ...
  'x_init=%g m incumple |x|<%g m desde t=0; ningun ensayo puede aprobar.',parametros.x_init,opciones.LimiteX);
end
for nombre={'main','Planta','Controlador','ControladorAngularPID','ControladorCorriente','RetroalimentacionNoLineal_v2'}
 load_system(fullfile(trabajo,[nombre{1} '.slx']));
end
% 3) Verificar conexiones esperadas e instrumentar las senales.
% Si se renombran bloques en Simulink, revisar estas rutas y las de registrar.
assert(strcmp(get_param('main/Constant4','Value'),'Kp_theta') && ...
 strcmp(get_param('main/Constant5','Value'),'Kd_theta') && ...
 strcmp(get_param('main/Constant6','Value'),'Ki_theta'), ...
 'Las constantes angulares ya no usan Kp_theta, Kd_theta y Ki_theta. Revisar el arnes.');
assert(strcmp(get_param('main/Manual Switch1','CurrentSetting'),'1'), ...
 'El selector no habilita el control. El barrido no cambia esa decision.');
registrar('Planta/Integrator1','barrido_x'); registrar('Planta/Integrator','barrido_dx');
registrar('Planta/Integrator6','barrido_theta'); registrar('Planta/Integrator5','barrido_omega');
registrar('Planta/Integrator4','barrido_i'); registrar('ControladorCorriente/Saturation1','barrido_v');
registrar('ControladorCorriente/Saturation','barrido_i_ref_lim');
registrar('RetroalimentacionNoLineal_v2/Divide2','barrido_i_ref');
% registrar habilita signal logging. Despues de sim(), las senales se consultan
% como salida.logsout.getElement('barrido_x').Values, un objeto timeseries.
%
% 4) Agregar paradas tempranas SOLO a la copia cargada en memoria.
% Solo detienen pruebas ya fallidas. No frenan ni limitan el estado de la planta.
add_block('simulink/Math Operations/Abs','main/BarridoAbsX');
add_block('simulink/Logic and Bit Operations/Compare To Constant','main/BarridoLimX', ...
 'const',num2str(opciones.LimiteX,17),'relop','>=');
add_block('simulink/Sinks/Stop Simulation','main/BarridoStopX');
add_line('main','Gain4/1','BarridoAbsX/1'); add_line('main','BarridoAbsX/1','BarridoLimX/1');
add_line('main','BarridoLimX/1','BarridoStopX/1');
add_block('simulink/Math Operations/Bias','main/BarridoErrorTheta','Bias','-pi');
add_block('simulink/Math Operations/Abs','main/BarridoAbsTheta');
add_block('simulink/Logic and Bit Operations/Compare To Constant','main/BarridoLimTheta','const','1.3','relop','>=');
add_block('simulink/Sinks/Stop Simulation','main/BarridoStopTheta');
add_line('main','Gain1/1','BarridoErrorTheta/1'); add_line('main','BarridoErrorTheta/1','BarridoAbsTheta/1');
add_line('main','BarridoAbsTheta/1','BarridoLimTheta/1'); add_line('main','BarridoLimTheta/1','BarridoStopTheta/1');
% 5) Preparar una plantilla de simulacion. SimulationInput asocia parametros
% a una ejecucion sin editar los valores guardados en los bloques del SLX.
entrada=Simulink.SimulationInput('main');
nombres=fieldnames(parametros);
for j=1:numel(nombres), entrada=entrada.setVariable(nombres{j},parametros.(nombres{j})); end
% Normal evita requerir la compilacion de Rapid Accelerator. CaptureErrors
% permite clasificar errores en la tabla. Fast Restart reutiliza la compilacion
% entre ensayos; no reutiliza los estados finales como estados iniciales.
entrada=entrada.setModelParameter('SimulationMode','normal','StopTime',num2str(opciones.Tfinal), ...
 'SignalLogging','on','SignalLoggingName','logsout','ReturnWorkspaceOutputs','on', ...
 'MaxStep',num2str(opciones.PasoMaximo),'CaptureErrors','on', ...
 'FastRestart',char(stringOnOff(opciones.FastRestart)));
% ndgrid genera todas las ternas. Ejemplo: 2 Kp, 3 Kd y 4 Ki producen 24 casos.
% P(j), D(j), I(j) son las ganancias de UNA fila del futuro resultado.
[P,D,I]=ndgrid(opciones.Kp,opciones.Kd,opciones.Ki); total=numel(P);
% Preasignar evita que la estructura crezca en memoria en cada iteracion.
filas=repmat(filaVacia, total,1); mejorPico=inf; mejoresSenales=[];
% Los workers no ven cambios sin guardar del cliente. Guardar el arnes y el
% logging SOLO en las copias de modelo_ensayo; nunca en los archivos originales.
if opciones.Paralelo
 prepararPool(opciones,origen);
 for nombre={'Planta','ControladorCorriente','RetroalimentacionNoLineal_v2','ControladorAngularPID','Controlador','main'}
  archivoModelo=get_param(nombre{1},'FileName');
  assert(startsWith(archivoModelo,trabajo),'Se intento guardar fuera de la copia de ensayo.');
  save_system(nombre{1});
 end
end
save(fullfile(carpetaSalida,'configuracion.mat'),'opciones','parametros','P','D','I');
fprintf('CARPETA_RESULTADOS %s\n',carpetaSalida);
fprintf('BARRIDO %d casos; posicion fija: Kpx=%.8g Kdx=%.8g Kix=%.8g\n', ...
 total,parametros.Kpx,parametros.Kdx,parametros.Kix);
fprintf('INICIALES theta=%.9g x=%.9g dx=%.9g dtheta=%.9g i=%.9g; paralelo=%d\n', ...
 parametros.theta_init,parametros.x_init,parametros.dx_init,parametros.dtheta_init,parametros.i_init,opciones.Paralelo);
reloj=tic;
% 6) Bucle principal: configurar -> simular -> evaluar -> guardar una fila.
for j=1:total
 % parsim distribuye un lote entre los workers. Acotar el lote evita retener
 % todas las trazas de una grilla grande en memoria; se procesan en orden.
 if opciones.Paralelo && mod(j-1,opciones.LoteParalelo)==0
  inicioLote=j; finLote=min(total,j+opciones.LoteParalelo-1);
  entradas=repmat(entrada,1,finLote-inicioLote+1);
  for q=inicioLote:finLote
   entradas(q-inicioLote+1)=entrada.setVariable('Kp_theta',P(q)) ...
    .setVariable('Kd_theta',D(q)).setVariable('Ki_theta',I(q)) ...
    .setModelParameter('FastRestart','off');
  end
  salidasLote=parsim(entradas,'UseFastRestart',char(stringOnOff(opciones.FastRestart)), ...
   'ShowProgress','on','ShowSimulationManager','off','StopOnError','off', ...
   'TransferBaseWorkspaceVariables','off','ManageDependencies','on', ...
   'SetupFcn',@() prepararWorker(trabajo),'CleanupFcn',@limpiarWorker);
 end
 fila=filaVacia; fila.Kp=P(j); fila.Kd=D(j); fila.Ki=I(j);
 % Dato teorico orientativo. NO se usa para descartar ni aprobar combinaciones:
 % Routh ideal no representa todos los estados y limites de esta cascada.
 fila.RouthIdeal=fila.Kp>0 && fila.Kd>0 && (fila.Ki==0 || fila.Kd*fila.Kp>fila.Ki);
 try
  % Solo cambian estas tres variables; el resto proviene de la plantilla.
  prueba=entrada.setVariable('Kp_theta',P(j)).setVariable('Kd_theta',D(j)).setVariable('Ki_theta',I(j));
  if opciones.Paralelo, salida=salidasLote(j-inicioLote+1);
  else, salida=sim(prueba); end
  if ~isempty(salida.ErrorMessage)
   fila.Estado="error_simulacion"; fila.Detalle=string(salida.ErrorMessage);
  else
   [fila,datos]=evaluar(salida.logsout,fila,opciones);
   % Conservar trazas completas solo del admisible con menor recorrido.
   % Todos los demas ensayos conservan sus metricas en la tabla.
   if fila.Cumple && fila.Xmax<mejorPico
    mejorPico=fila.Xmax; mejoresSenales=datos;
    save(fullfile(carpetaSalida,'mejor_ensayo.mat'),'fila','datos','opciones','parametros');
   end
  end
 catch err
  % Un error individual no cancela las demas combinaciones.
  fila.Estado="error_simulacion"; fila.Detalle=string(err.message);
 end
 filas(j)=fila;
 % Checkpoint cada diez casos y al finalizar. No es una reanudacion automatica:
 % permite consultar o recuperar las filas terminadas si se interrumpe el barrido.
 if mod(j,10)==0 || j==total
  resultados=struct2table(filas(1:j));
  writetable(resultados,fullfile(carpetaSalida,'resultados.csv'));
  save(fullfile(carpetaSalida,'resultados.mat'),'resultados','opciones','parametros','j','total');
  fprintf('PROGRESO %d/%d cumplen=%d tiempo=%.1fs ultimo=%s\n', ...
   j,total,nnz(resultados.Cumple),toc(reloj),fila.Estado);
 end
end
% 7) Exportacion final. La tabla completa incluye exitos, rechazos y errores.
set_param('main','FastRestart','off');
resultados=struct2table(filas);
writetable(resultados(resultados.Cumple,:),fullfile(carpetaSalida,'ganancias_admisibles.csv'));
dibujarMapa(resultados,opciones,carpetaSalida,parametros);
if ~isempty(mejoresSenales), dibujarMejor(mejoresSenales,opciones,carpetaSalida); end
fprintf('FINAL %d/%d admisibles.\n',nnz(resultados.Cumple),total);
disp(resultados(resultados.Cumple,{'Kp','Kd','Ki','Xmax','TAsentamiento','Imax','Vmax'}));
end

function p=cargarParametros(archivo)
% Evalua el script en este workspace local, sin reemplazar variables del usuario.
% Devuelve solo sus escalares double (masas, ganancias, constantes, etc.).
% Si se agregan buses, estructuras o parametros no escalares al modelo, ampliar
% este filtro: actualmente esos tipos no se transfieren a SimulationInput.
texto=fileread(archivo); eval(texto);
variables=whos; p=struct;
for j=1:numel(variables)
 nombre=variables(j).name;
 if ~ismember(nombre,{'archivo','texto'}) && strcmp(variables(j).class,'double') && variables(j).bytes==8
  p.(nombre)=eval(nombre);
 end
end
end
function registrar(bloque,nombre)
% Habilita el registro del primer puerto de salida con un nombre estable.
% El nombre del bloque indica de donde sale la senal; nombre indica como se
% encontrara despues en logsout. No son necesariamente el mismo texto.
ph=get_param(bloque,'PortHandles');
set_param(ph.Outport(1),'DataLogging','on','DataLoggingNameMode','Custom','DataLoggingName',nombre);
end
function fila=filaVacia
% Esquema de una fila: mismas columnas para todos los casos, aunque fallen.
% NaN significa que una metrica no se llego a calcular; consultar Estado/Detalle.
fila=struct('Kp',NaN,'Kd',NaN,'Ki',NaN,'RouthIdeal',false,'Cumple',false, ...
 'Estado',"pendiente",'Tfinal',NaN,'Xmax',NaN,'ThetaMaxGrados',NaN, ...
 'ErrorAngularColaGrados',NaN,'OmegaColaGrados',NaN,'XCola',NaN,'VelCola',NaN, ...
 'Imax',NaN,'Vmax',NaN,'SaturaConsigna',false,'TAsentamiento',NaN,'Detalle',"");
end
function [fila,datos]=evaluar(logs,fila,o)
% Extraer timeseries: .Time contiene tiempos y .Data, los valores registrados.
% theta y omega vienen en rad y rad/s; se convierten a grados para las bandas.
nombres={'x','dx','theta','omega','i','v','i_ref_lim','i_ref'}; datos=struct;
for j=1:numel(nombres)
 datos.(nombres{j})=logs.getElement(['barrido_' nombres{j}]).Values;
end
fila.Tfinal=datos.x.Time(end); fila.Xmax=max(abs(datos.x.Data(:)));
fila.ThetaMaxGrados=max(abs(datos.theta.Data(:)-pi))*180/pi;
fila.Imax=max(abs(datos.i.Data(:))); fila.Vmax=max(abs(datos.v.Data(:)));
fila.SaturaConsigna=max(abs(datos.i_ref.Data(:)-datos.i_ref_lim.Data(:)))>1e-5;
% Primero rechazar resultados no finitos: no deben poder aprobar por accidente.
for j=1:numel(nombres)
 if any(~isfinite(datos.(nombres{j}).Data(:)))
  fila.Estado="no_finito"; return
 end
end
% ASSERT por ensayo: se captura y clasifica para continuar con la grilla.
% Xmax usa el ensayo completo disponible. La comparacion es estricta (<).
% Estos assert son distintos de los iniciales: un rechazo aqui es un resultado
% esperado del barrido, no una configuracion erronea de la funcion.
try
 assert(fila.Xmax<o.LimiteX,'barrido:Recorrido','Se excedio el recorrido estricto.');
catch err
 fila.Estado="fuera_recorrido"; fila.Detalle=string(err.message); return
end
if fila.Tfinal<o.Tfinal-1e-6
 % Un ensayo detenido temprano no puede aprobar aunque su ultima muestra
 % permanezca apenas dentro de la banda por redondeo numerico.
 if fila.Xmax>o.LimiteX-1e-6, fila.Estado="fuera_recorrido";
 else, fila.Estado="perdida_angular"; end
 return
end
inicio=o.Tfinal-o.VentanaFinal;
% En un ensayo de 30 s con ventana de 2 s se evalua TODO el tramo [28,30].
% Asi se evita aprobar solo porque la senal cruce pi en el instante final.
fila.ErrorAngularColaGrados=max(abs(cola(datos.theta,inicio)-pi))*180/pi;
fila.OmegaColaGrados=max(abs(cola(datos.omega,inicio)))*180/pi;
fila.XCola=max(abs(cola(datos.x,inicio))); fila.VelCola=max(abs(cola(datos.dx,inicio)));
try
 assert(fila.ErrorAngularColaGrados<=o.TolThetaGrados,'barrido:Angulo','No mantiene el angulo en la banda final.');
 assert(fila.OmegaColaGrados<=o.TolOmegaGrados,'barrido:Omega','La velocidad angular no converge.');
 assert(fila.XCola<=o.TolX && fila.VelCola<=o.TolVelocidad, ...
  'barrido:Carrito','El carrito no converge al origen y al reposo.');
 fila.Cumple=true; fila.Estado="cumple";
catch err
 fila.Estado="no_converge"; fila.Detalle=string(err.message);
end
% Tiempo desde el cual todas las bandas se cumplen sin volver a salir.
% Las senales pueden tener distintos tiempos de muestreo. interp1 las compara
% sobre la misma base temporal, la de x. La referencia angular sigue siendo pi.
t=datos.x.Time; bueno=abs(datos.x.Data)<=o.TolX;
bueno=bueno & abs(interp1(datos.dx.Time,double(datos.dx.Data),t))<=o.TolVelocidad;
bueno=bueno & abs(interp1(datos.theta.Time,double(datos.theta.Data),t)-pi)<=o.TolThetaGrados*pi/180;
bueno=bueno & abs(interp1(datos.omega.Time,double(datos.omega.Data),t))<=o.TolOmegaGrados*pi/180;
ultimo=find(~bueno,1,'last');
if isempty(ultimo), fila.TAsentamiento=t(1);
elseif ultimo<numel(t), fila.TAsentamiento=t(ultimo+1); end
end
function y=cola(v,inicio)
% Seleccionar la ventana final de una timeseries, incluyendo su borde inicial.
idx=v.Time>=inicio; y=v.Data(idx);
% Agrega el valor interpolado en el inicio exacto de la ventana.
y=[interp1(v.Time,double(v.Data),inicio); double(y(:))];
end
function dibujarMapa(T,o,carpeta,parametros)
% Una seccion 2D por Ki: filas = Kp, columnas = Kd. Los codigos 0..3 se
% traducen a colores. Cada celda es un punto probado, no una interpolacion.
fig=figure('Visible','off','Color','w','Position',[100 100 1200 750]);
tiledlayout('flow');
for ki=o.Ki
 nexttile; Z=zeros(numel(o.Kp),numel(o.Kd));
 for a=1:numel(o.Kp)
  for b=1:numel(o.Kd)
   r=T(T.Kp==o.Kp(a)&T.Kd==o.Kd(b)&T.Ki==ki,:);
   if r.Cumple, Z(a,b)=3;
   elseif r.Estado=="fuera_recorrido", Z(a,b)=1;
   elseif r.Estado=="no_converge", Z(a,b)=2; end
  end
 end
 % Coordenadas de celdas uniformes: las etiquetas muestran las ganancias reales.
 imagesc(1:numel(o.Kd),1:numel(o.Kp),Z); axis xy;
 xticks(1:numel(o.Kd)); xticklabels(string(o.Kd));
 yticks(1:numel(o.Kp)); yticklabels(string(o.Kp));
 xlabel('Kd theta'); ylabel('Kp theta'); title(sprintf('Ki theta = %g',ki));
 clim([-0.5 3.5]); cb=colorbar;
 cb.Ticks=0:3; cb.TickLabels={'Error/perdida angular','Excede recorrido','No converge','Cumple'};
end
colormap(fig,[0.25 0.25 0.25;0.85 0.25 0.20;0.95 0.70 0.15;0.15 0.65 0.35]);
sgtitle(sprintf('Mapa nominal: theta inicial = %.1f grados; x inicial = %.2f m; |x| < %.2f m; T = %g s', ...
 parametros.theta_init*180/pi,parametros.x_init,o.LimiteX,o.Tfinal));
exportgraphics(fig,fullfile(carpeta,'mapa_pid_theta.png'),'Resolution',160);
savefig(fig,fullfile(carpeta,'mapa_pid_theta.fig')); close(fig);
end
function dibujarMejor(d,o,carpeta)
% Comparacion visual del caso admisible con menor pico de recorrido.
fig=figure('Visible','off','Color','w','Position',[100 100 1100 700]); tiledlayout(2,2);
nexttile; plot(d.x.Time,d.x.Data); hold on; yline(o.LimiteX,'r--'); yline(-o.LimiteX,'r--'); ylabel('x [m]'); grid on;
nexttile; plot(d.theta.Time,(d.theta.Data-pi)*180/pi); ylabel('theta - pi [grados]'); grid on;
nexttile; plot(d.i.Time,d.i.Data); ylabel('Corriente [A]'); grid on;
nexttile; plot(d.v.Time,d.v.Data); ylabel('Tension [V]'); grid on;
sgtitle('Ensayo admisible con menor pico de recorrido entre los puntos muestreados');
exportgraphics(fig,fullfile(carpeta,'mejor_ensayo.png'),'Resolution',150); close(fig);
end
function s=stringOnOff(v)
% Convertir un logical de MATLAB a la opcion 'on'/'off' esperada por Simulink.
if v, s="on"; else, s="off"; end
end
function prepararPool(o,origen)
% No eliminar ni reemplazar silenciosamente un pool abierto por el usuario.
assert(~isempty(ver('parallel')) && license('test','Distrib_Computing_Toolbox'), ...
 'barrido:SinPCT','Paralelo=true requiere Parallel Computing Toolbox disponible.');
pool=gcp('nocreate');
if isempty(pool)
 perfil=parcluster('Processes'); n=o.Workers;
 if n==0, n=min(4,perfil.NumWorkers); end
 pool=parpool(perfil,n);
else
 assert(~isa(pool,'parallel.ThreadPool'),'barrido:PoolThreads', ...
  'parsim requiere workers de procesos. Use un pool Processes, no Threads.');
 assert(o.Workers==0 || pool.NumWorkers==o.Workers,'barrido:WorkersDistintos', ...
  'El pool abierto tiene %d workers. Use Workers=0 para reutilizarlo o ajuste el pool manualmente.',pool.NumWorkers);
end
addAttachedFiles(pool,{fullfile(origen,'barrer_pid_theta.m')});
fprintf('POOL %d workers de procesos; se mantiene abierto para reutilizarlo.\n',pool.NumWorkers);
end
function prepararWorker(trabajo)
% Todos los parametros viajan en SimulationInput: no copiar el Base Workspace.
% parsim gestiona las carpetas de cache independientes de cada worker.
estado=struct('carpeta',pwd,'ruta',path);
setappdata(0,'barrido_theta_worker',estado);
addpath(trabajo,'-begin'); cd(trabajo);
end
function limpiarWorker
if isappdata(0,'barrido_theta_worker')
 estado=getappdata(0,'barrido_theta_worker');
 cd(estado.carpeta); path(estado.ruta); rmappdata(0,'barrido_theta_worker');
end
end
function restaurar(anterior,rutaAnterior,trabajo,archivos)
% Limpieza: descartar solo los cambios en las copias pertenecientes a esta
% ejecucion. No guardar ni cerrar modelos ajenos a la carpeta de trabajo.
for j=1:numel(archivos)
 [~,n]=fileparts(archivos(j).name);
 if bdIsLoaded(n) && startsWith(get_param(n,'FileName'),trabajo)
  try set_param(n,'FastRestart','off'); catch, end
  try close_system(n,0); catch, end
 end
end
cd(anterior); path(rutaAnterior);
end
