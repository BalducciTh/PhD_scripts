%% Edit 29/09/2020 TB
clear all

%addpath('/data/cnc/projects/fm/bids/derivatives/l1/duration/'); % TB ***

directory = '/data/cnc/pojects/fm/bids/derivatives/';
subjects = cellstr(spm_select('FPListRec', '/data/cnc/projects/fm/bids/derivatives/prep/dsp/', 'sw.*.nii$')); 


load('/data/cnc/projects/fm/ERT_out/taskduration/taskduration.mat') 

for i = 1:length(subjects)
    load('firstlevel_job_TB_290920.mat')
   
   
    % read subject code from path
    [unused, subjcode] = fileparts(fileparts(fileparts(fileparts(subjects{i}))));
   
    display(['Working on ' subjcode])
    
    % search all volumes for scan
    scans = cellstr(spm_select('ExtFPList', fileparts(subjects{i}), '^sw.*.nii$'));
    no_scan(i) = numel(scans);
    tasklength = ceil(taskduration(i)); %tasklength = ceil(taskdurations(i));
       
   % fill jobfile
    %dir_out = ['/data/cnc/students/dinkelacker/Documents/Data/MRI_data/Derivatives/firstlevelanalysis/Leiden/', subjcode, '/Functional/results/'];
     dir_out = ['/data/cnc/projects/fm/bids/derivatives/level1/', subjcode, '/func/results/'];
     
    % func = cellstr(spm_select('ExtFPListRec', ['/data/cnc/students/dinkelacker/Documents/Data/MRI_data/Derivatives/fmripreprocessing/Leiden/', subjcode, '/Functional/'], '^sw.*.nii', 1:ceil(tasklength)));
    func = cellstr(spm_select('ExtFPListRec', ['/data/cnc/projects/fm/bids/derivatives/prep/dsp/', subjcode, '/ses-1/func/'], '^sw.*.nii', 1:ceil(tasklength))); %ceil
    %designfile = cellstr(spm_select('FPListRec',['/data/cnc/students/dinkelacker/Documents/Data/MRI_data/Derivatives/firstlevelanalysis/Leiden/', subjcode, '/design/'], '^ERT.*.mat$'));
    sub_num = num2str(str2num(subjcode(5:end)));
    designfile = cellstr(spm_select('FPListRec',['/data/cnc/projects/fm/ERT_out/designs/'], ['^task_fmri_' sub_num '-1_design_wfx.*.mat$']));
    
    % select file inclCov_Dpv_and_FD.txtuding artefact and framewise displacement regressors
     regressor_file = ['/data/cnc/projects/fm/bids/derivatives/prep/realigment/' subjcode '/ses-1/func/FD_only_covariate_6r.mat']; %Cov_Dpv_and_FD.txt %FD_only_covariate.mat
    
    % regressor_file = ['/data/cnc/students/dinkelacker/Documents/Data/MRI_data/Derivatives/preprocessing/Leiden/' subjcode '/Functional/Cov_Dpv_and_FD.txt'];
    Rtmp = load(regressor_file);
    
    
    % crop regressors based on tasklength
    if tasklength > numel(func)
       tasklength = numel(func)
    end
    
   if ~isempty(Rtmp.R)
       R = Rtmp.R(1:tasklength, :); 
       R = R(:,any(R));
       % regressor_matfile =['/data/cnc/students/dinkelacker/Documents/Data/MRI_data/Derivatives/preprocessing/Leiden/' subjcode '/Functional/Cov_Dpv_and_FD.mat'];
       regressor_matfile =['/data/cnc/projects/fm/bids/derivatives/prep/realigment/' subjcode '/ses-1/func/FD_only_covariate_6r.mat'];%Cov_Dpv_and_FD.mat
       save(regressor_matfile, 'R');
   end
   %z = all(Rtmp.R)
     
    
%%
    % batch specifications
    matlabbatch{1}.spm.stats.fmri_spec.dir = { dir_out };                   % <directory>
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = func;                   % sw-files
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = designfile;             % design files / output from e-prime converted txt models
    if ~isempty(Rtmp.R)
        matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {regressor_file};   % regressor file, containing selected volumes with artefact and motion (framewise displacement)
     else
         matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {''};   % regressor file, containing selected volumes with artefact and motion (framewise displacement)
   end
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 192;                      % change high pass filter to 192, based on visual inspection of earlier models of this data
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [1 1];            % include time and dispersion derivatives
    
    %matlabbatch(3) = []
    %matlabbatch(2) = []
          
    % save and run job
    save(['jobfiles/' subjcode '_firstlevel_job_TB.mat'], 'matlabbatch');
    spm_jobman('run', matlabbatch) 
        
end

clear all
