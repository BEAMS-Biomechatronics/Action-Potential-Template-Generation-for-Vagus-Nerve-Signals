function generateDataForDetectActivationWithShift(resultDirectory)
    
    % load result from the given folder
    load([resultDirectory '/parameters.mat']);
    
    % load parametersChange (this is usefull if you want to change some
    % parameters that differ from the resultDirectory such as nPoints1D. 
    load parametersChange
    
    nPoints1D           = 36;
    
    % activate record of Vm and figure
    % (This option is desactivated when using optimisation procedure in
    % order to reduce production of data, this is the reason you may want
    % to produce some specific data). 
    recordVm    = true;
    recordFig   = true;
    
    % save all previous parameters with change made before. 
    save('parametersChange.mat');
    
    % run 
    newFolderResult = selectivity.anodalBlock.detectActivationWithShift('1D');
    
    % analyse data generated (it usefull to see if old result are well
    % reproduced). 
    selectivity.anodalBlock.mapActivationWithShiftTwoColors1D(newFolderResult);            
    
end