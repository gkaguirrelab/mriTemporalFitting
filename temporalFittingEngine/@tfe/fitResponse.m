function [paramsFit,fVal,predictedResponse] = fitResponse(obj,thePacket,varargin)
% [paramsFit,fVal,predictedResponse] = fitResponse(obj,thePacket,varargin)
%
% Fit method for the tfe class.  This is meant to be model independent, so
% that we only have to write it once.
%
% Inputs:
%   thePacket: a valid packet
%
% Optional key/value pairs
%  'defaultParamsInfo' - struct (default empty).  This is passed to the defaultParams method.
%  'paramLockMatrix' - matrix (default empty). If not emptye, do parameter locking according
%    to passed matrix. This matrix has the same number of columns as the
%    parameter vector, and each row contains a 1 and a -1, which locks the
%    two corresponding parameters to each other.
%
% Outputs:
%   paramsFit: fit parameters
%   fVal: mean value of fit error, mean taken over runs.
%   predictedResponse: big vector containing the fit response

%% Parse vargin for options passed here
p = inputParser;
p.addRequired('thePacket',@isstruct);
p.addParameter('defaultParamsInfo',[],@isstruct);
p.addParameter('paramLockMatrix',[],@isnumeric);
p.parse(thePacket,varargin{:});

%% Set initial values and reasonable bounds on parameters
% Have a go at reasonable initial values
[paramsFit0,vlb,vub] = obj.defaultParams('defaultParamsInfo',p.Results.defaultParamsInfo);
paramsFitVec0 = obj.paramsToVec(paramsFit0);
vlbVec = obj.paramsToVec(vlb);
vubVec = obj.paramsToVec(vub);

%% David sez: "Fit that sucker"
%
% I coded up the global search method, but it is very slow compared with
% fmincon alone, and fmincon seems to be fine.

USEGLOBAL = false;
if (~USEGLOBAL)
    options = optimset('fmincon');
    options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set');
    paramsFitVec = fmincon(@(modelParamsVec)obj.fitError(modelParamsVec, ...
        thePacket.stimulus,thePacket.response,thePacket.kernel),paramsFitVec0,[],[],p.Results.paramLockMatrix,zeros([size(p.Results.paramLockMatrix,1) 1]),vlbVec,vubVec,[],options);
else
    opts = optimoptions(@fmincon,'Algorithm','interior-point');
    problem = createOptimProblem('fmincon','objective', ...
        @(modelParamsVec)obj.fitError(modelParamsVec,thePacket.stimulus,thePacket.response,thePacket.kernel),...
        'x0',paramsFitVec0,'lb',vlbVec,'ub',vubVec,'Aeq',p.Results.paramLockMatrix,'beq',zeros([size(p.Results.paramLockMatrix,1) 1]),'options',opts);
    gs = GlobalSearch;
    paramsFitVec = run(gs,problem);
end

% Get error and predicted response for final parameters
[fVal,predictedResponse] = obj.fitError(paramsFitVec,thePacket.stimulus,thePacket.response,thePacket.kernel);

% Convert fit parameters for return
paramsFit = obj.vecToParams(paramsFitVec);


end



