function cost = costFindProgressiveWFPoly3(cible, IArray)
    
    load parameters
    
    % for fitting only
    timeStep        = 1e-6;
    startPulse      = 0.25e-3;
    timeEndOfData   = 1.2e-3;
    
    x          = [0.25e-3 0.7e-3 1.1e-3 1.8e-3];
    current1   = IArray(4);
    y          = [0 IArray(1) IArray(2) IArray(3)]./current1;
    
    
    
        
    display('Looking for WF1 of the form : Y = a*x^3+b*x^2+c*x+d [0.25;....]ms');
    display(sprintf('Values  of A1 :%0.7f , A2:%0.7f , A3:%0.7f, A4:%0.7f', IArray(1), IArray(2), IArray(3), IArray(4)));
    
    
    
    % generating WF with poly 3
    %change parameters
    WF1                         = selectivity.utilities.poly3FitToWF(x, y);
    current1                    = IArray(4);
       
        
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
            currentPonderation      = 1+abs(currentPonderation);%elemMilieu-abs(currentPonderation);
            
            % checking for transition position for the current diameter and
            % saving it at the right location (indiceDiameter).
            transitionPosition(indiceDiameter)    = sum(partOfAP);
            
            
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
    
    % global order condition
%     isInOrder = true;
%     for k=1:numel(transitionPosition)-1
%         if isInOrder
%             if transitionPosition(k)<transitionPosition(k+1)
%                 isInOrder = false;
%             end
%         end
%     end
%     
%     % When not in order, the cost function get a big penalty
%     if ~isInOrder
%         cost = cost + 400;
%     end
    
 % one by one order condition
    
    costOrder = 0;
    for k=1:numel(transitionPosition)-1
        if transitionPosition(k)<transitionPosition(k+1)
            costOrder = costOrder + round(numel(cible)/2);
        end
    end
    
    cost = cost + costOrder;
    


    save(['./' folderName '/' all_files(lastKFileName).name], 'cost', '-append');
        display(['The value of cost Function is : ' num2str(cost)]);
   
end