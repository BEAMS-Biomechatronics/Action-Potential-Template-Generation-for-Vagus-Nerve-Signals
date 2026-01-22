function xyN = xyToNormxy(XY, type)
    % Conversion from axis coordinates to normalised coordinates [0;1]
    % type is a string with 'x' or 'y' or 'w' (width) or 'h' (height)
    % XY is a vector with two x or two y component
    
    xyN = 0;
    
    xLim = get(gca,'XLim');
    yLim = get(gca,'YLim');
    
    axisPositon = get(gca, 'position');
     
    axisLeft    = axisPositon(1);
    axisBottom  = axisPositon(2);
    axisWidth   = axisPositon(3);
    axisHeight  = axisPositon(4);
    
    xLow    = xLim(1);
    xUp     = xLim(2);
    yLow    = yLim(1);
    yUp     = yLim(2);
    diffX   = xUp-xLow;
    diffY   = yUp-yLow;
    
    if strfind(type, 'x')
        xyN = ((XY-xLow)*axisWidth/diffX)+axisLeft;
    elseif strfind(type, 'y')
        xyN = ((XY-yLow)*axisHeight/diffY)+axisBottom;
    elseif strfind(type, 'w')
        xyN = XY/diffX*axisWidth;
    elseif strfind(type, 'h')
        xyN = XY/diffY*axisHeight;
    else
        error('you did not mention type correctly');
    end
    
  
    
    
end