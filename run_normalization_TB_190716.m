%edit TB 16/07/19
clear all
subjects = cellstr(spm_select('FPListRec', '/data/cnc/projects/fm/bids/derivatives/prep/icaa/', 'mean.*.nii$'));
%followup
% subjects = subjects(cellfun(@isempty, strfind(subjects, 'baseline')))
%baseline
%subjects = subjects(cellfun(@isempty, strfind(subjects, 'followup')))

spm_figure('GetWin','Graphics')

for i = 4%:length(subjects)
    load('normalise_estimate_write_job_RM.mat')
    % read subject code from path
    [unused, subj_code] = fileparts(fileparts(fileparts(fileparts(subjects{i}))));
   
    display(sprintf('working on %s', subj_code));
    %% followup
%     % search for anat scan (from coregistration)
%     anat = cellstr(spm_select('FPListRec', ['/data/cnc/projects/newpride/Ronja/TherapyEffects_ERT/derivatives/fmripreprocessing/' subj_code '/ses_followup1/anat/'], '.*._T1w.nii$')); 
%     % search for original func scans
%     func = cellstr(spm_select('ExtFPListRec', ['/data/cnc/projects/newpride/Ronja/TherapyEffects_ERT/sourcedata/' subj_code '/ses_followup1/func/'], 'sub.*.nii$', 1:1000)); 
    %% baseline
      %search for anat scan (from coregistration)
    anat = cellstr(spm_select('FPListRec', ['/data/cnc/projects/fm/bids/derivatives/prep/icaa/' subj_code '/ses-1/anat/'], '.*._T1w.*.nii$')); 
    % search for original func scans
    func = cellstr(spm_select('ExtFPListRec',  ['/data/cnc/projects/fm/bids/derivatives/prep/icaa/' subj_code '/ses-1/func/'], '^rsub.*.nii$', 1:1000)); 

    % fill jobfile
    matlabbatch{1,1}.spm.spatial.normalise.estwrite.subj.vol = anat;
    matlabbatch{1,1}.spm.spatial.normalise.estwrite.subj.resample = func;
    
    % save and run job
    save(['jobfiles/' subj_code '_normalization_estimate_write_job.mat'], 'matlabbatch');
    spm_jobman('run', matlabbatch)
    
end    