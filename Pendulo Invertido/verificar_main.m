function verificar_main()
%VERIFICAR_MAIN Comprueba estabilidad nominal, equilibrio y saturacion.
carpeta = fileparts(mfilename('fullpath'));
directorioAnterior = pwd;
restaurarDirectorio = onCleanup(@() cd(directorioAnterior));
cd(carpeta);
resultado = simular_main();
theta = resultado.logsout.getElement('theta').Values;
x = resultado.logsout.getElement('x').Values;
f = resultado.logsout.getElement('F_real').Values;
i = resultado.logsout.getElement('i_cmd').Values;
assert(all(isfinite(theta.Data(:))) && all(isfinite(x.Data(:))), ...
    'La simulacion produjo estados no finitos.');
assert(abs(theta.Data(end)-pi) < 1e-3, 'El pendulo no convergio.');
assert(abs(x.Data(end)) < 0.01, 'El carrito no convergio.');
imax = evalin('base','i_m_max');
assert(max(abs(i.Data(:))) <= imax + 1e-9, 'Se excedio la corriente maxima.');
fprintf('NOMINAL: error angular final %.6g rad; x final %.6g m; ', ...
    theta.Data(end)-pi,x.Data(end));
fprintf('max |x| %.6g m; max |F| %.6g N; max |i| %.6g A.\n', ...
    max(abs(x.Data(:))),max(abs(f.Data(:))),max(abs(i.Data(:))));
fig = figure('Visible','off','Color','w','Position',[100 100 1100 750]);
limpiarFigura = onCleanup(@() close(fig));
tiledlayout(2,2);
nexttile; plot(theta.Time,(theta.Data-pi)*180/pi); grid on;
xlabel('Tiempo [s]'); ylabel('Error angular [grados]');
nexttile; plot(x.Time,x.Data); grid on;
xlabel('Tiempo [s]'); ylabel('Posicion del carrito [m]');
nexttile; plot(f.Time,f.Data); grid on;
xlabel('Tiempo [s]'); ylabel('Fuerza aplicada [N]');
nexttile; plot(i.Time,i.Data); grid on;
xlabel('Tiempo [s]'); ylabel('Corriente de referencia [A]');
sgtitle('Modelo nominal: actuador ideal con saturacion de corriente');
exportgraphics(fig,fullfile(carpeta,'validacion_main.png'),'Resolution',140);

entrada = Simulink.SimulationInput('main');
entrada = entrada.setVariable('theta_init',pi);
entrada = entrada.setModelParameter('SimulationMode','normal','StopTime','2');
equilibrio = sim(entrada);
teq = equilibrio.logsout.getElement('theta').Values.Data;
xeq = equilibrio.logsout.getElement('x').Values.Data;
assert(max(abs(teq(:)-pi)) < 1e-8 && max(abs(xeq(:))) < 1e-8, ...
    'No se preserva el equilibrio vertical.');
disp('EQUILIBRIO_OK');

% Modelo de prueba temporal: prueba ambos signos sin modificar Actuador.slx.
modeloPrueba = 'prueba_actuador_codex';
assert(~bdIsLoaded(modeloPrueba),'Ya existe un modelo con el nombre de prueba.');
new_system(modeloPrueba);
limpiarModelo = onCleanup(@() close_system(modeloPrueba,0));
add_block('simulink/Sources/Constant',[modeloPrueba '/Consigna'],'Value','100');
add_block('simulink/Ports & Subsystems/Subsystem Reference', ...
    [modeloPrueba '/Actuador'],'ReferencedSubsystem','Actuador');
add_block('simulink/Sinks/To Workspace',[modeloPrueba '/F'], ...
    'VariableName','F_test','SaveFormat','Timeseries');
add_block('simulink/Sinks/To Workspace',[modeloPrueba '/I'], ...
    'VariableName','I_test','SaveFormat','Timeseries');
add_line(modeloPrueba,'Consigna/1','Actuador/1');
add_line(modeloPrueba,'Actuador/1','F/1');
add_line(modeloPrueba,'Actuador/2','I/1');
fmax = evalin('base','kt*i_m_max/r');
for signo = [-1 1]
    set_param([modeloPrueba '/Consigna'],'Value',num2str(signo*2*fmax));
    salida = sim(modeloPrueba,'SimulationMode','normal','StopTime','0.01', ...
        'ReturnWorkspaceOutputs','on');
    assert(abs(salida.F_test.Data(end)-signo*fmax)<1e-8);
    assert(abs(salida.I_test.Data(end)-signo*imax)<1e-8);
end
disp('SATURACION_POSITIVA_Y_NEGATIVA_OK');
disp('VERIFICACION_MAIN_OK');
end
