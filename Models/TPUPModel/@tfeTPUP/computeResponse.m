function response = computeResponse(obj,params,timebase,stimulus,varargin)
% response = computeResponse(obj,params,timebase,stimulus,varargin)
%
% Compute method for the two-component pupil response model.
%
% The forward model consists of two components (an exponentially decaying
%   sustained response, and a super-saturating function persistent
%   response), under the control of 7 parameters.
%
% Optional key/value pairs
%   'AddNoise' - true/false (default false).  Add noise to computed
%     response?  Useful for simulations.
%  'HRF' - structure (default empty).  Structure describing HRF to be used
%     to go from neural to BOLD response. If empty, no convolution is done

% Parse input. At the moment this does type checking on the params input
% and has an optional key value pair that does nothing, but is here for us
% as a template.
p = inputParser;
p.addRequired('params',@isstruct);
p.addRequired('timebase',@isnumeric);
p.addRequired('stimulus',@isstruct);
p.addParameter('addNoise',false,@islogical);
p.addParameter('kernel',[]);
p.parse(params,timebase,stimulus,varargin{:});
params = p.Results.params;
timebase = p.Results.timebase;
stimulus = p.Results.stimulus;

%% Detect the presence of NaN values in the paramMainMatrix.
% Not sure why this happens sometimes. If we find NaNs, return
% a response vector of zeros, and update the screen with an 'n'
if sum(isnan(params.paramMainMatrix))~=0
    fprintf('n');
    response=timebase*0;
else
    
    %% Compute the forward model
    % *assume timebase is the same for all stimuli*
    individualResponses = forwardModelTPUP(timebase, stimulus.values,...
        params.paramMainMatrix(:,strcmp(params.paramNameCell,'startTime')), ...
        params.paramMainMatrix(:,strcmp(params.paramNameCell,'gammaTau')), ...
        params.paramMainMatrix(:,strcmp(params.paramNameCell,'sustainedAmp')), ...
        params.paramMainMatrix(:,strcmp(params.paramNameCell,'sustainedTau')), ...
        params.paramMainMatrix(:,strcmp(params.paramNameCell,'persistentAmp')), ...
        params.paramMainMatrix(:,strcmp(params.paramNameCell,'persistentT50')), ...
        params.paramMainMatrix(:,strcmp(params.paramNameCell,'persistentAlpha'))     );
    response = sum(individualResponses,1);
    
    % report an iteration has completed
    fprintf('.');
    
    %% Optionally, convolve with a passed kernel
    response = obj.applyKernel(timebase,response,p.Results.kernel);
    
    %% Optional add noise
    if (p.Results.addNoise)
        response = response + normrnd(0,params.noiseSd,size(response));
    end
end

end