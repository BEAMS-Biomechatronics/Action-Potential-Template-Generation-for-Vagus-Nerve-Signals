function mapActivationWithShiftTwoColors(resultDirectory)
    % mapActivationWithShiftTwoColors(resultDirectory)
    % This function can be called after you have solved the problem with
    % the detectActivationWithShift() function. 
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
    
   
    
    
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%          PARAMETERS                                    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Loading important facts
    % - nNodeShift
    % - nFibreLayerPerFasicle
    % - nFibreFirstLayer    
    load([resultDirectory '/parameters.mat']);
        
    % generating unknown parameters (1+2+3+...+n) = n*(n+1)/2
    % number of points in one fascicle
    %nFibrePerFasicle           = 1+ (nFibreLayerPerFasicle*(nFibreLayerPerFasicle+1)/2)*nFibreFirstLayer;
    nFascicle                   = fasciclesGeometry.numberOfFascicles;
    % number of fibre diameter studied
    contentResultDirectory      = dir(resultDirectory);
    sizeResultDirectory         = size(contentResultDirectory);
    
    nDiameter                   = sizeResultDirectory(1)-3;
    diameterArray               = zeros(1,nDiameter);
    rangeOfDiameterValidity     = zeros(2,nDiameter);
   
    % retrieve diameters data
    for k = 3:nDiameter+2
        folderName              = contentResultDirectory(k).name;
        diameterArray(k-2)      = str2double(folderName(7:end));
    end
    
    % get Proportion of fibers for each fiber diameter
    hFD                         = histoFibreDiameter();
    nRange                      = hFD.getProportion(diameterArray);
    
    
    % load first result to extract coordinates (coordinates are common to
    % all the results :
    % - CoordonneesFibresXYZ
    type = [];    
    load(['./' resultDirectory '/' contentResultDirectory(3).name '/shift_0_mat.mat']);
    partOfAPTotal     = zeros(size(type));
    
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%          LOOPS                                               %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % loop for the different size of fiber
    for k = 1:nDiameter
        
        % Need the coordinates in XY of fibers and the central fibers
        % coordinates       
        X       = [squeeze(CoordonneesFibresXYZ(1,:,1))]';
        Y       = [squeeze(CoordonneesFibresXYZ(2,:,1))]';
        %XY0     = [X(1:nFibrePerFasicle:end); Y(1:nFibrePerFasicle:end)];

        [xq, yq] = meshgrid(-3e-3/2:0.01e-3:3e-3/2);

        
        % proportion of AP for a fixed diameter
        load(['./' resultDirectory '/' contentResultDirectory(k+2).name '/shift_0_mat.mat']);
        partOfAP     = zeros(size(type));
        
        for l=1:nNodeShift
            % shift value (as used in detectActivationWithShift)
            shift       = (l-1)/nNodeShift;
            % data file name (as used in detectActivationWithShift)
            currentFileName                = ['shift_' num2str(shift) '.mat'];
            currentFileName                = strrep(currentFileName, '.', '_');
            % Load currrent data to retrieve 'type results'
            load(['./' resultDirectory '/' contentResultDirectory(2+k).name '/' currentFileName]);
            partOfAP    = partOfAP + (type==1 | type==3)*0.0 + (type==2 | type==4)*1.0;
        end
        partOfAP = partOfAP/nNodeShift;
        
        % Compute the total proportion of fibers due to this fiber diameter
        % contribution. nRange contains the proportions of fibers for the
        % range associated to this size. 
        partOfAPTotal = partOfAPTotal + nRange(k) * partOfAP;
        
        
        
        % données d'interpolation    
        typeq = griddata(X,Y,partOfAP,xq,yq);


        % sélection de l'intérieur des fascicules
        theta = linspace(0,2*pi,200);

        % creation of polygon circles to avoid drawing of exterior of
        % fasciles
        
  

       % drawing nerve and electrodes
       xNerve     = 0*ones(1,200)    +nerveD/2*cos(theta);
       yNerve     = 0*ones(1,200)    +nerveD/2*sin(theta);
       xRing1     = 0*ones(1,200)    +ring1D/2*cos(theta);
       yRing1     = 0*ones(1,200)    +ring1D/2*sin(theta);
       xRing2     = 0*ones(1,200)    +ring2D/2*cos(theta);
       yRing2     = 0*ones(1,200)    +ring2D/2*sin(theta);  
       
       
        % mask of fasciles
        inFascicle = zeros(size(xq));
        for l = 1:nFascicle
            xFascicle = fasciclesGeometry.polyShape{l}(1,:)';
            yFascicle = fasciclesGeometry.polyShape{l}(2,:)';
            inFascicle =  inFascicle + inpolygon(xq,yq,xFascicle,yFascicle);
        end

       % masque = 1 dans les facicules, masque = 0 en dehors.
       masque = inFascicle;
       %masque = inFascicle1*1+inFascicle2*1+inFascicle3*1+inFascicle4*1+inFascicle5*1;

       % utilisation du masque sur typeq
       % On donne une valeur Nan en dehors des fascicules de telle sorte que
       % les valeur en dehors ne seront pas affichées lors de l'appel de la
       % fonction surf.
       typeq = (masque==1)*1.*typeq+(masque==0)*(-1);
       typeq(typeq==-1) = nan;


       %plot sans les mesh
       fig = figure()
       surf(xq,yq,typeq,'EdgeColor','none');

       %color map
       colormap(flipud(hot));                        %attribution de la map de couleur

       %dessin des fascicules, du nerf, et des électrodes.
       hold on;
       for l=1:nFascicle
            xFascicle   = [fasciclesGeometry.polyShape{l}(1,:) fasciclesGeometry.polyShape{l}(1,1)];
            yFascicle   = [fasciclesGeometry.polyShape{l}(2,:) fasciclesGeometry.polyShape{l}(2,1)];
            zFascicle   = zeros(size(xFascicle));
            plot3(xFascicle, yFascicle, zFascicle, 'k');
       end

       
%        plot3(xFascicle1,yFascicle1,zFascicle, 'k');
%        plot3(xFascicle2,yFascicle2,zFascicle, 'k');
%        plot3(xFascicle3,yFascicle3,zFascicle, 'k');
%        plot3(xFascicle4,yFascicle4,zFascicle, 'k');
%        plot3(xFascicle5,yFascicle5,zFascicle, 'k');
       hNerve = plot3(xNerve,yNerve,zeros(size(xNerve)),'k', 'LineWidth',1);
       hRing1 = plot3(xRing1,yRing1,zeros(size(xRing1)),'r+', 'LineWidth',1.5);
       hRing2 = plot3(xRing2,yRing2,zeros(size(xRing2)),'b--', 'LineWidth',1.5);

       %légende des tracés 
       legend([hNerve hRing1 hRing2], {'Contours du nerf et des fascicules','Anode (+)', 'Cathode (-)'}, 'Location', 'south');



       %point de vue du dessus
       caxis([0 1])
        axis equal
        az = 0;
        el = 90;
        view(az, el);

       %Illustration des diffénts types détectés.
       hcb = colorbar('YTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1] ,'YTickLabel',{'0% AP', '10%', '20%', '30%', '40%', '50%', '60%', '70%', '80%', '90%', '100% AP'})
       set(hcb, 'YTickMode', 'manual')
       %title('Déclenchement des potentiels d action dans le nerf et classement par type');
        diameterArray(k)*1e6
       stringParameters = sprintf('Diam. fibre : %0.1f µm\nDiam. cathode : %0.3f mm \nDiam. anode : %0.3f mm \nDiam. nerf : %0.3f mm \n|e|electode : %0.3f mm \nCond. Ext. (intérieur manchette) : %0.2f S/m', diameterArray(k)*1e6, ring2D*1e3, ring1D*1e3, nerveD*1e3, ringD*1e3, sigmaEXT)
       annotation(gcf,'textbox', [0 0 0.2 0.6], 'String',stringParameters, 'FitBoxToText','off', 'BackgroundColor',[1 1 1]);
       set(gcf,'Renderer','OpenGL')

       saveas(fig, ['proportionAPPourFibreDe' num2str(diameterArray(k)) '.fig']);
       %saveas(fig, ['proportionAPPourFibreDe' num2str(diameterArray(k)) '.png']);
       
       
       %% Plot Global figure
       if k==nDiameter
            
            
            typeq = griddata(X,Y,partOfAPTotal,xq,yq);
           % utilisation du masque sur typeq
           % On donne une valeur Nan en dehors des fascicules de telle sorte que
           % les valeur en dehors ne seront pas affichées lors de l'appel de la
           % fonction surf.
           typeq = (masque==1)*1.*typeq+(masque==0)*(-1);
           typeq(typeq==-1) = nan;

       
           % plot sans les mesh
           fig = figure()
           surf(xq,yq,typeq,'EdgeColor','none');

           % color map
           % colormap23 = [ones(16,1)*[1 0 0];ones(32,1)*[0 1 0];ones(32,1)*[0 0 0];ones(16,1)*[0 0 1]];   %noir et rouge
           colormap(flipud(hot));                        %attribution de la map de couleur


           %dessin des fascicules, du nerf, et des électrodes.
           hold on;
           for l=1:nFascicle
                xFascicle   = [fasciclesGeometry.polyShape{l}(1,:) fasciclesGeometry.polyShape{l}(1,1)];
                yFascicle   = [fasciclesGeometry.polyShape{l}(2,:) fasciclesGeometry.polyShape{l}(2,1)];
                zFascicle   = zeros(size(xFascicle));
                plot3(xFascicle, yFascicle, zFascicle, 'k');
           end


           hNerve = plot3(xNerve,yNerve,zeros(size(xNerve)),'k', 'LineWidth',1);
           hRing1 = plot3(xRing1,yRing1,zeros(size(xRing1)),'r+', 'LineWidth',1.5);
           hRing2 = plot3(xRing2,yRing2,zeros(size(xRing2)),'b--', 'LineWidth',1.5);

           %légende des tracés 
           legend([hNerve hRing1 hRing2], {'Nerve and Fasciles Contour','Ring Anode contour (+)', 'Ring Cathode contour (-)'}, 'Location', 'south');
           
           
           
           
           
           
           
%            
%            zFascicle=zeros(1,length(theta));
% 
%            hold on;
%            plot3(xFascicle1,yFascicle1,zFascicle, 'k');
%            plot3(xFascicle2,yFascicle2,zFascicle, 'k');
%            plot3(xFascicle3,yFascicle3,zFascicle, 'k');
%            plot3(xFascicle4,yFascicle4,zFascicle, 'k');
%            plot3(xFascicle5,yFascicle5,zFascicle, 'k');
%            hNerve = plot3(xNerve,yNerve,zFascicle,'k', 'LineWidth',1);
%            hRing1 = plot3(xRing1,yRing1,zFascicle,'r+', 'LineWidth',1.5);
%            hRing2 = plot3(xRing2,yRing2,zFascicle,'b--', 'LineWidth',1.5);
% 
%            %légende des tracés 
%            legend([hNerve hRing1 hRing2], {'Nerve and Fasciles Contour','Ring Anode contour (+)', 'Ring Cathode contour (-)'}, 'Location', 'south');



           %point de vue du dessus
           caxis([0 1])
            axis equal
            az = 0;
            el = 90;
            view(az, el);

           %Illustration des diffénts types détectés.
           hcb = colorbar('YTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1] ,'YTickLabel',{'0% AP', '10%', '20%', '30%', '40%', '50%', '60%', '70%', '80%', '90%', '100% AP'})
           set(hcb, 'YTickMode', 'manual')
           %title('Déclenchement des potentiels d action dans le nerf et classement par type');

           stringParameters = sprintf('Diam. fibre : [%0.1f,%0.1f]  µm\nDiam. cathode : %0.3f mm \nDiam. anode : %0.3f mm \nDiam. fascicle : %0.3f mm \nDiam. nerf : %0.3f mm \n|e|electode : %0.3f mm \nExt. cond. (inside cuff) : %0.2f S/m', min(diameterArray)*1e6,max(diameterArray)*1e6, ring2D*1e3, ring1D*1e3, fascicleD*1e3, nerveD*1e3, ringD*1e3, sigmaEXT)
           annotation(gcf,'textbox', [0 0 0.2 0.6], 'String',stringParameters, 'FitBoxToText','off', 'BackgroundColor',[1 1 1]);
           set(gcf,'Renderer','OpenGL')

           saveas(fig, ['proportionAPPourToutesLesFibresDe' num2str(min(diameterArray)) 'A' num2str(max(diameterArray)) '.fig']);
           %saveas(fig, ['proportionAPPourToutesLesFibresDe' num2str(diameterArray(1)) 'A' num2str(diameterArray(end)) '.png']); 
       
       end
       
    end

   
end