% 'myfun_comsol_build': build and compute solution from COMSOL 
function model = comsol_build(PScoeff, structure,savefile)
% Initialization
global TauShift1 DeltaEpsilonShift1 TauShift2 DeltaEpsilonShift2 ConstEpsilonShift EpsDistribution ...
    GetSolution PortNum

% Load base model
mphstart(PortNum);
model = mphload('base.mph');

%% Section I: Load Data
comsol_load_constant();

% Step One: Load input dielectric function model, if needed
if EpsDistribution
	comsol_load_epsilon_model(PScoeff);
end

% Step Two: Define composite structure
comsol_load_image(structure);

%% Section II: Create COMSOL model
% Step One: Initialize model
model       = comsol_modify_model(model);

% Step Two: Create statistically re-generated microstructure
model       = comsol_create_structure(model);

% Step Five: Assign entities with material properties
model       = comsol_create_material(model);

% Step Six: Create physics
model       = comsol_modify_physics(model);

% Step Seven: Create mesh
model       = comsol_modify_mesh(model);

% Step Eight: Assign shift factors for interphase 
SF  	= [TauShift1, DeltaEpsilonShift1, TauShift2 ,DeltaEpsilonShift2, ConstEpsilonShift];
model   = comsol_create_shifting_factors(model, SF);

%% Section III:  Obtain solution from COMSOL
% Step One: Create Physics-based Study
model       = comsol_create_study(model);

mphsave(model, 'PRECOMPUTED') % Save temp comsol model file for debug

if GetSolution == 1
    % Step Two: Obtain solution
    model   = comsol_create_solution(model);
    
    % Step Three: Post-processing
    model   = comsol_post_process(model, savefile);
end

end
