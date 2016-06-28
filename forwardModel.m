function [reconstructedTSmatrix,startTimesSorted_A, ...
          stimValuesSorted_A, startTimesSorted_B, stimValuesSorted_B, ...
          actualStimulusValues,f] ...
                                      = ...
          forwardModel(startTimesSorted,stimValuesSorted,tsFileNames, ...
          TS_timeSamples,stimDuration,stepFunctionRes,cosRamp,stimTypeArr, ...
          t_convolve,BOLDHRF,cleanedData,neuralParams)

% function [betaMatrix,reconstructedTSmatrix,startTimesSorted_A, ...
%           stimValuesSorted_A, startTimesSorted_B, stimValuesSorted_B, ...
%           actualStimulusValues] ...
%                                       = ...
%           forwardModel(startTimesSorted,stimValuesSorted,tsFileNames, ...
%           TS_timeSamples,stimDuration,stepFunctionRes,cosRamp, ...
%           t_convolve,BOLDHRF,cleanedData)
%
% implements forward model for BOLD fitting project
%
% startTimesSorted: vector of starting times
% stimValuesSorted: stimulus values corresponding to startTimesSorted
% tsFileNames     : names of time series files corresponding to above
% TS_timesamples  : time samples for time series
% stimDuration    : stimulus duration
% stepFunctionRes : resolution for constructing stimulus vector
% cosRamp         : duration of cosine ramp, in seconds
% t_convolve      : time samples of convolution vectors
% cleanedData     : clean time series data

% get unique stimulus values
actualStimulusValues = unique(stimValuesSorted(stimValuesSorted~=-1 & stimValuesSorted~=0));

% Stire Stimulus Order A & B
stimValuesSorted_A = [] ;
stimValuesSorted_B = [] ;

% for each run
for i = 1:size(startTimesSorted,1)
    
    % Stores A & B sequences-- For labeling Time Series by Stimulus Period
   if strfind(char(tsFileNames(i)),'_A_') & isempty(stimValuesSorted_A)
      startTimesSorted_A = startTimesSorted(i,startTimesSorted(i,:)~=-1);  
      stimValuesSorted_A = stimValuesSorted(i,stimValuesSorted(i,:)~=-1); 
   elseif strfind(char(tsFileNames(i)),'_B_') & isempty(stimValuesSorted_B)
      startTimesSorted_B = startTimesSorted(i,startTimesSorted(i,:)~=-1); 
      stimValuesSorted_B = stimValuesSorted(i,stimValuesSorted(i,:)~=-1); 
   else
      stimOrderMarker = [] ; 
   end
   
    % for each stimulus
   % for each stimulus
   for j = 1:length(actualStimulusValues)
       % grab the starting times
       startTimesForGivenStimValue = startTimesSorted(i,stimValuesSorted(i,:)==actualStimulusValues(j));
       % create stimulus model for each one, and sum those models together
       % to get the stimulus model for each stimulus type
       singleStimModel = [];
       for k = 1:length(startTimesForGivenStimValue)
           % create the stimulus model
           singleStimModel(k,:) = createStimVector(TS_timeSamples,startTimesForGivenStimValue(k), ...
                        stimDuration,stepFunctionRes,cosRamp);
       end
       % there is a vector for each run and stimulus
       singleStimModelAllRuns(i,j,:) = sum(singleStimModel).*neuralParams(stimTypeArr(i),j);
   end
end

sumSquaredError = [];

reconstructedTSmatrix = [];

% LOOP OVER RUNS
for i = 1:size(singleStimModelAllRuns,1)   
    stimMatrixForOneRun = squeeze(singleStimModelAllRuns(i,:,:));
    neuralVec = sum(stimMatrixForOneRun);
    reconstructedTS = createRegressor(neuralVec,TS_timeSamples,BOLDHRF,t_convolve);
    reconstructedTSmatrix(i,:) = reconstructedTS;
   % get the error, square it, and sum
   sumSquaredError(i) = sum((reconstructedTS - cleanedData(i,:)).^2);
end

% sum sum-squared-error across all runs
f = sum(sumSquaredError);

gribble = 1;