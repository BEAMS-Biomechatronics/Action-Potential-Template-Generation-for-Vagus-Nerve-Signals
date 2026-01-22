function cost = virtualCathodeCostFunction(input)
    import selectivity.comsol.*
    import selectivity.stimWaveForm.*
    import selectivity.fibreModel.fibre.*
    
    alphaSent = input(1);
    
    %Paramètres propres à la fonction
    nPosFacscicule      = 11;        %3 * n -1 avec n entier
    nPosLongitudinal    = 401;      %mettre un nombre impair (plus facile).
    nDimFiber           = 10;
    minDimFiber         = 5e-6;
    maxDimFiber         = 7.5e-6;
    
    %initialisation de la variable cout à 0
    cost = 0;    
    
    %paramètres à modifier dans le fichier
    %selectivty.comsol.parametersParaboleAnode
    %(va générer le fichiers parameters.mat)
    load parameters
    
    %Parmi les paramètres, on ne modifie que la valeur de alpha.
    alpha = alphaSent;
    save('changeParameters.mat', 'alpha', '-append');
    selectivity.comsol.parametersParaboleAnode();
    
    stepDimFiber        = (maxDimFiber-minDimFiber)/(nDimFiber-1);
    epsilonBorder       = 1e-5; %distance entre le point en bordure de fascicule et la frontière du fascicule
    stepPos             = nerveD/2/nPosFacscicule;
    


    fibreRange          = [minDimFiber:stepDimFiber:maxDimFiber];
    positionRange       = [0:stepPos:nerveD/2-epsilonBorder];

    
    %Model COMSOL              
    model = comsolModel();
    study = model.study('std1');
    data = model.result.dataset('dset1');

    %running model
    cMinMax = [];
    plotArray = [];
    VezzSave = zeros(length(fibreRange),nPosLongitudinal*length(positionRange));
    
    fig = figure()
    VeGrandeFibre = [];
    
    zF1 = [-2*cuffL:4*cuffL/(nPosLongitudinal-1):2*cuffL];
    for iPos = 1:length(positionRange)
        Vezz = zeros(length(fibreRange),nPosLongitudinal);
        for iDim = 1:length(fibreRange) 
            WF = stimWaveFormLinesByPieces();
            fibreInstance = fibre(fibreRange(iDim),1,20,WF,WF);
            LFibre = fibreInstance.L;
            
            xF = ones(1,length(zF1))*positionRange(iPos);
            yF = zeros(1,length(zF1));
            zF0 = zF1-ones(1,length(zF1))*LFibre;
            zF2 = zF1+ones(1,length(zF1))*LFibre;
    
            Ve0 = mphinterp(model ,'V','coord', [xF; yF; zF0],'dataset','dset1');
            Ve1 = mphinterp(model ,'V','coord', [xF; yF; zF1],'dataset','dset1');
            Ve2 = mphinterp(model ,'V','coord', [xF; yF; zF2],'dataset','dset1');
            %figure()
            %plot(zF1, Ve1)
            Vezz(iDim,:) = (Ve0+Ve2-2*Ve1);
            if iPos == length(positionRange) && iDim == length(fibreRange)
                VeGrandeFibre = Ve1;
            end
            
        end
        
        
        %sauvegarde des données 
        VezzSave(:,1+(iPos-1)*nPosLongitudinal:iPos*nPosLongitudinal) = Vezz;
        
       
        
    end
    

    %normalisation
    cMin = min(min(VezzSave));
    cMax = max(max(VezzSave));
    deltac = cMax-cMin;
    
    %VezzSave = VezzSave/deltac;
    VezzSave = VezzSave/cMax;
    
    %nouvelle bornes supérieurs et inférieurs
    cMin = cMin/cMax;%cMin/deltac;
    cMax = 1;%cMax/deltac;
    
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
        
        
        caxis(plotArray(iPos), [cMin, cMax]);
        %caxis(plotArray(iPos), [0 0.03]);
        
        if iPos~=length(positionRange)
            set(plotArray(iPos), 'Visible','off');  
            xlabel('Diam. fibre [m]');
            ylabel('Distance le long de la fibre [m]');
        end
        colormap(jet(1024));
        
        
        
           
    end
    
    
    figVezz = figure()
    VezzGrandeFibre = VezzSave(end,(length(positionRange)-1)*nPosLongitudinal:end);
    size(VezzGrandeFibre)
    plot(VezzGrandeFibre)
    [maxVgrandeFibre, indMaxVgrandeFibre] = max(VeGrandeFibre);
   
   cost = findpeaks(VezzGrandeFibre(indMaxVgrandeFibre:end),'NPEAKS',1);
    
    % Create textarrow
    annotation(fig,'textarrow',[0.0963541666666667 0.0963541666666667],...
    [0.931475884244373 0.184887459807074],'TextEdgeColor','none',...
    'TextRotation',90,...
    'VerticalAlignment','top',...
    'String',{'distance au centre du nerf'},...
    'HeadStyle','cback1');

    % Create colorbar
    colorbar(plotArray(end),...
    'Position' ,[0.942847222222221 0.138263665594855 0.0212152777777789 0.755016077170417]);
    
    %text box to indicate parameters
    stringParameters = sprintf('Diam. cathode : %0.3f mm \nDiam. anode : %0.3f mm \nDiam. nerf : %0.3f mm \n|e|electode : %0.3f mm \nLongueur cuff (isolant) : %0.2f mm\nExt. cond. (inside cuff) : %0.2f S/m\ncuffL : %f\nalpha : %f', ring2D*1e3, ring1D*1e3, nerveD*1e3, ringD*1e3, cuffL*1e3,  sigmaEXT, cuffL, alpha)
    annotation(gcf,'textbox', [0.1 0.4 0.15 0.15], 'String',stringParameters, 'FitBoxToText','off', 'BackgroundColor',[1 1 1]);

    %saveData
    filename = sprintf('alpha%2.0f_map2Derivative_cuffL%f.fig',alpha,cuffL); 
    saveas(fig,filename);
end