function parametersParaboleAnode()
% This function make a parameters.mat file containing the default
% parameters for the paraboleAnodeModel (COMSOL). 
% This funcion should not be changed directly.
% If you want to change a parameter :
% 1) call this function
% 2) load parameters.mat
% 3) Once it has been called juste change in your current code the
% parameters you want to change. 
% If using a function which calls this function, then run a simulation by
% itself. But you want to change parameters automaically. Then you should
% use the other file parametersChange.mat.
% This file is automatically loaded at the end of this function. 
% You just have to save the parameters you want to change in a file called
% 'parametersChange.mat'. 

    import selectivity.utilities.*
    import selectivity.comsol.*
    import selectivity.stimWaveForm.*


    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %           COMSOL MODEL                             %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % nerve
    nerveD              = 1.15e-3;                  %anciennement 1.9e-3
    fascicleD           = 400e-6;                   %anciennement fasciculeD
    fasciculeLayer      = 50e-6;                    %aucune importance, le perineurium fait 5% du diamètre (Deurloo2004 ?)
    nerveL              = 40e-3;
    nerveLComsol        = 40e-3;
%     nerveLComsol        = nerveL; %parameters changed in the main
%     function are loaded at then end of this function, thus, this line has
%     to be set AFTER changing the value of nerveL
    
    %conductivities of medium
    sigmaSaline         = 2;
    sigmaEpineurium     = 0.008;
    sigmaPerineurium    = 0.00336;
    sigmaFasciculexy    = 0.08;
    sigmaFasciculez     = 0.5;
    sigmaConjonctive    = 0.16;
    
    sigmaEXT = sigmaConjonctive;                    % conductivité externe à la fibre dans la cuff. 
    
    % cuff electrode    
    ringTorusD          = 30e-6;                    % ring donut radius
    ringCuffD           = 1.9e-3*1.5;               % cuff D
    ring1D              = 1.95e-3;                  % [m] diamètre de l'anneau 1.
    xRing1D             = 0;
    yRing1D             = 0;
    ring2D              = 2.6e-3;                   % [m] diamètre de l'anneau 2.
    xRing2D             = 0;
    yRing2D             = 0;
    ringD               = 2e-3;                     % [m] distance entre les deux anneaux. 
    cuffL               = 5.1e-3;                   % [m]longueur de la cuff (isolant) 
    alphaP              = -91.865395;               %-86.35;       % -38

    courant             = 1;                        %A, régle de trois pour le courant réel. 
    
    
    
    
    
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %           Various parameters                       %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 
  
    nProc           = feature('numcores');          % Nombre de processeurs dispo sur la machine
    
    
    %Paramètres du script modifiable durant les simulations. 
    %(MATLAB)
    
    fibreD          = 5e-6;                         %[m] diamètre de la fibre, vierge.
    current1        = 0;                            %[A] courant relatif, résultat de find current. Set to 0 if findCurrent must be used to determine it.
    current2        = 0;                            %[A] courant prepulse, if 0 : not used;              0.0021445; 
    shift           = 0;

    %densité des sondes dans chacun des fascicules sont donnés sous la forme
    %suivante: Une sonde au centre de la fascicule. Ensuite, position sur des cercles concentriques.
    %(nCouche) représente le nombre de couches voulues (nombre de cercles). 
    %(nInit) représente le nombre de points sur le premier cercle. Ensuite sur
    %les cercles suivants, la densité de point est identique à la première
    %(même longueur d'arc de cercle entre les points.
    % decaprited
    nFibreLayerPerFasicle         = 3;          %anciennement nCouche
    nFibreFirstLayer              = 4;          %anciennement nInit

    
    % Modèle COMSOL parmi les choix suivants :
    % - paraboleAnode
    % - twoRings
    % - twoPairsTwoRings
    % geometryName is used to save Data.
    
    comsolModel             = @paraboleAnode; 
    geometryName            = 'paraboleAnode';
    listMainProperties      = {'ring1D', 'ring2D', 'ringD', 'cuffL', 'alphaP'};

    % Nombre de niveau de décallage.
    nNodeShift      = 5;                       %10
    
    % Temperature in celsius
    TC                  = 37;

    % Choice of WaveForm 
    % see <selectivity.stimWaveForm.*> for choice available.
    % you can implement your own stimWaveForm by doing a class inheritance 
    % of <selectivity.stimWaveForm.stimWaveForm> abstract class.
    % If current2 = 0, WF2 will have no effect.
    %WF                  = stimWaveFormLinesByPieces();
    WF1                  = stimWaveFormLinesByPieces(1.1e-3,    5e-5,   [[0:1e-4:9e-3]; ones(size([0:1e-4:9e-3]))]);
    %WF2                  = stimWaveFormLinesByPieces(30e-6,     1e-6,   [[0:1e-4:9e-3]; ones(size([0:1e-4:9e-3]))]);
    
    % when running optimization procedure, this variable gives you
    % the oppportunity to keep all data or not. At the end of
    % mapActivationXXX, the data are deleted. 
    recordVm    = false;
    recordFig   = false;
    
    
    %% PARAMETERS FOR OPTIMIZING WF PROCEDURE
    
    % you have the choice to change those parameters in optimxxx.m script
    % OR you can load it from a previous optimizing procedure (load the
    % result.mat file after you have rename it in the form optimxxx.mat). 
    
    % number of parameters to optimize
    nVarOptim   = 5;
    
    % times = [t1 t2 t3 t4 t5 t6 t7 t8], only t3 -> t7 have variables
    % amplitude. 
    times               = [0  0.25e-3   0.4e-3                  0.6e-3                  0.8e-3                  1.2e-3                      1.5e-3                  5e-3];            
    
    % amplitude values for inital guess of optimizing procedure. 
    amp                 = zeros(1,length(times));
    
    % WF1 properties (avoiding anodal break)
    WF1RampTime             = 2.1e-3; %s
    WF1RampDelayOfSlope     = 5e-5;   %s 
    
    
    % optimizer parameters by default
    MaxMeshSize = 2e-3;
    TolX        = 1e-5;
    
    
    % Special optim dichotomie (detectTransition)
    nLevelDicho = 3;
    
    
    % finding current1 if not given
    fibreDSeuil         = 7.5e-6;       %diameter of the fiber for dichotomic research
    
    
    
    %cible 
    cible       = zeros(1,12);
    cible(1:6)  = 1;
    % when using non regular position option, this parameter gives you the
    % opportunity to choose the position of the transition of the target. 
    % In this case, cible must be asymetrical (111 000). 
    positionCible = 0.5;
    
    
    
    %% fascicle geometry (class fascicles)
    % by default, you can use : fasciclesGeometry   = fascicles(nerveD);
    % if you want more realistic shape of fascicles, provide polyShape cell
    % which contains contour of fascicles in the form of contour polygon.
    % see file humanSciatic.mat for example.
    %numberOfFascicles   = 29;
    % load data fascicles : polyShape 
    load('LIB_MATLAB\data\fascicles\frogSciatic.mat'); % frogSciatic, humanSciatic
    
    fasciclesGeometry   = fascicles(nerveD, polyShape, numberOfFascicles, 1);
    epFascicleLayer     = 90e-6; %epaisseur layer fascicle (90µm pour grosse, 50µm petite; ou 5% diamètre fascicule)
    
    % density of points for 2D results
    density2D           = 500/(pi*(nerveD/2)^2);
    
    %  1D Simulation will be running on a line defines by both parameters.
    line1D              = [0 0; nerveD/2 0];            % [x1 y1; x2 y2] line for 1D simulation
    nPoints1D           = 12;
    
    %  0D Simulation will be on the position defined here
    positionFiber0D     = [0 0];
    
    fiberDiam           = [5e-6:1.25e-6:10e-6];
    
    
    if exist('parametersChange.mat', 'file') == 2
        load('parametersChange.mat');
    end
    nerveLComsol        = nerveL;
    save('parameters.mat');
    
end

