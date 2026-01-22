function parametersTwoRings()
    import selectivity.utilities.*

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %           paramètres NON modifiable !              %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nerveD              = 1.9e-3;
    fascicleD           = 400e-6;
    fasciculeLayer      = 50e-6; %aucune importance, le perineurium fait 5% du diamètre (Deurloo2004 ?)
    sigmaSaline         = 2;
    sigmaEpineurium     = 0.008;
    sigmaPerineurium    = 0.00336;
    sigmaFasciculexy    = 0.08;
    sigmaFasciculez     = 0.5;
    sigmaConjonctive    = 0.16;
    nerveL              = 40e-3;
    ringTorusD          = 30e-6;
    ringCuffD           = nerveD*1.5;
    courant             = 1; %A, régle de trois pour le courant réel. 


    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %           paramètres modifiables !                 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    sigmaEXT = sigmaConjonctive;                % conductivité externe à la fibre dans la cuff. 

    %Paramètres du modèle modifiable depuis ce script (COMSOL)
    ring1D          = 1.95e-3;                  % [m] diamètre de l'anneau 1.
    ring2D          = 2.6e-3;                   % [m] diamètre de l'anneau 2.
    ringD           = 2e-3;                     % [m] distance entre les deux anneaux. 
    cuffL           = 2.2e-3;                     % [m]longueur de la cuff (isolant) 
   
    % computing parameter for parallel loop
    nProc           = 6;                        % Nombre de processeurs dispo sur la machine
    
    %Paramètres du script modifiable qui n'intervient que dans le calcul des AP
    %(MATLAB)
    fibre_d         = 5e-6;                     % [m] diamètre de la fibre
    courant_relatif = 100e-3;                   % [A] 0.2e-4

    %densité des sondes dans chacun des fascicules sont donnés sous la forme
    %suivante: Une sonde au centre de la fascicule. Ensuite, position sur des cercles concentriques.
    %(nCouche) représente le nombre de couches voulues (nombre de cercles). 
    %(nInit) représente le nombre de points sur le premier cercle. Ensuite sur
    %les cercles suivants, la densité de point est identique à la première
    %(même longueur d'arc de cercle entre les points.
    nCouche         = 3;
    nInit           = 4;

    %Fonctions appelées
    %Modèle COMSOL
    % Parmi les choix suivants :
    % - fasciclesDeurloo
    % - fasciclesDeurlooCylinderElectrode
    % - fasciclesDeurlooParaboleAnode
    comsolModel     = @twoRings; 



    %Nombre de tests effectués pour chaque diamètre de fibre de décalage du
    %noeuds centrale de part et d'autre -> NTotalDeShift = nNodeShift*2 + 1
    %               nNodeShift   <-...  |   |   0   |   |  ...-> nNodeShift
    nNodeShift      = 0;


    % Temperature in celsius
    TC         = 20;
    
    
    %%Stimulation WaveForm properties
    TPulseGlobal                    = 100e-3;
    TPulsePrepulse                  = 0;
    TPulseSurounding                = 100e-3;
    StartPulseGlobal                = 0;
    StartPulsePrepulse              = 0;
    StartPulseSurounding            = 0;
    TTransition                     = 1e-6;
    AmpPulseGlobal                  = 2.3e-3;
    AmpPulsePrepulse                = 0;
    AmpPulseSurounding              = 0.5e-3;             

    WF                              = stimWaveForm();
    WF.setParameters(TPulseGlobal, TPulsePrepulse, TPulseSurounding, StartPulseGlobal, StartPulsePrepulse, StartPulseSurounding, TTransition, AmpPulseGlobal, AmpPulsePrepulse, AmpPulseSurounding);
    WF.saveParameters();
    save('parameters.mat');
end
