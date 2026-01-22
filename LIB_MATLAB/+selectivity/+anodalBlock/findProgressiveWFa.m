function findProgressiveWFa(hasToFindCurrent1)
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
    I0                          = amp(6:nVarOptim+5)*current1;
 
    % configure optimzation
    options = psoptimset('PlotFcn',{@psplotbestf, @psplotmeshsize, @psplotfuncount, @psplotbestx} , 'Display', 'iter', 'TolX', TolX, 'MaxMeshSize', MaxMeshSize, 'MeshContraction', MeshContraction, 'MeshExpansion', MeshExpansion);

   
    

    % adapted function for optimizing procedure (function must depend only
    % of parameters to optimize). 
    costFindProgressiveWFSimplified = @(I) costFindProgressiveWFa(cible, I, times, amp);
    
    % Constraints 
    % next amp value must be higher than previous one
    A   = zeros(nVarOptim);
    Aindice1        = 1:nVarOptim+1:nVarOptim*(nVarOptim-1);
    Aindice_1       = 2:nVarOptim+1:nVarOptim*(nVarOptim-1);
    A(Aindice1)     = 1;
    A(Aindice_1)    = -1;
    A               = A';
    b               = zeros(nVarOptim,1);
    
    % There is no non-linear constraint
    Aeq = [];
    beq = [];
    
    % Min and Max values for parameters. 
    lb = zeros(1,numel(I0));            % does not accept a negative current
    ub = ones(1,numel(I0))*10e-3;       % Not more than 10 mA.
    
    % run optimzer procedure. 
    solution = patternsearch(costFindProgressiveWFSimplified,I0,A,b,Aeq,beq,lb,ub,[],options);
    save('result.mat', 'amp', 'times', 'solution', 'I0', 'cible');

end

