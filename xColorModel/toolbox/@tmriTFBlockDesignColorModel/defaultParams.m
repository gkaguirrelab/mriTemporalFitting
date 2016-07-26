function [params,paramsLb,paramsUb] = defaultParams(obj,varargin)
% [params,paramsLb,paramsUb] = defaultParams(obj,varargin)
%
% Set objects params to default values as well as provide reasonable lower
% and upper bournds.
%
% All three returns are in struct form, use paramsToVec on the structs to
% get vector form.
%
% % Optional key/value pairs
%  'DefaultParamsInfo' - A struct passed to the defaultParams method.  This
%  struct should have a field called nStimuli, which is used by this
%  routine.  If this struct is not passed, nStimuli is set to 10.

%% Parse vargin for options passed here
p = inputParser;
p.addParameter('DefaultParamsInfo',[],@isstruct);
p.parse(varargin{:});

%% Handle default number of stimuli
if (isempty(p.Results.DefaultParamsInfo))
    nStimuli = 10;
else
    nStimuli = p.Results.DefaultParamsInfo.nStimuli;
end

% Use general routine that is also called by the non-object oriented
% version of this model.  For that reason, we'll need to do a little
% reformating.
paramStruct = paramCreateBDCM(nStimuli);
params.paramNameCell = paramStruct.paramNameCell;
params.paramMainMatrix = paramStruct.paramMainMatrix;
params.matrixRows = size(params.paramMainMatrix,1);
params.matrixCols = size(params.paramMainMatrix,2);

% Upper and lower bound
paramsLb.paramNameCell = paramStruct.paramNameCell;
paramsLb.paramMainMatrix = paramStruct.vlb;
paramsUb.paramNameCell = paramStruct.paramNameCell;
paramsUb.paramMainMatrix = paramStruct.vub;

% Noise parameter for simulation
params.noiseSd = 0;

end