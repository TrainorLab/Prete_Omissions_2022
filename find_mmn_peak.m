
function output = find_mmn_peak(x,regions,time) 

% x       = erp data in fieldtrip format after ft_timelockanalysis
% regions = logical index of EEG channels 
% time    = vector of the time of the ERP
% output  = location index of the peak latency 

output = zeros(length(regions),1);

for ii  = 1:length(regions)
    
    data = -1*mean(x.avg(regions{ii},:),1);
    
    [~, ind_100] = min(abs(time -.100));
    [~, ind_300] = min(abs(time -.300));
    
    [peaks,locs]  = findpeaks(data(:,ind_100:ind_300));
    [~, max_peak] = max(peaks);
    
    if isempty(max_peak)
        output(ii) = nan;
    else
        output(ii) = locs(max_peak)+ind_100-1;
    end
end

end








