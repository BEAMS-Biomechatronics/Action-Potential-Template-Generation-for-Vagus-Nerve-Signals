function fig = drawConfigParaboleAnode()
    import selectivity.utilities.*
    
    fig = figure();

    load parameters.mat
    
    
    
    
    
    % dessin de la cuff
    cuffD = nerveD * 1.5;
    cuffR = cuffD/2;
    
    xCuff = [-cuffL/2 cuffL/2 cuffL/2 -cuffL/2 -cuffL/2];
    yCuff = [-cuffR -cuffR cuffR cuffR -cuffR];
    
    plot(xCuff, yCuff, 'k');
    hold on;
        
    % dessin du nerf
    nerveR = nerveD/2;
    
    x1Nerf = [-nerveL/2 nerveL/2];
    y1Nerf = [nerveR nerveR];
    x2Nerf = [-nerveL/2 nerveL/2];
    y2Nerf = [-nerveR -nerveR];
    
    plot(x1Nerf,y1Nerf, 'k--');
    plot(x2Nerf,y2Nerf, 'k--');
    
    % axe central
    x1Nerf = [-nerveL/2 nerveL/2];
    y1Nerf = [0 0];
    
    plot(x1Nerf,y1Nerf, 'k-.');
       
    %dessin de la cathode
    [xCircle1, yCircle1] = circle([-ringD/2 ring2D/2], ringTorusD*3, 50);
    [xCircle2, yCircle2] = circle([-ringD/2 -ring2D/2], ringTorusD*3, 50);
    
    fill(xCircle1, yCircle1, 'r');
    fill(xCircle2, yCircle2, 'r');
    
    %xlim([-nerveL/2 nerveL/2]);
    axis equal
    %set(gca, 'XLimMode', 'manual', 'YLimMode', 'manual');
    %dessin de l'anode (duplicated from Comsol Model)
    s1 = [0:0.001e-3:0.05e-3];
    s2 = [0:0.1e-3:1.5e-3];
    
    x0 = ringD/2;
    y0 = 0.05e-3 + ring1D/2;
    
    xAnode1 = s2 + x0*ones(1,length(s2));
    yAnode1 = -alphaP*s2.^2 + y0*ones(1,length(s2));
    
    xAnode2 = s2(end)*ones(1,length(s1)) + x0*ones(1,length(s1));
    yAnode2 = -alphaP*s2(end)^2*ones(1,length(s1))+ s1 + y0*ones(1,length(s1));
    
    xAnode3 = s2(end:-1:1) + x0*ones(1,length(s2));
    yAnode3 = -alphaP*s2(end:-1:1).^2 + y0*ones(1,length(s2)) + s1(end)*ones(1,length(s2));
    
    xAnode4 = s2(1)*ones(1,length(s1)) + x0*ones(1,length(s1));
    yAnode4 = -alphaP*s2(1)^2*ones(1,length(s1))+ s1(end:-1:1) + y0*ones(1,length(s1));
    
    xAnode = [xAnode1 xAnode2 xAnode3 xAnode4];
    yAnode = [yAnode1 yAnode2 yAnode3 yAnode4];
    
    fill(xAnode, yAnode, 'r');    
    fill(xAnode, -yAnode, 'r');    
    
    
    
    axis equal
    ylim([-diff(ylim())/2 diff(ylim())/2]);
    
    %% dessin des axes et mesures
    
    
    %NERF
    % nerve limit
    xNerfLineMeasure1 = [-nerveL/2 -nerveL/2];
    yNerfLineMeasure1 = [nerveR nerveR+nerveR];
    
    xNerfLineMeasure2 = [nerveL/2 nerveL/2];
    yNerfLineMeasure2 = [nerveR nerveR+nerveR];
    
    % nerve dimension L
    plot(xNerfLineMeasure1, yNerfLineMeasure1,'k--', xNerfLineMeasure2, yNerfLineMeasure2, 'k--');
    
    % nerve arrow dimension L
    arrowX1 = xyToNormxy(xNerfLineMeasure1(2), 'x');
    arrowX2 = xyToNormxy(xNerfLineMeasure2(2), 'x');
    arrowY1 = xyToNormxy(yNerfLineMeasure1(2), 'y');
    arrowY2 = xyToNormxy(yNerfLineMeasure2(2), 'y');
    annotation('doublearrow', [arrowX1 arrowX2], [arrowY1 arrowY2]);
    
    % nerve box arrow dimension L
    boxW = 0.4;
    boxH = 0.05;
    boxX = (arrowX1 + arrowX2)*(1/3) - boxW/2;
    boxY = (arrowY1 + arrowY2)/2;
    
    textBoxPosition = [boxX boxY boxW boxH];
    testBoxText     = sprintf('%0.1f mm', nerveL*1e3);
    annotation('textbox',textBoxPosition , 'String', testBoxText, 'LineStyle', 'none', 'HorizontalAlignment', 'center');
    
    % nerve arrow dimension R
    arrowX1 = xyToNormxy(-nerveL/4, 'x');
    arrowX2 = xyToNormxy(-nerveL/4, 'x');
    arrowY1 = xyToNormxy(nerveR, 'y');
    arrowY2 = xyToNormxy(0, 'y');
    annotation('arrow', [arrowX2 arrowX1], [arrowY2 arrowY1]);
    
    % nerve box arrow dimension R
    boxW = 0.15;
    boxH = 0.1;
    boxX = (arrowX1 + arrowX2)/2 ;
    boxY = (arrowY1 + arrowY2)/2 - boxH/2;
    
    textBoxPosition = [boxX boxY boxW boxH];
    testBoxText     = sprintf('%0.1f mm', nerveR*1e3);
    annotation('textbox',textBoxPosition , 'String', testBoxText, 'LineStyle', 'none', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');
    
    %  between ring distance limit
    xNerfLineMeasure1 = [-ringD/2 -ringD/2];
    yNerfLineMeasure1 = [ring2D/2 ring2D/2+ring2D];
    
    xNerfLineMeasure2 = [ringD/2 ringD/2];
    yNerfLineMeasure2 = [ring1D/2 ring2D/2+ring2D];
    
    %  between ring distance limit
    plot(xNerfLineMeasure1, yNerfLineMeasure1,'k-.', xNerfLineMeasure2, yNerfLineMeasure2, 'k-.');
    
    % between ring distance arrow 
    arrowX1 = xyToNormxy(xNerfLineMeasure1(2), 'x');
    arrowX2 = xyToNormxy(xNerfLineMeasure2(2), 'x');
    arrowY1 = xyToNormxy(yNerfLineMeasure1(2), 'y');
    arrowY2 = xyToNormxy(yNerfLineMeasure2(2), 'y');
    annotation('doublearrow', [arrowX1 arrowX2], [arrowY1 arrowY2]);
    
    % between ring distance arrow 
    boxW = 0.4;
    boxH = 0.05;
    boxX = (arrowX1 + arrowX2)/2 - boxW/2;
    boxY = (arrowY1 + arrowY2)/2 + boxH/2;
    
    textBoxPosition = [boxX boxY boxW boxH];
    testBoxText     = sprintf('%0.1f mm', ringD*1e3);
    annotation('textbox',textBoxPosition , 'String', testBoxText, 'LineStyle', 'none', 'HorizontalAlignment', 'center');
    
    % cuff arrow dimension R
    arrowX1 = xyToNormxy(nerveL/4, 'x');
    arrowX2 = xyToNormxy(nerveL/4, 'x');
    arrowY1 = xyToNormxy(cuffR, 'y');
    arrowY2 = xyToNormxy(0, 'y');
    annotation('arrow', [arrowX2 arrowX1], [arrowY2 arrowY1]);
    
    % cuff box arrow dimension R
    boxW = 0.15;
    boxH = 0.1;
    boxX = (arrowX1 + arrowX2)/2 ;
    boxY = (arrowY1 + arrowY2)/2 - boxH/2;
    
    textBoxPosition = [boxX boxY boxW boxH];
    testBoxText     = sprintf('%0.1f mm', cuffR*1e3);
    annotation('textbox',textBoxPosition , 'String', testBoxText, 'LineStyle', 'none', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');
    
    
    
    
    % cuff limit
    xNerfLineMeasure1 = [-cuffL/2 -cuffL/2];
    yNerfLineMeasure1 = [0 -cuffR-cuffR];
    
    xNerfLineMeasure2 = [cuffL/2 cuffL/2];
    yNerfLineMeasure2 = [0 -cuffR-cuffR];
    
    % cuff dimension L
    plot(xNerfLineMeasure1, yNerfLineMeasure1,'k--', xNerfLineMeasure2, yNerfLineMeasure2, 'k--');
    
    % cuff arrow dimension L
    arrowX1 = xyToNormxy(xNerfLineMeasure1(2), 'x');
    arrowX2 = xyToNormxy(xNerfLineMeasure2(2), 'x');
    arrowY1 = xyToNormxy(yNerfLineMeasure1(2), 'y');
    arrowY2 = xyToNormxy(yNerfLineMeasure2(2), 'y');
    annotation('doublearrow', [arrowX2 arrowX1], [arrowY2 arrowY1]);
    
    % cuff box arrow dimension L
    boxW = 0.4;
    boxH = 0.05;
    boxX = (arrowX1 + arrowX2)*(1/2) - boxW/2;
    boxY = (arrowY1 + arrowY2)/2-boxH;
    
    textBoxPosition = [boxX boxY boxW boxH];
    testBoxText     = sprintf('%0.1f mm', cuffL*1e3);
    annotation('textbox',textBoxPosition , 'String', testBoxText, 'LineStyle', 'none', 'HorizontalAlignment', 'center');
    
    % ring2 (cathode) arrow dimension R
    arrowX1 = xyToNormxy(-ringD/2, 'x');
    arrowX2 = xyToNormxy(-ringD/2, 'x');
    arrowY1 = xyToNormxy(-ring2D/2, 'y');
    arrowY2 = xyToNormxy(0, 'y');
    annotation('arrow', [arrowX2 arrowX1], [arrowY2 arrowY1]);
    
    % ring2 (cathode) box arrow dimension R
    boxW = 0.15;
    boxH = 0.1;
    boxX = (arrowX1 + arrowX2)/2 - boxW;
    boxY = (arrowY1 + arrowY2)/2 - boxH/2;
    
    textBoxPosition = [boxX boxY boxW boxH];
    testBoxText     = sprintf('%0.2f mm', ring2D/2*1e3);
    annotation('textbox',textBoxPosition , 'String', testBoxText, 'LineStyle', 'none', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
    
    
    % parabole (cathode) arrow dimension R
    arrowX1 = xyToNormxy(ringD/2, 'x');
    arrowX2 = xyToNormxy(ringD/2, 'x');
    arrowY1 = xyToNormxy(-ring1D/2, 'y');
    arrowY2 = xyToNormxy(0, 'y');
    annotation('arrow', [arrowX2 arrowX1], [arrowY2 arrowY1]);
    
    % parabole (cathode) box arrow dimension R
    boxW = 0.15;
    boxH = 0.1;
    boxX = (arrowX1 + arrowX2)/2 ;
    boxY = (arrowY1 + arrowY2)/2 - boxH/2;
    
    
    
    
    % alpha arrow dimension L
    textBoxPosition = [boxX boxY boxW boxH];
    testBoxText     = sprintf('%0.2f mm', ring1D/2*1e3);
    annotation('textbox',textBoxPosition , 'String', testBoxText, 'LineStyle', 'none', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');
        
    % alpha arrow dimension L
    arrowX1 = xyToNormxy(nerveL/4, 'x');
    arrowX2 = xyToNormxy(xAnode1(end/2), 'x');
    arrowY1 = xyToNormxy(nerveL/4, 'y');
    arrowY2 = xyToNormxy(yAnode1(end/2), 'y');
    %annotation('doublearrow', [arrowX2 arrowX1], [arrowY2 arrowY1]);
    
    % alpha box arrow dimension L
    boxW = 0.4;
    boxH = 0.05;
    boxX = (arrowX1 + arrowX2)*(1/3) - boxW/2;
    boxY = (arrowY1 + arrowY2)/2-boxH;
    
    textBoxPosition = [boxX boxY boxW boxH];
    testBoxText     = sprintf('alpha = %0.1f', alphaP);
    annotation('textarrow',[arrowX1 arrowX2],[arrowY1 arrowY2] , 'String', testBoxText,  'HorizontalAlignment', 'center');
    
    
end