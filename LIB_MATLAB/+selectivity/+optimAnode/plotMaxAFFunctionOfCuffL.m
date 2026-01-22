function plotMaxAFFunctionOfCuffL()
% PLOTMAXAFFUNCTIONOFCUFFL
%
% Plot max(d2V/d2z)|(right anode) = f(cuffL)
%
% Résumé de la fonction :
%
%   - boucle sigmaEXT
%   - boucle cuffL [5mm 20mm]
%   - stocker :
%       - les données d2V/d2z pour la fibre centrale et la fibre
%           périphérique
%       - les graphiques
%       - un instantané 2D du résultat COMSOL
%       - les données finales
%   - plot des résultats

    import selectivity.comsol.*
    import selectivity.utilities.*
    import selectivity.activatingFunction.*
    import com.comsol.model.*
    import com.comsol.model.util.*

    % Make parameters.mat default for Parabole Comsol Model
    parametersParaboleAnode();
    % Load default parameters
    load('parameters.mat')

    %parameters of this function
    rangeCuffL          = [5.01e-3:0.01e-3:5.11e-3];
    rangeSigmaExt       = [sigmaSaline; sigmaConjonctive];
    alphaPRange         = [-86.354567; -91.865395];
    rangeFiberD         = [5e-6 7.5e-6 10e-6];

    
    %color for plotting
    colorPlot = ['y', 'c', 'r', 'g', 'b', 'k'];


    % Make some changes in parameters.mat if you don't want the default
    % parameters (defaults can be found in parametersParaboleAnode())
    % Example :
    % cuffL = 10e-3;
    % save('parameters.mat', 'cuffL', '-append');


    % Load the variables now if made any change.
    load('parameters.mat');

    % Coordinates
    fiberD                  = 5e-6;
    nFibreLayerPerFasicle   = 5;
    
    nerveL                  = 2e-2;
    nerveD                  = 2e-3;
    fascicleD               = 0.4e-3;
    
    nerveL                  = 3e-2;
    
    % commit to parameters.mat
    save('parameters.mat', 'fiberD', 'nFibreLayerPerFasicle', 'nNodeShift', 'nerveL', 'nerveD', 'fascicleD', 'nerveL', '-append');
  
    % External voltage extracted from Comsol Model
    
   
   
    
    
        
    for k = 1:length(rangeSigmaExt)
        % figure for this conductivity (sigmaExt)
        % We plot external and central fiber for 3 diameters of fiber
        fig = figure();
        
        % stocking result here
        saveMaxAFFunctionCentral    = zeros(length(rangeFiberD), length(rangeCuffL));
        saveMaxAFFunctionExt        = zeros(length(rangeFiberD), length(rangeCuffL));
        
        for l = 1:length(rangeCuffL)
            for n = 1:length(rangeFiberD)

                %changement des paramètres
                sigmaEXT        = rangeSigmaExt(k);
                alphaP          = alphaPRange(k);
                fiberD          = rangeFiberD(n);
                save('parameters.mat', 'sigmaEXT', 'alphaP', 'fiberD', '-append');



                % Change the parameters of the simulation
                cuffL           = rangeCuffL(l);            
                save('parameters.mat', 'cuffL', '-append');

                %Comsol Model running
                model           = comsolModel();

                % Stock the values of virtual Cathode activating function
                z                           = [];
                VezzCentralFiberComplete    = [];
                VezzExternalFiberComplete   = [];


                for m = 0:0.1:0.9

                    %changing node Shift
                    nNodeShift              = m;
                    XYZ                     = getFiberCoordinates(fiberD, nFibreLayerPerFasicle, nNodeShift, nerveL, nerveD, fascicleD);
                    % Let's start with simulation
                    % Parameters of the simulation are extracted from parameters.mat
                    % and model is solved directly.

                    Ve                          = getExternalVoltage(model, XYZ);
                    %keep values of z
                    zTemp = squeeze(XYZ(3,1,1,:));
                    z = [z; zTemp(2:end-1)];

                    % find Ve2z discrete for central fiber and external fiber
                    VezzCentralFiber            = getActivatingFunction(squeeze(Ve(1,1,:)));
                    VezzExternalFiber           = getActivatingFunction(squeeze(Ve(2,end,:)));

                    %keep values of Ve2z discrete for central fiber and external fiber
                    VezzCentralFiberComplete    = [VezzCentralFiberComplete; VezzCentralFiber];
                    VezzExternalFiberComplete   = [VezzExternalFiberComplete; VezzExternalFiber];


                end

                %TEMP 
                display(size(VezzCentralFiberComplete));
                display(size(z));

                % sort the data due to nodeShift mess up 
                [z, sortIndex]              = sort(z);
                VezzCentralFiberComplete    = VezzCentralFiberComplete(sortIndex);
                VezzExternalFiberComplete   = VezzExternalFiberComplete(sortIndex);

                % find the minimum of activating function -> correspondance with
                % hyperoplarization node.
                [VezzCentralFiberMinValue, VezzCentralFiberMinIndice] =  min(VezzCentralFiberComplete);
                [VezzExternalFiberMinValue, VezzExternalFiberMinIndice] =  min(VezzExternalFiberComplete);

                % normalize Ve2z with reference to min value (! min value is
                % negative)
                VezzCentralFiberNorm            = VezzCentralFiberComplete/-VezzCentralFiberMinValue;
                VezzExternalFiberNorm           = VezzExternalFiberComplete/-VezzExternalFiberMinValue;

                VezzCentralFiberMax             = max(VezzCentralFiberNorm(VezzCentralFiberMinIndice:end));
                VezzExternalFiberMax            = max(VezzExternalFiberNorm(VezzExternalFiberMinIndice:end));
                
                saveMaxAFFunctionCentral(n,l) = VezzCentralFiberMax;
                saveMaxAFFunctionExt(n,l)     = VezzExternalFiberMax;
                
                
                
            end
        end
        
        for n = 1:length(rangeFiberD)
            plot(rangeCuffL*1e3, saveMaxAFFunctionCentral(n,:), colorPlot(n));
            hold on;
            plot(rangeCuffL*1e3, saveMaxAFFunctionExt(n,:), colorPlot(n+3));
        end
        % labels of axis
        xlabel('cuff length [mm]');
        ylabel('Value of virutal cathode activating function normalised [V] (Ven+1 + Ven-1 -2*Ven)');
        
        % title
        typeSolution = [];
        if k==1
            typeSolution = 'solution saline';
        else
            typeSolution = 'tissu conjonctif';
        end
        
        %legend
        legend(['Central Fiber' num2str(rangeFiberD(1)*1e6) ' µm'],['External Fiber' num2str(rangeFiberD(1)*1e6) ' µm'],['Central Fiber' num2str(rangeFiberD(2)*1e6) ' µm'],['External Fiber' num2str(rangeFiberD(2)*1e6) ' µm'],['Central Fiber' num2str(rangeFiberD(3)*1e6) ' µm'],['External Fiber' num2str(rangeFiberD(3)*1e6) ' µm']);
        
        title(['Cuff remplie de ' typeSolution]);

        %save figure
        saveas(fig, typeSolution);

        %save data and figure in a subfolder named string(typeSolution)
        saveData(typeSolution);
    end
end

