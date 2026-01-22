function findProgressiveWFexp2(hasToFindCurrent1, coefFit)
    % hasToFindCurrent1 = true | false
    % - true will run algorithm to find current1 able to generate transiton
    % type : '23' at position given by variable 'positionSeuil' for fiber
    % size 'fibreDSeuil'.
    % - false will not run any algorithm and will just take current1 for
    % max of WF1 amplitude (WF1 is responsible for blocking the APs). 
    
    
    import selectivity.anodalBlock.*
    import selectivity.comsol.*
    
    
    
    % update parameters with script values. 
    selectivity.comsol.parametersParaboleAnode();
        
    % loading parameters (default parameters generated in
    % parametersParaboleAnode.m and owverwritten in optimxxx.m script).
    % Do not change parameters here !
    load parameters
    
    
    
    
    %% Pretraetment (optional)
    
    % run simulation with current parameters
    %bestGuessCurrent = solution(end);%selectivity.fibreModel.fibre.findCurrent(fibreDSeuil, positionSeuil, comsolModel);   
    
    if hasToFindCurrent1   
        current1    = selectivity.fibreModel.fibre.findCurrent(fibreDSeuil, positionSeuil, comsolModel);  
    else
        % solution should have been recorded in the optimxxx.m script file
        % if you want to use this option. 
        current1    = solution(end);
    end
        
   
    % Save current1 and update config file
    save('parametersChange.mat', 'current1', '-append');
    selectivity.comsol.parametersParaboleAnode();
    
    
    
    %% optimization procedure
    
    % inital guess = amp * current1
    I0                          = [coefFit];
 
    % configure optimzation
    options = psoptimset('PlotFcn',{@psplotbestf, @psplotmeshsize, @psplotfuncount, @psplotbestx} , 'Display', 'iter', 'TolX', TolX, 'MaxMeshSize', MaxMeshSize, 'MeshContraction', MeshContraction, 'MeshExpansion', MeshExpansion);

   
    

    % adapted function for optimizing procedure (function must depend only
    % of parameters to optimize). 
    costFindProgressiveWFSimplified = @(I) costFindProgressiveWFexp2(cible, I);
    
    % No linear constraints 
    
    A   = [];
    b   = [];
    
    % There is no non-linear constraint
    Aeq = [];
    beq = [];
    
    % Min and Max values for parameters. 
    % No more than 0.2 variation for the normalised curve when changing one
    % of thise parameters
    time = [0.25e-3:1e-6:1.5e-3];
    
    aC           = coefFit(1);
    bC           = coefFit(2);
    cC           = coefFit(3);
    dC           = coefFit(4);
    
    df_da_Max   = max(abs(exp(bC*time)));
    df_db_Max   = max(abs(aC*time.*exp(bC*time)));
    df_dc_Max   = max(abs(exp(dC*time)));
    df_dd_Max   = max(abs(cC*time.*exp(dC*time)));
    
    maxdF       = 0.2;
    
    lb = [I0(1)-maxdF/df_da_Max I0(2)-maxdF/df_db_Max I0(3)-maxdF/df_dc_Max I0(4)-maxdF/df_dd_Max];            % 
    ub = [I0(1)+maxdF/df_da_Max I0(2)+maxdF/df_db_Max I0(3)+maxdF/df_dc_Max I0(4)+maxdF/df_dd_Max];            %
    
    % run optimzer procedure. 
    solution = patternsearch(costFindProgressiveWFSimplified,I0,A,b,Aeq,beq,lb,ub,[],options);
    save('result.mat', 'amp', 'times', 'solution', 'I0', 'cible');

end

