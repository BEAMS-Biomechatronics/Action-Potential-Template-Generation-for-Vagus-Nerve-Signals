function cost = costFindProgressiveWF(cible, IArray, times, amp)
    
    load parameters
    
    
    
    I1                              = IArray(1);
    I2                              = IArray(2);
    I3                              = IArray(3);
    I4                              = IArray(4);
    IMax                            = IArray(5);
    
    display(sprintf('Values [mA] of I1 :%0.3f , I2:%0.3f , I3:%0.3f , I4:%0.3f ,Imax:%0.3f', I1*1e3, I2*1e3, I3*1e3, I4*1e3, IMax*1e3));
    
    ampUpdated                      = amp;
    ampUpdated(1,3:7)               = [I1/IMax I2/IMax  I3/IMax  I4/IMax 1];
    
    
    %change parameters
    WF1                         = selectivity.stimWaveForm.stimWaveFormLinesByPieces(2.1e-3, 50e-6, [times; ampUpdated], 'notNormed');
    current1                    = IMax;
    WF2                         = selectivity.stimWaveForm.stimWaveFormLinesByPieces(200e-6,    5e-6,   [[0 5e-3]; [1 1]]);
    
    nNodeShift                  = 1;
    
        
    save('parametersChange.mat', 'WF1', 'current1', 'WF2', 'nNodeShift', '-append');
    
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