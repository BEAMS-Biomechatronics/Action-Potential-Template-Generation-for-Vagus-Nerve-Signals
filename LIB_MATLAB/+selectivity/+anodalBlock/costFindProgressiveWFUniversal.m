function cost = costFindProgressiveWFUniversal(cible, IArray, times, amp, indiceParameters, ciblePosition)
    
    load parameters
    
    % special distribution for the positions
    activateCostTransition = true;
    activateCostPeer2PeerOrder = true;
    activateCostGlobalOrder = true;
    
    displayMsg = 'Values [mA] of ';
    for i=1:length(IArray)
        displayMsg = [displayMsg sprintf('I%d :%0.3f, ',i, IArray(i)*1e3)];
    end
    display(displayMsg);
    
    
    ampUpdated                                                      = amp;
    ampUpdated(1,[indiceParameters indiceParameters(end)+1])        = [IArray(1:end)./IArray(end) 1];
    
    
    %change parameters
    WF1                         = selectivity.stimWaveForm.stimWaveFormLinesByPieces(WF1RampTime, WF1RampDelayOfSlope, [times; ampUpdated], 'notNormed');
    current1                    = IArray(end);
    
        
        
    save('parametersChange.mat', 'WF1', 'current1', '-append');
    
    % run simulation with current parameters
    if isempty(ciblePosition)
        % regular distribution for the positions values
        folderName = selectivity.anodalBlock.detectActivationWithShift('1D', 1);
    else
        % special distribution for the positions values
        folderName = selectivity.anodalBlock.detectActivationWithShift('1D', 1, ciblePosition);
    end
    
    % plot result and save data
    selectivity.anodalBlock.mapActivationWithShiftTwoColors1D(folderName);
    
    % retrieve data( AP or Not AP)
    contentResultDirectory      = dir(folderName);
    all_files                   = contentResultDirectory(~[contentResultDirectory(:).isdir]);
    
    % cost computation
    cost = 0;
    lastKFileName = 0;
    transitionPosition = [];
    for k=1:numel(all_files)
        if strfind(all_files(k).name, 'proportion')
            %save last k
            lastKFileName = k;
            load(['./' folderName '/' all_files(k).name], 'partOfAP', 'diameterArray', 'currentDiameter');
            
            %retrieve diameter array needed for ponderation
            diameterArraySorted     = sort(diameterArray); 
            % cas pair
            % ponderationFactor = [3 2 1 0 -1 -2 -3] (example)
            ponderationFactor       = [];
            elemMilieu              = 0;
            if mod(numel(diameterArray),2) == 0
                elemMilieu              = floor(numel(diameterArray)/2);
                ponderationFactor       = [elemMilieu-1:-1:1 zeros(1,elemMilieu+1)] + [zeros(1,elemMilieu+1) -1:-1:-(elemMilieu-1)];

            else
                elemMilieu              = ceil(numel(diameterArray)/2);
                ponderationFactor       = [elemMilieu-1:-1:-elemMilieu+1];

            end
            
            %looking for ponderation cost in diameterArray
            indiceDiameter          = find(diameterArraySorted==currentDiameter);
            currentPonderation      = ponderationFactor(indiceDiameter);   
            currentPonderation      = elemMilieu-abs(currentPonderation);
            
            % checking for transition position for the current diameter and
            % saving it at the right location (indiceDiameter).
            transitionPosition(indiceDiameter)    = sum(partOfAP);
            
            
            % cost function
            costUnMatchHorsCible    = sum((ones(size(cible))-cible).*partOfAP);
            costUnMatchCible        = sum(cible.*(ones(size(partOfAP))-partOfAP));
            costTransition          = (length(partOfAP)~=sum(partOfAP) && sum(partOfAP)~=0)*(-length(partOfAP));
            % basic cost
            if activateCostTransition           
                cost = cost + currentPonderation*(costUnMatchHorsCible + costUnMatchCible) + costTransition;
            else
                cost = cost + currentPonderation*(costUnMatchHorsCible + costUnMatchCible);
            end
            
            
            
%             %most complex cost 
%             if currentPonderation < 0
%                 cost = cost - currentPonderation * costUnMatchCible;
%             elseif currentPonderation > 0
%                 cost = cost + currentPonderation * costUnMatchHorsCible;
%             end
        end
    end 
    
    % natural order condition
    if activateCostPeer2PeerOrder
        isInOrder = true;
        for k=1:numel(transitionPosition)-1
            if isInOrder
                if transitionPosition(k)<transitionPosition(k+1)
                    isInOrder = false;
                end
            end
        end
    end
    
    % When not in order, the cost function get a big penalty
    if ~isInOrder
        cost = cost + 400;
    end
    
    save(['./' folderName '/' all_files(lastKFileName).name], 'cost', '-append');
        display(['The value of cost Function is : ' num2str(cost)]);
   
end