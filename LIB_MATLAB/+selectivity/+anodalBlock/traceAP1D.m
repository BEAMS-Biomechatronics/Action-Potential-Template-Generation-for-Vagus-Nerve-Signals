function traceAP1D(resultDirectory)
% mapActivationWithShiftTwoColors(resultDirectory)
    % This function can be called after you have solved the problem with
    % the detectActivationWithShift('1D') function. 
    % You should run it at the root directory of the result.
    % The input parameter contains the string which correspond to the
    % result folder name which you want to plot.
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Structure of the result folder is the following :
    %
    % -*geometry_parameters_result_folder
    %   ->parameters.mat    € (geometricalParameters)
    %   -*fibreD[fibreD]
    %       -*figure
    %           -*shift_[shiftX1]
    %               ->figure_fibreD_[fibreD]_fibreNum_[numFibre].fig
    %               -> ...
    %           -* ...
    %       ->shift_[shift]_mat.mat     € (Vm, t ,type)
    %       -> ...
    %  
    % % (the variables included in the name of files (->) and folders (-*) 
    % are written between brackets []) 
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    import selectivity.utilities.*
    
    warning('off','signal:findpeaks:largeMinPeakHeight');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%          PARAMETERS                                    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Loading important facts
    % - nNodeShift
    % - nFibreLayerPerFasicle
    % - nFibreFirstLayer    
    
    newresultDirectory = resultDirectory;
    load([resultDirectory '/parameters.mat']);
    resultDirectory = newresultDirectory;
   
   
    % number of fibre diameter studied
    contentResultDirectory      = dir(resultDirectory);
    all_dir = contentResultDirectory([contentResultDirectory(:).isdir]);
    nDiameter = numel(all_dir)-2;
    
    
    diameterArray               = zeros(1,nDiameter);
    rangeOfDiameterValidity     = zeros(2,nDiameter);
   
    % retrieve diameters data
    timeSave                    = [];
    minTime = 1e20;
    for k = 3:nDiameter+2
        folderName              = contentResultDirectory(k).name;
        diameterArray(k-2)      = str2double(folderName(7:end));
        % proportion of AP for a fixed diameter
        load(['./' resultDirectory '/' contentResultDirectory(k).name '/shift_0_mat.mat'], 'time');
        currentMaxTime          = numel(time{1});
        if currentMaxTime < minTime
            minTime             = currentMaxTime;
            timeSave            = time{1};
        end
    end
    
    % get Proportion of fibers for each fiber diameter
    hFD                         = histoFibreDiameter();
    nRange                      = hFD.getProportion(diameterArray);
    
    
    % load first result to extract coordinates (coordinates are common to
    % all the results :
    % - CoordonneesFibresXYZ
    % - time
    type = [];    
    load(['./' resultDirectory '/' contentResultDirectory(3).name '/shift_0_mat.mat']);
    
    %size of CoordonneesFibresXYZ
    sizeXYZ             = size(CoordonneesFibresXYZ);
    nFibre              = sizeXYZ(2);
    nNoeuds             = sizeXYZ(3);
    nFascicle           = fasciclesGeometry.numberOfFascicles;
    nTime               = minTime;   
    
    
    partOfAPTotal       = [];
    colorsChange        = {'-r', '.g', '-.b'};
    
    
    lInterNodal         = cell(nDiameter);
    XYZCell             = cell(nDiameter, nNodeShift);
    indiceVmPeaks       = cell(nDiameter, nNodeShift, nFibre, nTime);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%          LOOPS                                               %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % loop for the different size of fiber
    for k = 1:nDiameter
        
        % Need the coordinates in XY of fibers and the central fibers
        % coordinates
        X       = reshape([squeeze(CoordonneesFibresXYZ(1,:,1))]', nFibre, 1);
        Y       = reshape([squeeze(CoordonneesFibresXYZ(2,:,1))]', nFibre, 1);
        Z       = squeeze(CoordonneesFibresXYZ(3,:,1)); % z coordinates for first node
        rXY     = sqrt(X.^2+Y.^2);
        %XY0     = [X(1:nFibrePerFasicle:end); Y(1:nFibrePerFasicle:end)];

        
        % proportion of AP for a fixed diameter
        load(['./' resultDirectory '/' contentResultDirectory(k+2).name '/shift_0_mat.mat'], 'type', 'Vm');
 
        
        lInterNodal{k}              = fibreSave{1}.L;
        
        for l=1:nNodeShift
            % shift value (as used in detectActivationWithShift)
            shift                           = (l-1)/nNodeShift;
            % data file name (as used in detectActivationWithShift)
            currentFileName                 = ['shift_' num2str(shift) '.mat'];
            currentFileName                 = strrep(currentFileName, '.', '_');
            % Load currrent data to retrieve 'type results'
            load(['./' resultDirectory '/' contentResultDirectory(2+k).name '/' currentFileName], 'Vm', 'CoordonneesFibresXYZ', 'fibreSave');
            
            
            XYZCell{k,l}                    = CoordonneesFibresXYZ; 
            for m = 1:numel(Vm)
                
                display(sprintf('k : %d,l : %d, m:%d',k,l,m));
                for tI=1:nTime
                    
                    if ~isempty(Vm{m})
                        [~, location]               = findpeaks(Vm{m}(tI,:),'MinPeakHeight', 0.045);
                        indiceVmPeaks{k,l,m,tI}     = location;
                    else
                        indiceVmPeaks{k,l,m,tI}     = [];
                    end
                end
            end
        end
    end
    
    save('trace.mat', 'XYZCell',  'indiceVmPeaks', 'nDiameter', 'nTime','nNodeShift', 'nFibre');
    load trace;
    
    filename=sprintf('movieVmFiberNbr_%d.mp4',1);
    v = VideoWriter(filename, 'MPEG-4');
    open(v);
    epsZ = abs(XYZCell{1,1}(1,1,1)-XYZCell{1,1}(1,2,1))/nFibre/2;
    
    fig = figure('Position', [500 0 1280 800]);
    
    colorPlot           = {'sb', 'xr', 'dg', 'pk', '>c', '+y', '*b', '^r', 'vg', '>k', '<c', 'oy', 'sb', 'xr', 'dg', 'pk', '>c', '+y', '*b', '^r', 'vg', '>k', '<c', 'oy'}; 

    for k=1:nTime
       clf;
       hold on;
       subplot(3,1,[1 ,2])
       for l=1:nDiameter
           for m=1:nNodeShift
               for n=1:nFibre
                   %display(sprintf('time : %d,diam : %d, shift:%d, nFibre:%d',k,l,m,n));
                   if ~isempty(indiceVmPeaks{l,m,n,k})
                        plot(squeeze(XYZCell{l,m}(3,n,[indiceVmPeaks{l,m,n,k}])),l*epsZ*ones(size(squeeze(XYZCell{l,m}(1,n,[indiceVmPeaks{l,m,n,k}]))))+squeeze(XYZCell{l,m}(1,n,[indiceVmPeaks{l,m,n,k}])), colorPlot{mod(l,12)+1});%
                        hold on;
                   end
               end
           end
       end
       yIntervalle = [line1D(1,1) line1D(2,1)];
       axis([-nerveL/2 nerveL/2 min(yIntervalle) max(yIntervalle)]);
       
       %plot WF
       subplot(3,1,3), plot(timeSave*1e3, WF1.WF(timeSave)*current1*1e3);
       xlabel('temps [ms]');
       ylabel('courrant [mA]');
       maxWF1           = max(WF1.WF(timeSave));
       minWF1           = min(WF1.WF(timeSave));
       hold on, plot([timeSave(k) timeSave(k)]*1e3,  [minWF1 maxWF1]*1e3*current1);
       title(sprintf('Time : %d µs',round(timeSave(k)*1e6)));
       
       F = getframe(gcf);%rect
       writeVideo(v,F)
       hold off
    end
    close(v);
end

