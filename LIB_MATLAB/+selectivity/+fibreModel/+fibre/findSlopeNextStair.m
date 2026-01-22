function lastSlope = findSlopeNextStair(stepT, slopes, WFstartT, TPulseGlobal, TTransition, currentAmp, Ve, fiber_d)


    
    import selectivity.fibreModel.fibre.*
    import selectivity.stimWaveForm.*
    import selectivity.anodalBlock.*
    import com.comsol.model.*
    import com.comsol.model.util.*
    
    % Do not use Local MPI
    distcomp.feature( 'LocalUseMpiexec', false )
    
    % loading parameters
    load parameters
    
    

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %           paramètres modifiables !                 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Paramètres du script modifiable qui n'intervient que dans le calcul des AP
    %(MATLAB)
    relTol          = 1e-3; %s
    nodeShift       = 0;
    

    %% MODELE FIBRE MATLAB

    %calcul du nombre de noeuds nécessaire
    %Couvrir toute la longueur du modèle
    fibreTest           = fibre(fiber_d,1,20);
    
    LFibre              = fibreTest.L;
    
    % nombre de noeuds sur la longueur de la fibre
    nNoeuds = floor((nerveL-LFibre)/LFibre)+1-2;
        
    
   
    % intial time range into which to look for
    slopeInit       = [];
    if isempty(slopes)
        slopeInit   = [0 1e20]; %AMP 1/10µs
    else
        slopeInit   = [slopes(end) 1e20]; %AMP * 1/10µs
    end
    
    
    %% Model COMSOL
    
    %coordonnées à rechercher
    xF = ones(1,nNoeuds)*positionFiber0D(1);  
    yF = ones(1,nNoeuds)*positionFiber0D(2);
    zF=[];
    
    %tensions aux noeuds rapatriés
    
    if mod(nNoeuds,2)==1
        zF = [ceil(-nNoeuds/2):1:floor(nNoeuds/2)]*LFibre + LFibre * nodeShift * ones(1,nNoeuds);
    else
        zF = [round(-nNoeuds/2):1:round(nNoeuds/2-1)]*LFibre + LFibre * nodeShift * ones(1,nNoeuds);
    end
    
    
    % variable to stock the current range over time
    slopeInter = slopeInit;

    % variable to know the width of the current range
    diff = 1;
    
    % running parallel process manager
    %parpool('local',nProc)
    
    % dichotomic method to find the right timing. 
    
    while diff>relTol
        
        % dichtomic method cut the range into nProc+1 pieces.
        alphaL                  = atan(double(slopeInter(1)));
        alphaR                  = atan(double(slopeInter(2)));
        deltaAlpha              = double((alphaR-alphaL)/(nProc+1));
        alphaValue              = double(alphaL+deltaAlpha:deltaAlpha:alphaR-deltaAlpha);
        
        slopeValue              = tan(alphaValue);
        

        
        % basic WF with no data (only instances). 
        WF1Array(1:nProc) = selectivity.stimWaveForm.stimWaveFormLinesByPieces();
        
        % build the WF function with different time for the last stair
        % 'timeValue' value
        for k = 1:nProc
            slopeWF                 = [slopes slopeValue(k)];
            WF1Array(k)             = WFSlopeGenerator(slopeWF, stepT, WFstartT, TPulseGlobal, TTransition);
        end
        
        WF2Array(1:nProc)           = WF2.copy();
        current1Array(1:nProc)      = currentAmp;
        current2Array(1:nProc)      = current2;
       
        fibreDArray(1:nProc)        = fiber_d;
        nNoeudsArray(1:nProc)       = nNoeuds;
        
        fibreSave(1:nProc)          = fibre(fibreDArray(1),nNoeudsArray(1),20, WF1Array(1), WF2Array(1));
        
        blockedOrNot = zeros(1,nProc);
        parfor k=1:nProc %parfor
                fibreInstance   = fibre(fibreDArray(k),nNoeudsArray(k),20, WF1Array(k), WF2Array(k));

                %Introduction des valeurs de Ve dans le modèle de la fibre.
                fibreInstance   = fibreInstance.setVe(Ve);
                fibreInstance   = fibreInstance.setCurrent([current1Array(k) current2Array(k)]);

                %Résolution du problème d'une fibre soumise à un potentiel Ve
                %aux noeuds. 
                fibreInstance   = fibreInstance.solve();
                fibreSave(k)    = fibreInstance;

                %Analyse de la propagation des AP et classification de la fibre dans l'une des 5 catégories.            
                APtracking      = selectivity.anodalBlock.AP();
                APtracking      = APtracking.findAP(fibreInstance.solution(:,1:fibreInstance.n), fibreInstance.time, Ve', fibreInstance.WF1.TPulseGlobal*1.3); % 1.3 rajouté... bof bof
%                 hWF1            = WF1Array(k).plotWaveForm(0:1e-5:3e-3, current1Array(k));
%                 saveas(hWF1, sprintf('WF1_%d.fig', k));
%                 hFibre          = fibreInstance.plotBaton(12);
%                 saveas(hFibre,sprintf('fibre_%d.fig', k));
                
                %Sauvegarde
                blockedOrNot(k)   = (APtracking.type==3||APtracking.type==4||APtracking.type==5)*1+(APtracking.type==2||APtracking.type==1)*0;
        end
        save(sprintf('fibre%2.0f.mat', fiber_d*1e6), 'fibreSave');
        
        blockedOrNot            = [0 blockedOrNot 1];
        slopeValue              = [slopeInter(1) slopeValue slopeInter(2)];
        courantTransition23     = find(blockedOrNot==1);
        newLeft                 = slopeValue(courantTransition23(1)-1);
        newRight                = slopeValue(courantTransition23(1));
        slopeInter              = [newLeft newRight];
        display(sprintf('L intervale est le suivant : [%f %f]',slopeInter(1), slopeInter(2)));
        diff                    = (newRight-newLeft)/newRight;
        display(['convergence findSlope : ' num2str(diff)]);
        
    end
    delete(gcp);

    lastSlope = slopeInter(1);
    display(sprintf('La pente nécessaire pour bloquer la fibre [%0.3f %0.3f]mm de %0.2f micros est de %0.3f [1]/s.', positionFiber0D(1)*1e3, positionFiber0D(2)*1e3, fiber_d*1e6, lastSlope));
    
    



end

