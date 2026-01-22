function build_ActionPotential_1fiber(fiberDiam,Temperature,plot_results)
display('Adding path and libraries...')
addpath('LIB_MATLAB');
import selectivity.stimWaveForm.*;
import selectivity.comsol.*;
import selectivity.fibreModel.fibre.*;
import com.comsol.model.util.*;
import selectivity.utilities.*;
import selectivity.anodalBlock.*;
import selectivity.Axel.*;
import selectivity.CAPfunctions.*;
noCompute = false;
%This function computes AP for the model and parameters input, displays them
%on the screen and saves them in a figure folder
%You must run this function at least once to initialize the values for the
%CAP. When this is done, you don't have to run it anyumore, except if you
%want to change parameters or to compute AP again
%This script simulates only one fiber 

display('Defining simulation time...')
% Stimulation
%calculation of simulation time 
simulation_duration = round(0.3/((33*fiberDiam)/8e-6),4) + 5e-3; %propagation speed for a fiber of 8e-6m is 33m/s
display('Defining stimulation parameters...')
%current value 
current1 = 1e-3;
current2 = 0;
%stimulation duration value
stimulation_duration = 0.5e-4;
%define stimulation signal
stim=[[0:.5e-4:simulation_duration]; ones(size([0:.5e-4:simulation_duration]))];

display('Creating waveform stimulation...')
%
WF1 = stimWaveFormLinesByPieces(stimulation_duration,    5e-5,   stim);
WF2 = stimWaveFormLinesByPieces(30e-6,     1e-6,  stim); %WF2 is not used

%
display('Loading parameters...')
parametersParaboleAnode();
%load parameters;
fibreD = fiberDiam;
%loading voltages in the nodes
load('Vnodes.mat');
display('Creating a fiber instance...')
% RETURN THE AP PROPAGATION THROUGH FIBERS
nFibers = size(Vnodes,1); 
nNodes = size(Vnodes,2); %nodes per fiber
iFib = 1; %fiber at the center
Vm = cell(1,nFibers);

fiberSave = cell(1, nFibers); %Only 1 fiber

fiberInstance =  fibre(fibreD, nNodes, Temperature, WF1,WF2, simulation_duration); %create a fiber
display('Setting parameters to the fiber...')
VActualFiber = Vnodes(iFib, :);  %we want all the nodes voltage of the centered fiber
fiberInstance = fiberInstance.setVe(VActualFiber); %we give to the fiber created the voltages we've retrieved from the comsol model
fiberInstance = fiberInstance.setCurrent([current1 current2]); % setCurrent function is in file "fibre.m"

display('Solving fiber...')
fiberInstance = fiberInstance.solve(); %and the differential equation is being solved with these voltages. solve function is in file "fibre.m"
fiberInstance.solution(:,1:end/8) = fliplr(fiberInstance.solution(:,(end/8)+1:end/4)); %voltage first half of nodes equals voltage second half of nodes (mirror effect)

Vm{iFib}=fiberInstance.solution(:,1:nNodes); %saves all the voltages for all nodes of the center fiber
time = fiberInstance.time; %save times that will be used later on
fiberInstance = fiberInstance.setStim(stim); %used to input the stimulation we have input at the beginning to the fiber

if plot_results==1
    display('Ploting resutls...')
    fig = fiberInstance.plotBaton(10);
    figureFileName = sprintf('fibreNum_%f',iFib);
    figureFileName = strrep(figureFileName, '.', '_');
    
    AP = [];
    for iNode = 1:nNodes
        AP(:, iNode) = Vm{iFib}(:,iNode);
    end
    
    figure;
    apfig=plot(time(:,1),Vm{iFib}(:,:));
end
fiberSave{iFib} = fiberInstance;
shift = 0;
display('Saving results...')

if round(Temperature) == Temperature
    save(['parameters_AP_' num2str(fibreD*1e6) 'um_' num2str(Temperature) 'degC_mod3'], 'Vm', 'nNodes', 'nFibers', 'Vnodes','noCompute');
    save(['fiber_AP_build_' num2str(fibreD*1e6) 'um_' num2str(Temperature) 'degC_mod3'], 'fiberSave');
else
    strTemp = num2str(Temperature);
    strTemp = strsplit(strTemp,'.');
    save(['parameters_AP_' num2str(fibreD*1e6) 'um_' strTemp{1} 'degC' strTemp{2} '_mod3'], 'Vm', 'nNodes', 'nFibers', 'Vnodes','noCompute');
    save(['fiber_AP_build_' num2str(fibreD*1e6) 'um_' strTemp{1} 'degC' strTemp{2} '_mod3'], 'fiberSave');
end
end
