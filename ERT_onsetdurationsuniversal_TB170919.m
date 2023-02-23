%addpath('/data/cnc/software/spm/spm12/');
%addpath('/data/cnc/students/muller/Documents/fMRI_data_wave6_NESDA/Scripts/FirstLevelAnalysis/ScriptsFirstLevel_Margot/')
%addpath('/data/cnc/students/muller/Documents/')

%addpath('/data/server_share/matlab_applications/spm12');
%addpath('/data/server_share/matlab_applications_dev/scripts/other/')
%addpath('/data/cnc/projects/fm/')

input_dir = '/data/cnc/projects/fm/eprime_txt_w/';
files = dir('/data/cnc/projects/fm/eprime_txt_w/*.txt');

%/data/cnc/projects/fm/eprime_txt_w/*.txt');

for i = 28%:length(files)
    
    clear onsets names durations;

    DATA = readlog_eprime(input_dir, files(i).name);
    scan_start = 120689%DATA.IntroOefening1.OnsetTime.value; %adjust according to trigger: = DATA.IntroOefening1.OnsetTime.value;

    stimuli_onsets = ((DATA.ImageDisplay1.OnsetTime.value) - scan_start) / 1000;
    stimuli_durations = 8;
    
    instruction_onsets = ((DATA.Instruction.OnsetTime.value) - scan_start) / 1000;
    instruction_durations = 4;
    
    vas_onsets  = ((DATA.VAS1n.OnsetTime.value)- scan_start) / 1000;
    vas_offsets = ((DATA.WashoutPract2.OnsetTime.value) - scan_start) / 1000;
    vas_durations = vas_offsets(1:end) - vas_onsets(1:end); % vas_offsets(2:end) - vas_onsets;
          
    %FixInBlock_onsets = ((DATA.FixInBlockImg.OnsetTime.value) - scan_start) / 1000;
    %FixInBlock_durations = (DATA.FixInBlockImg.Duration.value)/1000;
    
    categories = cellstr(DATA.Cat.value);      
    instructions = cellstr(DATA.ListStim.value);
    instructions = instructions(1:end); %instructions = instload('firstlevel_job_TB_071019.mat')ructions(2:end);
      
    teller=1;
    for s = 1:length(categories)
        for t = 1:4
        	cat_stim{teller} = categories{s};
            inst_stim{teller} = instructions{s};
            teller = teller +1;            
        end
        
    end
    
    
    unique_cat = unique(categories);
    unique_inst = unique(instructions);
    unique_cat=sort(unique_cat)
    unique_inst=sort(unique_inst)
    teller = 1;
    for cat = 1:length(unique_cat)
        for inst = 1:length(unique_inst);                        
            
            cat_ind =  find(~cellfun(@isempty, strfind(cat_stim,unique_cat{cat})));
            inst_ind = find(~cellfun(@isempty, strfind(inst_stim,unique_inst{inst})));
            
            cat_inst_ind = intersect(cat_ind, inst_ind);
            names{teller} = [ unique_cat{cat} ' - ' unique_inst{inst} ];           
            onsets{teller} = stimuli_onsets(cat_inst_ind);
            durations{teller} = repmat(8,1, length(onsets{teller}))';
            if ~isempty(onsets{teller})
                teller = teller + 1;
            end
            
            
        end
    end

 
    names{teller} = 'VAS';
    onsets{teller} = vas_onsets;
    durations{teller} = vas_durations;
    
    teller = teller + 1;
    names{teller} = 'Instructions';
    onsets{teller} = instruction_onsets;
    durations{teller} = instruction_durations;
    
    %teller = teller + 1;
    %names{teller} = 'FixInBlock';
    %onsets{teller} = FixInBlock_onsets;
    %durations{teller} = FixInBlock_durations;
    
    filename = files(i).name;
    [unused other] = strtok(filename, '-');
    Pident = strtok(other, '-');
    

     
    
    refStrVer = 'REDUCIR';  %VERMINDER
    refStrBek = 'OBSERVAR'; %BEKIJK
    refStrSup = 'SUPRIMIR'; %%
    
    ss_ind = intersect(strmatch('Sad', names), find(~cellfun(@isempty,strfind(names,refStrBek))));
    fs_ind = intersect(strmatch('Fear', names), find(~cellfun(@isempty,strfind(names,refStrBek))));
        
  
    if xor(~isempty(fs_ind),~isempty(ss_ind));
        if(~isempty(fs_ind));
            names{fs_ind} = 'Negativo - OBSERVAR'; %Negatief - BEKIJK'
            durations{fs_ind}=[durations{fs_ind}']';
            onsets{fs_ind}=[onsets{fs_ind}']';
        end%addpath('/data/cnc/software/spm/spm12/');

        if(~isempty(ss_ind));
            names{ss_ind} = 'Negativo - OBSERVAR'; %Negatief - BEKIJK
            durations{ss_ind}=[durations{ss_ind}']';
            onsets{ss_ind}=[onsets{ss_ind}']';
        end

    end
    

    if and(~isempty(fs_ind),~isempty(ss_ind))
        names{fs_ind} = 'Negativo - OBSERVAR'; %Negatief - BEKIJK
        names(ss_ind)=[]
        durations{fs_ind} = [durations{ss_ind}',durations{fs_ind}']';
        durations(ss_ind)=[]
        onsets{fs_ind} = [onsets{ss_ind}',onsets{fs_ind}']'; 
        onsets(ss_ind)=[]
    end
    %dummy = find(~cellfun(@isempty,strfind(names,"Negatief - Bekijk")));


    names

        
    
    sv_ind = intersect(strmatch('Sad', names), find(~cellfun(@isempty,strfind(names,refStrVer))));
    fv_ind = intersect(strmatch('Fear', names), find(~cellfun(@isempty,strfind(names,refStrVer))));
    
    
      
    if xor(~isempty(fv_ind),~isempty(sv_ind));
        if(~isempty(fv_ind));
            names{fv_ind} = 'Negativo - REDUCIR'; %Negatief - VERMINDER
            durations{fv_ind}=[durations{fv_ind}']';
            onsets{fv_ind}=[onsets{fv_ind}']';
        end
        if(~isempty(sv_ind));
            names{sv_ind} = 'Negativo - REDUCIR'; %Negatief - VERMINDER
            durations{sv_ind}=[durations{sv_ind}']';
            onsets{sv_ind}=[onsets{sv_ind}']';
        end

    end
   
    if and(~isempty(fv_ind),~isempty(sv_ind))
        names{fv_ind} = 'Negativo - REDUCIR'; %Negatief - VERMINDER
        names(sv_ind)=[]
        durations{fv_ind} = [durations{sv_ind}',durations{fv_ind}']';
        durations(sv_ind)=[]
        onsets{fv_ind} = [onsets{sv_ind}',onsets{fv_ind}']'; 
        onsets(sv_ind)=[]
    end

    
    ss_ind = intersect(strmatch('Sad', names), find(~cellfun(@isempty,strfind(names,refStrSup))));
    fs_ind = intersect(strmatch('Fear', names), find(~cellfun(@isempty,strfind(names,refStrSup))));
        
  
    if xor(~isempty(fs_ind),~isempty(ss_ind));
        if(~isempty(fs_ind));
            names{fs_ind} = 'Negativo - SUPRIMIR'; %Negatief - BEKIJK'
            durations{fs_ind}=[durations{fs_ind}']';
            onsets{fs_ind}=[onsets{fs_ind}']';
        end%addpath('/data/cnc/software/spm/spm12/');

        if(~isempty(ss_ind));
            names{ss_ind} = 'Negativo - SUPRIMIR'; %Negatief - BEKIJK
            durations{ss_indnames}=[durations{ss_ind}']';
            onsets{ss_ind}=[onsets{ss_ind}']';
        end

    end
    

    if and(~isempty(fs_ind),~isempty(ss_ind))
        names{fs_ind} = 'Negativo - SUPRIMIR'; %Negatief - BEKIJK
        names(ss_ind)=[]
        durations{fs_ind} = [durations{ss_ind}',durations{fs_ind}']';
        durations(ss_ind)=[]
        onsets{fs_ind} = [onsets{ss_ind}',onsets{fs_ind}']'; 
        onsets(ss_ind)=[]
    end
    
    
    
    %%  reorganize the columns to have the right order 
    names_temp(:,:) = names(:,1:9);
    durations_temp(:,:) = durations(:,1:9);
    onsets_temp(:,:) = onsets(:,1:9);
    
    attend = strcmpi (names(7), 'Negativo - OBSERVAR'); %needs to be in the first position 7-->1 Negatief - BEKIJK
    regulate = strcmpi (names(7), 'Negativo - REDUCIR'); %needs to be in the second position 7-->2 Negatief - VERMINDER
    suppress = strcmpi (names(1), 'Negativo - SUPRIMIR');
    
    if attend == 1
        names_temp = names(:,[7 1 2 3 4 5 6 8 9]) %reorders the columns accordingly
        durations_temp = durations(:, [7 1 2 3 4 5 6 8 9]);
        onsets_temp= onsets(:, [7 1 2 3 4 5 6 8 9])
        
        
    elseif regulate == 1 && suppress == 0
        names_temp = names(:,[1 7 2 3 4 5 6 8 9])
        durations_temp = durations(:, [1 7 2 3 4 5 6 8 9]);
        onsets_temp= onsets(:, [1 7 2 3 4 5 6 8 9])
        
    elseif suppress == 1  
        names_temp = names(:,[6 7 1 2 3 4 5 8 9])
        durations_temp = durations(:, [6 7 1 2 3 4 5 8 9]);
        onsets_temp= onsets(:, [6 7 1 2 3 4 5 8 9])
        
    end
    
    names = names_temp;
    durations = durations_temp;
    onsets = onsets_temp;
    
    task_length(i) = onsets{1,8}(21) + durations{1,8}(21); %{vas}(21)
    taskduration(i) = task_length(i);
       
    [folder base ext ] = fileparts(files(i).name);
     file_out = [ input_dir '4/designs/' base '_design.mat'];
     save(file_out' ,'onsets', 'names' ,'durations');
     display(sprintf('Saving to %s', file_out));
end
    taskduration = taskduration/2; %/2.32
    taskdir = [ input_dir '4/taskduration/taskduration.mat'];
    save(taskdir, 'taskduration');
    display(sprintf('Saving taskdurations to %s', taskdir));

