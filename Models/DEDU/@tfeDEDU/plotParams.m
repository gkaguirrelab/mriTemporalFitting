function [h, meanParamValues,stdErrorParamValues] = plotParams(obj,params,stimulusStruct,varargin)
% plotParams(obj,params,stimulus,varargin)
%
% Generates plots of parameters
%
% Inputs:
%   params   : parameter structure
%   stimulus : stimulus structure
%
% Optional key/value pairs
%   'bFitZero' - boolean specifying whether to count '0' stimuli as stimuli
%                (default false)
% Outputs:
%   h: the figure handle
%   meanParamValues: m x n matrix of mean parameters, where m is the number
%                    of parameter types and n is the number of stimuli.
%                    Essentially stores the data to plot.

p = inputParser; p.PartialMatching = false;
p.addRequired('params',@isstruct);
p.addRequired('stimulusStruct',@isstruct);
p.addParameter('bFitZero',false,@islogical);
p.parse(params,stimulusStruct,varargin{:});

% Optionally remove stimulus values of 0 (some analyses might want to leave them in)
if ~p.Results.bFitZero
    stimulusStruct.values = stimulusStruct(stimulusStruct~=0);
end

% number of types of parameters, e.g. amp, tau2
numParamTypes = length(params.paramNameCell);

% get unique stimulus values
[uniqueStimValues,~] = unique(stimulusStruct);

% for each parameter type and stimulus value
for i = 1:numParamTypes
    for j = 1:length(uniqueStimValues)
       % go into the parameter matrix, find the appropriate column, and
       % pull out all positions with a given unique stim value
       meanParamValues(i,j) = mean(params.paramMainMatrix(uniqueStimValues(j)==stimulusStruct,i));
       stdErrorParamValues(i,j) = std(params.paramMainMatrix(uniqueStimValues(j)==stimulusStruct,i)) ...
                                      ./length(params.paramMainMatrix(uniqueStimValues(j)==stimulusStruct,i));
    end    
end

h = figure;
set(h,'Position',[398 380 1099 664]);
for i = 1:numParamTypes
    subplot(1,numParamTypes,i)
    plot(uniqueStimValues,meanParamValues(i,:),'-k^','MarkerSize',10,'LineWidth',1.5); axis square;
    set(gca,'Xscale','log'); set(gca,'Xtick',uniqueStimValues);
    ylabel(params.paramNameCell(i)); xlabel('Temporal frequency');
    set(gca,'FontSize',15);
end

end