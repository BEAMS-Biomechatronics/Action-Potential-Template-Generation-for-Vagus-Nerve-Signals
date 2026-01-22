function Ve = getExternalVoltage(varargin)
% getExternalVoltage(comsolModel, fiberCoordinates) get External Voltage 
% from Comsol Model.
% Return Ve(numeroDeLaFibre, numeroDuNoeuds)
% To use this function, you have to send the points in the form of an array
% constructed with selectivity.utilities.getFiberCoordinates().
% Input parameters are : 
%   $ comsolModel : the handle to the COMSOL model, loaded into the COMSOL server,
%       and already solved. 
%   $ fiberCoordinates;

    import com.comsol.model.*
    import com.comsol.model.util.*


    if nargin == 2
        comsolModel             = varargin{1};
        XYZ                     = varargin{2};

        % Extraction of coordinates
        xF                      = squeeze(XYZ(1,:,:));
        yF                      = squeeze(XYZ(2,:,:));
        zF                      = squeeze(XYZ(3,:,:));

        VeTemp = mphinterp(comsolModel ,'V','coord', [xF(:), yF(:), zF(:)]','dataset','dset1');
        
         % find nFascile, nFibre, nNoeuds
        sizeXYZ                 = size(XYZ);
        nFibre                  = sizeXYZ(2);
        nNoeuds                 = sizeXYZ(3);
        
        %   Création de la structure du tableau de Ve
        Ve                      = zeros(nFibre, nNoeuds);
        
        %   MphInterp a renvoyé un vecteur avec toutes les tensions, il faut
        %   les remettre en ordre pour respecter la structure du tableau des
        %   coordonnées.
        indice = 1;
        for noeuds = 1:nNoeuds
            for fibre = 1:nFibre
                Ve(fibre, noeuds) = VeTemp(indice);
                indice = indice + 1;                
            end
        end

    else
        error('selectivity:comsol:getExternalVoltage','Wrong number of input parameters');
    end
end

