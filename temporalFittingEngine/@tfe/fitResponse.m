function [paramsFit,fVal,modelResponseStruct] = fitResponse(obj,thePacket,varargin)
% [paramsFit,fVal,modelResponseStruct] = fitResponse(obj,thePacket,varargin)
%
% Syntax:
%  [paramsFit,fVal,modelResponseStruct] = obj.fitResponse(thePacket)
%
% Description:
%   Fit method for the tfe class.  This is meant to be model independent,
%   so that we only have to write it once.
%
% Inputs:
%   thePacket             - Structure. A valid packet
%
% Optional key/value pairs
%  'defaultParamsInfo'    - Struct (default empty).  This is passed to the
%                           defaultParams method.
%  'defaultParams'        - Struct (default empty). Params values for
%                           defaultParams to return. In turn determines
%                           starting value for search.
%  'searchMethod          - String (default 'fmincon').  Specify search
%                           method:
%                              'fmincon' - Use fmincon
%                              'global' - Use global search
%                              'linearRegression' - rapid estimation of
%                                   simplified models with only an
%                                   amplitude parameter
%  'DiffMinChange'        - Double (default empty). If not empty, changes
%                           the default value of this in the fmincon
%                           optionset.
%  'fminconAlgorithm'     - String (default 'active-set'). Passed on as
%                           algorithm in options to fmincon.
%  'errorType'            - String (default 'rmse'). Determines what error 
%                           is minimized, passed as an option to fitError
%                           method.
%
% Outputs:
%   paramsFit             - Structure. Fit parameters.
%   fVal                  - Scalar. Fit error
%   predictedResponse     - Structure. Response predicted from fit.
%
% History:
%   11/26/18  dhb       Added comments about key/value pairs that were not
%                       previously commented.
%   12/09/18  dhb       Comment improvements.
%   12/13/18  gka       Notes placed in git commit comments.

%% Parse vargin for options passed here
%
% Setting 'KeepUmatched' to true means that we can pass the varargin{:})
% along from a calling routine without an error here, if the key/value
% pairs recognized by the calling routine are not needed here.
p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('thePacket',@isstruct);
p.addParameter('defaultParamsInfo',[],@(x)(isempty(x) | isstruct(x)));
p.addParameter('defaultParams',[],@(x)(isempty(x) | isstruct(x)));
p.addParameter('searchMethod','fmincon',@ischar);
p.addParameter('DiffMinChange',[],@isnumeric);
p.addParameter('fminconAlgorithm','active-set',@ischar);
p.addParameter('errorType','rmse',@ischar);
p.parse(thePacket,varargin{:});

% Check packet validity
if (~obj.isPacket(thePacket))
    error('The passed packet is not valid for this model');
else
    switch (obj.verbosity)
        case 'high'
            fprintf('valid\n');
    end
end

%% Set initial values and reasonable bounds on parameters
[paramsFit0,vlb,vub] = obj.defaultParams('defaultParamsInfo',p.Results.defaultParamsInfo,'defaultParams',p.Results.defaultParams,varargin{:});
paramsFitVec0 = obj.paramsToVec(paramsFit0);
vlbVec = obj.paramsToVec(vlb);
vubVec = obj.paramsToVec(vub);

%% David sez: "Fit that sucker"
switch (obj.verbosity)
    case 'high'
        fprintf('Fitting.');
end

switch (p.Results.searchMethod)
    case 'fmincon'
        options = optimset('fmincon');
        options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm',p.Results.fminconAlgorithm);
        if ~isempty(p.Results.DiffMinChange)
            options = optimset(options,'DiffMinChange',p.Results.DiffMinChange);
        end
        paramsFitVec = fmincon(@(modelParamsVec)obj.fitError(modelParamsVec, ...
            thePacket, varargin{:}),paramsFitVec0,[],[],[],[],vlbVec,vubVec,[],options);
    case 'linearRegression'
        % linear regression can be used only when the paramsFit0 has only
        % a single parameter.
        if length(paramsFit0.paramNameCell)~=1
            error('fitResponse:invalidLinearRegression','Linear regression can only be applied in the case of a single model parameter')
        end
        %  Warn if the parameter is not called "amplitude".
        if ~(min(paramsFit0.paramNameCell{1}=='amplitude')==1)
            warning('fitResponse:invalidLinearRegression','Only amplitude parameters are suitable for linear regression')
        end
        % Take the stimulus.values as the regression matrix
        regressionMatrixStruct=thePacket.stimulus;
        % Convolve the rows of stimulus values by the kernel
        regressionMatrixStruct = obj.applyKernel(regressionMatrixStruct,thePacket.kernel,varargin{:});
        % Downsample regressionMatrixStruct to the timebase of the response
        regressionMatrixStruct = obj.resampleTimebase(regressionMatrixStruct,thePacket.response.timebase,varargin{:});
        % Perform the regression
        X=regressionMatrixStruct.values';
        y=thePacket.response.values';
        paramsFitVec=X\y;
    otherwise
        error('fitResponse:invalidSearchMethod','Do not know how to fit that sucker with specified method');
end

% Get error and predicted response for final parameters
[fVal,modelResponseStruct] = obj.fitError(paramsFitVec,thePacket,'errorType',p.Results.errorType);

switch (obj.verbosity)
    case 'high'
        fprintf('\n');
        fprintf('Fit error value: %g', fVal);
        fprintf('\n');
end

% Convert fit parameters for return
paramsFit = obj.vecToParams(paramsFitVec);

end



