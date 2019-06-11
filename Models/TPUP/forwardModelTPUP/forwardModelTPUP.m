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

delayVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'delay'));
gammaTauVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'gammaTau'));
persistentGammaTauVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'persistentGammaTau'));
exponentialTauVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'exponentialTau')).*1000;
amplitudeTransientVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'amplitudeTransient')).*1000;
amplitudeSustainedVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'amplitudeSustained')).*1000;
amplitudePersistentVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'amplitudePersistent')).*1000;

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
exponentialIRF.values=stimulusStruct.timebase .* 0;
exponentialIRF.timebase=stimulusStruct.timebase;


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
    
    transientComponent = stimulusSlewOn;
    sustainedComponent = stimulus;
    persistentComponent = stimulusSlewOn;
    
    %% Perform second neural transformation of input
    % Create the gamma kernel for the persistent component
    persistentGammaIRF.values = stimulus.timebase .* exp(-stimulus.timebase./persistentGammaTauVec(ii));
    persistentGammaIRF=normalizeKernelArea(persistentGammaIRF);

    
    % Create the exponential kernel
    exponentialIRF.values=exp(-1/exponentialTauVec(ii)*stimulus.timebase);
    exponentialIRF=normalizeKernelArea(exponentialIRF);
    
    % standard: make persistent component out of stimulusOnset. This implements the old TPUP
    %persistentComponent = obj.applyKernel(persistentComponent,exponentialIRF); 

    % apply transformation to the persistent component
    persistentComponent = obj.applyKernel(obj.applyKernel(persistentComponent,exponentialIRF),persistentGammaIRF); % standard: make persistent component out of stimulusOnset

    
    % for this stage, transient and sustained components are merely
    % intended to be convolved by a delta function. This operation returns
    % the input, so now actual code for this has been implemented.
    %% Perform motor plant transformtaion of input
    
    % Create the gamma kernel for pupil motor
    gammaIRF.values = stimulus.timebase .* exp(-stimulus.timebase./gammaTauVec(ii));
    gammaIRF=normalizeKernelArea(gammaIRF);
    
    % apply gamma kernel to each component
    transientComponent = obj.applyKernel(transientComponent,gammaIRF);
    sustainedComponent = obj.applyKernel(sustainedComponent,gammaIRF);
    persistentComponent = obj.applyKernel(persistentComponent,gammaIRF);

    
    %% Scale each component to have unit area
    transientComponent=normalizeKernelArea(transientComponent);
    sustainedComponent=normalizeKernelArea(sustainedComponent);
    persistentComponent=normalizeKernelArea(persistentComponent);
    
    yPupil=transientComponent.values * amplitudeTransientVec(ii) + ...
        sustainedComponent.values * amplitudeSustainedVec(ii) + ...
        persistentComponent.values * amplitudePersistentVec(ii);
    
    %% Apply the temporal delay
    initialValue=yPupil(1);
    yPupil=fshift(yPupil,-1*delayVec(ii)/deltaT);
    yPupil(1:ceil(-1*delayVec(ii)/deltaT))=initialValue;
    
    %% Add this stimulus model to the response matrix
    responseMatrix(ii,:)=yPupil;
    
end % loop over stimulus instances

% Check the result for nans
if ~sum(sum(isnan(responseMatrix)))==0
    error('NaNs detected in the responseMatrix');
end

%% Build the modelResponseStruct to return
modelResponseStruct.timebase=stimulusStruct.timebase;
modelResponseStruct.values=sum(responseMatrix,1);

end % function
