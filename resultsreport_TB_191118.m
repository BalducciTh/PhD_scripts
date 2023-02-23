clear all 
%spm_jobman('initcfg');
spm('defaults','FMRI');
datadir = '/data/cnc/projects/fm/scripts/1l';
subjects = cellstr(spm_select('FPListRec', '/data/cnc/projects/fm/bids/derivatives/prep/dsp/', '^sw.*._bold.nii$'));

for i = 2%:length(subjects) 
    load ('resultsreport_job_TB_191119_ps.mat');
     
    % read subject code from path
    [unused, subjcode] = fileparts(fileparts(fileparts(fileparts(subjects{i}))));
   
    display(['Working on ' subjcode])
    matfile= cellstr(spm_select('FPListRec', ['/data/cnc/projects/fm/bids/derivatives/level1_dsp_original-regressors/', subjcode, '/func/results'] ,'SPM.mat'));
    matlabbatch{1}.spm.stats.results.spmmat = matfile;
    matlabbatch{1}.spm.stats.results.conspec.titlestr = '';
    matlabbatch{1}.spm.stats.results.conspec.contrasts = inf;
    matlabbatch{1}.spm.stats.results.conspec.threshdesc = 'none';
    matlabbatch{1}.spm.stats.results.conspec.thresh = 0.001;
    matlabbatch{1}.spm.stats.results.conspec.extent = 0;
    matlabbatch{1}.spm.stats.results.conspec.mask.none = 1;
    matlabbatch{1}.spm.stats.results.units = 1;
    matlabbatch{1}.spm.stats.results.print = 'ps'; %ps
    matlabbatch{1}.spm.stats.results.write.none = 1;
    
    spm_jobman('run', matlabbatch);
    
    cd '/data/cnc/projects/fm/bids/derivatives/level1_dsp'
    cd '/data/cnc/projects/fm/scripts/1l'
   end