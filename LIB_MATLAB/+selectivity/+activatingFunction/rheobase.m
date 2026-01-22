function rheobase()

import selectivity.fibreModel.fibre.*
import selectivity.stimWaveForm.*
import selectivity.anodalBlock.*

delete(gcp);
distcomp.feature( 'LocalUseMpiexec', false );



for w=4:12


    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %           paramètres modifiables !                 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Paramètres du script modifiable qui n'intervient que dans le calcul des AP
    %(MATLAB)
    fiberD = w*1.25e-6;                 %[m] diamètre de la fibre
    
    pusleTTransition = 1e-5;
    nProc = 4; %(6 sur la station, 4 sur PC perso). 
    relTol = 1e-3;
    

    

    %% MODELE FIBRE MATLAB

    %calcul du nombre de noeuds nécessaire
    %Couvrir toute la longueur du modèle
    nNoeuds = 41;
    fibreTest = fibre(fiberD,nNoeuds,20);
    LFibre = fibreTest.L;
    Ve = [];

    %sauvegarde des conclusions de simulation
    % type
    % coordonnées
    % taille fibre
    % decalage
    coordonnee = [];
    diametreFibre = [];
    type = [];
    
    
    % intervale de tension à appliquer en un noeud. 
    VInterInit = [-0.16 0];
    pulseTEnd =  10.^[-5:0.25:-3];
   
    %Ici, il faudra vérifier si les deux valeurs extrémales de la tension
    %donne bien un AP et pas d'AP. Si ce n'est pas le cas, arrêter le
    %script et afficher un message d'erreur. 
   
    
    
    VSauvegarde = zeros(1,length(pulseTEnd));
    for m = 1:length(pulseTEnd)        
    
         
        WF                        = selectivity.stimWaveForm.stimWaveFormLinesByPieces();
        WF.setParameters(pulseTEnd(m), 1e-6, [0 1;1 1]);
        
        % Arrays for parallel loop
        WFArray(1:nProc)          = WF.copy();
        fiberDArray(1:nProc)      = fiberD;
        nNoeudsArray(1:nProc)     = nNoeuds;
        
        VInter = VInterInit;        
        diff = 1;
        
               
        parpool(nProc);
        while diff>relTol
            stepV = (VInter(2)-VInter(1))/(nProc+1);
            VValue = VInter(1)+stepV:stepV:VInter(2)-stepV;
            
            
            
            fAPOrNotAP = zeros(1,nProc);
            parfor k=1:nProc
                    
                    % 
                    fibreInstance = fibre(fiberDArray(k), nNoeudsArray(k), 20, WFArray(k));

                    % Recherche dans le modèle COMSOL du potentiel externe aux
                    % noeuds (Ve)
                    Vek = zeros(1,41);
                    Vek(19) = VValue(k);


                    % Introduction des valeurs de Ve dans le modèle de la fibre.
                    fibreInstance.setVe(Vek);

                    % Résolution du problème d'une fibre soumise à un potentiel Ve
                    % aux noeuds. 
                    fibreInstance = fibreInstance.solve();

                    % Analyse de la propagation des AP et classification de la fibre dans l'une des 4 catégories.            
                    APtracking = AP();
                    APtracking = APtracking.findAP(fibreInstance.solution(:,1:fibreInstance.n), fibreInstance.time, Vek);

                    % Sauvegarde
                    fAPOrNotAP(k) = (APtracking.type==2||APtracking.type==3||APtracking.type==4)*1;

%                     %Mise en forme du résultat pour la fibre
%                     currentFig = fibreInstance.plotBaton(10,[-20:1:20],4,APtracking);
%                     saveas(currentFig, sprintf('figure%d_%d_%d.fig',w,m,k));
            end
            fAPOrNotAP = [1 fAPOrNotAP 0];
            VValue = [VInter(1) VValue VInter(2)];
            Vtransition10 = find(fAPOrNotAP==0);
            newLeft = VValue(Vtransition10(1)-1);
            newRight = VValue(Vtransition10(1));
            VInter = [newLeft newRight];
            display(sprintf('L intervale est le suivant : [%f %f]',VInter(1), VInter(2)));
            diff = newRight-newLeft
        end
        delete(gcp);
        
        
        VSauvegarde(m) = VInter(1);
    end
    
    
    figure
    plot(pulseTEnd, VSauvegarde);
    hold on;
    xlabel('Pulse Time [s]');
    ylabel('Cathode voltage');
    legend(sprintf('rheobaes curve for %0.1fµm fiber',fiberD*1e6 ))
    filename = sprintf('sauvegarde%d.mat',fiberD);
    save(filename,  'fiberD', 'pulseTEnd', 'VSauvegarde');
end