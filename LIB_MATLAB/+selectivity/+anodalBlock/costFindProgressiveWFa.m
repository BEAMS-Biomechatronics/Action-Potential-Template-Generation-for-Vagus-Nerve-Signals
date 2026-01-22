function cost = costFindProgressiveWFa(cible, IArray, times, amp)
    
    load parameters
    
    
    displayMsg = 'Values [mA] of ';
    for i=1:length(IArray)
        displayMsg = [displayMsg sprintf('I%d :%0.3f, ',i, IArray(i)*1e3)];
    end
    display(displayMsg);
    
    
    ampUpdated                                          = amp;
    ampUpdated(1,6:6+length(IArray))                    = [IArray(1:end-1)./IArray(end) 1 1];
    
    
    %change parameters
    WF1                         = selectivity.stimWaveForm.stimWaveFormLinesByPieces(2.1e-3, 50e-6, [times; ampUpdated], 'notNormed');
    current1                    = IArray(end);    
    
        
        
    save('parametersChange.mat', 'WF1', 'current1', '-append');
    
    % run simulation with current parameters
    folderName = selectivity.anodalBlock.detectActivationWithShift('1D', 1);
    
    % plot result and save data
    selectivity.anodalBlock.mapActivationWithShiftTwoColors1D(folderName);
    
    % retrieve data( AP or Not AP)
    contentResultDirectory      = dir(folderName);
    all_files                   = contentResultDirectory(~[contentResultDirectory(:).isdir]);
    
    % cost computation
    cost = 0;
    lastKFileName = 0;
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
            
            % cost function
            costUnMatchHorsCible    = sum((ones(size(cible))-cible).*partOfAP);
            costUnMatchCible        = sum(cible.*(ones(size(partOfAP))-partOfAP));
            costTransition          = (length(partOfAP)~=sum(partOfAP) && sum(partOfAP)~=0)*(-length(partOfAP));
            % basic cost
            cost = cost + currentPonderation*(costUnMatchHorsCible + costUnMatchCible) + costTransition;
            
            
            
%             %most complex cost 
%             if currentPonderation < 0
%                 cost = cost - currentPonderation * costUnMatchCible;
%             elseif currentPonderation > 0
%                 cost = cost + currentPonderation * costUnMatchHorsCible;
%             end
        end
    end 
    save(['./' folderName '/' all_files(lastKFileName).name], 'cost', '-append');
    display(['The value of cost Function is : ' num2str(cost)]);
   
end