function mapActivationWithShiftFourColors(resultFile)
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TO UPDATE !!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %chargement de tous les paramètres :
    load(resultFile);      
    
    
    fibreTest = fibre(diametreFibre(1),1,[0],20, 0, 0);
    X = [];
    Y = [];
    
    nFasicule = length(CoordonneesFibresXY(:,1))/2;
    nFibreParFasicule = length(CoordonneesFibresXY(1,:));
    XY0 = [];
    for i=1:nFasicule
        for k=1:nFibreParFasicule
            X = [X CoordonneesFibresXY((i-1)*2+1,k)];
            Y = [Y CoordonneesFibresXY(i*2,k)];
            if k==1
                XY0 = [XY0 [CoordonneesFibresXY((i-1)*2+1,k);CoordonneesFibresXY(i*2,k)]];
            end
        end
    end
    [xq, yq] = meshgrid(-3e-3/2:0.01e-3:3e-3/2);
    
    %données d'interpolation
   typeq = griddata(X,Y,type,xq,yq);
  
   
   %sélection de l'intérieur des fascicules
   theta = linspace(0,2*pi,200);
   
   xFascicle1 = XY0(1,1)*ones(1,200)    +fasciculeD/2*cos(theta);
   yFascicle1 = XY0(2,1)*ones(1,200)    +fasciculeD/2*sin(theta);
   xFascicle2 = XY0(1,2)*ones(1,200)    +fasciculeD/2*cos(theta);
   yFascicle2 = XY0(2,2)*ones(1,200)    +fasciculeD/2*sin(theta);
   xFascicle3 = XY0(1,3)*ones(1,200)    +fasciculeD/2*cos(theta);
   yFascicle3 = XY0(2,3)*ones(1,200)    +fasciculeD/2*sin(theta);
   xFascicle4 = XY0(1,4)*ones(1,200)    +fasciculeD/2*cos(theta);
   yFascicle4 = XY0(2,4)*ones(1,200)    +fasciculeD/2*sin(theta);
   xFascicle5 = XY0(1,5)*ones(1,200)    +fasciculeD/2*cos(theta);
   yFascicle5 = XY0(2,5)*ones(1,200)    +fasciculeD/2*sin(theta);
   xNerve     = XY0(1,1)*ones(1,200)    +nerveD/2*cos(theta);
   yNerve     = XY0(2,1)*ones(1,200)    +nerveD/2*sin(theta);
   xRing1     = XY0(1,1)*ones(1,200)    +ring1D/2*cos(theta);
   yRing1     = XY0(2,1)*ones(1,200)    +ring1D/2*sin(theta);
   xRing2     = XY0(1,1)*ones(1,200)    +ring2D/2*cos(theta);
   yRing2     = XY0(2,1)*ones(1,200)    +ring2D/2*sin(theta);  
   
   inFascicle1 = inpolygon(xq,yq,xFascicle1,yFascicle1)*1;
   inFascicle2 = inpolygon(xq,yq,xFascicle2,yFascicle2)*1;
   inFascicle3 = inpolygon(xq,yq,xFascicle3,yFascicle3);
   inFascicle4 = inpolygon(xq,yq,xFascicle4,yFascicle4);
   inFascicle5 = inpolygon(xq,yq,xFascicle5,yFascicle5);
   
   %masque = 1 dans les facicules, masque = 0 en dehors.
   masque = inFascicle1*1+inFascicle2*1+inFascicle3*1+inFascicle4*1+inFascicle5*1;
   
   %utilisation du masque sur typeq
   %On donne une valeur Nan en dehors des fascicules de telle sorte que
   %les valeur en dehors ne seront pas affichées lors de l'appel de la
   %fonction surf.
   typeq = (masque==1)*1.*typeq+(masque==0)*0;
   typeq(typeq==0) = nan;
   
   
      
   %plot sans les mesh
   figure()
   surf(xq,yq,typeq,'EdgeColor','none');
   
   %color map
   colormap23 = [ones(16,1)*[1 0 0];ones(32,1)*[0 1 0];ones(32,1)*[0 0 0];ones(16,1)*[0 0 1]];   %noir et rouge
   colormap(colormap23);                        %attribution de la map de couleur
   
   
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
   caxis([1 4])
    axis equal
    az = 0;
    el = 90;
    view(az, el);
    
   %Illustration des diffénts types détectés.
   hcb = colorbar('YTick',[1 2 3 4] ,'YTickLabel',{'No AP at all', 'AP Cathode', 'No AP (anodic block)', 'AP (virutal cathode)'})
   set(hcb, 'YTickMode', 'manual')
   title('Déclenchement des potentiels d action dans le nerf et classement par type');
   
   stringParameters = sprintf('Diam. fibre : %0.1f µm\nDiam. cathode : %0.3f mm \nDiam. anode : %0.3f mm \nDiam. fascicle : %0.3f mm \nDiam. nerf : %0.3f mm \n|e|electode : %0.3f mm \nCurrent : %0.3f mA \nPulse Time : %0.2f ms \nExt. cond. (inside cuff) : %0.2f S/m', diametreFibre(1)*1e6, ring2D*1e3, ring1D*1e3, fasciculeD*1e3, nerveD*1e3, ringD*1e3, courant_relatif*1e3, pulseTEnd*1e3, sigmaEXT)
   annotation(gcf,'textbox', [0.1 0.4 0.15 0.15], 'String',stringParameters, 'FitBoxToText','off', 'BackgroundColor',[1 1 1]);
   set(gcf,'Renderer','OpenGL')
    
   
end