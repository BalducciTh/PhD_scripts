%edit TB 09/08/19
clear all
subjects = cellstr(spm_select('FPListRec', '/data/cnc/projects/fm/bids/derivatives/prep/icaa/', 'mean.*.nii$'));

%subjects = cellstr(spm_select('FPListRec', '/data/cnc/projects/newpride/Ronja/TherapyEffects_ERT/derivatives/', 'mean.*.nii$'));
%followup
% subjects = subjects(cellfun(@isempty, strfind(subjects, 'baseline')))
%baseline
%subjects = subjects(cellfun(@isempty, strfind(subjects, 'followup')))

spm_figure('GetWin','Graphics')
for i= 2:length(subjects)
    load('coregistration_estimate_job_RM.mat')
    
    %load('coregistration_estimate_job_RM.mat')
    % read subject code from path
    [unused, subj_code] = fileparts(fileparts(fileparts(fileparts(subjects{i}))));
   
    display(sprintf('working on %s', subj_code));
    
    % search for anat scan
    anat = cellstr(spm_select('FPListRec', ['/data/cnc/projects/fm/bids/derivatives/prep/icaa/' subj_code '/ses-1/anat/'], '.*._T1.*.nii$'));
    
    
    % search for mean scan
    func = cellstr(spm_select('FPListRec', ['/data/cnc/projects/fm/bids/derivatives/prep/icaa/' subj_code '/ses-1/func/'], '^mean.*.nii$')); 
    % fill jobfile
    matlabbatch{1}.spm.spatial.coreg.estimate.ref = func;
    matlabbatch{1}.spm.spatial.coreg.estimate.source = anat;
    
    % save and run job
    save(['jobfiles/' subj_code '_coregistration_estimate_job.mat'], 'matlabbatch');
    %save(['jobfiles/baseline/' subj_code '_coregistration_estimate_job.mat'], 'matlabbatch');
    spm_jobman('run', matlabbatch)
    
end    