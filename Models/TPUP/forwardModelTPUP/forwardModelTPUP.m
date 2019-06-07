function [modelResponseStruct] = forwardModelTPUP(obj,params,stimulusStruct)

%% forwardModelTPUP
%
% Models an evoked pupil response with a 6-parameter, 3-component model.
%
% The input to the model is the stimulus profile. An additional two input
%  vectors, representing the rate of stimulus change at onset, are created
%  by differentiating the stimulus profile and retaining the positive
%  elements. These three vectors are then subjected to convolution
%  operations composed of a gamma and exponential decay function, each
%  under the control of a single time-constant parameter. The resulting
%  three components (red) were normalized to have unit area, and then
%  subjected to multiplicative scaling by a gain parameter applied to each
%  component. The scaled components are summed to produce the modeled
%  response, which is temporally shifted.
%
% The response to be modeled should be in % change units (e.g. 10%
%  contraction, as opposed to 0.1) so that the various parameters have
%  similar magnitudes of effect upon the modeled response.
%
% delay - time to shift the model to the right (msecs)
% gammaTau - time constant of the Gamma function (msecs)
% exponentialTau - time constant of the persistent component (seconds)
% amplitudeTransient - scaling of the transient component in (%change*secs)
% amplitudeSustained - scaling of the sustained component in (%change*secs)
% amplitudePersistent - scaling of the persistent component in (%change*secs)



%% Unpack the params
%   Overall model timing
%     startTime -  left or right tie shift for the entire model, relative
%     to the stimulus
%     gammaTau - time constant of the transient gamma function


gammaTauVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'gammaTau'));
persistentGammaTauVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'persistentGammaTau'));
LMSDelayVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'LMSDelay'));
LMSExponentialTauVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'LMSExponentialTau')).*1000;
LMSAmplitudeTransientVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'LMSAmplitudeTransient')).*1000;
LMSAmplitudeSustainedVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'LMSAmplitudeSustained')).*1000;
LMSAmplitudePersistentVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'LMSAmplitudePersistent')).*1000;
MelanopsinDelayVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'MelanopsinDelay'));
MelanopsinExponentialTauVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'MelanopsinExponentialTau')).*1000;
MelanopsinAmplitudeTransientVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'MelanopsinAmplitudeTransient')).*1000;
MelanopsinAmplitudeSustainedVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'MelanopsinAmplitudeSustained')).*1000;
MelanopsinAmplitudePersistentVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'MelanopsinAmplitudePersistent')).*1000;
LightFluxDelayVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'LightFluxDelay'));
LightFluxExponentialTauVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'LightFluxExponentialTau')).*1000;
LightFluxAmplitudeTransientVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'LightFluxAmplitudeTransient')).*1000;
LightFluxAmplitudeSustainedVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'LightFluxAmplitudeSustained')).*1000;
LightFluxAmplitudePersistentVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'LightFluxAmplitudePersistent')).*1000;

% derive some basic properties of the stimulus values
numInstances=size(stimulusStruct.values,1);
check = diff(stimulusStruct.timebase);
deltaT = check(1);


% pre-allocate the responseMatrix and kernels here for speed
responseMatrix=zeros(numInstances,length(stimulusStruct.timebase));
gammaIRF.values = stimulusStruct.timebase .* 0;
gammaIRF.timebase = stimulusStruct.timebase;
persistentGammaIRF.values = stimulusStruct.timebase .* 0;
persistentGammaIRF.timebase = stimulusStruct.timebase;

LMSExponentialIRF.values=stimulusStruct.timebase .* 0;
LMSExponentialIRF.timebase=stimulusStruct.timebase;
MelanopsinExponentialIRF.values=stimulusStruct.timebase .* 0;
MelanopsinExponentialIRF.timebase=stimulusStruct.timebase;
LightFluxExponentialIRF.values=stimulusStruct.timebase .* 0;
LightFluxExponentialIRF.timebase=stimulusStruct.timebase;


%% We loop through each row of the stimulus matrix
for ii=1:numInstances
    
    %% Perform first neural transformation of input
    
    % grab the current stimulus
    stimulus.values = stimulusStruct.values(ii,:);
    stimulus.timebase = stimulusStruct.timebase;
    
    % Create a stimulusSlewOn vector. This is the rate of change of the
    % stimulus at the time of onset.
    stimulusSlewOn.values= max( [ [diff(stimulus.values) 0]; zeros(1,length(stimulus.timebase)) ] );
    stimulusSlewOn.timebase=stimulus.timebase;
    
    LMSTransientComponent = stimulusSlewOn;
    LMSSustainedComponent = stimulus;
    LMSPersistentComponent = stimulusSlewOn;
    
    %%%% MODELING THE LMS RESPONSE
    %% Perform second neural transformation of input
    % Create the gamma kernel for the persistent component
    persistentGammaIRF.values = stimulus.timebase .* exp(-stimulus.timebase./(persistentGammaTauVec(ii)));
    persistentGammaIRF=normalizeKernelArea(persistentGammaIRF);
    
    
    % Create the exponential kernel
    LMSExponentialIRF.values=exp(-1/LMSExponentialTauVec(ii)*stimulus.timebase);
    LMSExponentialIRF=normalizeKernelArea(LMSExponentialIRF);
    
    % Old TPUP implmentation: make persistent component out of stimulusOnset
    %persistentComponent = obj.applyKernel(persistentComponent,exponentialIRF);
    
    % apply transformation to the persistent component
    LMSPersistentComponent = obj.applyKernel(obj.applyKernel(LMSPersistentComponent,LMSExponentialIRF),persistentGammaIRF); % standard: make persistent component out of stimulusOnset
    
    
    % for this stage, transient and sustained components are merely
    % intended to be convolved by a delta function. This operation returns
    % the input, so now actual code for this has been implemented.
    %% Perform motor plant transformtaion of input
    
    % Create the gamma kernel for pupil motor
    gammaIRF.values = stimulus.timebase .* exp(-stimulus.timebase./gammaTauVec(ii));
    gammaIRF=normalizeKernelArea(gammaIRF);
    
    % apply gamma kernel to each component
    LMSTransientComponent = obj.applyKernel(LMSTransientComponent,gammaIRF);
    LMSSustainedComponent = obj.applyKernel(LMSSustainedComponent,gammaIRF);
    LMSPersistentComponent = obj.applyKernel(LMSPersistentComponent,gammaIRF);
    
    
    %% Scale each component to have unit area
    LMSTransientComponent=normalizeKernelArea(LMSTransientComponent);
    LMSSustainedComponent=normalizeKernelArea(LMSSustainedComponent);
    LMSPersistentComponent=normalizeKernelArea(LMSPersistentComponent);
    
    LMSPupil=LMSTransientComponent.values * LMSAmplitudeTransientVec(ii) + ...
        LMSSustainedComponent.values * LMSAmplitudeSustainedVec(ii) + ...
        LMSPersistentComponent.values * LMSAmplitudePersistentVec(ii);
    
    %% Apply the temporal delay
    initialValue=LMSPupil(1);
    LMSPupil=fshift(LMSPupil,-1*LMSDelayVec(ii)/deltaT);
    LMSPupil(1:ceil(-1*LMSDelayVec(ii)/deltaT))=initialValue;
    
    
    %%%% MODELING THE MELANOPSIN RESPONSE
       %% Perform first neural transformation of input
    
    % grab the current stimulus
    stimulus.values = stimulusStruct.values(ii,:);
    stimulus.timebase = stimulusStruct.timebase;
    
    % Create a stimulusSlewOn vector. This is the rate of change of the
    % stimulus at the time of onset.
    stimulusSlewOn.values= max( [ [diff(stimulus.values) 0]; zeros(1,length(stimulus.timebase)) ] );
    stimulusSlewOn.timebase=stimulus.timebase;
    
    MelanopsinTransientComponent = stimulusSlewOn;
    MelanopsinSustainedComponent = stimulus;
    MelanopsinPersistentComponent = stimulusSlewOn;
    
    %% Perform second neural transformation of input
    % Create the gamma kernel for the persistent component
    persistentGammaIRF.values = stimulus.timebase .* exp(-stimulus.timebase./(persistentGammaTauVec(ii)));
    persistentGammaIRF=normalizeKernelArea(persistentGammaIRF);
    
    
    % Create the exponential kernel
    MelanopsinExponentialIRF.values=exp(-1/MelanopsinExponentialTauVec(ii)*stimulus.timebase);
    MelanopsinExponentialIRF=normalizeKernelArea(MelanopsinExponentialIRF);
    
    % Old TPUP implmentation: make persistent component out of stimulusOnset
    %persistentComponent = obj.applyKernel(persistentComponent,exponentialIRF);
    
    % apply transformation to the persistent component
    MelanopsinPersistentComponent = obj.applyKernel(obj.applyKernel(MelanopsinPersistentComponent,MelanopsinExponentialIRF),persistentGammaIRF); % standard: make persistent component out of stimulusOnset
    
    
    % for this stage, transient and sustained components are merely
    % intended to be convolved by a delta function. This operation returns
    % the input, so now actual code for this has been implemented.
    %% Perform motor plant transformtaion of input
    
    % Create the gamma kernel for pupil motor
    gammaIRF.values = stimulus.timebase .* exp(-stimulus.timebase./gammaTauVec(ii));
    gammaIRF=normalizeKernelArea(gammaIRF);
    
    % apply gamma kernel to each component
    MelanopsinTransientComponent = obj.applyKernel(MelanopsinTransientComponent,gammaIRF);
    MelanopsinSustainedComponent = obj.applyKernel(MelanopsinSustainedComponent,gammaIRF);
    MelanopsinPersistentComponent = obj.applyKernel(MelanopsinPersistentComponent,gammaIRF);
    
    
    %% Scale each component to have unit area
    MelanopsinTransientComponent=normalizeKernelArea(MelanopsinTransientComponent);
    MelanopsinSustainedComponent=normalizeKernelArea(MelanopsinSustainedComponent);
    MelanopsinPersistentComponent=normalizeKernelArea(MelanopsinPersistentComponent);
    
    MelanopsinPupil=MelanopsinTransientComponent.values * MelanopsinAmplitudeTransientVec(ii) + ...
        MelanopsinSustainedComponent.values * MelanopsinAmplitudeSustainedVec(ii) + ...
        MelanopsinPersistentComponent.values * MelanopsinAmplitudePersistentVec(ii);
    
    %% Apply the temporal delay
    initialValue=MelanopsinPupil(1);
    MelanopsinPupil=fshift(MelanopsinPupil,-1*MelanopsinDelayVec(ii)/deltaT);
    MelanopsinPupil(1:ceil(-1*MelanopsinDelayVec(ii)/deltaT))=initialValue;
    
    
    %%%% MODELING THE LIGHTFLUX RESPONSE
        %% Perform first neural transformation of input
    
    % grab the current stimulus
    stimulus.values = stimulusStruct.values(ii,:);
    stimulus.timebase = stimulusStruct.timebase;
    
    % Create a stimulusSlewOn vector. This is the rate of change of the
    % stimulus at the time of onset.
    stimulusSlewOn.values= max( [ [diff(stimulus.values) 0]; zeros(1,length(stimulus.timebase)) ] );
    stimulusSlewOn.timebase=stimulus.timebase;
    
    LightFluxTransientComponent = stimulusSlewOn;
    LightFluxSustainedComponent = stimulus;
    LightFluxPersistentComponent = stimulusSlewOn;
    
    %% Perform second neural transformation of input
    % Create the gamma kernel for the persistent component
    persistentGammaIRF.values = stimulus.timebase .* exp(-stimulus.timebase./(persistentGammaTauVec(ii)));
    persistentGammaIRF=normalizeKernelArea(persistentGammaIRF);
    
    
    % Create the exponential kernel
    LightFluxExponentialIRF.values=exp(-1/LightFluxExponentialTauVec(ii)*stimulus.timebase);
    LightFluxExponentialIRF=normalizeKernelArea(LightFluxExponentialIRF);
    
    % Old TPUP implmentation: make persistent component out of stimulusOnset
    %persistentComponent = obj.applyKernel(persistentComponent,exponentialIRF);
    
    % apply transformation to the persistent component
    LightFluxPersistentComponent = obj.applyKernel(obj.applyKernel(LightFluxPersistentComponent,LightFluxExponentialIRF),persistentGammaIRF); % standard: make persistent component out of stimulusOnset
    
    
    % for this stage, transient and sustained components are merely
    % intended to be convolved by a delta function. This operation returns
    % the input, so now actual code for this has been implemented.
    %% Perform motor plant transformtaion of input
    
    % Create the gamma kernel for pupil motor
    gammaIRF.values = stimulus.timebase .* exp(-stimulus.timebase./gammaTauVec(ii));
    gammaIRF=normalizeKernelArea(gammaIRF);
    
    % apply gamma kernel to each component
    LightFluxTransientComponent = obj.applyKernel(LightFluxTransientComponent,gammaIRF);
    LightFluxSustainedComponent = obj.applyKernel(LightFluxSustainedComponent,gammaIRF);
    LightFluxPersistentComponent = obj.applyKernel( LightFluxPersistentComponent,gammaIRF);
    
    
    %% Scale each component to have unit area
    LightFluxTransientComponent=normalizeKernelArea(LightFluxTransientComponent);
    LightFluxSustainedComponent=normalizeKernelArea(LightFluxSustainedComponent);
    LightFluxPersistentComponent=normalizeKernelArea( LightFluxPersistentComponent);
    
    LightFluxPupil=LightFluxTransientComponent.values * LightFluxAmplitudeTransientVec(ii) + ...
        LightFluxSustainedComponent.values *  LightFluxAmplitudeSustainedVec(ii) + ...
        LightFluxPersistentComponent.values *  LightFluxAmplitudePersistentVec(ii);
    
    %% Apply the temporal delay
    initialValue=LightFluxPupil(1);
    LightFluxPupil=fshift(LightFluxPupil,-1*LightFluxDelayVec(ii)/deltaT);
    LightFluxPupil(1:ceil(-1*LightFluxDelayVec(ii)/deltaT))=initialValue;
    
    %% Add this stimulus model to the response matrix
    responseMatrix(ii,:)=[LMSPupil(1:length(stimulus.timebase)/3), MelanopsinPupil(1:length(stimulus.timebase)/3), LightFluxPupil(1:length(stimulus.timebase)/3)];
    
end % loop over stimulus instances

% Check the result for nans
if ~sum(sum(isnan(responseMatrix)))==0
    error('NaNs detected in the responseMatrix');
end

%% Build the modelResponseStruct to return
modelResponseStruct.timebase=stimulusStruct.timebase;
modelResponseStruct.values=sum(responseMatrix,1);

end % function
