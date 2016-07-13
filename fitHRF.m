function [HRF, cleanedData, SEHRF] = fitHRF(timeSeries,attnStartTimes,lengthAttnHRF,TS_timeSamples,T_R,type)

% function HRF = fitHRF_FIR(timeSeries,attnStartTimes)
%
% derives HRF across multiple runs

% call the HRF generator for each run, then average across runs
for i = 1:size(timeSeries,1)
   if strcmp(type,'Fourier')
       [hrf,timeSeriesNoAttn] = Derive_HRF_using_Fourier(TS_timeSamples, ...
                 timeSeries(i,:), attnStartTimes(i,attnStartTimes(i,:)~=-1)', ...
                 lengthAttnHRF,T_R) ;
   elseif strcmp(type,'FIR')
       [hrf,timeSeriesNoAttn] = attentionFIR(TS_timeSamples, ...
                 timeSeries(i,:), attnStartTimes(i,attnStartTimes(i,:)~=-1)', ...
                 lengthAttnHRF,T_R) ;
   else
       error('fitHRF: SPECIFY VALID MODEL');
   end
   hrfStore(i,:) = hrf ;    
   cleanedData(i,:) = timeSeriesNoAttn;
end

HRF = mean(hrfStore);
SEHRF = std(hrfStore)./sqrt(size(hrfStore,1));

gribble = 1;