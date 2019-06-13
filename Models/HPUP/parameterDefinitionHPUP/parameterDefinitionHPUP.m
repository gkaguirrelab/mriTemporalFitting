function paramStruct = parameterDefinitionHPUP(nInstances, varargin)
% paramStruct = paramCreateBDCM(nStimuli)
%
% Create a default parameters structure for the three component, six
% parameter pupil model.
%
% This includes default parameters plus lower and upper bounds,
% as well as a field with parameter names.
%
% If passed, the paramMainMtrix (which are the initial values), vlb,
%   or vub will be used instead of the default values.
%

%% Parse vargin for options passed here
p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('nInstances',@isnumeric);
p.addParameter('initialValues',[],@isnumeric);
p.addParameter('vlb',[],@isnumeric);
p.addParameter('vub',[],@isnumeric);
p.parse(nInstances,varargin{:});

% Parameters:
% delay - time to shift the model to the right (msecs)
% gammaTau - time constant of the Gamma function (msecs)
% exponentialTau - time constant of the persistent component (seconds)
% amplitudeTransient - scaling of the transient component in (%change*secs)
% amplitudeSustained - scaling of the sustained component in (%change*secs)
% amplitudePersistent - scaling of the persistent component in (%change*secs)


% cell for labeling each parameter column
paramStruct.paramNameCell = {...
    'gammaTau', ...
    'LMSPersistentGammaTau', ...
    'LMSDelay',...
    'LMSExponentialTau', ...
    'LMSAmplitudeTransient', ...
    'LMSAmplitudeSustained', ...
    'LMSAmplitudePersistent', ...
    'MelanopsinPersistentGammaTau', ...
    'MelanopsinDelay',...
    'MelanopsinExponentialTau', ...
    'MelanopsinAmplitudeTransient', ...
    'MelanopsinAmplitudeSustained', ...
    'MelanopsinAmplitudePersistent', ...
    'LightFluxPersistentGammaTau', ...
    'LightFluxDelay',...
    'LightFluxExponentialTau', ...
    'LightFluxAmplitudeTransient', ...
    'LightFluxAmplitudeSustained', ...
    'LightFluxAmplitudePersistent', ...
    };

% initial values
if isempty(p.Results.initialValues)
    paramStruct.paramMainMatrix(:,1) = 200.*ones([nInstances 1]);
    paramStruct.paramMainMatrix(:,2) = 200.*ones([nInstances 1]);
    paramStruct.paramMainMatrix(:,3) = -200.*ones([nInstances 1]);
    paramStruct.paramMainMatrix(:,4) = 10.*ones([nInstances 1]);
    paramStruct.paramMainMatrix(:,5) = -1.*ones([nInstances 1]);
    paramStruct.paramMainMatrix(:,6) = -1.*ones([nInstances 1]);
    paramStruct.paramMainMatrix(:,7) = -1.*ones([nInstances 1]);
    paramStruct.paramMainMatrix(:,8) = 200.*ones([nInstances 1]);
    paramStruct.paramMainMatrix(:,9) = -200.*ones([nInstances 1]);
    paramStruct.paramMainMatrix(:,10) = 10.*ones([nInstances 1]);
    paramStruct.paramMainMatrix(:,11) = -1.*ones([nInstances 1]);
    paramStruct.paramMainMatrix(:,12) = -1.*ones([nInstances 1]);
    paramStruct.paramMainMatrix(:,13) = -1.*ones([nInstances 1]);
    paramStruct.paramMainMatrix(:,14) = 200.*ones([nInstances 1]);
    paramStruct.paramMainMatrix(:,15) = -200.*ones([nInstances 1]);
    paramStruct.paramMainMatrix(:,16) = 10.*ones([nInstances 1]);
    paramStruct.paramMainMatrix(:,17) = -1.*ones([nInstances 1]);
    paramStruct.paramMainMatrix(:,18) = -1.*ones([nInstances 1]);
    paramStruct.paramMainMatrix(:,19) = -1.*ones([nInstances 1]);
else % use passed initial values
    for ii=1:length(paramStruct.paramNameCell)
        paramStruct.paramMainMatrix(:,ii) = p.Results.initialValues(ii).*ones([nInstances 1]);
    end
end

% set lower bounds
if isempty(p.Results.vlb)
    paramStruct.vlb(:,1) = repmat(1,[nInstances 1]);
    paramStruct.vlb(:,2) = repmat(1,[nInstances 1]);
    paramStruct.vlb(:,3) = repmat(-500,[nInstances 1]);
    paramStruct.vlb(:,4) = repmat(1,[nInstances 1]);
    paramStruct.vlb(:,5) = repmat(-10,[nInstances 1]);
    paramStruct.vlb(:,6) = repmat(-10,[nInstances 1]);
    paramStruct.vlb(:,7) = repmat(-10,[nInstances 1]);
    paramStruct.vlb(:,8) = repmat(1,[nInstances 1]);
    paramStruct.vlb(:,9) = repmat(-500,[nInstances 1]);
    paramStruct.vlb(:,10) = repmat(1,[nInstances 1]);
    paramStruct.vlb(:,11) = repmat(-10,[nInstances 1]);
    paramStruct.vlb(:,12) = repmat(-10,[nInstances 1]);
    paramStruct.vlb(:,13) = repmat(-10,[nInstances 1]);
    paramStruct.vlb(:,14) = repmat(1,[nInstances 1]);
    paramStruct.vlb(:,15) = repmat(-500,[nInstances 1]);
    paramStruct.vlb(:,16) = repmat(1,[nInstances 1]);
    paramStruct.vlb(:,17) = repmat(-10,[nInstances 1]);
    paramStruct.vlb(:,18) = repmat(-10,[nInstances 1]);
    paramStruct.vlb(:,19) = repmat(-10,[nInstances 1]);
else % used passed lower bounds
    for ii=1:length(paramStruct.paramNameCell)
        paramStruct.vlb(:,ii) = p.Results.vlb(ii).*ones([nInstances 1]);
    end
end

% set upper bounds
if isempty(p.Results.vub)
    paramStruct.vub(:,1) = repmat(1000,[nInstances 1]);
    paramStruct.vub(:,2) = repmat(1000,[nInstances 1]);
    paramStruct.vub(:,3) = repmat(0,[nInstances 1]);
    paramStruct.vub(:,4) = repmat(20,[nInstances 1]);
    paramStruct.vub(:,5) = repmat(0,[nInstances 1]);
    paramStruct.vub(:,6) = repmat(0,[nInstances 1]);
    paramStruct.vub(:,7) = repmat(0,[nInstances 1]);
    paramStruct.vub(:,8) = repmat(1000,[nInstances 1]);
    paramStruct.vub(:,9) = repmat(0,[nInstances 1]);
    paramStruct.vub(:,10) = repmat(20,[nInstances 1]);
    paramStruct.vub(:,11) = repmat(0,[nInstances 1]);
    paramStruct.vub(:,12) = repmat(0,[nInstances 1]);
    paramStruct.vub(:,13) = repmat(0,[nInstances 1]);
    paramStruct.vub(:,14) = repmat(1000,[nInstances 1]);
    paramStruct.vub(:,15) = repmat(0,[nInstances 1]);
    paramStruct.vub(:,16) = repmat(20,[nInstances 1]);
    paramStruct.vub(:,17) = repmat(0,[nInstances 1]);
    paramStruct.vub(:,18) = repmat(0,[nInstances 1]);
    paramStruct.vub(:,19) = repmat(0,[nInstances 1]);
else % used passed upper bounds
    for ii=1:length(paramStruct.paramNameCell)
        paramStruct.vub(:,ii) = p.Results.vub(ii).*ones([nInstances 1]);
    end
end

end % function
