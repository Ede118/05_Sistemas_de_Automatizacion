function resultado = simular_main()
%SIMULAR_MAIN Ejecuta 30 s en modo Normal, sin compilar Rapid Accelerator.
%   resultado = simular_main() inicializa los parametros del proyecto y
%   devuelve las senales registradas en resultado.logsout.
carpeta = fileparts(mfilename('fullpath'));
directorioAnterior = pwd;
restaurarDirectorio = onCleanup(@() cd(directorioAnterior));
cd(carpeta);
load_system(fullfile(carpeta, 'main.slx'));
archivoParametros = strrep(fullfile(carpeta, 'Pendulo_Invertido.m'), '''', '''''');
evalin('base', ['run(''' archivoParametros ''');']);
resultado = sim('main', 'SimulationMode', 'normal', ...
    'StopTime', '30', 'ReturnWorkspaceOutputs', 'on');
end
