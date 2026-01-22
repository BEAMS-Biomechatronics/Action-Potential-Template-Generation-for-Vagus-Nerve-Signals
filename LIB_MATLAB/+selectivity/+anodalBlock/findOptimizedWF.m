function [WFOptim] = findOptimizedWF(positionFibre)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here


 % import functions from library
    import selectivity.fibreModel.fibre.*
    import selectivity.comsol.*
    import selectivity.stimWaveForm.*
    import selectivity.utilities.*

    parametersParaboleAnode();
    load parameters;

    % COMSOL MODEL and coordinates
    %modelC       = comsolModel();
    filenameVe  = 'model.mph';
    %modelC.save([pwd '\' filenameVe]);

    %load
    modelC   = mphload([pwd '\' filenameVe]);
    
    
    
    
    %% first find current for pulse 2 (déclenchement)
    
    fibreD       = 5e-6;
    positionFiber0D = [0 0];
    
    save('parametersChange.mat', 'fibreD', 'positionFiber0D');
    parametersParaboleAnode();
    XYZ          = getFiberCoordinates('0D');
    Ve           = getExternalVoltage(modelC, XYZ);

    
    % pulse triangulaire de déclenchement
    WF1                     = stimWaveFormLinesByPieces(300e-6,    50e-6,   [[0 1e-3 5e-3]; [0.2 1 1]]);
    current2                = 0;
    save('parametersChange.mat', 'WF1', 'current2', '-append');
    parametersParaboleAnode();
    
    % find current to trigger all fibers and put it as new WF2
    current2                = findCurrent(fibreD, positionFiber0D, modelC,'12',0, 'alreadySolved');
    WF2                     = stimWaveFormLinesByPieces(300e-6,    50e-6,   [[0 1e-3 5e-3]; [0 1 1]]);
    save('parametersChange.mat', 'current2', 'WF2' ,'-append');
    parametersParaboleAnode();
    
    
    
    
    
    
    %% BLOCAGE
    % parameters of the function 
    sizeDiameter        = 10e-6:-2.5e-6:5e-6;
    positionFiber0D     = positionFibre;
    
    
    %variables to work with
    currentAmp          = [];
    timeStair           = [];
    
    for k=1:numel(sizeDiameter)

        fibreD       = sizeDiameter(k);
        save('parametersChange.mat', 'fibreD', 'positionFiber0D','-append');
        parametersParaboleAnode();
        XYZ          = getFiberCoordinates('0D');
        Ve           = getExternalVoltage(modelC, XYZ);
        
        %trouver le courant pour la fibre de taile ... (indice k)
        %   ___________________________________________________
        %  | ______________________5___________________________|
        %  |______________________7.5__________________________|
        %  |______________________10___________________________|
        
        %pulse de blocage (WF1 is the pusle to be optimized)
        % This is why we invert both pusle (WF1 blocage, WF2 pusle to
        % trigger AP)
        WF1                  = stimWaveFormLinesByPieces(2e-3,    5e-5,    [[0 100e-6 125e-6 5e-3];         [0 0 1 1]]);        %square pulse
        current1             = 0;
                       
        % update parameters
        save('parametersChange.mat', 'WF1', 'current1' ,'-append');
        parametersParaboleAnode();
        
        % find current (block) for current fibre size
        
        currentProp         = 1;
        if k ~= numel(sizeDiameter)
            currentAmp(k)       = currentProp*selectivity.fibreModel.fibre.findCurrent(sizeDiameter(k), positionFiber0D, modelC,'23',0, 'alreadySolved');
        else
            currentAmp(k)       = 1.0*selectivity.fibreModel.fibre.findCurrent(sizeDiameter(k), positionFiber0D, modelC,'23',0, 'alreadySolved');
        end
        
        display(sprintf('Le courant nécessaire pour bloquer la fibre de %0.2f microns est de %0.2f mA.', fibreD*1e6, currentAmp(k)*1e3));
        
        %trouver le temps pour lequel le décalage du dernier échelon n'a
        %plus d'influence sur la fibre de diamètre supérieur (précédent). 
        
        %
        %              ________________________________________
        %    ________T/______________7.5_______________________|
        %   |________________________10________________________|
        
        % look for proportion of each stair
        proportionOfAmplitude   = zeros(1,k);
        for l = 1:k-1
            if l == 1
                proportionOfAmplitude(l) = currentAmp(l)/currentAmp(k);
            else
                proportionOfAmplitude(l) = (currentAmp(l)-currentAmp(l-1))/currentAmp(k);
            end
        end
        proportionOfAmplitude(k)       = 1-sum(proportionOfAmplitude);
        plot(proportionOfAmplitude)

        
        % cherche le temps pour lequel l'ajout de cet échelon
        % supplémentaire ne va pas bloquer le potentiel d'action de la
        % fibre de taille supérieur sizeDiameter(k-1)
        
        
        
        
        if k == 1
            % first stair always begin at 0
            timeStair = [270e-6];            
     
        else      
            fibreD       = sizeDiameter(k-1);
            save('parametersChange.mat', 'fibreD', 'positionFiber0D','-append');
            parametersParaboleAnode();
            XYZ          = getFiberCoordinates('0D');
            Ve           = getExternalVoltage(modelC, XYZ);
            
            % will compute the absolute time at which the new stair will
            % begin
            timeForNextStair = findTimeNextStair(timeStair, proportionOfAmplitude, currentAmp(k), Ve, fibreD, numel(sizeDiameter));
            % adding it to the array which contain all the begining time of
            % each stair.
            timeStair = [timeStair timeForNextStair];
                
        end

        
        
        
        
        
        
        
        
    end
    
            

    


    

end

