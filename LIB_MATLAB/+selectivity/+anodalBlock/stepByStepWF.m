function [WFOptim] = stepByStepWF(positionFibre)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here


 % import functions from library
    import selectivity.fibreModel.fibre.*
    import selectivity.comsol.*
    import selectivity.stimWaveForm.*
    import selectivity.utilities.*
    import selectivity.anodalBlock.*

    parametersParaboleAnode();
    load parameters;
    
    
    
    % parameters of the function 
    sizeDiameter        = 10e-6:-1e-6:4e-6;
    
    
    

    % COMSOL MODEL and coordinates
    %modelC       = comsolModel();
    filenameVe  = 'model.mph';
    %modelC.save([pwd '\' filenameVe]);

    %load
    modelC   = mphload([pwd '\' filenameVe]);
    
    display('Model Comsol loaded in server.');
    
    
    
    %% first find current for pulse 2 (déclenchement)
    
    display('Computing amplitude of traingular pulse to trigger AP in all fibers.');
    
    fibreD       = sizeDiameter(end);
    positionFiber0D = [0 0];
    
    save('parametersChange.mat', 'fibreD', 'positionFiber0D',  '-append');
    parametersParaboleAnode();
    XYZ          = getFiberCoordinates('0D');
    Ve           = getExternalVoltage(modelC, XYZ);

    
    % pulse triangulaire de déclenchement
    WF1                     = stimWaveFormLinesByPieces(150e-6,    5e-6,   [[0 1e-3 5e-3]; [1 1 1]]);
    current2                = 0;
    save('parametersChange.mat', 'WF1', 'current2', '-append');
    parametersParaboleAnode();
    
    % find current to trigger all fibers and put it as new WF2
    current2                = 1.39e-3;%findCurrent(fibreD, positionFiber0D, modelC,'12',0, 'alreadySolved');
    WF2                     = stimWaveFormLinesByPieces(150e-6,    5e-6,   [[0 1e-3 5e-3]; [1 1 1]]);
    save('parametersChange.mat', 'current2', 'WF2' ,'-append');
    parametersParaboleAnode();
    
    
    
    
    
    
    %% BLOCAGE
    % parameters of the function 
    
    
    fibreSlopeReached   = zeros(size(sizeDiameter));
    
    positionFiber0D     = positionFibre;
    stepT               = 25e-6;
    initialT            = 250e-6;
    times               = [initialT:stepT:1.5e-3];
    TPulseGlobal        = 1.5e-3;
    TTransition         = 100e-6;
    currentAnodalBlock  = 10e-3;
    epsilon             = 20e-6;
    
    %variables to work with
    slopes              = [];
    currentSizeInd      = 1;
    
    for k=1:numel(times)
        display(sprintf('iteration : %d',k));
        % find the fiber to be blocked first (blockedSize)
        fiberNotBlocked     = find(fibreSlopeReached==0);
        % si on est arrivé à la dernière taille. 
        if numel(fiberNotBlocked) == 0
            currentSizeInd      = numel(fibreSlopeReached); % on prend le dernier élément comme taille de référence. 
        else
            currentSizeInd      = fiberNotBlocked(1);
        end
        fibreD                  = sizeDiameter(currentSizeInd);
        positionFiber0D         = positionFibre;
        save('parametersChange.mat', 'fibreD', 'positionFiber0D','-append');
        parametersParaboleAnode();
        XYZ                     = getFiberCoordinates('0D');
        Ve                      = getExternalVoltage(modelC, XYZ);
        
        %trouver la pente pour la fibre de taile ... (indice k)
        % si fibre de taille supérieure, déterminez si cette nouvelle forme
        % d'onde bloque cette taille pour le points xEps, et laisse le passage en
        % x-Eps.
       
        slopes   = [slopes selectivity.fibreModel.fibre.findSlopeNextStair(stepT, slopes, initialT, TPulseGlobal, TTransition, currentAnodalBlock, Ve, fibreD)];
        
        display(sprintf('First slope found for fiber of %0.1f µm, value of slope :%0.1f ', fibreD*1e6 , slopes(end)));

        if k ~= 1
            % check if size of higher diameter are influenced by new slope
            % in the points x-e, x+e
            display('Check if new slope respect constraints for higher diameter size.');
            % coordinates x-eps (should be blocked)
            fibreD          = sizeDiameter(currentSizeInd-1);
            positionFiber0D = positionFibre - currentSizeInd*[epsilon 0];
    
            save('parametersChange.mat', 'fibreD', 'positionFiber0D', '-append');
            parametersParaboleAnode();
            XYZmE           = getFiberCoordinates('0D');
            VemE            = getExternalVoltage(modelC, XYZmE);
            

            
            load parameters;            
            WF1         = WFSlopeGenerator(slopes, stepT, initialT, TPulseGlobal, TTransition);
            

            
            % simulation en x-e
            simXmE = simOneFiber(fibreD, [WF1 WF2], [currentAnodalBlock current2], XYZmE, 0);
            simXmE.solve(VemE);
            typeXmE = simXmE.type;
            simXmE.plotBaton(20);
            
            display(sprintf('Type in -eps [%0.2f; %0.2f] µm : %d for fiber of %0.1f µm', positionFiber0D(1)*1e6, positionFiber0D(2)*1e6, typeXmE, fibreD*1e6));
            
            if typeXmE == 2
                display('epsilon test passed');
                fibreSlopeReached(currentSizeInd) = 1;
            else
                slopes(k) = slopes(k-1);
            end
        else
            fibreSlopeReached(currentSizeInd) = 1;
        end
    end
    WFOptim = [selectivity.stimWaveForm.WFSlopeGenerator(slopes, stepT, initialT, TPulseGlobal, TTransition) WF2];
end

