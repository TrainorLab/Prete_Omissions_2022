# Prete_Omissions_2022

Preprocessing, analysis and amplitude data used for the Prete et al., 2022 manuscript. Repository uses the open source MIT license agreement. 

Repeated_measures_Anova.R = R script used for statistical ananlysis of the peak ERP data

MMN_ICA_One_latency_per_region_per_condition_typical_filte2r.csv = CSV file containing the peak MMN ampltitudes used for statistical analysis
p3a_ICA_One_latency_per_region_per_condition_typical_filte2r.csv = CSV file containing the peak MMN ampltitudes used for statistical analysis

InfantOmitt_rates_Preproc_ERP_typical_filter.m = MATLAB script used to preprocess the EEG data and calcualte the ERPS. Requires fieldtrip toolbox
InfatnOmit_rates_component_means_per_region.m  = MATLAB script used to caluclate the peak MMN and P3a amplitudes from the preprocessed ERP data. REquires filedtrip toolbox, extract)means.m, find_mmn_peak.m and find_p3a_peak.m

extract_means.m = MATLAB function used to calculate the mean peak amplitude. 
find_mmn_peak.m = MATLBA function to find peak MMN latencies
find_p3a_peak.m = MATLAB function to find peak p3A latencies
