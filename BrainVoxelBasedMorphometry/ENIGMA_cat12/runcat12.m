   
function runcat12

addpath(genpath([fileparts(which('spm')),'/toolbox/ENIGMA_Ataxia/ENIGMA_cat12']));
            images=spm_select(inf,'any','Select .nii T1-w images to include in CAT12 analysis');          
for i=1:size(images, 1)
    x=images(i,:) ;
BatchCAT12(x)
end 
            
end