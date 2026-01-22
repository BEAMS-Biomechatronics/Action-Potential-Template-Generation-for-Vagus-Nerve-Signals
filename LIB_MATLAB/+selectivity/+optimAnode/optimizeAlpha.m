function optimizeAlpha()
    %Load package to establish parameters
    import selectivity.comsol.*
    import selectivity.optimAnode.*
    
    parametersParaboleAnode();
    load frogSciatic;    
    save('changeParameters.mat', 'polyShape', 'numberOfFascicles');
    
    parametersParaboleAnode();
    
    %choose the limit for alpha to optimize
    alphaMin = -200;
    alphaMax = -1;
    
    %options du solver
    options = optimoptions('fmincon', 'Diagnostics', 'on', 'Display', 'iter-detailed', 'MaxIter', 100, 'PlotFcns', @optimplotx)%('Display', 'iter', 'InitialMeshSize', 30);
    
    %Recherche de l'optimum
    x = fmincon(@virtualCathodeCostFunction,[(alphaMax+alphaMin)/2], [],[], [], [], [alphaMin], [alphaMax], [], options)
end