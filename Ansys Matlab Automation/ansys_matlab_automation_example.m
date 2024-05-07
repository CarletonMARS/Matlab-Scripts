close all;
clear all;
clc;
set(0,'defaultaxesfontsize',20)
set(0,'defaultaxesfontname','Times New Roman')

%% This code runs a pre-defined error-free hfss project. It sets desired local variables and can retrieve the results back into matlab.

Runs = 3; % number of runs

for i = 1:Runs % run the code multiple times

    R0m = rand(1,20)*100; % variables to change
    Cap0m = rand(1,20)*2.2; % variables to change

    script = fopen('Coupled_Resonator_Circuit_Sweep.py', 'w'); %create an IronPython Script compatible with HFSS

    fprintf(script, 'import ScriptEnv\n');
    fprintf(script, 'ScriptEnv.Initialize("Ansoft.ElectronicsDesktop")\n');
    fprintf(script, 'oDesktop.RestoreWindow()\n');

    fprintf(script, 'oDesktop.OpenProject("/home/shulabh.gupta/fast_local_storage/HFSS_SIMULATIONS/ANSYS_AUTOMATION/CoupledResonator_ID_Cuts_optim.aedt")\n'); % open a project (CHANGE THE PATH)
    fprintf(script, 'oProject = oDesktop.SetActiveProject("CoupledResonator_ID_Cuts_optim")\n'); % set an active project
    fprintf(script, 'oDesign = oProject.SetActiveDesign("1D_Array")\n'); % set an active design


    for k = 1:length(R0m) % start changing the variables
        fprintf(script, 'oDesign.ChangeProperty(["NAME:AllTabs", ["NAME:LocalVariableTab",["NAME:PropServers", "LocalVariables"],\n');

        fprintf(script, strcat('["NAME:ChangedProps",["NAME:R', num2str(k-1), '","Value:=" , "', num2str(R0m(k)), 'ohm"]]]])\n'));

    end

    for k = 1:length(Cap0m)
        fprintf(script, 'oDesign.ChangeProperty(["NAME:AllTabs", ["NAME:LocalVariableTab",["NAME:PropServers", "LocalVariables"],\n');

        fprintf(script, strcat('["NAME:ChangedProps",["NAME:cap', num2str(k-1), '","Value:=" , "', num2str(Cap0m(k)), 'pF"]]]])\n'));

    end

    fprintf(script, 'oDesign.Analyze("Setup1")\n'); % Run a pre-defind setup

    fprintf(script, 'oModule = oDesign.GetModule("ReportSetup")\n'); % export data from a pre-defined report
    fprintf(script, 'oModule.ExportToFile("rE Plot 1", "H:/Automation/Farfield_Scattering.csv", False)\n'); % save the data on a disk
    fprintf(script, 'oProject.Save()\n'); % save the project
    fprintf(script, 'oDesktop.CloseProject("CoupledResonator_ID_Cuts_optim")\n'); % close the project

    fclose(script);

    system('"/CMC/tools/ansys/ansys.2024r1/v241/Linux64/ansysedt" -RunScript "Coupled_Resonator_Circuit_Sweep.py"'); % open HFSS, run script and exit on Linux machine
%     system('"C:\Program Files\AnsysEM\v241\Win64\ansysedt.exe" -RunScriptAndExit "Coupled_Resonator_Circuit_Sweep.py"'); % open HFSS, run script and exit on Windows machine


    %% read the data

    data = csvread('Farfield_Scattering.csv', 1, 0);
    theta = data(:,3);
    Pat = data(:,4);

    figure(1);
    hold on;
    plot(theta, Pat)

    disp('end')

end