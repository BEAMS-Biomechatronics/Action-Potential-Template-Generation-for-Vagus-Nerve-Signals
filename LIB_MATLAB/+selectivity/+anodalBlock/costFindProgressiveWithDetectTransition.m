function cost = costFindProgressiveWithDetectTransition(cible, IArray, times, amp, indiceParameters)
    
    load parameters
    
    
    activateCostTransition      = true;
    activateCostAdjacentOrder   = false;
    activateCostGlobalOrder     = false;
    
    
    % special distribution for the positions
    
    displayMsg = 'Values [mA] of ';
    for i=1:length(IArray)
        displayMsg = [displayMsg sprintf('I%d :%0.3f, ',i, IArray(i)*1e3)];
    end
    display(displayMsg);
    
    
    ampUpdated                                                      = amp;
    ampUpdated(1,indiceParameters)        = [IArray(1:end)./IArray(end)];
    
    
    %change parameters
    WF1                         = selectivity.stimWaveForm.stimWaveFormLinesByPieces(WF1RampTime, WF1RampDelayOfSlope, [times; ampUpdated], 'notNormed');
    current1                    = IArray(end);
    
        
        
    save('parametersChange.mat', 'WF1', 'current1', '-append');
    
    folderName = selectivity.anodalBlock.detectTransition();
    
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
            currentPonderation      = 1+abs(currentPonderation)%elemMilieu-abs(currentPonderation);
            
            % checking for transition position for the current diameter and
            % saving it at the right location (indiceDiameter).
            transitionPosition(indiceDiameter)    = sum(partOfAP);
            
            
            % cost function
            
            currentDiameter
            costUnMatchHorsCible    = sum((ones(size(cible))-cible).*partOfAP)^2
            costUnMatchCible        = sum(cible.*(ones(size(partOfAP))-partOfAP))^2
            costTransition          = (length(partOfAP)~=sum(partOfAP) && sum(partOfAP)~=0)*(-length(partOfAP))*1e7;
                      
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
    
    % global order condition
    if activateCostGlobalOrder
        isInOrder = true;
        for k=1:numel(transitionPosition)-1
            if isInOrder
                if transitionPosition(k)<=transitionPosition(k+1)
                    isInOrder = false;
                end
            end
        end

        % When not in order, the cost function get a big penalty
        if ~isInOrder
            cost = cost + 1e5;
        end
    end
 
    % one by one order condition
    if activateCostAdjacentOrder
        costOrder = 0;
        for k=1:numel(transitionPosition)-1
            for l=k+1:numel(transitionPosition)
                if transitionPosition(k)<=transitionPosition(l)
                    costOrder = costOrder + round(numel(cible)^2);
                end
            end
        end

        cost = cost + costOrder;
    end
    
    
    
   % recording best cost and folder name of the best solution
    files_current_dir               = dir();
    files_current_dir_structure     = struct2cell(files_current_dir);
    fileNameCostDoNotExist          = ~any(ismember(files_current_dir_structure(1,:),'cost.mat'));
    bestCost                        = 1e30;
    
    if fileNameCostDoNotExist
        bestCost                    = cost;
        bestCostFolderName          = folderName;
    else
        load cost
        if bestCost > cost 
            bestCost            = cost;
            bestCostFolderName  = folderName;
        end
    end
    save('cost.mat', 'bestCost', 'bestCostFolderName');
    
    % recording cost in the actual folder
    save(['./' folderName '/' all_files(lastKFileName).name], 'cost', '-append');
    
    % display cost 
    display(['The value of cost Function is : ' num2str(cost)]);
   
end