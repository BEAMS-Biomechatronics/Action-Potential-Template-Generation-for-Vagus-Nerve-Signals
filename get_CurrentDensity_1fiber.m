function get_CurrentDensity_1fiber(fiberDiam,Temperature)
    display('Adding path and libraries...')
    addpath('LIB_MATLAB');
    addpath('COMSOL_VE');
    addpath('COMSOL_VE\MATLAB1');
    import selectivity.stimWaveForm.*;
    import selectivity.comsol.*;
    import selectivity.fibreModel.fibre.*;
    import com.comsol.model.util.*;
    import selectivity.utilities.*;
    import selectivity.anodalBlock.*;
    import selectivity.Axel.*;
    import selectivity.CAPfunctions.*;
    display('Loading parameters...')
    if round(Temperature) == Temperature
        load(['parameters_AP_' num2str(fiberDiam*1e6) 'um_' num2str(Temperature) 'degC_mod3']);
        load(['fiber_AP_build_' num2str(fiberDiam*1e6) 'um_' num2str(Temperature) 'degC_mod3']);
    else
        strTemp = num2str(Temperature);
        strTemp = strsplit(strTemp,'.');
        load(['parameters_AP_' num2str(fiberDiam*1e6) 'um_' strTemp{1} 'degC' strTemp{2} '_mod3']);
        load(['fiber_AP_build_' num2str(fiberDiam*1e6) 'um_' strTemp{1} 'degC' strTemp{2} '_mod3']);
    end
    
    display('Setting parameters...')
    nerveD = 0.4e-3; % to fit to the right COMSOL model
    internodeLength = 100*fiberDiam; % internodal distance depending of the nerve diameter
    nDiameters=1;
    time = cell(nDiameters,nFibers);
    current_density = cell(nDiameters,nFibers);
    
    iFib = 1;
    iDiam = 1;
    
    display('Getting fiber instance...')
    currentFiber = fiberSave{iDiam, iFib}; % current is not the current in the fiber. It means we are working on the actual/current fiber
    time{iDiam, iFib} = currentFiber.time;
    display('Getting fiber spatial current (integral solution)...')
    action_current = (currentFiber.conductance_current); % The conductace current is obtained from the fiber, but its integral
    nerve_second_part = 2; % to keep the positive part of the nerve (in the z axis) and avoid the center of the nerve
    action_current(:,1:round(nNodes/nerve_second_part)) = zeros(size(action_current,1), round(nNodes/nerve_second_part));
    action_current(:,end-4:end) = zeros(size(action_current,1), 5);
    display('Getting fiber spatial current (integral solution) density...')
    current_density_temp{iDiam, iFib} = action_current / (internodeLength*pi*(nerveD/2)^2)*1e-9; % Integral conductance current divided by the volume of a node of Ranvier
    display('Getting fiber spatial current density...')
    current_density{iDiam, iFib} = diff(current_density_temp{iDiam, iFib}); % Get diff to remove the integral and obtain the actual conductance current
    display('Saving current density...')
    if round(Temperature) == Temperature
        save(['COMSOL models\current_density_' num2str(fiberDiam*1e6) 'um_' num2str(Temperature) 'degC_mod3.mat'], 'current_density','time')
    else
        strTemp = num2str(Temperature);
        strTemp = strsplit(strTemp,'.');
        save(['COMSOL models\current_density_' num2str(fiberDiam*1e6) 'um_' strTemp{1} 'degC' strTemp{2} '_mod3.mat'], 'current_density','time')
    end
end