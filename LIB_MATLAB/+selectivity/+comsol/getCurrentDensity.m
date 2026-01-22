function getCurrentDensity(ComsolFile, modelType)
    %getCurrentDensity(comsolFile, modelType) will give current density
    %  
    % getCurrentDensity(comsolFile, modelType) : 
    % comsolFile is the result of the simulation created by this library
    % and modelTYpe is a string which gives the type of model you are
    % using.
    % For the moment, the only modelType implemented is paraboleAnode.
    % 'paraboleAnode'. 
    
    import com.comsol.model.*
    import com.comsol.model.util.*
    
    model       = mphload([pwd '\COMSOL_VE\' ComsolFile]);
    intModel    = 0;
    
    % classifyig model type
    if strcmp(modelType,'paraboleAnode')
        intModel = 1;
    end
    
    
    % case modelType = 'paraboleAnode'
    if intModel == 1
        
        %Computing max current density in COMSOL
        % MAXIMUM
        model.result.numerical.create('max1', 'MaxVolume');
        model.result.numerical('max1').selection.set([2]);
        model.result.numerical('max1').set('expr', 'ec.normJ');
        model.result.numerical('max1').set('descr', 'Current density norm');
        model.result.table.create('tbl1', 'Table');
        model.result.table('tbl1').comments('Volume Maximum 1 (ec.normJ)');
        model.result.numerical('max1').set('table', 'tbl1');
        model.result.numerical('max1').setResult;
        model.result.numerical('max1').set('dataseries', 'maximum');
        model.result.numerical('max1').set('table', 'tbl1');
        model.result.numerical('max1').appendResult;
        
        
        
        %getting data from COMSOL
        % MAX current density for 1A
        maxTbl  = mphtable(model, 'tbl1');
        max     = maxTbl.data;
        
        % Voltage difference between electrodes for 1 A
        VDiff    = mphglobal(model, {'abs(cir.v_2-cir.v_1)'});
    end

    max = max(1);
    VDiff;
    
    
    %loading parameters from the simulation
    load parameters
    
    Jmoy = current1/pi^2/ringTorusD/ring2D;
    Jmax = max;
    
    display(['la densité de courant moyen à l\prime électrode la plus défavorable pour un courant de ' num2str(current1) ' [A] est de : ' num2str(Jmoy/10) ' [mA/cm²]']); 
    
    
    
    
end