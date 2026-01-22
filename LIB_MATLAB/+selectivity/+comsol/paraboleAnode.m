function out = paraboleAnode()
%
% parabole_change.m
%
% Model exported on Dec 7 2016


%importing COMSOL Library
import com.comsol.model.*
import com.comsol.model.util.*

load parameters;

model = ModelUtil.create('Model');
ModelUtil.showProgress(true);

model.modelPath([pwd '/COMSOL_VE/']);

model.label('parabole.mph');

model.comments(['no Comment']);



model.param.set('ringAnodeSpace', '0.3[mm]');
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
model.param.set('ring1D', sprintf('%0.6f[m]',ring1D));
model.param.set('xRing1D', sprintf('%0.6f[m]',xRing1D));
model.param.set('yRing1D', sprintf('%0.6f[m]',yRing1D));
model.param.set('ring2D', sprintf('%0.6f[m]',ring2D));
model.param.set('xRing2D', sprintf('%0.6f[m]',xRing2D));
model.param.set('yRing2D', sprintf('%0.6f[m]',yRing2D));
model.param.set('ringD', sprintf('%0.6f[m]',ringD));

model.param.set('nerveLComsol',sprintf('%0.6f[m]',nerveLComsol));
model.param.set('ringTorusD', sprintf('%0.6f[m]',ringTorusD));
model.param.set('ringCuffD', sprintf('%0.10f[m]',ringCuffD));    
model.param.set('courant', sprintf('%0.5f[A]',courant));
model.param.set('cuffL', sprintf('%0.6f[m]',cuffL));
model.param.set('LayerBC', '100[mm]');
model.param.set('alpha', sprintf('%0.6f[m]',alphaP));
model.param.set('sigmaConjonctive', sprintf('%0.6f[m]',sigmaConjonctive));
model.param.set('epFascicleLayer', sprintf('%0.6f[m]',epFascicleLayer));



model.modelNode.create('comp1');

model.geom.create('geom1', 3);

model.mesh.create('mesh1', 'geom1');

% ring 2 selection
model.geom('geom1').selection.create('csel7', 'CumulativeSelection');
model.geom('geom1').selection('csel7').label('ring2Domain');

% ring 1 selection
model.geom('geom1').selection.create('csel8', 'CumulativeSelection');
model.geom('geom1').selection('csel8').label('ring1Domain');

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
model.geom('geom1').create('tor2', 'Torus');
model.geom('geom1').feature('tor2').label('ring2');
model.geom('geom1').feature('tor2').set('rmaj', 'ring2D/2');
model.geom('geom1').feature('tor2').set('contributeto', 'csel7');
model.geom('geom1').feature('tor2').set('rmin', 'ringTorusD/2');
model.geom('geom1').feature('tor2').set('pos', {'xRing2D' 'yRing2D' '-ringD/2'});
model.geom('geom1').create('cyl3', 'Cylinder');
model.geom('geom1').feature('cyl3').label('cuff');
model.geom('geom1').feature('cyl3').set('r', 'ringCuffD/2');
model.geom('geom1').feature('cyl3').set('pos', {'0' '0' '-cuffL/2'});
model.geom('geom1').feature('cyl3').set('h', 'cuffL');
model.geom('geom1').feature('cyl3').set('selresult', 'on');


% making the geometry of fascicles
% see selectivity.comsol.fasciles (class) for more details
fasciclesGeometry.comsolGeom(model);

% parabole electrode
model.geom('geom1').create('pc1', 'ParametricCurve');
model.geom('geom1').feature('pc1').set('parmin', '5[mm]');
model.geom('geom1').feature('pc1').set('coord', {'0' '0' 's'});
model.geom('geom1').feature('pc1').set('parmax', 'nerveLComsol/2');
model.geom('geom1').feature('pc1').set('selresult', 'on');
model.geom('geom1').create('ps1', 'ParametricSurface');
model.geom('geom1').feature('ps1').set('coord', {'-alpha/1[m]*(s2)^2+s1+xRing1D' '0' 's2'});
model.geom('geom1').feature('ps1').set('parmax1', '0.05[mm]');
model.geom('geom1').feature('ps1').set('parmax2', '1.5[mm]');
model.geom('geom1').feature('ps1').set('pos', {'0.05[mm]+ring1D/2' '0' 'ringD/2'});
model.geom('geom1').feature('ps1').set('selresult', 'on');
model.geom('geom1').run('ps1');
model.geom('geom1').create('rev1', 'Revolve');

model.geom('geom1').feature('rev1').set('revolvefrom', 'faces');
model.geom('geom1').feature('rev1').set('angtype', 'full');
model.geom('geom1').feature('rev1').set('contributeto', 'csel8');
model.geom('geom1').feature('rev1').set('pos3', {'xRing1D' '0' '0'});
model.geom('geom1').feature('rev1').set('axis3', {'0' '0' '1'});
model.geom('geom1').feature('rev1').set('axistype', '3d');
model.geom('geom1').feature('rev1').set('selresult', 'on');
model.geom('geom1').feature('rev1').selection('inputface').named('ps1');
model.geom('geom1').create('sel1', 'ExplicitSelection');
model.geom('geom1').feature('sel1').label('ringpara1');
model.geom('geom1').feature('sel1').selection('selection').set('rev1(1)', [1]);
model.geom('geom1').create('pc2', 'ParametricCurve');
model.geom('geom1').feature('pc2').set('parmin', '-2[cm]');
model.geom('geom1').feature('pc2').set('coord', {'0' '0' 's'});
model.geom('geom1').feature('pc2').set('parmax', '2[cm]');
model.geom('geom1').feature('pc2').set('selresult', 'on');
model.geom('geom1').create('pc3', 'ParametricCurve');
model.geom('geom1').feature('pc3').set('parmin', '-2[cm]');
model.geom('geom1').feature('pc3').set('coord', {'nerveD/4' '0' 's'});
model.geom('geom1').feature('pc3').set('parmax', '2[cm]');
model.geom('geom1').feature('pc3').set('selresult', 'on');
%model.geom('geom1').run('fin');

%% selection

% All domain
model.geom('geom1').create('ballsel1', 'BallSelection');
model.geom('geom1').feature('ballsel1').set('r', '1');
model.geom('geom1').feature('ballsel1').label('AllDomain');
model.geom('geom1').feature('ballsel1').set('condition', 'inside');
model.geom('geom1').run('ballsel1');


% real Domain to Solve (- electrodes)
model.geom('geom1').create('difsel2', 'DifferenceSelection');
model.geom('geom1').feature('difsel2').label('RealDomain');
model.geom('geom1').feature('difsel2').set('add', {'ballsel1'});
model.geom('geom1').feature('difsel2').set('subtract', {'csel7' 'csel8'});
model.geom('geom1').runPre('difsel2');

model.geom('geom1').create('intsel1', 'IntersectionSelection');
model.geom('geom1').feature('intsel1').set('entitydim', '2');
model.geom('geom1').feature('intsel1').label('NerveFascicleIntersection');
model.geom('geom1').feature('intsel1').set('input', {'csel5' 'csel4'});
model.geom('geom1').create('difsel1', 'DifferenceSelection');
model.geom('geom1').feature('difsel1').set('entitydim', '2');
model.geom('geom1').feature('difsel1').label('fasciclePeripheralB');
model.geom('geom1').feature('difsel1').set('add', {'csel4'});
model.geom('geom1').feature('difsel1').set('subtract', {'intsel1'});
% model.geom('geom1').create('unisel1', 'UnionSelection');
% model.geom('geom1').feature('unisel1').label('FascicleD');

% Nerf Without Fasciles
model.geom('geom1').create('difsel3', 'DifferenceSelection');
model.geom('geom1').feature('difsel3').label('NerfWithoutFascicles');
model.geom('geom1').feature('difsel3').set('add', {'cyl1'});
model.geom('geom1').feature('difsel3').set('subtract', {'csel4'});
% model.geom('geom1').runPre('difsel3');
% model.geom('geom1').run('difsel3');
% model.geom('geom1').run('difsel3');
% model.geom('geom1').runPre('fin');

model.geom('geom1').run('difsel3');

% cuff selection
model.geom('geom1').create('ballsel2', 'BallSelection');
model.geom('geom1').feature('ballsel2').label('cuffSurfacePeiphery');
model.geom('geom1').feature('ballsel2').set('entitydim', '2');
model.geom('geom1').feature('ballsel2').set('groupcontang', 'on');
model.geom('geom1').feature('ballsel2').set('posx', 'ringCuffD/2');
model.geom('geom1').feature('ballsel2').set('r', '0.1[mm]');

model.geom('geom1').run;

model.view.create('view3', 2);

%% MATERIALS

model.material.create('mat4', 'Common', 'comp1'); % saline
model.material.create('mat3', 'Common', 'comp1'); % Interior of cuff
model.material.create('mat1', 'Common', 'comp1'); % epineurium
model.material.create('mat2', 'Common', 'comp1'); % facicle
model.material.create('mat5', 'Common', 'comp1'); % fascicle boundary (perineurium)


model.material('mat1').selection.named('geom1_cyl1_dom');
model.material('mat2').selection.named('geom1_csel4_dom');
model.material('mat3').selection.named('geom1_cyl3_dom');
model.material('mat4').selection.all;
model.material('mat4').label('Saline');
model.material('mat5').selection.named('geom1_difsel1');

%% PHYSICS

model.physics.create('ec', 'ConductiveMedia', 'geom1');
model.physics('ec').selection.named('geom1_difsel2');
model.physics('ec').create('ci1', 'ContactImpedance', 2);
model.physics('ec').feature('ci1').selection.named('geom1_difsel1');
model.physics('ec').create('dimp1', 'DistributedImpedance', 2);
model.physics('ec').feature('dimp1').selection.named('geom1_csel3_bnd');
model.physics('ec').create('term1', 'Terminal', 2);
model.physics('ec').feature('term1').selection.named('geom1_csel7_bnd');
model.physics('ec').create('term2', 'Terminal', 2);
model.physics('ec').feature('term2').selection.named('geom1_csel8_bnd');
model.physics.create('cir', 'Circuit', 'geom1');
model.physics('cir').create('I1', 'CurrentSourceCircuit', -1);
model.physics('cir').create('IvsU1', 'ModelDeviceIV', -1);
model.physics('cir').create('I2', 'CurrentSourceCircuit', -1);
model.physics('cir').create('IvsU2', 'ModelDeviceIV', -1);

model.physics('ec').create('ein2', 'ElectricInsulation', 2);
model.physics('ec').feature('ein2').selection.named('geom1_ballsel2');


model.mesh('mesh1').create('ftet1', 'FreeTet');

model.view('view1').set('scenelight', 'off');
model.view('view3').axis.set('ymin', '-0.5677165985107422');
model.view('view3').axis.set('xmax', '1.261846899986267');
model.view('view3').axis.set('xmin', '-1.261846899986267');
model.view('view3').axis.set('ymax', '1.5677165985107422');

model.material('mat1').label('epineurium');
model.material('mat1').propertyGroup('def').set('electricconductivity', {'sigmaEpineurium' '0' '0' '0' 'sigmaEpineurium' '0' '0' '0' 'sigmaEpineurium'});
model.material('mat1').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat2').label('fascicle');
model.material('mat2').propertyGroup('def').set('electricconductivity', {'sigmaFasciculexy' '0' '0' '0' 'sigmaFasciculexy' '0' '0' '0' 'sigmaFasciculez'});
model.material('mat2').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat3').label('conjonctiveTissue');
model.material('mat3').propertyGroup('def').set('electricconductivity', {'sigmaEXT' '0' '0' '0' 'sigmaEXT' '0' '0' '0' 'sigmaEXT'});
model.material('mat3').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat4').propertyGroup('def').set('electricconductivity', {'sigmaSaline' '0' '0' '0' 'sigmaSaline' '0' '0' '0' 'sigmaSaline'});
model.material('mat4').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat5').label('perineurium');
model.material('mat5').propertyGroup('def').set('electricconductivity', {'sigmaPerineurium' '0' '0' '0' 'sigmaPerineurium' '0' '0' '0' 'sigmaPerineurium'});
model.material('mat5').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});

model.physics('ec').feature('ci1').set('ds', 'epFascicleLayer');
model.physics('ec').feature('dimp1').set('ds', 'LayerBC');
model.physics('ec').feature('dimp1').set('sigmabnd_mat', 'userdef');
model.physics('ec').feature('dimp1').set('sigmabnd', 'sigmaConjonctive');
model.physics('ec').feature('dimp1').set('epsilonrbnd_mat', 'userdef');
model.physics('ec').feature('term1').set('TerminalType', 'Circuit');
model.physics('ec').feature('term2').set('TerminalName', '0');
model.physics('ec').feature('term2').set('TerminalType', 'Circuit');
model.physics('cir').prop('CircuitSettings').set('CreateNodes', '0');
model.physics('cir').feature('I1').set('Connections', {'1'; '0'});
model.physics('cir').feature('I1').set('value', 'courant');
model.physics('cir').feature('IvsU1').set('V_src', 'root.comp1.ec.V0_1');
model.physics('cir').feature('IvsU1').set('Connections', {'1'; '0'});
model.physics('cir').feature('I2').set('Connections', {'2'; '0'});
model.physics('cir').feature('I2').set('value', '-courant');
model.physics('cir').feature('IvsU2').set('V_src', 'root.comp1.ec.V0_0');
model.physics('cir').feature('IvsU2').set('Connections', {'2'; '0'});

model.mesh('mesh1').feature('size').set('hauto', 3);
model.mesh('mesh1').feature('size').set('custom', 'on');
model.mesh('mesh1').feature('size').set('hmin', '0.5E-4');
model.mesh('mesh1').run;

model.study.create('std1');
model.study('std1').create('stat', 'Stationary');

model.sol.create('sol1');
model.sol('sol1').study('std1');
model.sol('sol1').attach('std1');
model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').create('s1', 'Stationary');
model.sol('sol1').feature('s1').create('fc1', 'FullyCoupled');
model.sol('sol1').feature('s1').create('i1', 'Iterative');
model.sol('sol1').feature('s1').feature('i1').create('mg1', 'Multigrid');
model.sol('sol1').feature('s1').feature.remove('fcDef');

model.result.create('pg1', 'PlotGroup3D');
model.result('pg1').create('mslc1', 'Multislice');

model.sol('sol1').attach('std1');
model.sol('sol1').feature('s1').feature('i1').set('linsolver', 'cg');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').set('prefun', 'amg');
model.sol('sol1').runAll;

model.result('pg1').label('Electric Potential (ec)');
model.result('pg1').set('frametype', 'spatial');

out = model;
