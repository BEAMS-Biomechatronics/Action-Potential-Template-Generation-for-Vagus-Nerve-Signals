function fig = map2dDiscrete(varargin)
    % map2dDiscrete(normChoice, [cMinMax]) plot the activating function for different locations
    % and different size of fibers. It shows clearly the cathode and anode
    % area but also the virtual ones. 
    % normChoice must be one of this string :
    % - cathode
    % - anode
    % - absolute
    % The data are normalised or by the max of the activating function
    % value or by the min of the activating function. 
    % If you provide as a second (optional) parameter the limits of the
    % range you want to plot, figure will ploted accordingly to this will. 
    import selectivity.comsol.*
    import selectivity.fibreModel.fibre.*
    
    
    cMinMax = [];  
    
    if nargin == 1
        normChoice      = varargin{1};
    elseif nargin == 2
        normChoice      = varargin{1};
        cMinMax     = varargin{2};
    else
        error('number of input parameters is ! of 1 or 2');
    end

    % plot's parameter
    nPosFacscicule      = 11;       %3 * n -1 avec n entier
    nPosLongitudinal    = 401;      %mettre un nombre impair (plus facile).
    nDimFiber           = 15;
    minDimFiber         = 5e-6;
    maxDimFiber         = 10e-6;
    
    
    
    % loading parameters
    load parameters
    
    % pre compute some value
    stepDimFiber        = (maxDimFiber-minDimFiber)/(nDimFiber-1);
    epsilonBorder       = 1e-5;                                                     %distance entre le point en bordure de fascicule et la frontière du fascicule
    stepPos             = (3*fascicleD/2-3*epsilonBorder)/(nPosFacscicule-2);
    


    fibreRange          = [minDimFiber:stepDimFiber:maxDimFiber];
    positionRange1      = [0:stepPos:fascicleD/2-epsilonBorder];
    positionRange2      = [nerveD/4-fascicleD/2+epsilonBorder:stepPos:nerveD/4+fascicleD/2-epsilonBorder];
    positionRange       = [positionRange1 positionRange2];
    
    %Model COMSOL
    % if you want to change some parameters, it is here.
    % but be aware that parameters.mat will change. 
    % Normally this code should be run in a directory with 
    % a parameters.mat file already fixed. 
    % If you want to change the parameters, do it as usual
    % 1) parameterToChange = valueToChange
    % 2) save('parameters.mat', 'parameterToChange', '-append');
    %cuffL               = 5.1e-3;
    %alpha               = -91.8654;                                % alphaSaline = -86.3545 alphaConjonctif = -91.8654
    save('parameters.mat', 'cuffL', '-append');
    
   
    % creating model and running it
    model               = twoRings();
    
    plotArray           = [];
    VezzSave            = zeros(length(fibreRange),nPosLongitudinal*length(positionRange));
    
    fig = figure()
    
    zF1 = [-nerveL/2:nerveL/(nPosLongitudinal-1):nerveL/2];
    for iPos = 1:length(positionRange)
        Vezz = zeros(length(fibreRange),nPosLongitudinal);
        for iDim = 1:length(fibreRange)
            % create a fiber object to retrieve internodale distance
            fibreInstance = fibre(fibreRange(iDim),1,[0],20, 1, 1);
            LFibre = fibreInstance.L;
            
            % coordinates of the fibers
            xF = ones(1,length(zF1))*positionRange(iPos);
            yF = zeros(1,length(zF1));
            zF0 = zF1-ones(1,length(zF1))*LFibre;
            zF2 = zF1+ones(1,length(zF1))*LFibre;
    
            Ve0 = mphinterp(model ,'V','coord', [xF; yF; zF0],'dataset','dset1');
            Ve1 = mphinterp(model ,'V','coord', [xF; yF; zF1],'dataset','dset1');
            Ve2 = mphinterp(model ,'V','coord', [xF; yF; zF2],'dataset','dset1');
           
            Vezz(iDim,:) = courant_relatif*(Ve0+Ve2-2*Ve1);
            
        end
        
        
        %sauvegarde des données 
        VezzSave(:,1+(iPos-1)*nPosLongitudinal:iPos*nPosLongitudinal) = Vezz;
        
       
        
    end
    

    %normalisation
    cMin = min(min(VezzSave));
    cMax = max(max(VezzSave));
    
    
    if strfind(normChoice, 'cathode')
        deltac = cMax;
    elseif strfind(normChoice, 'anode')
        deltac = -cMin;
    elseif strfind(normChoice, 'absolute')
        deltac = 1;
    else 
        error('You did not choose a possible input parameter : cathode, anode or absolute');
    end
      
    VezzSave = VezzSave/deltac;
    
    %nouvelle bornes supérieurs et inférieurs
    cMin = cMin/deltac;
    cMax = cMax/deltac;
    
    for iPos = 1:length(positionRange)
        
        [zPos,fibreDimGrid] = meshgrid(zF1,fibreRange);
        h = subplot(length(positionRange),1,iPos);
        
        
        %subplot de la surface
        Vezz = VezzSave(:,1+(iPos-1)*nPosLongitudinal:iPos*nPosLongitudinal);
        surf(fibreDimGrid, zPos, Vezz, 'linestyle', 'none')
        shading interp
        plotArray = [plotArray h];
        
        if iPos==1
             title('Dérivée seconde discrète');
        end
      
         p = get(h, 'pos');
         p(4) = 0.1;
         set(h, 'pos', p);
        
        
        
        az = 90;
        el = 90;
        view(az, el);
        %set(gca,'visible','off')
        
        % choose the range to plot (saturated value beyond).    
        if isempty(cMinMax)
            caxis(plotArray(iPos), [cMin, cMax]);
        else
            caxis(plotArray(iPos), cMinMax);
        end
        
        if iPos~=length(positionRange)
            set(plotArray(iPos), 'Visible','off');  
            xlabel('Diam. fibre [m]');
            ylabel('Distance le long de la fibre [m]');
        end
        colormap(jet(1024));
    end
    
    
    % Create textarrow
    annotation(fig,'textarrow',[0.0963541666666667 0.0963541666666667],...
    [0.931475884244373 0.184887459807074],'TextEdgeColor','none',...
    'TextRotation',90,...
    'VerticalAlignment','top',...
    'String',{'distance au centre du nerf'},...
    'HeadStyle','cback1');

    % Create colorbar
    colorbar('Position', [0.942847222222221 0.138263665594855 0.0212152777777789 0.755016077170417]);
    %colorbar('peer',plotArray(end), [0.942847222222221 0.138263665594855 0.0212152777777789 0.755016077170417]);
    
    %text box to indicate parameters
    stringParameters = sprintf('Diam. cathode : %0.3f mm \nDiam. anode : %0.3f mm \nDiam. fascicle : %0.3f mm \nDiam. nerf : %0.3f mm \n|e|electode : %0.3f mm \nLongueur cuff (isolant) : %0.2f mm\nExt. cond. (inside cuff) : %0.2f S/m', ring2D*1e3, ring1D*1e3, fascicleD*1e3, nerveD*1e3, ringD*1e3, cuffL*1e3,  sigmaEXT)
    annotation(gcf,'textbox', [0.1 0.4 0.15 0.15], 'String',stringParameters, 'FitBoxToText','off', 'BackgroundColor',[1 1 1]);

   
end