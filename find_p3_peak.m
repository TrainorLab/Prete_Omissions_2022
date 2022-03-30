
function output = find_p3_peak(x, regions,time) 

% x       = erp data in fieldtrip format after ft_timelockanalysis
% regions = logical index of EEG channels 
% time    = vector of the time of the ERP
% output  = location index of the peak latency 


output = zeros(length(regions),1);
for ii = 1:length(regions)
    data = mean(x.avg(regions{ii},:),1); 
     
    [~, ind_250] = min(abs(time -.250));
    [~, ind_400] = min(abs(time -.400));

    [peaks,locs]  = findpeaks(data(:,ind_250:ind_400));
    [~, max_peak] = max(peaks);
    
    if isempty(max_peak)
        output(ii) = nan;
    else
        output(ii) = locs(max_peak)+ind_250-1;
    end
end
end