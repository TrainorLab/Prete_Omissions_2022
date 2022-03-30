%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% SETUP AND TOOLBOXES %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%SET DATA DIRECTORY AND SAVING DIRECTORY. ENSURES THAT THE SAVE DIRECTORY
%EXISTS BEFORE ATTEMPTING TO SAVE THE WORK 
datadir = '\\trainorserv.mcmaster.ca\trainorlab\David_Prete\Infant_Omit_rates\EGI Data\';
savedir ='D:\Desktop\Infant_Omit_rates\EGI Data\';
if ~exist(savedir,'dir'); mkdir(savedir); end

addpath('\\trainorserv.mcmaster.ca\trainorlab\David_Prete\Infant_Omit_rates\EGI Data\GitHub\')
addpath('\\trainorserv.mcmaster.ca\trainorlab\David_Prete\Infant_MMN_Omitt\Scripts\AB_NONGUI')
addpath('D:\David\MATLAB\fieldtrip-20170625\fieldtrip-20170625\');
ft_defaults
ft_warning off

%GETTING THE ELECTRODE TEMPLATE 
layoutFile= 'D:\David\MATLAB\fieldtrip-20170625\fieldtrip-20170625\template\electrode\GSN-HydroCel-129.sfp';
elec = ft_read_sens(layoutFile);

cfg = [];
cfg.method = 'distance';
cfg.neighbordist = 4; 
cfg.elec = elec;
neighbours = ft_prepare_neighbours(cfg);

    
%FINDING THE RAW EEG DATA TO BE PROCESSED
files          = dir([datadir,'omit_rates_adult*.mff']);
output_silence = [savedir, 'silence_adults_atypical_short.mat'];
load("D:\Desktop\Infant_Omit_rates\EGI Data\silences_typical_filter_short_ica_comps.mat")
allData_expected_silence   = cell(30,1);
allData_unexpected_silence = cell(30,1);

%ICA COMPOENENTS DEEMED NOISE TO BE REJECTED
comps_to_remove = {[2,3,7,11,35],...
                   [1,2,6,12,22,24,52,54,56],...
                   [1,2,8,11,22,25,26,31,43,44],...
                   [1,2,8,9,11,32,57],... 
                   [1,3,9,12,14,17,56,58],... #5
                   [1,2,7,8,38,44,47],...
                   [1,3,5,11,17,41],...
                   [1,2,7,12,17,18,22,23,25,28,48,53,55],...
                   [1,2,3,8,13,24,36,53],...
                   [1,2,5,11,16,17,19,25,30,31,35,47],... #10
                   [1,2,3,16,19,22,25,34,49,40,43,60],...
                   [1,2,3,4,18,25,27,39,43,49,56],...
                   [1,2,7,18,19,27,30,33,37,49,52],...
                   [1,2,3,4,8,17,18,26,29,43],...
                   [1,3,4,18,19,27,35,48,56],...#15
                   [1,2,3,22,23,25,26,27,28,60],...
                   [1,2,7,25,29,35,36,37,47,49,60],...
                   [3,7,8,10,14,15,21,22,25,36],...
                   [1,2,7,17,27,19,30,23,37,34,41,60,53],...
                   [1,2,15,11,34,40,52,57],... #20
                   [1,5,9,6,28,23,34,32,54,53],...
                   [1,5,12,20,16,27,29,31,38,49,47,57,54],...
                   [1,4,8,16,26,28,11,39,40,57],...
                   [1,2,4,9,14,19,28,43,57,34],...
                   [1,2,7,17,13,14,21,26,27,39,53],...#25
                   [1,2,9,10,14,27,34,39,50,48,60],...
                   [1,3,8,20,14,13,19,22,29,32,41],...
                   [2,3,5,17,18,12,16,19,13,21,26,25,31,48,41,59],...
                   [1,2,3,4,11,13,19,14,21,22,12,38,51,52,55],...
                   [1,2,17,14,15,23,30,40,32,31,54,56]
                   };

%%

%%%%%%%%%%%%%%%%%%%%%%%
%%%% PREPROCESSING %%%%
%%%%%%%%%%%%%%%%%%%%%%%
for s = 1:30

part_start = tic;
disp('---------------------------------------')
disp(['Preprocessing: ',part_group, num2str(s)])
disp('---------------------------------------')

%Getting the file name of the EEG data
%loading the data into fieldtrip
disp('Loading data...')
    fileName    = strcat(files(s).folder,'\',files(s).name);
    cfg         = [];
    cfg.dataset = fileName;
    data        = ft_preprocessing(cfg);
    
%DEFINING THE TRIALS BASED ON DIN TRIGGERS
    cfg=[];
    cfg.trialdef.eventtype  = '255_DINs';
    cfg.dataset             = fileName;
    fs                      = data.fsample;
    cfg.fsample             = fs;
    cfg.trialdef.prestim    = -0.250;
    cfg.trialdef.poststim   =  0.500;
    cfg.trialdef.eventvalue = 'DIN5';%['DIN1','DIN2','DIN4','DIN5'];
    [trl, value]            = InfantOmitt_definetrial(cfg);

    din1 = contains(value, 'DIN1');
    din2 = contains(value, 'DIN2');
    din4 = contains(value, 'DIN4');
    din5 = contains(value, 'DIN5');
    din8 = contains(value, 'DIN8');
    
    trl(din1,4)= 1;
    trl(din2,4)= 2;
    trl(din4,4)= 4;
    trl(din5,4)= 5;
    trl(din8,4)= 8;

    % HIGH PASS FILTER THE DATA
    disp('Filtering...')
    cfg            = [];
    cfg.hpfilter   = 'yes';
    cfg.hpfreq     = 0.5;
    cfg.hpfilttype = 'but';        
    cfg.hpfiltord  = 4;
    cfg.channel    = {'all','-E43','-E44','-E48' ,'-E49','-E56','-E63','-E81','-E99','-E107','-E113' '-E114','-E119','-E120'};
    data           = ft_preprocessing(cfg, data);

    % LOW PASS FILTER THE DATA
    cfg = [];
    cfg.lpfilter= 'yes';
    cfg.lpfreq = 20;
    cfg.lpfilttype = 'but';
    cfg.lpfiltord = 4;
    data = ft_preprocessing(cfg, data);


    % REREFERENCE DATA TO COMMON AVERAGE NOTING CZ (AKAK VREF) WAS INITALLY
    % USED AS THE REFERNCE 
    disp('Re-referencing...')
    cfg             = []; 
    cfg.implicitref = 'VREF';
    cfg.refchannel  = {'all','-E43','-E44','-E48' ,'-E49','-E56','-E63','-E81','-E99','-E107','-E113' '-E114','-E119','-E120'};
    cfg.reref       = 'yes';
    data            = ft_preprocessing(cfg,data);
    

%This conducts Artifcat blocking. It is a type of artifact correction for
%high amplitude artifact such as blink, movements, jaw clenching. It is
%based on the paper by Mourad, Reilly, Debruin and Hasey, 2007
disp( 'Artifact Blocking...')

   ref_data              = data.trial{1}(end,:);
   AB_data               = data.trial{1}(1:end-1,:);
   Parameters            = [];
   Parameters.Approach   = 'Window'; 
   Parameters.Threshold  = 75; %voltage threshold 
   Parameters.Fs         = fs;
   Parameters.WindowSize = 5; % unit in second
   Parameters.InData     = AB_data; % may have to exclude the high-pass artifact before AB
   Parameters            = Run_AB(Parameters);
    
    
   data.trial{1}= [Parameters.OutData; ref_data];
   clear AB_data ref_data
%REFERENCE TO COMMON AVERAGE

%DEFINE TRIALS AND SEGEMENT THE DATA 
disp('Defining trials...')  
    cfg       = [];
    cfg.trl   = trl;
    data      = ft_redefinetrial(cfg,data);
    data.elec = elec;

%DOWNSAMPLE TO 128 HZ    
    cfg             = [];
    cfg.resamplefs  = 128;
    cfg.trl         = trl(:,1:3);
    cfg.detrend     = 'no';
    data            = ft_resampledata(cfg,data);

%APPY ICA ANALYSIS DONE ON NON-DOWNSAMPLED DATA TO THE DOWNSAMPLED DATA     
    cfg                = [];
    cfg.method         = 'runica';
    cfg.runica.pca     = 60;
    cfg.unmixing       = allData_comps{s,1}.unmixing;
    cfg.topolabel      = allData_comps{s,1}.topolabel;
    comps              = ft_componentanalysis(cfg,data);

    cfg = [];
    cfg.component = comps_to_remove{1,s}; % to be removed component(s)
    data = ft_rejectcomponent(cfg, comps, data);

% CUSTOM TRIAL REJECTION
% FIND TRIALS THAT HAVE AMPLITUDE RANGE GREATER THAN 100 MICROVOLTS IN ANY
% CHANNEL AND REMOVES THAT TRIAL
trials_to_reject = [];

for jj = 1:length(data.trial)
    trial = data.trial{jj};
    maximums = max(trial,[],2 );
    minimums = min(trial,[],2 );
    ranges   = abs(minimums-maximums);
    reject   = sum(ranges>=100);
    
    if reject>0
        trials_to_reject   = [trials_to_reject,jj];
    end
end


data.trial(trials_to_reject)     = [];
data.time(trials_to_reject)      = [];
data.trialinfo(trials_to_reject) = [];
data.artifacts = trials_to_reject;

%SEPARATE THE SILENCE CONDITIONS
cfg         = [];
cfg.trials  = find(data.trialinfo == 4);
data_unexpected_silence = ft_selectdata(cfg,data);

cfg.trials  = find(data.trialinfo == 2);
data_expected_silence = ft_selectdata(cfg,data);

%STORE THE PREPROCESSED DATA    
allData_expected_silence{s,1}   = data_expected_silence;
allData_unexpected_silence{s,1} = data_unexpected_silence;
part_end = toc(part_start);
fprintf('--- Participant %d took %.3f seconds.--- \n', s, part_end)

end 

disp('Saving data...')
   save(output_silence,'allData_unexpected_silence','allData_expected_silence','-v7.3');
disp('Data Saved!')
 
%%

%%%%%%%%%%%%%%
%%%% ERPS %%%%
%%%%%%%%%%%%%%

%SETUP FOR DIRECTORIES AND TOOLBOXES
datadir ='D:\Desktop\Infant_Omit_rates\EGI Data\';
savedir = 'D:\Desktop\Infant_Omit_rates\EGI Data\ERP\ICA';
if ~exist(savedir,'dir'); mkdir(savedir); end

addpath('\\trainorserv.mcmaster.ca\trainorlab\David_Prete\Infant_MMN_Omitt\Scripts') 
addpath('\\trainorserv.mcmaster.ca\trainorlab\David_Prete\Infant_Omit_rates\EGI Data\GitHub')
load('D:\Desktop\Infant_Omit_rates\EGI Data\silence_adults_atypical_short.mat')
output_silence = [datadir, 'silences_ERP_trials_atypical_filter.mat'];
    
    

for s=1:length(allData_expected_silence)

%CALCUALTE THE ERP FOR EACH SUBJECT
    cfg                       = [];
    cfg.keeptrials            ='yes';
    ERP_expected_silence      = ft_timelockanalysis(cfg,allData_expected_silence{s,1});
    ERP_unexpected_silence    = ft_timelockanalysis(cfg,allData_unexpected_silence{s,1});

%APPLY BASELINE CORRECTION TO THE ERPS
    cfg                    = [];
    cfg.baseline           = [-0.100 0];
    cfg.channel            = {'all','-E44','-E48' ,'-E49','-E56','-E107','-E113' '-E114','-E117'};
    ERP_unexpected_silence = ft_timelockbaseline(cfg,ERP_unexpected_silence);
    ERP_expected_silence   = ft_timelockbaseline(cfg,ERP_expected_silence);

%STORE ERP DATA
    allData_unexpected_silence{s,1} = ERP_unexpected_silence;
    allData_expected_silence{s,1} =ERP_expected_silence;
end
  
disp('Saving data...')
   save(output_silence,'allData_unexpected_silence','allData_expected_silence');
disp('Data Saved!')
