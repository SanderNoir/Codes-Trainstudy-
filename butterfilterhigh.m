function [Y]=butterfilterhigh(order,fs,cf,signal)
% High-pass butterworth filter
% Input
% order     - The order of the filter
% fs        - Sample frequency
% cf        - Cutoff frequentie
% signal    - The signal you want to filter
%
% Output
% Y         - Filtered signal
%
% Created by Tom Buurke (2017)
% University of Groningen, University Medical Center Groningen, Center for
% Human Movement Sciences, The Netherlands
%
% Version 1.0 - Changelog (August 15 2017):
% First version
%

Wn=cf/(fs/2); %normalized cutoff frequency

% Filter:
[B,A]=butter(order,Wn,'high'); 
Y=filtfilt(B,A,signal);