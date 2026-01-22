function [simFibre1, simFibre2] = AFvsCompleteModelvsPassiveModel() 
    import selectivity.comsol.*
    import selectivity.utilities.*

    % Load model parameters
    selectivity.comsol.parametersParaboleAnode();
    load parameters;

    fibreDSeuil     = 5e-6;                     % taille de fibre à exploiter pour le courant seuil.
    save('parameters.mat', 'fibreDSeuil', '-append');
   
    
    % coordinates
    XYZ             = selectivity.utilities.getFiberCoordinates(5e-6, 4, 1, nerveL, 1.95e-3, 400e-6);
    
    % sim fibre one
    position1       = [0 0];
    position2       = [0 nerveD/4 + fascicleD/2 - 1e-6];
    
    courant1        = selectivity.fibreModel.fibre.findCurrent(5e-6, position1, comsolModel, '12');
    courant2        = selectivity.fibreModel.fibre.findCurrent(5e-6, position2, comsolModel, '12');
    
    modelFEM        = comsolModel();
    Ve              = getExternalVoltage(modelFEM, XYZ);
    
    Ve1             = squeeze(Ve(1,ceil(end/2), :));
    Ve2             = squeeze(Ve(2,end, :));
    
    % simultation one fibre
    simFibre1       = selectivity.anodalBlock.simOneFiber(5e-6, WF, courant1, position1, 1);
    simFibre2       = selectivity.anodalBlock.simOneFiber(5e-6, WF, courant2, position2, 1);
    
    %
    simFibre1.solve(Ve1');
    simFibre2.solve(Ve2');
    
    
    
    

end