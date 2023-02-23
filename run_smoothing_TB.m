%edit TB 19/07/19
clear all
subjects = cellstr(spm_select('FPListRec', '/data/cnc/projects/fm/bids/derivatives/prep/icaa_wo_stc/', 'wr.*.nii$'));


% subjects = cellstr(spm_select('FPListRec', '/data/cnc/projects/newpride/Ronja/TherapyEffects_ERT/derivatives/', 'wsub.*.nii$'));
%for followup
% subjects = subjects(cellfun(@isempty, strfind(subjects, 'baseline')))

% for baseline
% subjects = subjects(cellfun(@isempty, strfind(subjects, 'followup')))

spm_figure('GetWin','Graphics')

for i=3%:length(subjects)
    
    load('smoothing_job_RM.mat')
    % read subject code from path
    [unused, subj_code] = fileparts(fileparts(fileparts(fileparts(subjects{i}))));
   
    display(sprintf('working on %s', subj_code));
    % search for w* images
%     %followup
    scans = cellstr(spm_select('ExtFPListRec', ['/data/cnc/projects/fm/bids/derivatives/prep/icaa_wo_stc/' subj_code '/ses-1/func/'], 'wr.*.nii$', 1:1000)); 
%     %baseline
%        scans = cellstr(spm_select('ExtFPListRec', ['/data/cnc/projects/newpride/Ronja/TherapyEffects_ERT/derivatives/fmripreprocessing/' subj_code '/ses_baseline/func/'], 'w.*.nii$', 1:1000));     
    
    
    % fill jobfile
    matlabbatch{1}.spm.spatial.smooth.data = scans;
    
    % save and run job
    save(['jobfiles/' subj_code '_smoothing_job.mat'], 'matlabbatch');
    spm_jobman('run', matlabbatch)
    
end    