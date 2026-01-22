function [z, Vzz, Ve] = getActivatingFunctionFromCoordinates(model, fiberD, XY)
% [z,Vzz] = getActivatingFunctionFromCoordinates(model, fiberD, XY)
% send back the basic activating function and the coordinates of the
% corrensponding nodes.


    import selectivity.comsol.*
    import selectivity.utilities.*
    import selectivity.activatingFunction.*
    import selectivity.fibreModel.fibre.*
    import com.comsol.model.*
    import com.comsol.model.util.*

  
    % Load the variables now if made any change.
    load('parameters.mat');

    % Coordinates
    nFibreLayerPerFasicle       = 5;
        
   
    fig                         = figure();

   
    
    % calcul de la longueur internodale à partie de fiberD
    internodalLengthFiber       = fibre(fiberD,1,[0],20, 0, 0);
    lInternodal                 = internodalLengthFiber.L;
    % nombre de noeuds sur la longueur de la fibre
    nNoeuds                     = floor((nerveL-lInternodal)/lInternodal)+1-2;
           
    

    % Stock the values of virtual Cathode activating function
    z                           = [];
    VzzComplete                 = [];
    Ve                          = [];


    for m = 0:0.1:0.9
        
        
        

        

        %changing node Shift
        nNodeShift              = m;
        XYZ                     = zeros(3,1,1,nNoeuds);
        XYZ(1,1,1,:)            = ones(1,nNoeuds)*XY(1);
        XYZ(2,1,1,:)            = ones(1,nNoeuds)*XY(2);
        XYZ(3,1,1,:)            = ones(1,nNoeuds);
        
        % traitement du cas pair et impair
        numNoeuds = [];
        if mod(nNoeuds,2)==1
            numNoeuds = [ceil(-nNoeuds/2):1:floor(nNoeuds/2)];
        else
            numNoeuds = [round(-nNoeuds/2):1:round(nNoeuds/2-1)];
        end
        
        %Z, fibre 1,2
        XYZ(3,1,1,:) = [numNoeuds * lInternodal + nNodeShift*lInternodal*ones(1,nNoeuds)]; 
       
        % Let's start with simulation
        % Parameters of the simulation are extracted from parameters.mat
        % and model is solved directly.

        VeTemp                      = getExternalVoltage(model, XYZ);
        %keep values of z
        zTemp                       = squeeze(XYZ(3,1,1,:));
        z                           = [z; zTemp(2:end-1)];

        % find Ve2z discrete for central fiber and external fiber
        VzzTemp           = getActivatingFunction(squeeze(VeTemp(1,1,:)));

        %keep values of Ve2z discrete for central fiber and external fiber
        VzzComplete                 = [VzzComplete; VzzTemp];
        Ve                          = [Ve; squeeze(VeTemp(2:end-1))];
      
    end

    % sort the data due to nodeShift mess up 
    size(z)
    size(VzzComplete)
    size(Ve)
    
    [z, sortIndex]              = sort(z);
    Vzz                         = VzzComplete(sortIndex);
    Ve                          = Ve(sortIndex);




end