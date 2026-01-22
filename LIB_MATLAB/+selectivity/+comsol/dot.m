function model = dot(currentNodeID, varargin)
%DOT comsol Model for Dot configuration (current sources)
%  currentNodeID give the dot which must be set to 1 ampere. 

    import com.comsol.model.*
    import com.comsol.model.util.*

model = ModelUtil.create(sprintf('ModelDots%04d',currentNodeID));
ModelUtil.showProgress(true);

model.modelPath(pwd);

model.label(sprintf('ModelDots%04d.mph',currentNodeID));

model.comments(['Basis\n\nno Comment']);

load parameters;

I = [];
if nargin == 2
    I = varargin{1};
end


% classical parameters

model.param.set('x0', '0');

model.param.set('nerveD', sprintf('%0.5f[m]',nerveD));
model.param.set('fasciculeD', sprintf('%0.8f[m]',fascicleD));
model.param.set('fasciculeLayer', sprintf('%0.8f[m]',fasciculeLayer));
model.param.set('sigmaSaline',sprintf('%0.10f[S/m]',sigmaSaline));
model.param.set('sigmaEpineurium',sprintf('%0.10f[S/m]',sigmaEpineurium));
model.param.set('sigmaPerineurium',sprintf('%0.10f[S/m]',sigmaPerineurium));
model.param.set('sigmaFasciculexy',sprintf('%0.10f[S/m]',sigmaFasciculexy));
model.param.set('sigmaFasciculez',sprintf('%0.10f[S/m]',sigmaFasciculez));
model.param.set('sigmaEXT',sprintf('%0.10f[m]',sigmaEXT));
model.param.set('ringD', sprintf('%0.6f[m]',ringD));
model.param.set('ringCuffD', sprintf('%0.6f[m]',ringCuffD));

model.param.set('nerveLComsol',sprintf('%0.6f[m]',nerveLComsol));
model.param.set('courant', sprintf('%0.5f[A]',courant));
model.param.set('cuffL', sprintf('%0.6f[m]',cuffL));
model.param.set('LayerBC', '100[mm]');

model.param.set('sigmaConjonctive', sprintf('%0.6f[m]',sigmaConjonctive));
model.param.set('epFascicleLayer', sprintf('%0.6f[m]',epFascicleLayer));

% dots specific parameters
model.param.set('dotsNRevolve', sprintf('%d',dotsNRevolve));
model.param.set('dotsNLongitudinal',sprintf('%d',dotsNLongitudinal));
model.param.set('dotsWidth', sprintf('%0.10f[m]',dotsWidth) , 'theta dimension (dimension !)');
model.param.set('dotsLength', sprintf('%0.10f[m]',dotsLength), 'Longitudinal dimension of dot');
model.param.set('dotsDepth',  sprintf('%0.10f[m]',dotsDepth), 'radial dimension of dot');
model.param.set('dotsOffCenter', sprintf('%0.10f[m]',dotsOffCenter), 'distance of dots and center line of nerve');
model.param.set('dotsAngle', 'dotsWidth/dotsOffCenter', 'radian');
model.param.set('dotsZFirst', sprintf('%0.10f[m]',dotsZFirst));
model.param.set('dotsZLast',  sprintf('%0.10f[m]',dotsZLast));

for i=1:dotsNRevolve*dotsNLongitudinal
    model.param.set(sprintf('I%d',i),  sprintf('%d',0));
end

model.modelNode.create('comp1');

model.geom.create('geom1', 3);

model.mesh.create('mesh1', 'geom1');

model.geom('geom1').selection.create('csel7', 'CumulativeSelection');
model.geom('geom1').selection('csel7').label('ring2Domain');
model.geom('geom1').selection.create('csel8', 'CumulativeSelection');
model.geom('geom1').selection('csel8').label('ring1Domain');


% selections specific to dots
for i = 1:dotsNRevolve*dotsNLongitudinal
    % surface string name (selection)
    % cselDotsSurface0001   -> dotsSurface0001
    stringCSelSurface   = sprintf('cselDotsSurface%04d', i);
    stringdotsSurface   = sprintf('dotsSurface%04d', i);
    % volume string name (selection)
    % cselDotsVolume0001    -> dotsVolume0001
    stringCSelVolume    = sprintf('cselDotsVolume%04d', i); 
    stringdotsVolume    = sprintf('dotsVolume%04d', i);
    
    model.geom('geom1').selection.create(stringCSelSurface, 'CumulativeSelection');
    model.geom('geom1').selection(stringCSelSurface).label(stringdotsSurface);
    model.geom('geom1').selection.create(stringCSelVolume, 'CumulativeSelection');
    model.geom('geom1').selection(stringCSelVolume).label(stringdotsVolume);
end

model.geom('geom1').selection.create('csel3', 'CumulativeSelection');
model.geom('geom1').selection('csel3').label('extBC');
model.geom('geom1').selection.create('csel4', 'CumulativeSelection');
model.geom('geom1').selection('csel4').label('fascicle');
model.geom('geom1').selection.create('csel5', 'CumulativeSelection');
model.geom('geom1').selection('csel5').label('nerveB');
model.geom('geom1').selection.create('csel6', 'CumulativeSelection');
model.geom('geom1').selection('csel6').label('fascicleDomain');
model.geom('geom1').create('cyl1', 'Cylinder');
model.geom('geom1').feature('cyl1').label('nerf');
model.geom('geom1').feature('cyl1').set('r', 'nerveD/2');
model.geom('geom1').feature('cyl1').set('contributeto', 'csel5');
model.geom('geom1').feature('cyl1').set('pos', {'0' '0' '-nerveLComsol/2'});
model.geom('geom1').feature('cyl1').set('selresult', 'on');
model.geom('geom1').feature('cyl1').set('h', 'nerveLComsol');
model.geom('geom1').create('cyl2', 'Cylinder');
model.geom('geom1').feature('cyl2').label('milieu');
model.geom('geom1').feature('cyl2').set('r', 'ringCuffD*1.5');
model.geom('geom1').feature('cyl2').set('layername', {'' '' '' '' ''});
model.geom('geom1').feature('cyl2').set('contributeto', 'csel3');
model.geom('geom1').feature('cyl2').set('layertop', true);
model.geom('geom1').feature('cyl2').set('selresultshow', 'bnd');
model.geom('geom1').feature('cyl2').set('pos', {'0' '0' '-nerveLComsol'});
model.geom('geom1').feature('cyl2').set('selresult', 'on');
model.geom('geom1').feature('cyl2').set('h', 'nerveLComsol*2');
model.geom('geom1').feature('cyl2').set('layerbottom', true);
model.geom('geom1').create('cyl3', 'Cylinder');
model.geom('geom1').feature('cyl3').label('cuff');
model.geom('geom1').feature('cyl3').set('r', 'ringCuffD/2');
model.geom('geom1').feature('cyl3').set('pos', {'0' '0' '-cuffL/2'});
model.geom('geom1').feature('cyl3').set('selresult', 'on');
model.geom('geom1').feature('cyl3').set('h', 'cuffL');
model.geom('geom1').create('wp1', 'WorkPlane');
model.geom('geom1').feature('wp1').set('unite', 'on');
model.geom('geom1').feature('wp1').set('quickz', 'nerveLComsol/2');
model.geom('geom1').feature('wp1').geom.create('pol1', 'Polygon');
model.geom('geom1').feature('wp1').geom.feature('pol1').set('x', '0.00064125  0.00063996  0.00063609  0.00062966   0.0006207  0.00060923  0.00059532    0.000579  0.00056036  0.00053945  0.00051638  0.00049123  0.00046409  0.00043509  0.00040434  0.00037196  0.00033808  0.00030284  0.00026638  0.00022885   0.0001904  0.00015118  0.00011135  7.1075e-05  3.0512e-05 -1.0174e-05 -5.0819e-05 -9.1259e-05 -0.00013133 -0.00017088 -0.00020973 -0.00024774 -0.00028476 -0.00032062  -0.0003552 -0.00038835 -0.00041993 -0.00044982  -0.0004779 -0.00050406 -0.00052818 -0.00055018 -0.00056997 -0.00058745 -0.00060258 -0.00061527 -0.00062549  -0.0006332 -0.00063835 -0.00064093 -0.00064093 -0.00063835  -0.0006332 -0.00062549 -0.00061527 -0.00060258 -0.00058745 -0.00056997 -0.00055018 -0.00052818 -0.00050406  -0.0004779 -0.00044982 -0.00041993 -0.00038835  -0.0003552 -0.00032063 -0.00028476 -0.00024774 -0.00020973 -0.00017088 -0.00013133 -9.1259e-05 -5.0819e-05 -1.0174e-05  3.0512e-05  7.1075e-05  0.00011135  0.00015118   0.0001904  0.00022885  0.00026638  0.00030284  0.00033808  0.00037196  0.00040434  0.00043509  0.00046409  0.00049123  0.00051638  0.00053945  0.00056036    0.000579  0.00059532  0.00060923   0.0006207  0.00062966  0.00063609  0.00063996  0.00064125');
model.geom('geom1').feature('wp1').geom.feature('pol1').set('y', '-1.3799e-20  4.0671e-05  8.1177e-05  0.00012136  0.00016105  0.00020009  0.00023833  0.00027561  0.00031177  0.00034669   0.0003802  0.00041219  0.00044251  0.00047106   0.0004977  0.00052235  0.00054489  0.00056523   0.0005833  0.00059902  0.00061233  0.00062317  0.00063151   0.0006373  0.00064052  0.00064117  0.00063923  0.00063472  0.00062766  0.00061806  0.00060598  0.00059146  0.00057456  0.00055534  0.00053389  0.00051028  0.00048462  0.00045702  0.00042757  0.00039639  0.00036363   0.0003294  0.00029384   0.0002571  0.00021932  0.00018066  0.00014127  0.00010132  6.0955e-05  2.0346e-05 -2.0346e-05 -6.0955e-05 -0.00010132 -0.00014127 -0.00018066 -0.00021932  -0.0002571 -0.00029384  -0.0003294 -0.00036363 -0.00039639 -0.00042757 -0.00045702 -0.00048462 -0.00051028 -0.00053389 -0.00055534 -0.00057456 -0.00059146 -0.00060598 -0.00061806 -0.00062766 -0.00063472 -0.00063923 -0.00064117 -0.00064052  -0.0006373 -0.00063151 -0.00062317 -0.00061233 -0.00059902  -0.0005833 -0.00056523 -0.00054489 -0.00052235  -0.0004977 -0.00047106 -0.00044251 -0.00041219  -0.0003802 -0.00034669 -0.00031177 -0.00027561 -0.00023833 -0.00020009 -0.00016105 -0.00012136 -8.1177e-05 -4.0671e-05 -1.7086e-19');
model.geom('geom1').create('ext1', 'Extrude');
model.geom('geom1').feature('ext1').set('contributeto', 'csel4');
model.geom('geom1').feature('ext1').set('selresult', 'on');
model.geom('geom1').feature('ext1').set('reverse', true);
model.geom('geom1').feature('ext1').set('selresultshow', 'all');
model.geom('geom1').feature('ext1').setIndex('distance', 'nerveLComsol', 0);
model.geom('geom1').feature('ext1').selection('input').set({'wp1'});


% creation of Dots
for l=1:dotsNLongitudinal
    for k=1:dotsNRevolve
        
        % string name to refer to
        % ==========================================
        indiceDot           = (l-1)*dotsNRevolve + k;
        % surface string name (selection)
        % cselDotsSurface0001   -> dotsSurface0001
        stringCSelSurface   = sprintf('cselDotsSurface%04d', indiceDot);
        stringdotsSurface   = sprintf('dotsPSurface%04d', indiceDot);
        
        % volume string name (selection)
        % cselDotsVolume0001    -> dotsVolume0001
        stringCSelVolume    = sprintf('cselDotsVolume%04d', indiceDot); 
        stringdotsVolume    = sprintf('dotsVolume%04d', indiceDot);
        
        % parametric surface ID
        stringPS            = sprintf('ps%04d', indiceDot);
        stringRev           = sprintf('rev%04d', indiceDot);
        % ==========================================
        
        
        model.geom('geom1').create(stringPS, 'ParametricSurface');
        model.geom('geom1').feature(stringPS).label(stringdotsSurface);
        model.geom('geom1').feature(stringPS).set('selresult', 'on');
        model.geom('geom1').feature(stringPS).set('contributeto', stringCSelSurface);
        model.geom('geom1').feature(stringPS).set('coord', {'s1' '0' 's2'});
        model.geom('geom1').feature(stringPS).set('parmin1', '-dotsLength/2');
        model.geom('geom1').feature(stringPS).set('pos', {sprintf('dotsOffCenter*cos(2*pi/dotsNRevolve*(%d-1))', k) sprintf('dotsOffCenter*sin(2*pi/dotsNRevolve*(%d-1))',k) sprintf('dotsZFirst+(%d-1)*(dotsZLast-dotsZFirst)/dotsNLongitudinal',l)});
        model.geom('geom1').feature(stringPS).set('parmin2', '-dotsDepth/2');
        model.geom('geom1').feature(stringPS).set('parmax1', 'dotsLength/2');
        model.geom('geom1').feature(stringPS).set('parmax2', 'dotsDepth/2');
        model.geom('geom1').feature(stringPS).set('rot', sprintf('360*(2*pi*(%d-1)/dotsNRevolve)/(2*pi)', k));
        model.geom('geom1').create(stringRev, 'Revolve');
        model.geom('geom1').feature(stringRev).set('selresult', 'on');
        model.geom('geom1').feature(stringRev).set('contributeto', stringCSelVolume);
        model.geom('geom1').feature(stringRev).set('revolvefrom', 'faces');
        model.geom('geom1').feature(stringRev).set('selresultshow', 'all');
        model.geom('geom1').feature(stringRev).set('axis3', {'0' '0' '1'});
        model.geom('geom1').feature(stringRev).set('angle2', '360/(2*pi)*dotsAngle');
        model.geom('geom1').feature(stringRev).set('axistype', '3d');
        model.geom('geom1').feature(stringRev).selection('inputface').named(stringPS);
    end
end



model.geom('geom1').create('ballsel1', 'BallSelection');
model.geom('geom1').feature('ballsel1').label('AllDomain');
model.geom('geom1').feature('ballsel1').set('r', '1');
model.geom('geom1').feature('ballsel1').set('condition', 'inside');
model.geom('geom1').create('intsel1', 'IntersectionSelection');
model.geom('geom1').feature('intsel1').set('entitydim', '2');
model.geom('geom1').feature('intsel1').label('NerveFascicleIntersection');
model.geom('geom1').feature('intsel1').set('input', {'csel5' 'csel4'});
model.geom('geom1').create('difsel1', 'DifferenceSelection');
model.geom('geom1').feature('difsel1').set('entitydim', '2');
model.geom('geom1').feature('difsel1').label('fasciclePeripheralB');
model.geom('geom1').feature('difsel1').set('add', {'csel4'});
model.geom('geom1').feature('difsel1').set('subtract', {'intsel1'});
model.geom('geom1').create('difsel3', 'DifferenceSelection');
model.geom('geom1').feature('difsel3').label('NerfWithoutFascicles');
model.geom('geom1').feature('difsel3').set('add', {'cyl1'});
model.geom('geom1').feature('difsel3').set('subtract', {'csel4'});
model.geom('geom1').create('ballsel2', 'BallSelection');
model.geom('geom1').feature('ballsel2').set('entitydim', '2');
model.geom('geom1').feature('ballsel2').label('cuffSurfacePeiphery');
model.geom('geom1').feature('ballsel2').set('r', '0.1[mm]');
model.geom('geom1').feature('ballsel2').set('groupcontang', true);
model.geom('geom1').feature('ballsel2').set('posx', 'ringCuffD/2');



% creation of Domain excluding inside of dots (difference selection)
model.geom('geom1').create('difsel2', 'DifferenceSelection');
model.geom('geom1').feature('difsel2').label('RealDomain');
model.geom('geom1').feature('difsel2').set('add', {'ballsel1'});


% substraction of individual dots domains
arraySelectionToSubstract           = {};
for i=1:dotsNRevolve*dotsNLongitudinal
    % selection name
    stringCSelVolume                = sprintf('cselDotsVolume%04d', i); 
    arraySelectionToSubstract       = {arraySelectionToSubstract{:} stringCSelVolume};
end


% substraction of the global domain
model.geom('geom1').feature('difsel2').set('subtract', arraySelectionToSubstract);    
   
model.geom('geom1').run;




model.view.create('view3', 2);

model.material.create('mat4', 'Common', 'comp1');
model.material.create('mat3', 'Common', 'comp1');
model.material.create('mat1', 'Common', 'comp1');
model.material.create('mat2', 'Common', 'comp1');
model.material.create('mat5', 'Common', 'comp1');
model.material('mat3').selection.named('geom1_cyl3_dom');
model.material('mat1').selection.named('geom1_cyl1_dom');
model.material('mat2').selection.named('geom1_csel4_dom');
model.material('mat5').selection.named('geom1_difsel1');

model.physics.create('ec', 'ConductiveMedia', 'geom1');
model.physics('ec').selection.named('geom1_difsel2');
model.physics('ec').create('ci1', 'ContactImpedance', 2);
model.physics('ec').feature('ci1').selection.named('geom1_difsel1');
model.physics('ec').create('dimp1', 'DistributedImpedance', 2);
model.physics('ec').feature('dimp1').selection.named('geom1_csel3_bnd');

model.physics('ec').create('ein2', 'ElectricInsulation', 2);
model.physics('ec').feature('ein2').selection.named('geom1_ballsel2');
model.physics.create('cir', 'Circuit', 'geom1');

% terminal and circuit associated with dots

for i=1:dotsNRevolve*dotsNLongitudinal
    % string names
    stringDotsTerminal      = sprintf('term%d', i);
    stringCSelVolume        = sprintf('cselDotsVolume%04d', i); 
    stringCurrentSource     = sprintf('I%04d', i);
    stringCurrentSourceName = sprintf('IvsU%04d', i);
    
    % circuit & terminal
    model.physics('ec').create(stringDotsTerminal, 'Terminal', 2);
    model.physics('ec').feature(stringDotsTerminal).selection.named('geom1_cselDotsVolume0001_bnd');
    model.physics('ec').feature(stringDotsTerminal).selection.named(['geom1_' stringCSelVolume '_bnd']);
    
    model.physics('cir').create(stringCurrentSource, 'CurrentSourceCircuit', -1);
    model.physics('cir').create(stringCurrentSourceName, 'ModelDeviceIV', -1);
    
    model.physics('ec').feature(stringDotsTerminal).set('TerminalName', sprintf('%d',i));
    model.physics('ec').feature(stringDotsTerminal).set('TerminalType', 'Circuit');
    model.physics('ec').feature(stringDotsTerminal).label(sprintf('Terminal %d',i));
end

model.mesh('mesh1').create('ftet1', 'FreeTet');

model.result.table.create('evl3', 'Table');

model.view('view1').set('scenelight', 'off');
model.view('view3').axis.set('ymin', '-0.5677165985107422');
model.view('view3').axis.set('xmax', '1.261846899986267');
model.view('view3').axis.set('xmin', '-1.261846899986267');
model.view('view3').axis.set('ymax', '1.5677165985107422');

model.material('mat4').label('Saline');
model.material('mat4').propertyGroup('def').set('electricconductivity', {'sigmaSaline' '0' '0' '0' 'sigmaSaline' '0' '0' '0' 'sigmaSaline'});
model.material('mat4').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat3').label('conjonctiveTissue');
model.material('mat3').propertyGroup('def').set('electricconductivity', {'sigmaEXT' '0' '0' '0' 'sigmaEXT' '0' '0' '0' 'sigmaEXT'});
model.material('mat3').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat1').label('epineurium');
model.material('mat1').propertyGroup('def').set('electricconductivity', {'sigmaEpineurium' '0' '0' '0' 'sigmaEpineurium' '0' '0' '0' 'sigmaEpineurium'});
model.material('mat1').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat2').label('fascicle');
model.material('mat2').propertyGroup('def').set('electricconductivity', {'sigmaFasciculexy' '0' '0' '0' 'sigmaFasciculexy' '0' '0' '0' 'sigmaFasciculez'});
model.material('mat2').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat5').label('perineurium');
model.material('mat5').propertyGroup('def').set('electricconductivity', {'sigmaPerineurium' '0' '0' '0' 'sigmaPerineurium' '0' '0' '0' 'sigmaPerineurium'});
model.material('mat5').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});

model.physics('ec').feature('ci1').set('ds', 'epFascicleLayer');
model.physics('ec').feature('dimp1').set('ds', 'LayerBC');
model.physics('ec').feature('dimp1').set('sigmabnd_mat', 'userdef');
model.physics('ec').feature('dimp1').set('sigmabnd', 'sigmaConjonctive');
model.physics('ec').feature('dimp1').set('epsilonrbnd_mat', 'userdef');



% circuit design
for i=1:dotsNRevolve*dotsNLongitudinal
    
    % string names
    stringCurrentSource     = sprintf('I%04d', i);
    stringCurrentSourceName = sprintf('IvsU%04d', i);
    
    % circuit properties
    model.physics('cir').prop('CircuitSettings').set('CreateNodes', '1'); %nodes are associatetd with numbers (0(masse),1,2,3,..)
    model.physics('cir').feature(stringCurrentSource).set('Connections', {'0'; sprintf('%d',i)});
    model.physics('cir').feature(stringCurrentSource).set('value', sprintf('I%d',i)); % changer 'courant' à Ix
    model.physics('cir').feature(stringCurrentSourceName).set('V_src', sprintf('root.comp1.ec.V0_%d',i)); %V0_X 
    model.physics('cir').feature(stringCurrentSourceName).set('Connections', {sprintf('%d',i); '0'});
end

model.mesh('mesh1').feature('size').set('hauto', 3);
model.mesh('mesh1').feature('size').set('custom', 'on');
model.mesh('mesh1').feature('size').set('hmin', '0.5E-4');
model.mesh('mesh1').run;

model.result.table('evl3').label('Evaluation 3D');
model.result.table('evl3').comments('Interactive 3D values');

%generating one study because loop was asking too much memory for XXX
%studies in one mph file.

    i = 1;
    
    % normal case
    model.param.set(sprintf('I%d',currentNodeID),  sprintf('%d',1));
    if nargin == 2
        for k=1:numel(I)
            model.param.set(sprintf('I%d',k),  sprintf('%0.15f',I(k)));
        end
    end
    
    stringStudyName         = sprintf('std%d',i); %stdX
    stringStudyStepName     = sprintf('st%d',i); %stX
    stringStationaryName    = sprintf('s%d',i); %sX
    stringSolName           = sprintf('sol%d',i); %solX
    
    model.study.create(stringStudyName);
    model.study(stringStudyName).create('stat', 'Stationary');

    model.sol.create(stringSolName);
    model.sol(stringSolName).study(stringStudyName);
    model.sol(stringSolName).attach(stringStudyName);
    model.sol(stringSolName).create(stringStudyStepName, 'StudyStep');
    model.sol(stringSolName).create('v1', 'Variables');
    model.sol(stringSolName).create(stringStationaryName, 'Stationary');
    model.sol(stringSolName).feature(stringStationaryName).create('fc1', 'FullyCoupled');
    model.sol(stringSolName).feature(stringStationaryName).create('i1', 'Iterative');
    model.sol(stringSolName).feature(stringStationaryName).feature('i1').create('mg1', 'Multigrid');
    model.sol(stringSolName).feature(stringStationaryName).feature.remove('fcDef');

%     model.result.create('pg1', 'PlotGroup3D');
%     model.result('pg1').create('mslc1', 'Multislice');

    
    model.sol(stringSolName).feature(stringStationaryName).feature('i1').set('linsolver', 'cg');
    model.sol(stringSolName).feature(stringStationaryName).feature('i1').feature('mg1').set('prefun', 'amg');
    model.sol(stringSolName).runAll;
    
    %model.param.set(sprintf('I%d',i),  sprintf('%d',0));
    

%model.sol('sol1').runAll;

% model.result('pg1').label('Electric Potential (ec)');
% model.result('pg1').set('frametype', 'spatial');
    mkdir('DOTS');
    model.save([pwd sprintf('\\DOTS\\ModelDots%04d.mph',currentNodeID)]);
    
    

end

