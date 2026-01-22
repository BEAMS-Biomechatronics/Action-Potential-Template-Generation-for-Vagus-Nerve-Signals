function cost = costFindProgressiveWFexp2(cible, IArray)
    
    load parameters
    
    % for fitting only
    timeStep        = 1e-6;
    startPulse      = 0.25e-3;
    timeEndOfData   = 1.2e-3;
    
    a       = IArray(1);
    b       = IArray(2);
    c       = IArray(3);
    d       = IArray(4);
    %IMax    = IArray(5);
    
    display('Looking for WF1 of the form : Y = a*exp(b*x)+c*exp(d*x) [0.25;....]ms');
    display(sprintf('Values  of a :%0.3f , b:%0.3f , c:%0.3f , d:%0.3f ,Imax[mA]:%0.3f', a, b, c, d, current1*1e3));
    
    
    fitWFUpdated    = fit([1 1 1 1]',[1 1 1 1]','exp2');
    
    fitWFUpdated.a  = a;
    fitWFUpdated.b  = b;
    fitWFUpdated.c  = c;
    fitWFUpdated.d  = d;
    
        
    timesPlot       = [0:1e-5:5e-3];
    times0          = [0:timeStep:startPulse-timeStep];


    %change parameters
    WF1                         = selectivity.stimWaveForm.stimWaveFormLinesByPieces(2e-3, 1e-4, [times0 timesPlot+startPulse*ones(size(timesPlot)); zeros(size(times0)) fitWFUpdated(timesPlot')'], 'notNormed');
    %current1                    = IMax;
    WF1.plotWaveForm([0:1e-5:2e-3], current1);
    WF2                         = selectivity.stimWaveForm.stimWaveFormLinesByPieces(200e-6,    5e-6,   [[0 5e-3]; [1 1]]);
    
    nNodeShift                  = 1;
    
        
    save('parametersChange.mat', 'WF1', 'current1', 'WF2', 'nNodeShift', '-append');
    
    % run simulation with current parameters
    folderName = selectivity.anodalBlock.detectTransition();
    
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