%Edit TB 04/07/19 to realign&estimate to get both r and rp files
clear all
subjects = cellstr(spm_select('FPListRec', '/data/cnc/projects/fm/bids/derivatives/prep/icaa/', '^sub.*emo_bold.nii$'));
%spm_figure('GetWin','Graphics')
%subjects = subjects(cellfun(@isempty, strfind(subjects, 'baseline')))

for i = 2:length(subjects)
    load('/data/cnc/projects/fm/scripts/pp/Realign_Reslice_mean_all_190425.mat')
    
    % read subject code from path
    %[unused, subjcode] = fileparts(fileparts(fileparts(subjects{i})));
    [unused, subjcode]= fileparts(fileparts(fileparts(fileparts(subjects{i}))));
    
    % search all volumes for scan
    %scans = cellstr(spm_select('ExtFPListRec', ['/data/cnc/students/muller/Documents/fMRI_data_wave6_NESDA/Derivatives/', subjcode, 'ses-1
    scans = cellstr(spm_select('ExtFPListRec', ['/data/cnc/projects/fm/bids/derivatives/prep/icaa/', subjcode,'/ses-1/func/'], '^sub.*emo_bold.nii$', 1:999)); 
    %scans = scans(cellfun(@isempty, strfind(scans, 'baseline')))

    % fill jobfile
    matlabbatch{1,1}.spm.spatial.realign.estwrite.data{1}= scans;

    % save and run job
    save(['./jobfiles/' subjcode '_realign_estimate_reslice_job_anat.mat'], 'matlabbatch');
    spm_jobman('run', matlabbatch)
    
end