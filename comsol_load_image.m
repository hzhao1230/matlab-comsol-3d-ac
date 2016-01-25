% myfun_comsol_load_image

function [] = comsol_load_image( imagefile)
global  dimensionX dimensionY dimensionZ DomainSide ...
    dimension_to_pixel ImageType CutSide EllipseMatrix NewClusterNo...
    vf_expt ReScale  ...    

RemainSide = 1-2*CutSide;

% Obtain dimension to pixel convertion and simulation box side length.
disp(['Ratio of physical length to pixel: ',num2str(dimension_to_pixel),'nm-per-pixel'])
dimensionX = DomainSide*dimension_to_pixel*1e-3; % [um]
dimensionY = dimensionX;
dimensionZ = dimensionX;


load(imagefile);
[NewClusterNo,~] = size(img_para);
EllipseMatrix = zeros(NewClusterNo,7);
EllipseMatrix(:,1)=img_para(1:NewClusterNo,1)/DomainSide*RemainSide*dimensionX + CutSide*dimensionX; % X coordinate
EllipseMatrix(:,2)=img_para(1:NewClusterNo,2)/DomainSide*RemainSide*dimensionY + CutSide*dimensionY; % Y 
EllipseMatrix(:,3)=img_para(1:NewClusterNo,3)/DomainSide*RemainSide*dimensionZ + CutSide*dimensionZ; % Z        
EllipseMatrix(:,4)=img_para(1:NewClusterNo,4)/DomainSide*RemainSide*dimensionX; % long axis
EllipseMatrix(:,5)=img_para(1:NewClusterNo,5)/DomainSide*RemainSide*dimensionX; % short axis        
EllipseMatrix(:,6)=img_para(1:NewClusterNo,6); % Y rotation angle. Angles in degree in COMSOL build
EllipseMatrix(:,7)=img_para(1:NewClusterNo,7); % Z rotation angle. Angles in degree in COMSOL build


disp(['Number of clusters in FEA geometry: ',num2str(NewClusterNo)])
ShortSq = EllipseMatrix(:,5).^2;
ActualVF = (4/3)*pi*EllipseMatrix(:,4)'*ShortSq/(dimensionX*dimensionY*dimensionZ);
disp(['VF before scaling: ',num2str(ActualVF)])

% Correct long/short axes to match apparent VF with labeled
if ReScale == 1
	ReScale = (vf_expt/ActualVF)^(1/3);
	EllipseMatrix(:,4) = EllipseMatrix(:,4)*ReScale; 
	EllipseMatrix(:,5) = EllipseMatrix(:,5)*ReScale; 
	ShortSq = EllipseMatrix(:,5).^2;
	CorrectedVF = (4/3)*pi*EllipseMatrix(:,4)'*ShortSq/(dimensionX*dimensionY*dimensionZ);
	disp(['Corrected VF in simulation window: ',num2str(CorrectedVF)]) 
end
end