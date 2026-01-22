function mapActivationWithShiftTwoColors1D(resultDirectory)
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
    
   
   
    % number of fibre diameter studied
    contentResultDirectory      = dir(resultDirectory);
    all_dir = contentResultDirectory([contentResultDirectory(:).isdir]);
    nDiameter = numel(all_dir)-2;
    
    
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
    
    %size of CoordonneesFibresXYZ
    sizeXYZ             = size(CoordonneesFibresXYZ);
    nFibre              = sizeXYZ(2);
    nNoeuds             = sizeXYZ(3);
    nFascicle           = fasciclesGeometry.numberOfFascicles;
    
    
    partOfAPTotal       = [];
    colorsChange        = {'->r', '-*g', '->b', '-+c', '-xk', '-sb', '-pr'};
    
    fig                 = figure();
    widthBar            = [1 2/3 1/2 1/3 1/4 1/5 1/6 1/8 1/20];
    %set(fig,'Renderer','OpenGL')
    
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
        if numel(find(X<0))==0 & numel(find(Y<0))==0
            rXY     = sqrt(X.^2+Y.^2);
        else
            rXY     = X;
        end
        %XY0     = [X(1:nFibrePerFasicle:end); Y(1:nFibrePerFasicle:end)];
        
%         dataZToEliminate = reshape([squeeze(Z)]', 1, nFibre);
%          
%         %find parasite data (z first node ccordinate is null).
%         realDataIndice   = find(dataZToEliminate~=0);
        
        % proportion of AP for a fixed diameter
        load(['./' resultDirectory '/' contentResultDirectory(k+2).name '/shift_0_mat.mat']);
        partOfAP     = zeros(size(type));
        
        if numel(partOfAPTotal) == 0
            partOfAPTotal = zeros(size(type));
        end
        
        for l=1:nNodeShift
            % shift value (as used in detectActivationWithShift)
            shift       = (l-1)/nNodeShift;
            % data file name (as used in detectActivationWithShift)
            currentFileName                = ['shift_' num2str(shift) '.mat'];
            currentFileName                = strrep(currentFileName, '.', '_');
            % Load currrent data to retrieve 'type results'
            load(['./' resultDirectory '/' contentResultDirectory(2+k).name '/' currentFileName]);
            partOfAP    = partOfAP + (type==1 | type==3)*0.0 + (type==2 | type==4 | type==5)*1.0;   
        end
        
        % eliminate wrong data
        %rXY                     = rXY(realDataIndice);        
        %partOfAP                = partOfAP(realDataIndice);
        
        partOfAP = partOfAP/nNodeShift;
        
        % Compute the total proportion of fibers due to this fiber diameter
        % contribution. nRange contains the proportions of fibers for the
        % range associated to this size. 
        partOfAPTotal = partOfAPTotal + nRange(k) * partOfAP;
        
       
        
        
        
        
        rXYq                    = linspace(rXY(1), rXY(end), 250);
        xq                      = linspace(X(1), X(end), 250);
        yq                      = linspace(Y(1), Y(end), 250);
        partOfAPInterpolated    = interp1(rXY,partOfAP,rXYq);


       % masque = 1 dans les facicules, masque = 0 en dehors.
       % mask of fasciles
        inFascicle = zeros(size(rXYq));
        for l = 1:nFascicle
            xFascicle = fasciclesGeometry.polyShape{l}(1,:)';
            yFascicle = fasciclesGeometry.polyShape{l}(2,:)';
            inFascicle =  inFascicle + inpolygon(xq,yq,xFascicle,yFascicle);
        end
       masque = inFascicle;

       % utilisation du masque sur typeq
       % On donne une valeur Nan en dehors des fascicules de telle sorte que
       % les valeur en dehors ne seront pas affichées lors de l'appel de la
       % fonction surf.
       partOfAPInterpolated = (masque==1)*1.*partOfAPInterpolated+(masque==0)*(-1);
       partOfAPInterpolated(partOfAPInterpolated==-1) = nan;


       % plot
       
       %b = plot(rXYq, partOfAPInterpolated, widthBar(k), 'FaceColor', colorsChange(k));
       plot(rXYq, partOfAPInterpolated, colorsChange{mod(k,3)+1});
       
       leg = legend;
       legend([leg.String sprintf('D = %0.1f µm', diameterArray(k)*1e6)]);
       ylim([-0.1 1.1]);
       grid;
       alpha(0.05);
       hold on;

       
       %  vals         = repelem(rXYq,partOfAPInterpolated*10);
%        h            = histogram(vals);
%        h.FaceAlpha  = 0.2;
%        b = bar(rXYq, partOfAPInterpolated, 'FaceColor', colorsChange(k));
% %        b.FaceAlpha = 0.5;
%        set(get(b,'Children'),'FaceAlpha',0.1)
%        
%        %h = findobj(gca,'Type','patch')
       %set(h,'FaceColor',colorsChange(k),'EdgeColor','w','facealpha',0.5);
       
      
      
      
      
       %Illustration des diffénts types détectés.
      
      
       title(sprintf('Proportion of fiber active for diameters of [%0.1f %0.1f]', min(diameterArray)*1e6, max(diameterArray)*1e6));

       stringParameters = sprintf('Diam. fibre : %0.1f µm\nDiam. cathode : %0.3f mm \nDiam. anode : %0.3f mm \nDiam. fascicle : %0.3f mm \nDiam. nerf : %0.3f mm \n|e|electode : %0.3f mm \nExt. cond. (inside cuff) : %0.2f S/m', diameterArray(k)*1e6, ring2D*1e3, ring1D*1e3, fascicleD*1e3, nerveD*1e3, ringD*1e3, sigmaEXT)
       %annotation(gcf,'textbox', [0.1 0.4 0.15 0.15], 'String',stringParameters, 'FitBoxToText','off', 'BackgroundColor',[1 1 1]);
       %set(gcf,'Renderer','OpenGL')

       % save figure and data computed
       saveas(fig, ['proportionAPPourFibreDe' num2str(diameterArray(k)) '.fig']);
       currentDiameter      = diameterArray(k);
       save(['./' resultDirectory '/' 'proportionAPPourFibreDe' num2str(diameterArray(k)) '.mat'], 'diameterArray', 'partOfAP', 'rXY', 'currentDiameter');
       
       
       
       %% Plot Global figure
       
       if k==0
            
            
            typeq = griddata(X,Y,partOfAPTotal,xq,yq);
           % utilisation du masque sur typeq
           % On donne une valeur Nan en dehors des fascicules de telle sorte que
           % les valeur en dehors ne seront pas affichées lors de l'appel de la
           % fonction plot.
           typeq = (masque==1)*1.*typeq+(masque==0)*(-1);
           typeq(typeq==-1) = nan;

       
           % plot sans les mesh
           fig = figure()
           surf(xq,yq,typeq,'EdgeColor','none');

           % color map
           % colormap23 = [ones(16,1)*[1 0 0];ones(32,1)*[0 1 0];ones(32,1)*[0 0 0];ones(16,1)*[0 0 1]];   %noir et rouge
           colormap(flipud(gray));                        %attribution de la map de couleur


           %dessin des fascicules, du nerf, et des électrodes.
           zFascicle=zeros(1,length(theta));

           hold on;
           plot3(xFascicle1,yFascicle1,zFascicle, 'k');
           plot3(xFascicle2,yFascicle2,zFascicle, 'k');
           plot3(xFascicle3,yFascicle3,zFascicle, 'k');
           plot3(xFascicle4,yFascicle4,zFascicle, 'k');
           plot3(xFascicle5,yFascicle5,zFascicle, 'k');
           hNerve = plot3(xNerve,yNerve,zFascicle,'k', 'LineWidth',1);
           hRing1 = plot3(xRing1,yRing1,zFascicle,'r+', 'LineWidth',1.5);
           hRing2 = plot3(xRing2,yRing2,zFascicle,'b--', 'LineWidth',1.5);

           %légende des tracés 
           legend([hNerve hRing1 hRing2], {'Nerve and Fasciles Contour','Ring Anode contour (+)', 'Ring Cathode contour (-)'}, 'Location', 'south');



           %point de vue du dessus
           caxis([0 1])
            axis equal
            az = 0;
            el = 90;
            view(az, el);

           %Illustration des diffénts types détectés.
           hcb = colorbar('YTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1] ,'YTickLabel',{'0% AP', '10%', '20%', '30%', '40%', '50%', '60%', '70%', '80%', '90%', '100% AP'})
           set(hcb, 'YTickMode', 'manual')
           title('Déclenchement des potentiels d action dans le nerf et classement par type');

           stringParameters = sprintf('Diam. fibre : [%0.1f,%0.1f]  µm\nDiam. cathode : %0.3f mm \nDiam. anode : %0.3f mm \nDiam. fascicle : %0.3f mm \nDiam. nerf : %0.3f mm \n|e|electode : %0.3f mm \nExt. cond. (inside cuff) : %0.2f S/m', min(diameterArray)*1e6,max(diameterArray)*1e6, ring2D*1e3, ring1D*1e3, fascicleD*1e3, nerveD*1e3, ringD*1e3, sigmaEXT)
           annotation(gcf,'textbox', [0.1 0.4 0.15 0.15], 'String',stringParameters, 'FitBoxToText','off', 'BackgroundColor',[1 1 1]);
           set(gcf,'Renderer','OpenGL')

           saveas(fig, ['proportionAPPourToutesLesFibresDe' num2str(min(diameterArray)) 'A' num2str(max(diameterArray)) '.fig']);
           %saveas(fig, ['proportionAPPourToutesLesFibresDe' num2str(diameterArray(1)) 'A' num2str(diameterArray(end)) '.png']); 
       
       end
       
    end



end

