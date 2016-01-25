% comsol_conf.m
% Configuration files for COMSOL 3D model using API

clear all; close all; clc; warning('off', 'all')

global PortNum DomainSide vf_expt TauShift1 DeltaEpsilonShift1 TauShift2 DeltaEpsilonShift2 ConstEpsilonShift ...
		InterfaceThickness1 InterfaceThickness2 InterfaceThickness ... 
		dimension_to_pixel epmodel ReScale CutSide ... 
		ManualMesh MeshLevel EpsDistribution GetSolution  ...
		
% --------------user defined input ------------------------

id 						= 1; % current run ID
GetSolution             = 1; % '1' for getting solution. '0' for outputing a MPH model with just simulation setup w/o running simulation
PortNum 				= 2036;
		 
DomainSide              = 300; % voxel side length in 3D FEA
vf_expt               	= 1/100;
TauShift1 				= 1;  % beta relaxation, s_beta, For tau <= 1, Shift multiplier along x direction. 1 is no shift
DeltaEpsilonShift1 		= 1;  % beta relaxation, M_beta, For tau <= 1, Shift multiplier along y direction. 1 is no shift
TauShift2 				= 1;  % Alpha relaxation, s_alpha, for tau > 1, Shift multiplier along x direction. 1 is no shift
DeltaEpsilonShift2		= 1;  % Alpha relaxation, M_alpha, For tau > 1, Shift multiplier along y direction. 1 is no shift
ConstEpsilonShift		= 0;
tau0                   	= 0.05; % tau*freq_crit = 1. E.g, for freq_crit = 10 Hz, tau = 0.1 s. 
dimension_to_pixel		= 523/500; % [nm]/[# of pixel]

% Add API source files to path
addpath('/home/hzg972/comsol42/mli','/home/hzg972/comsol42/mli/startup');
% microstructure
structure = './crop_reduced_3D_structure_output.mat';
% experimental dielectric relaxation data 
exptdata = '../expt_epoxy_DS/terthiophene_PGMA_2wt%-TK.csv'; 
% neat polymer properties
PolymerPronySeries   = './RoomTempEpoxy.mat'; 

CutSide                 = 0.1;                               % Assign all clusters in the central (1-cutside*2)^2 region.
IP1                     = 5;                                % [nm]
IP2                     = 8;                                % [nm]
InterfaceThickness1     = IP1*1e-3;                          % [um], physical length, Interficial region thickness with constant properties
InterfaceThickness2     = IP2*1e-3; 
InterfaceThickness      = InterfaceThickness2 + InterfaceThickness1; 

ReScale 				= 0;            % '1' for re-scaling to match with vf_expt. '0' to use actual VF from binary image
EpsDistribution 		= 1;            % '1' for using dielectric relaxation distribution, rather than a fixed value
ManualMesh              = 0; 
MeshLevel               = 5;            % Use when ManualMesh = 0. Range from 1 to 9 (finest to most coarse)

if EpsDistribution == 0; % Constant valued permittivity model (not frequency dependent)
	% polymer permittivity
	epmodel.ep		= 2; 
	epmodel.epp 	= 1e-3;
	% interphase permittivity added by shifting factors
	epintShift 	= 0;
	epmodel.epint 	= epmodel.ep + epintShift;
	eppintShift 	= 0;
	epmodel.eppint 	= epmodel.epp + eppintShift;
end

% Run model
savefile = ['./3D_comsolbuild_',date,'_IP',num2str(IP1),'+',num2str(IP2),'_run_',num2str(id)]; 
tic
model = comsol_build(PolymerPronySeries, structure, savefile);
disp('Job done. Output result to .mph file');

% Export API-created model to file
mphsave(model, savefile);

% Plot computed results and compare against expt data
plot_results(savefile, exptdata)
toc

