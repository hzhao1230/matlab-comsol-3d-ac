% Modified EC physics
function model = comsol_modify_physics(model)
global InitialVoltage AppliedVoltage 
model.physics('ec').feature('init1').set('V', 1, InitialVoltage);
model.physics('ec').feature('term1').set('V0', 1, AppliedVoltage); 

