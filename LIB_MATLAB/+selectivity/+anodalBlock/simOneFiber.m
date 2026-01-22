classdef simOneFiber < handle
    
    properties
        fibreInstance;
        APInstance;
        WF;
        positionFiber;
        fiberD;
        comsolModel;
        shift;
        nNoeuds;
        Ve;
        type;
        APtracking;
        current;
        LFibre;
        
    end
    
    methods
        function o = simOneFiber(fiberD, WF, current, varargin)
            % simOneFiber(fiberD, WF, current, [positionFiber[x y], shift])
            
            % import functions from library
            import selectivity.fibreModel.fibre.*
            import selectivity.comsol.*
            import selectivity.stimWaveForm.*
            
            
            % parameters attribution
            o.fiberD            = fiberD;
            
            o.type              = 0;
            o.current           = current;
            
            
            % optional input
            if nargin == 5
                o.positionFiber     = varargin{1};
                o.shift             = varargin{2};
            elseif nargin ~= 3
                error('selectivity:anodalBlock:simOneFiber', 'Wrong input number');
            end
            
            load parameters
            
            %calcul du nombre de noeuds nécessaire
            %Couvrir toute la longueur du modèle
            fibreTest           = fibre(o.fiberD,1,20);
            o.LFibre            = fibreTest.L;
            
            % nombre de noeuds sur la longueur de la fibre
            o.nNoeuds           = floor((nerveL-o.LFibre)/o.LFibre)+1-2;
            
            % wave Form
            o.WF                = WF;
     
        end
        
        function nNode = getNumberOfNode(o)
            nNode = o.nNoeuds;
        end
            
        
        function solve(o, varargin)
            % solve([Ve])
            % If Ve si not given as input argument, a comsol Model with
            % paraters based on parameters.mat is used. 
            % If there is no parameters.mat file in the current folder, you
            % should create it with
            % selectivity.comsol.parametersParaboleAnode.m first. 
            % Note also that when you create an instance of this class, if
            % you use cosmol model, you should have passed as arguments : 
            % [positionFiber[x y], shift].
            
            % import functions from library
            import selectivity.fibreModel.fibre.*
            import selectivity.comsol.*
            import selectivity.stimWaveForm.*
            import selectivity.anodalBlock.*
            
            
            % Load parameters for geometry
            load parameters
            
            o.Ve                = [];
            
            % Separated cases for Ve given as input or Ve computed from
            % Comsol model.
            if nargin == 1
                % call the function initalisating the model and running it
                % once. 
                o.comsolModel       = comsolModel();
                
                %coordonnées à rechercher
                xF                  = ones(1,o.nNoeuds)*o.positionFiber(1);  
                yF                  = ones(1,o.nNoeuds)*o.positionFiber(2);
                zF                  = [];

                %tensions aux noeuds rapatriés
                i=0;
                if mod(o.nNoeuds,2) == 1
                    zF                  = [ceil(-o.nNoeuds/2):1:floor(o.nNoeuds/2)]*o.LFibre;
                else
                    zF                  = [round(-o.nNoeuds/2):1:round(o.nNoeuds/2-1)]*o.LFibre;
                end

                Ve1A                = mphinterp(o.comsolModel ,'V','coord', [xF; yF; zF],'dataset','dset1');
          
                %Recherche dans le modèle COMSOL du potentiel externe aux
                %noeuds (Ve)
                o.Ve                = Ve1A';

            elseif nargin == 2
                o.Ve                = varargin{1};
            else
                error('selectivity:anodalBlock:simOneFiber', 'Too many input arguments');
            end
            

            
            
            % final fiber model
            o.fibreInstance     = fibre(o.fiberD ,o.nNoeuds,20,o.WF(1), o.WF(2));
            
            
            
            
            %Introduction des valeurs de Ve dans le modèle de la fibre.
            o.fibreInstance     = o.fibreInstance.setVe(o.Ve);
            o.fibreInstance     = o.fibreInstance.setCurrent(o.current);

            %Résolution du problème d'une fibre soumise à un potentiel Ve
            %aux noeuds. 
            o.fibreInstance     = o.fibreInstance.solve();

            %Analyse de la propagation des AP et classification de la fibre dans l'une des 4 catégories.            
            o.APtracking        = AP();
            o.APtracking        = o.APtracking.findAP(o.fibreInstance.solution(:,1:o.fibreInstance.n), o.fibreInstance.time, o.Ve');
            
            o.type              = o.APtracking.type;
        end
        
        
        function fig = plotBaton(o,timeDivision)
            fig = o.fibreInstance.plotBaton(timeDivision);
        end
            
        
    end
end