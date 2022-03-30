%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% GET MMN VALUES %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

ERPdir =  'D:\Desktop\Infant_Omit_rates\EGI Data\ERP\';%'\\trainorserv.mcmaster.ca\trainorlab\David_Prete\Infant_Omit_rates\EGI Data\ERP\';

layoutFile= 'D:\David\MATLAB\fieldtrip-20170625\fieldtrip-20170625\template\electrode\GSN-HydroCel-128.sfp';
addpath('\\trainorserv.mcmaster.ca\trainorlab\David_Prete\Infant_MMN_Omitt\Scripts\')
addpath('D:\David\MATLAB\fieldtrip-20170625\fieldtrip-20170625\');
ft_defaults

disp('Loading ERPs and Stats...')
    
load('D:\Desktop\Infant_Omit_rates\EGI Data\silences_ERP_trials_typical_filter.mat')




%%

% SET UP FOR ELECTRODE REGIONS 

disp('ERPS and Stats loaded!')

FL = {'E18','E22','E23','E24','E26','E27'};
FR = {'E3','E2','E10','E9','E124','E123'};
FZ = {'E16','E11','E12','E6','E5','E4','E19'};

CL = {'E34','E28','E20','E35','E29','E13','E41','E36','E30'};
CR = {'E118','E117','E116','E112','E111','E110','E105','E104','E103'};
CZ = {'E7','E106','VREF','E31','E55','E80'};

Left = {'E18','E22','E23','E24','E26','E27','E34','E28','E20','E35','E29','E13','E41','E36','E30'};
Right= {'E3','E2','E10','E9','E124','E123','E118','E117','E116','E112','E111','E110','E105','E104','E103'};
Midline = {'E16','E11','E12','E5','E4','E19','E7','E106','VREF','E31','E55','E80'};

all = [Left,Midline,Right];

PL = {'E47','E42','E37','E51','E52','E53','E54'};
PR = {'E87','E93','E98','E79','E86','E92','E97'};
PZ = {'E62','E72','E61','E78','E67','E77'};

OL = {'E58','E59','E60','E64','E65','E66'};
OR = {'E85','E91','E96','E84','E90','E95'};
OZ = {'E75','E70','E83','E71','E76'};

time = allData_unexpected_silence{1}.time; 

%PREALLOCATE MATRIX FOR THE MEAN AMPLITUDES
allSubs_mmn_C_means = zeros(length(allData_unexpected_silence),9);
allSubs_p3_C_means  = zeros(length(allData_unexpected_silence),9);

allSubs_mmn_F_means = zeros(length(allData_unexpected_silence),9);
allSubs_p3_F_means  = zeros(length(allData_unexpected_silence),9);


%LOGICAL INDICIES FOR THE ELECTRODE REGIONS 
CL_ind = ismember(allData_unexpected_silence{1}.label,CL);
CR_ind = ismember(allData_unexpected_silence{1}.label,CR); 
CZ_ind = ismember(allData_unexpected_silence{1}.label,CZ);

central = {CL_ind,CZ_ind,CR_ind};

FL_ind = ismember(allData_unexpected_silence{1}.label,FL);
FR_ind = ismember(allData_unexpected_silence{1}.label,FR); 
FZ_ind = ismember(allData_unexpected_silence{1}.label,FZ);

frontal = {FL_ind,FZ_ind,FR_ind};

OL_ind = ismember(allData_unexpected_silence{1}.label,FL);
OR_ind = ismember(allData_unexpected_silence{1}.label,FR); 
OZ_ind = ismember(allData_unexpected_silence{1}.label,FZ);


all_ind = ismember(allData_unexpected_silence{1}.label,all);

%PREALLOCATE MATRIX FOR THE PEAK AMPLITUDE LOCATIONS
mmn_C_locs = zeros (length(allData_expected_silence),9);
mmn_F_locs = zeros (length(allData_expected_silence),9);

p3_C_locs = zeros (length(allData_expected_silence),9);
p3_F_locs = zeros (length(allData_expected_silence),9);


%%

for s = 1:length(allData_unexpected_silence) 
    
    data_un_silence  = allData_unexpected_silence{s}; 
    data_exp_silence = allData_expected_silence{s}; 
    
    %CALCULATE THE DIFFERNCE WAVEFORM 
    cfg=[];
    cfg.operation = 'subtract'; 
    cfg.parameter = 'avg';
    data_diff = ft_math(cfg,data_un_silence, data_exp_silence);

    %USES CUSTOM FUNCTION AT END OF SCRIPT TO FIND PEAK MMN LATENCIES
    unexp_mmn_c_locs = find_mmn_peak(data_un_silence, central, time);
    exp_mmn_c_locs   = find_mmn_peak(data_exp_silence, central, time);
    diff_mmn_c_locs  = find_mmn_peak(data_diff, central, time);

    unexp_mmn_f_locs = find_mmn_peak(data_un_silence, frontal, time);
    exp_mmn_f_locs   = find_mmn_peak(data_exp_silence, frontal, time);
    diff_mmn_f_locs  = find_mmn_peak(data_diff, frontal, time);

    
    mmn_C_locs(s,1:3) = unexp_mmn_c_locs;
    mmn_C_locs(s,4:6) = exp_mmn_c_locs;
    mmn_C_locs(s,7:9) = diff_mmn_c_locs;

    mmn_F_locs(s,1:3) = unexp_mmn_f_locs;
    mmn_F_locs(s,4:6) = exp_mmn_f_locs;
    mmn_F_locs(s,7:9) = diff_mmn_f_locs;
    
    %USES CUSTOM FUNCTION AT END OF SCRIPT TO FIND PEAK P3a LATENCIES
    unexp_p3_c_locs = find_p3_peak(data_un_silence, central, time);
    exp_p3_c_locs   = find_p3_peak(data_exp_silence, central, time);
    diff_p3_c_locs  = find_p3_peak(data_diff, central, time);

    unexp_p3_f_locs = find_p3_peak(data_un_silence, frontal, time);
    exp_p3_f_locs   = find_p3_peak(data_exp_silence, frontal, time);
    diff_p3_f_locs  = find_p3_peak(data_diff, frontal, time);

    p3_C_locs(s,1:3) = unexp_p3_c_locs;
    p3_C_locs(s,4:6) = exp_p3_c_locs;
    p3_C_locs(s,7:9) = diff_p3_f_locs;
 
    p3_F_locs(s,1:3) = unexp_p3_f_locs;
    p3_F_locs(s,4:6) = exp_p3_f_locs;
    p3_F_locs(s,7:9) = diff_p3_f_locs;

    
end

%REPLACES ANY NAN IN THE DATA WITH THE AVERAGE LATENCY
mmn_nan = isnan(mmn_C_locs);
avg_mmn_loc = round(mean(nanmean(mmn_C_locs)));
mmn_C_locs(mmn_nan) = avg_mmn_loc;

mmn_nan = isnan(mmn_F_locs);
avg_mmn_loc = round(mean(nanmean(mmn_F_locs)));
mmn_F_locs(mmn_nan) = avg_mmn_loc;

p3_nan = isnan(p3_C_locs);
avg_p3_loc = round(mean(nanmean(p3_C_locs)));
p3_C_locs(p3_nan) = avg_p3_loc;

p3_nan = isnan(p3_F_locs);
avg_p3_loc = round(mean(nanmean(p3_F_locs)));
p3_F_locs(p3_nan) = avg_p3_loc;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% MEAN AROUND PEAK FOR CENTRAL  ELECTRODES %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for s = 1:length(allData_unexpected_silence) 
    
    data_un_silence  = allData_unexpected_silence{s}; 
    data_exp_silence = allData_expected_silence{s}; 
    
    cfg=[];
    cfg.operation = 'subtract'; 
    cfg.parameter = 'avg';
    data_diff = ft_math(cfg,data_un_silence, data_exp_silence);

    %CALUCLATES MEAN AMPLITUDE FOR THE MMN AROUND PEAK LATENCY WITH CUSTOM FUNCTION
    unexp_mmn_mean = extract_means(data_un_silence, mmn_C_locs(s,1:3), CL_ind, CZ_ind,CR_ind);
    exp_mmn_mean   = extract_means(data_exp_silence, mmn_C_locs(s,4:6), CL_ind, CZ_ind,CR_ind);
    diff_mmn_mean  = extract_means(data_diff, mmn_C_locs(s,7:9), CL_ind, CZ_ind,CR_ind);

    %CONCATENATE AND STORE THE MMN MEAN APLITUDE DATA
    mmn_means = [unexp_mmn_mean, exp_mmn_mean,diff_mmn_mean];
    allSubs_mmn_C_means(s,:) = mmn_means;
    
    %CALUCLATES MEAN AMPLITUDE FOR THE P3a AROUND PEAK LATENCY WITH CUSTOM FUNCTION  
    unexp_p3_mean = extract_means(data_un_silence, p3_C_locs(s,1:3),CL_ind, CR_ind,CZ_ind);
    exp_p3_mean   = extract_means(data_exp_silence,p3_C_locs(s,4:6),CL_ind, CR_ind,CZ_ind);
    diff_p3_mean  = extract_means(data_diff, p3_C_locs(s,7:9), CL_ind, CR_ind,CZ_ind);
    
    %CONCATENATE AND STORE THE P3a MEAN APLITUDE DATA
    p3_means = [unexp_p3_mean, exp_p3_mean,diff_p3_mean];
    allSubs_p3_C_means(s,:) = p3_means;
    
   
end


%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% MEAN AROUND PEAK FOR FRONTAL  ELECTRODES %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for s = 1:length(allData_unexpected_silence) 
    data_un_silence = allData_unexpected_silence{s}; 
    data_exp_silence = allData_expected_silence{s}; 

    cfg=[];
    cfg.operation = 'subtract'; 
    cfg.parameter = 'avg';
    data_diff = ft_math(cfg,data_un_silence, data_exp_silence);

    %CALUCLATES MEAN AMPLITUDE FOR THE P3a AROUND PEAK LATENCY WITH CUSTOM FUNCTION 
    unexp_mmn_mean = extract_means(data_un_silence, mmn_F_locs(s,1:3), FL_ind, FR_ind,FZ_ind);
    exp_mmn_mean = extract_means(data_exp_silence, mmn_F_locs(s,4:6), FL_ind, FR_ind,FZ_ind);
    diff_mmn_mean   = extract_means(data_diff, mmn_F_locs(s,7:9), FL_ind, FR_ind,FZ_ind);
    
    %CONCATENATE AND STORE THE P3a MEAN APLITUDE DATA
    mmn_means = [unexp_mmn_mean, exp_mmn_mean,diff_mmn_mean];
    allSubs_mmn_F_means(s,:) = mmn_means;
    
    %CALUCLATES MEAN AMPLITUDE FOR THE P3a AROUND PEAK LATENCY WITH CUSTOM FUNCTION 
    unexp_p3_mean = extract_means(data_un_silence, p3_F_locs(s,1:3),FL_ind, FR_ind,FZ_ind);
    exp_p3_mean = extract_means(data_exp_silence,p3_F_locs(s,4:6),FL_ind, FR_ind,FZ_ind);
    diff_p3_mean   = extract_means(data_diff,p3_F_locs(s,7:9),FL_ind, FR_ind,FZ_ind);

    %CONCATENATE AND STORE THE P3a MEAN APLITUDE DATA
    p3_means = [unexp_p3_mean, exp_p3_mean, diff_p3_mean];
    allSubs_p3_F_means(s,:) = p3_means;
    
   
end


allSubs_mmn = [allSubs_mmn_C_means, allSubs_mmn_F_means];
allSubs_p3  = [allSubs_p3_C_means,  allSubs_p3_F_means];

