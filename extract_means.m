
function output = extract_means(input, peak_loc, left ,midline, right )
% input    = erp data in fieldtrip format after ft_timelockanalysis 
% peak_loc = 1x3 vector containing the ind of the peak latency for the
%            left, midline and right electrode regions 
% left     = logical index of the left electrode regions to be used
% midline  = logical index of the middle electrode regions to be used
% right    = logical index of the right electrode regions to be used
%
%output    = 1x3 vector of the mean amplitude average around the peak
%            latencies provided by peak_loc. 


    left_data    = mean(input.avg(left,:));
    right_data   = mean(input.avg(right,:));
    midline_data = mean(input.avg(midline,:));
    
    %+/- 3 ensure the window of average is 50ms around the peak latency
    win_left  = peak_loc-3;
    win_right = peak_loc+3;
    
    left_avg    = mean(left_data(:,win_left(1):win_right(1)));
    right_avg   = mean(right_data(:,win_left(3):win_right(3)));
    midline_avg = mean(midline_data(:,win_left(2):win_right(2)));
    output      = [left_avg,midline_avg,right_avg];

end