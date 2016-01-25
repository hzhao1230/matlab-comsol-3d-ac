% Create 3D comsol model microstructure

function model = comsol_create_structure(model)
global InterfaceThickness1 InterfaceThickness2 dimensionX dimensionY  dimensionZ ... 
    EllipseMatrix NewClusterNo...

disp('Load cluster geometry ...');
FeatureName={}; % List of filler circles
FeatureName1={}; % List of interface circles

% Modify rectangular domain
model.geom('geom1').feature('blk1').set('size', [dimensionX, dimensionY, dimensionZ]);
model.geom('geom1').feature('blk1').set('createselection', 'on');
model.geom('geom1').runAll;

% Create fillers
for i = 1 : NewClusterNo
    FeatureName{i}=['Ellipse',num2str(i)];
    model.geom('geom1').feature().create(FeatureName{i},'Ellipsoid');
    model.geom('geom1').feature(FeatureName{i}).set('pos',[EllipseMatrix(i,1) EllipseMatrix(i,2) EllipseMatrix(i,3)]);
    model.geom('geom1').feature(FeatureName{i}).set('semiaxes',[EllipseMatrix(i,4), EllipseMatrix(i,5), EllipseMatrix(i,5)]);
    model.geom('geom1').feature(FeatureName{i}).set('rot', EllipseMatrix(i,6));
    model.geom('geom1').feature(FeatureName{i}).set('createselection','on');
    disp(['Ellipse',num2str(i)])
end
model.geom('geom1').runAll;
model.geom('geom1').feature.create('UnionFiller', 'Union');
model.geom('geom1').feature('UnionFiller').selection('input').set(FeatureName);
model.geom('geom1').feature('UnionFiller').set('createselection', 'on');
model.geom('geom1').feature('UnionFiller').set('intbnd', 'off');
model.geom('geom1').runAll;

% Create Ellipses containing IF1 and fillers
for i = 1: NewClusterNo
    FeatureName1{i}=['EllipseIF1',num2str(i)];
    model.geom('geom1').feature().create(FeatureName1{i},'Ellipsoid');
    model.geom('geom1').feature(FeatureName1{i}).set('pos',[EllipseMatrix(i,1) EllipseMatrix(i,2) EllipseMatrix(i,3)]);
    model.geom('geom1').feature(FeatureName1{i}).set('semiaxes',[EllipseMatrix(i,4)+InterfaceThickness1, EllipseMatrix(i,5)+InterfaceThickness1, EllipseMatrix(i,5)+InterfaceThickness1]);
    model.geom('geom1').feature(FeatureName1{i}).set('rot', EllipseMatrix(i,6));
    model.geom('geom1').feature(FeatureName1{i}).set('createselection','on');
    disp(['EllipseIF1-',num2str(i)])
end
model.geom('geom1').runAll;
model.geom('geom1').feature.create('UnionLargeEllipse1', 'Union');
model.geom('geom1').feature('UnionLargeEllipse1').selection('input').set(FeatureName1);
model.geom('geom1').feature('UnionLargeEllipse1').set('createselection', 'on');
model.geom('geom1').feature('UnionLargeEllipse1').set('intbnd', 'off');
model.geom('geom1').runAll;

% Create IF1 by taking difference between 1st outer ellipses and fillers
model.geom('geom1').feature.create('DiffInterface1', 'Difference');
model.geom('geom1').feature('DiffInterface1').selection('input').set('UnionLargeEllipse1');
model.geom('geom1').feature('DiffInterface1').selection('input2').set('UnionFiller');
model.geom('geom1').feature('DiffInterface1').set('keep', 'on');
model.geom('geom1').feature('DiffInterface1').set('createselection', 'on');
model.geom('geom1').feature('DiffInterface1').set('intbnd', 'off');
model.geom('geom1').runAll;

% Ellipses contain IF2, IF1 and fillers
for i = 1: NewClusterNo
    FeatureName2{i}=['EllipseIF2',num2str(i)];
    model.geom('geom1').feature().create(FeatureName2{i},'Ellipsoid');
    model.geom('geom1').feature(FeatureName2{i}).set('pos',[EllipseMatrix(i,1) EllipseMatrix(i,2) EllipseMatrix(i,3)]);
    model.geom('geom1').feature(FeatureName2{i}).set('semiaxes',[EllipseMatrix(i,4)+InterfaceThickness1+InterfaceThickness2, EllipseMatrix(i,5)+InterfaceThickness1+InterfaceThickness2, EllipseMatrix(i,5)+InterfaceThickness1+InterfaceThickness2]);
    model.geom('geom1').feature(FeatureName2{i}).set('rot', EllipseMatrix(i,6));
    model.geom('geom1').feature(FeatureName2{i}).set('createselection','on');
    disp(['EllipseIF2-',num2str(i)])
end
model.geom('geom1').runAll;

mphsave(model, 'GEOM_ONLY_1') % Save temp comsol model to file for debug

model.geom('geom1').feature.create('UnionLargeEllipse2', 'Union');
model.geom('geom1').feature('UnionLargeEllipse2').selection('input').set(FeatureName2);
model.geom('geom1').feature('UnionLargeEllipse2').set('createselection', 'on');
model.geom('geom1').feature('UnionLargeEllipse2').set('intbnd', 'off');
model.geom('geom1').runAll;

% Create IF2 by taking difference between 2nd and 1st outer ellipses
model.geom('geom1').feature.create('DiffInterface2', 'Difference');
model.geom('geom1').feature('DiffInterface2').selection('input').set('UnionLargeEllipse2');
model.geom('geom1').feature('DiffInterface2').selection('input2').set('UnionLargeEllipse1');
model.geom('geom1').feature('DiffInterface2').set('keep', 'on');
model.geom('geom1').feature('DiffInterface2').set('createselection', 'on');
model.geom('geom1').feature('DiffInterface2').set('intbnd', 'off');
model.geom('geom1').runAll;

% Create matrix material 
model.geom('geom1').feature.create('DiffMatrix', 'Difference');
model.geom('geom1').feature('DiffMatrix').selection('input').set('blk1');
model.geom('geom1').feature('DiffMatrix').selection('input2').set('UnionLargeEllipse2');
model.geom('geom1').feature('DiffMatrix').set('keep', 'on');
model.geom('geom1').feature('DiffMatrix').set('createselection', 'on');
model.geom('geom1').runAll;

mphsave(model, 'GEOM_ONLY') % Save temp comsol model to file for debug

disp('Finished building unions and differences on fillers, interphase, and rectangular simulation block.');

end
