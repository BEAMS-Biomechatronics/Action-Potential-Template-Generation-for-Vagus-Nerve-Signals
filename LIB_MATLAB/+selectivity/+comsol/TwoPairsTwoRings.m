function out = model(nerveD, fasciculeD, fasciculeLayer, sigmaSaline, sigmaEpineurium, sigmaPerineurium, sigmaFasciculexy, sigmaFasciculez, sigmaEXT, nerveL, ringTorusD, cuffL, alphaP, Sim1ringD, Sim1ringAnD, ...
    Sim1ringCatD, Sim1courant, Sim2ringD, Sim2ringAnD, Sim2ringCatD, Sim2courant, Sim1z0, Sim2z0, label)
%
% double_electrodev2.m
%
% Model exported on Nov 25 2016, 15:03 by COMSOL 5.2.0.166.

import com.comsol.model.*
import com.comsol.model.util.*

%model = ModelUtil.create('Model');
model = ModelUtil.create(label);

model.modelPath('E:\Documents\Dropbox\papier_nerf\simulation\selectivity\FH\Final_script\PC_NICO\AP_collision\Comsol\base');

model.label(label);

model.comments(['R1D 1.950000 r2D 2.600000 rD 0.300000 cuffL 20.000000 alpha -38.000000\n\nR1D 1.950000 r2D 2.600000 rD 2.000000\n\nUntitled\n\nR1D 1.950000 r2D 2.600000 rD 2.000000\n\nR1D 1.100000 r2D 1.100000 rD 1.000000\n\nUntitled\n\n']);

model.param.set('nerveD', '0.00190[m]');
model.param.set('fasciculeD', '0.00040000[m]');
model.param.set('fasciculeLayer', '0.00005000[m]');
model.param.set('sigmaSaline', '2.0000000000[S/m]');
model.param.set('sigmaEpineurium', '0.0080000000[S/m]');
model.param.set('sigmaPerineurium', '0.0033600000[S/m]');
model.param.set('sigmaFasciculexy', '0.0800000000[S/m]');
model.param.set('sigmaFasciculez', '0.5000000000[S/m]');
model.param.set('sigmaEXT', '0.1600000000[m]');
model.param.set('Sim1ringAnD', '0.001950[m]');
model.param.set('Sim1ringCatD', '0.002600[m]');
model.param.set('nerveL', '0.040000[m]');
model.param.set('ringTorusD', '0.000030[m]');
model.param.set('ringCuffD', 'nerveD*1.5');
model.param.set('Sim1courant', '0');
model.param.set('LayerBC', '50[mm]');
model.param.set('ringAnodeSpace', '0.3[mm]');
model.param.set('alpha', '-38.000000[m]');
model.param.set('x0', '0');
model.param.set('cuffL', '0.0060000[m]');
model.param.set('Sim2ringD', '0.000300[m]');
model.param.set('Sim2ringAnD', '0.001950[m]');
model.param.set('Sim2ringCatD', '0.002600[m]');
model.param.set('Sim2courant', '1[A]');
model.param.set('Sim1z0', '1[mm]');
model.param.set('Sim2z0', '-1[mm]');
model.param.set('Sim1ringD', '0.000300[m]');


model.param.set('nerveD', sprintf('%0.5f[m]',nerveD));
model.param.set('fasciculeD', sprintf('%0.8f[m]',fasciculeD));
model.param.set('fasciculeLayer', sprintf('%0.8f[m]',fasciculeLayer));
model.param.set('sigmaSaline',sprintf('%0.10f[S/m]',sigmaSaline));
model.param.set('sigmaEpineurium',sprintf('%0.10f[S/m]',sigmaEpineurium));
model.param.set('sigmaPerineurium',sprintf('%0.10f[S/m]',sigmaPerineurium));
model.param.set('sigmaFasciculexy',sprintf('%0.10f[S/m]',sigmaFasciculexy));
model.param.set('sigmaFasciculez',sprintf('%0.10f[S/m]',sigmaFasciculez));
model.param.set('sigmaEXT',sprintf('%0.10f[m]',sigmaEXT));
model.param.set('nerveL',sprintf('%0.6f[m]',nerveL));
model.param.set('cuffL', sprintf('%0.6f[m]',cuffL));
model.param.set('alpha', sprintf('%0.6f[m]',alphaP));
model.param.set('ringTorusD', sprintf('%0.6f[m]',ringTorusD));
model.param.set('Sim1ringAnD', sprintf('%0.6f[m]',Sim1ringAnD));
model.param.set('Sim1ringCatD', sprintf('%0.6f[m]',Sim1ringCatD));
model.param.set('Sim1courant', sprintf('%0.2f[A]',Sim1courant));
model.param.set('Sim2ringD', sprintf('%0.6f[m]',Sim2ringD));
model.param.set('Sim2ringAnD', sprintf('%0.6f[m]',Sim2ringAnD));
model.param.set('Sim2ringCatD', sprintf('%0.6f[m]',Sim2ringCatD));
model.param.set('Sim2courant', sprintf('%0.6f[A]',Sim2courant));
model.param.set('Sim1z0', sprintf('%0.6f[m]',Sim1z0));
model.param.set('Sim2z0', sprintf('%0.6f[m]',Sim2z0));
model.param.set('Sim1ringD', sprintf('%0.6f[m]',Sim1ringD));


model.modelNode.create('comp1');

model.geom.create('geom1', 3);

model.mesh.create('mesh1', 'geom1');

model.geom('geom1').geomRep('comsol');
model.geom('geom1').selection.create('csel7', 'CumulativeSelection');
model.geom('geom1').selection('csel7').label('Sim1CathodeBoundary');
model.geom('geom1').selection.create('csel8', 'CumulativeSelection');
model.geom('geom1').selection('csel8').label('Sim1AnodeBoundary');
model.geom('geom1').selection.create('csel9', 'CumulativeSelection');
model.geom('geom1').selection('csel9').label('Sim2CathodeBoundary');
model.geom('geom1').selection.create('csel1', 'CumulativeSelection');
model.geom('geom1').selection('csel1').label('ring1Boundary');
model.geom('geom1').selection.create('csel2', 'CumulativeSelection');
model.geom('geom1').selection('csel2').label('ring2Boundary');
model.geom('geom1').selection.create('csel3', 'CumulativeSelection');
model.geom('geom1').selection('csel3').label('extBC');
model.geom('geom1').selection.create('csel4', 'CumulativeSelection');
model.geom('geom1').selection('csel4').label('fascicleB');
model.geom('geom1').selection.create('csel5', 'CumulativeSelection');
model.geom('geom1').selection('csel5').label('nerveB');
model.geom('geom1').selection.create('csel6', 'CumulativeSelection');
model.geom('geom1').selection('csel6').label('fascicleDomain');
model.geom('geom1').selection.create('csel10', 'CumulativeSelection');
model.geom('geom1').selection('csel10').label('Sim2AnodeBoundary');
model.geom('geom1').create('cyl1', 'Cylinder');
model.geom('geom1').feature('cyl1').label('nerf');
model.geom('geom1').feature('cyl1').set('r', 'nerveD/2');
model.geom('geom1').feature('cyl1').set('contributeto', 'csel5');
model.geom('geom1').feature('cyl1').set('pos', {'0' '0' '-nerveL/2'});
model.geom('geom1').feature('cyl1').set('selresult', 'on');
model.geom('geom1').feature('cyl1').set('h', 'nerveL');
model.geom('geom1').create('cyl2', 'Cylinder');
model.geom('geom1').feature('cyl2').label('milieu');
model.geom('geom1').feature('cyl2').set('r', 'nerveD*2');
model.geom('geom1').feature('cyl2').set('layername', {'' '' '' '' ''});
model.geom('geom1').feature('cyl2').set('contributeto', 'csel3');
model.geom('geom1').feature('cyl2').set('layertop', true);
model.geom('geom1').feature('cyl2').set('selresultshow', 'bnd');
model.geom('geom1').feature('cyl2').set('pos', {'0' '0' '-nerveL'});
model.geom('geom1').feature('cyl2').set('selresult', 'on');
model.geom('geom1').feature('cyl2').set('h', 'nerveL*2');
model.geom('geom1').feature('cyl2').set('layerbottom', true);
model.geom('geom1').create('cyl3', 'Cylinder');
model.geom('geom1').feature('cyl3').label('cuff');
model.geom('geom1').feature('cyl3').set('r', 'ringCuffD/2');
model.geom('geom1').feature('cyl3').set('pos', {'0' '0' '-cuffL/2'});
model.geom('geom1').feature('cyl3').set('h', 'cuffL');
model.geom('geom1').create('cyl4', 'Cylinder');
model.geom('geom1').feature('cyl4').label('fascicule1');
model.geom('geom1').feature('cyl4').set('r', 'fasciculeD/2');
model.geom('geom1').feature('cyl4').set('contributeto', 'csel4');
model.geom('geom1').feature('cyl4').set('selresultshow', 'all');
model.geom('geom1').feature('cyl4').set('pos', {'0' '0' '-nerveL/2'});
model.geom('geom1').feature('cyl4').set('selresult', 'on');
model.geom('geom1').feature('cyl4').set('h', 'nerveL');
model.geom('geom1').create('cyl5', 'Cylinder');
model.geom('geom1').feature('cyl5').label('fascicule2');
model.geom('geom1').feature('cyl5').set('r', 'fasciculeD/2');
model.geom('geom1').feature('cyl5').set('contributeto', 'csel4');
model.geom('geom1').feature('cyl5').set('selresultshow', 'all');
model.geom('geom1').feature('cyl5').set('pos', {'nerveD/4' '0' '-nerveL/2'});
model.geom('geom1').feature('cyl5').set('selresult', 'on');
model.geom('geom1').feature('cyl5').set('h', 'nerveL');
model.geom('geom1').create('cyl6', 'Cylinder');
model.geom('geom1').feature('cyl6').label('fascicule3');
model.geom('geom1').feature('cyl6').set('r', 'fasciculeD/2');
model.geom('geom1').feature('cyl6').set('contributeto', 'csel4');
model.geom('geom1').feature('cyl6').set('selresultshow', 'all');
model.geom('geom1').feature('cyl6').set('pos', {'-nerveD/4' '0' '-nerveL/2'});
model.geom('geom1').feature('cyl6').set('selresult', 'on');
model.geom('geom1').feature('cyl6').set('h', 'nerveL');
model.geom('geom1').create('cyl7', 'Cylinder');
model.geom('geom1').feature('cyl7').label('fascicule4');
model.geom('geom1').feature('cyl7').set('r', 'fasciculeD/2');
model.geom('geom1').feature('cyl7').set('contributeto', 'csel4');
model.geom('geom1').feature('cyl7').set('selresultshow', 'all');
model.geom('geom1').feature('cyl7').set('pos', {'0' 'nerveD/4' '-nerveL/2'});
model.geom('geom1').feature('cyl7').set('selresult', 'on');
model.geom('geom1').feature('cyl7').set('h', 'nerveL');
model.geom('geom1').create('cyl8', 'Cylinder');
model.geom('geom1').feature('cyl8').label('fascicule5');
model.geom('geom1').feature('cyl8').set('r', 'fasciculeD/2');
model.geom('geom1').feature('cyl8').set('contributeto', 'csel4');
model.geom('geom1').feature('cyl8').set('selresultshow', 'all');
model.geom('geom1').feature('cyl8').set('pos', {'0' '-nerveD/4' '-nerveL/2'});
model.geom('geom1').feature('cyl8').set('selresult', 'on');
model.geom('geom1').feature('cyl8').set('h', 'nerveL');
model.geom('geom1').create('tor2', 'Torus');
model.geom('geom1').feature('tor2').label('Sim1Cathode');
model.geom('geom1').feature('tor2').set('rmaj', 'Sim1ringCatD/2');
model.geom('geom1').feature('tor2').set('contributeto', 'csel7');
model.geom('geom1').feature('tor2').set('selresult', 'on');
model.geom('geom1').feature('tor2').set('rmin', 'ringTorusD/2');
model.geom('geom1').feature('tor2').set('pos', {'0' '0' '-Sim1ringD/2+Sim1z0'});
model.geom('geom1').create('ps1', 'ParametricSurface');
model.geom('geom1').feature('ps1').set('coord', {['10[' native2unicode(hex2dec({'00' 'b5'}), 'unicode') 'm]+Sim1ringAnD/2-alpha/1[m]*(s2-Sim1ringD/2)^2+s1'] '0' 's2+Sim1z0'});
model.geom('geom1').feature('ps1').set('parmax1', '0.01[mm]');
model.geom('geom1').feature('ps1').set('parmin2', 'Sim1ringD/2');
model.geom('geom1').feature('ps1').set('parmax2', 'Sim1ringD+1[mm]');
model.geom('geom1').feature('ps1').set('selresult', 'on');
model.geom('geom1').create('rev1', 'Revolve');
model.geom('geom1').feature('rev1').label('Sim1Anode');
model.geom('geom1').feature('rev1').set('angtype', 'full');
model.geom('geom1').feature('rev1').set('contributeto', 'csel8');
model.geom('geom1').feature('rev1').set('axis3', {'0' '0' '1'});
model.geom('geom1').feature('rev1').set('axistype', '3d');
model.geom('geom1').feature('rev1').set('selresult', 'on');
model.geom('geom1').feature('rev1').selection('inputface').named('ps1');
model.geom('geom1').create('tor3', 'Torus');
model.geom('geom1').feature('tor3').label('Sim2Cathode');
model.geom('geom1').feature('tor3').set('rmaj', 'Sim2ringCatD/2');
model.geom('geom1').feature('tor3').set('contributeto', 'csel9');
model.geom('geom1').feature('tor3').set('rmin', 'ringTorusD/2');
model.geom('geom1').feature('tor3').set('pos', {'0' '0' 'Sim2ringD/2+Sim2z0'});
model.geom('geom1').create('tor4', 'Torus');
model.geom('geom1').feature('tor4').label('Sim2Anode');
model.geom('geom1').feature('tor4').set('rmaj', 'Sim2ringAnD/2');
model.geom('geom1').feature('tor4').set('contributeto', 'csel10');
model.geom('geom1').feature('tor4').set('rmin', 'ringTorusD/2');
model.geom('geom1').feature('tor4').set('pos', {'0' '0' '-Sim2ringD/2+Sim2z0'});
model.geom('geom1').create('sel1', 'ExplicitSelection');
model.geom('geom1').feature('sel1').label('Electrodes');
model.geom('geom1').feature('sel1').selection('selection').set('rev1(1)', [1]);
model.geom('geom1').feature('sel1').selection('selection').set('tor2(1)', [1]);
model.geom('geom1').feature('sel1').selection('selection').set('tor3(1)', [1]);
model.geom('geom1').feature('sel1').selection('selection').set('tor4(1)', [1]);
model.geom('geom1').run('fin');
model.geom('geom1').create('intsel1', 'IntersectionSelection');
model.geom('geom1').feature('intsel1').set('entitydim', '2');
model.geom('geom1').feature('intsel1').label('NerveFascicleIntersection');
model.geom('geom1').feature('intsel1').set('input', {'csel5' 'csel4'});
model.geom('geom1').create('difsel1', 'DifferenceSelection');
model.geom('geom1').feature('difsel1').set('entitydim', '2');
model.geom('geom1').feature('difsel1').label('fasciclePeripheralB');
model.geom('geom1').feature('difsel1').set('add', {'csel4'});
model.geom('geom1').feature('difsel1').set('subtract', {'intsel1'});
model.geom('geom1').create('unisel1', 'UnionSelection');
model.geom('geom1').feature('unisel1').label('FascicleD');
model.geom('geom1').feature('unisel1').set('input', {'cyl8' 'cyl7' 'cyl6' 'cyl5' 'cyl4'});
model.geom('geom1').feature('unisel1').set('contributeto', 'csel6');
model.geom('geom1').run;

model.view.create('view3', 2);
model.view.create('view4', 3);

model.material.create('mat1', 'Common', 'comp1');
model.material.create('mat2', 'Common', 'comp1');
model.material.create('mat3', 'Common', 'comp1');
model.material.create('mat4', 'Common', 'comp1');
model.material.create('mat5', 'Common', 'comp1');
model.material('mat1').selection.set([7 9]);
model.material('mat2').selection.named('geom1_csel6_dom');
model.material('mat3').selection.set([1 2 5 8]);
model.material('mat4').selection.set([1]);
model.material('mat5').selection.named('geom1_difsel1');

model.physics.create('ec', 'ConductiveMedia', 'geom1');
model.physics('ec').selection.set([1 2 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24]);
model.physics('ec').create('ein2', 'ElectricInsulation', 2);
model.physics('ec').feature('ein2').selection.set([5 6 98 155]);
model.physics('ec').create('ci1', 'ContactImpedance', 2);
model.physics('ec').feature('ci1').selection.named('geom1_difsel1');
model.physics('ec').create('dimp1', 'DistributedImpedance', 2);
model.physics('ec').feature('dimp1').selection.named('geom1_csel3_bnd');
model.physics('ec').create('term2', 'Terminal', 2);
model.physics('ec').feature('term2').selection.named('geom1_csel8_bnd');
model.physics('ec').create('term1', 'Terminal', 2);
model.physics('ec').feature('term1').selection.named('geom1_csel7_bnd');
model.physics('ec').create('term4', 'Terminal', 2);
model.physics('ec').feature('term4').selection.named('geom1_csel10_bnd');
model.physics('ec').create('term3', 'Terminal', 2);
model.physics('ec').feature('term3').selection.named('geom1_csel9_bnd');
model.physics.create('cir1', 'Circuit', 'geom1');
model.physics('cir1').identifier('cir1');
model.physics('cir1').create('I1', 'CurrentSourceCircuit', -1);
model.physics('cir1').create('IvsU1', 'ModelDeviceIV', -1);
model.physics('cir1').create('I2', 'CurrentSourceCircuit', -1);
model.physics('cir1').create('IvsU2', 'ModelDeviceIV', -1);
model.physics('cir1').create('I3', 'CurrentSourceCircuit', -1);
model.physics('cir1').create('IvsU3', 'ModelDeviceIV', -1);
model.physics('cir1').create('I4', 'CurrentSourceCircuit', -1);
model.physics('cir1').create('IvsU4', 'ModelDeviceIV', -1);

model.mesh('mesh1').create('ftet1', 'FreeTet');

model.view('view1').set('scenelight', 'off');
model.view('view3').axis.set('xmax', '1.0677165985107422');
model.view('view3').axis.set('xmin', '-1.0677165985107422');

model.material('mat1').label('epineurium');
model.material('mat1').propertyGroup('def').set('electricconductivity', {'sigmaEpineurium' '0' '0' '0' 'sigmaEpineurium' '0' '0' '0' 'sigmaEpineurium'});
model.material('mat1').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat2').label('fascicle');
model.material('mat2').propertyGroup('def').set('electricconductivity', {'sigmaFasciculexy' '0' '0' '0' 'sigmaFasciculexy' '0' '0' '0' 'sigmaFasciculez'});
model.material('mat2').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat3').label('conjonctiveTissue');
model.material('mat3').propertyGroup('def').set('electricconductivity', {'sigmaEXT' '0' '0' '0' 'sigmaEXT' '0' '0' '0' 'sigmaEXT'});
model.material('mat3').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat4').label('Surounding');
model.material('mat4').propertyGroup('def').set('electricconductivity', {'sigmaSaline' '0' '0' '0' 'sigmaSaline' '0' '0' '0' 'sigmaSaline'});
model.material('mat4').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat5').label('perineurium');
model.material('mat5').propertyGroup('def').set('electricconductivity', {'sigmaPerineurium' '0' '0' '0' 'sigmaPerineurium' '0' '0' '0' 'sigmaPerineurium'});
model.material('mat5').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});

model.physics('ec').feature('ci1').set('ds', '0.05*fasciculeD');
model.physics('ec').feature('dimp1').set('ds', 'LayerBC');
model.physics('ec').feature('dimp1').set('sigmabnd_mat', 'userdef');
model.physics('ec').feature('dimp1').set('sigmabnd', 'sigmaSaline');
model.physics('ec').feature('dimp1').set('epsilonrbnd_mat', 'userdef');
model.physics('ec').feature('term2').set('TerminalName', '0');
model.physics('ec').feature('term2').set('TerminalType', 'Circuit');
model.physics('ec').feature('term2').label('Sim1Anode');
model.physics('ec').feature('term1').set('TerminalName', '1');
model.physics('ec').feature('term1').set('TerminalType', 'Circuit');
model.physics('ec').feature('term1').label('Sim1Cathode');
model.physics('ec').feature('term4').set('TerminalName', '2');
model.physics('ec').feature('term4').set('TerminalType', 'Circuit');
model.physics('ec').feature('term4').label('Sim2Anode');
model.physics('ec').feature('term3').set('TerminalName', '3');
model.physics('ec').feature('term3').set('TerminalType', 'Circuit');
model.physics('ec').feature('term3').label('Sim2Cathode');
model.physics('cir1').label('Electrical Circuit');
model.physics('cir1').prop('CircuitSettings').set('CreateNodes', '0');
model.physics('cir1').feature('I1').set('Connections', {'1'; '0'});
model.physics('cir1').feature('I1').set('value', 'Sim1courant');
model.physics('cir1').feature('IvsU1').set('V_src', 'root.comp1.ec.V0_1');
model.physics('cir1').feature('IvsU1').set('Connections', {'1'; '0'});
model.physics('cir1').feature('I2').set('Connections', {'2'; '0'});
model.physics('cir1').feature('I2').set('value', '-Sim1courant');
model.physics('cir1').feature('IvsU2').set('V_src', 'root.comp1.ec.V0_0');
model.physics('cir1').feature('IvsU2').set('Connections', {'2'; '0'});
model.physics('cir1').feature('I3').set('Connections', {'3'; '0'});
model.physics('cir1').feature('I3').set('value', 'Sim2courant');
model.physics('cir1').feature('IvsU3').set('V_src', 'root.comp1.ec.V0_3');
model.physics('cir1').feature('IvsU3').set('Connections', {'3'; '0'});
model.physics('cir1').feature('I4').set('Connections', {'4'; '0'});
model.physics('cir1').feature('I4').set('value', '-Sim2courant');
model.physics('cir1').feature('IvsU4').set('V_src', 'root.comp1.ec.V0_2');
model.physics('cir1').feature('IvsU4').set('Connections', {'4'; '0'});

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

model.result.create('pg4', 'PlotGroup3D');
model.result.create('pg5', 'PlotGroup3D');
model.result('pg4').create('mslc1', 'Multislice');
model.result('pg5').create('mslc1', 'Multislice');

model.sol('sol1').attach('std1');
model.sol('sol1').feature('s1').feature('i1').set('linsolver', 'cg');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').set('prefun', 'amg');
%model.sol('sol1').runAll;

model.result('pg4').label('Electric Potential (ec) 1');
model.result('pg4').set('data', 'none');
model.result('pg4').set('frametype', 'spatial');
model.result('pg4').feature('mslc1').set('data', 'none');
model.result('pg4').feature('mslc1').set('znumber', '0');
model.result('pg4').feature('mslc1').set('ynumber', '0');
model.result('pg5').label('Electric Potential (ec)');
model.result('pg5').set('frametype', 'spatial');

out = model;
