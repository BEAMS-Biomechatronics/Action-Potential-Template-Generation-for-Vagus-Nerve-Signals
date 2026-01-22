function courant = findCurrent(fiber_d, position, varargin)
    %findCurrent(fiber_d, position, [comsolModel], [transitionType], [nodeShift], [solved?])
    %   
    %   * fiber_d = diamètre de l'axone
    %       La fonction cherche le courrant à appliquer pour que la fibre de
    %   * position = [x y]
    %   * comsolModel (handle ou objet déjà résolu)
    %   * typeTransition = 
    %                   - '12'
    %                   - '23'
    %                   - '34'
    %   * nodeShift : proportion of fiber length shift
    %   * solved ? ['alreadySolved' | 'notSolved' ] 
    
    import selectivity.fibreModel.fibre.*
    import selectivity.stimWaveForm.*
    import selectivity.anodalBlock.*
    import com.comsol.model.*
    import com.comsol.model.util.*
    
    % Do not use Local MPI
    distcomp.feature( 'LocalUseMpiexec', false )
    
    %paramètres à ne pas modifier
    load parameters
    
    % optional varagin treatement
    % default 2-3 (no argument)
    transitionType  = '23';
    nodeShift       = 0;
    modelC          = [];
    
    if nargin == 3
        % by default the model has not been solved, function to initiate it
        % and run it must be send as argument.
        modelC = varargin{1}();
    elseif nargin == 4
        modelC          = varargin{1};
        transitionType  = varargin{2};
    elseif nargin == 5
        modelC          = varargin{1};
        transitionType  = varargin{2};
        nodeShift       = varargin{3};
        
    elseif nargin == 6
        % solving management
        solved          = varargin{4};
        if strcmp(solved, 'alreadySolved')
            modelC          = varargin{1};
        else
            modelC          = varargin{1}();
        end
        
        transitionType  = varargin{2};
        nodeShift       = varargin{3};
    end
    
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %           paramètres modifiables !                 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Paramètres du script modifiable qui n'intervient que dans le calcul des AP
    %(MATLAB)
    relTol = 10e-6;
    

    %% MODELE FIBRE MATLAB

    %calcul du nombre de noeuds nécessaire
    %Couvrir toute la longueur du modèle
    fibreTest           = fibre(fiber_d,1,20);
    
    LFibre              = fibreTest.L;
    
    % nombre de noeuds sur la longueur de la fibre
    nNoeuds = floor((nerveL-LFibre)/LFibre)+1-2;
        
    
   
    % intial current range into which to look for
    courantInterInit = [0 0.015]; %V
    
   
    %% Model COMSOL
    
    %coordonnées à rechercher
    xF = ones(1,nNoeuds)*position(1);  
    yF = ones(1,nNoeuds)*position(2);
    zF=[];
    
    %tensions aux noeuds rapatriés
    
    if mod(nNoeuds,2)==1
        zF = [ceil(-nNoeuds/2):1:floor(nNoeuds/2)]*LFibre + LFibre * nodeShift * ones(1,nNoeuds);
    else
        zF = [round(-nNoeuds/2):1:round(nNoeuds/2-1)]*LFibre + LFibre * nodeShift * ones(1,nNoeuds);
    end
    
    Ve1A = mphinterp(modelC ,'V','coord', [xF; yF; zF],'dataset','dset1');
    %Ve1A
    
    % variable to stock the current range over time
    courantInter = courantInterInit;

    % variable to know the width of the current range
    diff = 1;
    
    % running parallel process manager
    parpool('local',nProc)
    
    % dichotomic method to find the current. 
    
    while diff>relTol
        
        % dichtomic method cut the range into nProc+1 pieces.
        stepCourant                 = (courantInter(2)-courantInter(1))/(nProc+1);
        courantValue                = courantInter(1)+stepCourant:stepCourant:courantInter(2)-stepCourant;

        % WF1 and WF2 must be defined whatever the usage
        % If current2 == 0, WF2 will have no impact.
        WF1Array(1:nProc)           = WF1.copy();
        WF2Array(1:nProc)           = WF2.copy();
        
        current2Array(1:nProc)      = current2;
       
        fibreDArray(1:nProc)        = fiber_d;
        nNoeudsArray(1:nProc)       = nNoeuds;
        
        fAPOrNotAP = zeros(1,nProc);
        parfor k=1:nProc
                fibreInstance   = fibre(fibreDArray(k),nNoeudsArray(k),20, WF1Array(k), WF2Array(k));
                %WF1Array(k).plotWaveForm(0:1e-5:2e-3);
                                
                %Recherche dans le modèle COMSOL du potentiel externe aux
                %noeuds (Ve)
                Ve = Ve1A';


                %Introduction des valeurs de Ve dans le modèle de la fibre.
                fibreInstance   = fibreInstance.setVe(Ve);
                fibreInstance   = fibreInstance.setCurrent([courantValue(k) current2Array(k)]);

                %Résolution du problème d'une fibre soumise à un potentiel Ve
                %aux noeuds. 
                fibreInstance   = fibreInstance.solve();

                %Analyse de la propagation des AP et classification de la fibre dans l'une des 4 catégories.            
                APtracking      = AP();
                APtracking      = APtracking.findAP(fibreInstance.solution(:,1:fibreInstance.n), fibreInstance.time,Ve, fibreInstance.WF1.TPulseGlobal*1.3); % 1.3 rajouté... bof bof

                %Sauvegarde
                if      strcmp('12', transitionType) == 1
                    fAPOrNotAP(k)   = (APtracking.type==2||APtracking.type==3||APtracking.type==4||APtracking.type==5)*1;
                elseif  strcmp('23', transitionType) == 1
                    fAPOrNotAP(k)   = (APtracking.type==3||APtracking.type==4||APtracking.type==5)*1;
                elseif  strcmp('34', transitionType) == 1
                    fAPOrNotAP(k)   = (APtracking.type==4||APtracking.type==5)*1;
                end

              
        end
        fAPOrNotAP          = [0 fAPOrNotAP 1];
        courantValue        = [courantInter(1) courantValue courantInter(2)];
        courantTransition23 = find(fAPOrNotAP==1);
        newLeft             = courantValue(courantTransition23(1)-1);
        newRight            = courantValue(courantTransition23(1));
        courantInter        = [newLeft newRight];
        display(sprintf('L intervale est le suivant : [%f %f]',courantInter(1), courantInter(2)));
        diff                = newRight-newLeft;
        display(['convergence findCurrent : ' num2str(diff)]);
        
    end
    delete(gcp);

    courant = courantInter(2);
    display(sprintf('Le courrant nécessaire pour activer la fibre à la position [%2.2f %2.2f] mm est de %2.2f mA \n pour la fibre de dimension : %2.2f µm', position(1)*1e3, position(2)*1e3, courant*1e3, fiber_d*1e6));
    
    
end