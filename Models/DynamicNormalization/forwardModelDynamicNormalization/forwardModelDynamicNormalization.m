function [modelResponseStruct] = forwardModelDynamicNormalization(obj,params,stimulusStruct)
%% forwardModelDynamicNormalization
%
% This function creates a model of neural response given a vector of
% stimulus input, a vector of time points, and a set of parameters.
%
% The model includes the following stages:
%
%  - a neural impulse response function (modeled as a gamma function)
%  - a compressive non-linearity
%  - a delayed, divisive normalization stage
%    [or, a simple multiplicative exponential decay temporal scaling]
%  - an adaptive after-response, modeled as the subtractive influence
%    of a leaky (exponentialy decaying) integrator.
%
% The primary, positive response is taken from:
%
%   Zhou, Benson, Kay, Winawer (2017) Systematic changes in temporal
%     summation across human visual cortex

%% Unpack the params
%      amplitude - multiplicative scaling of the stimulus.
%      tauGammaIRF_CTS - time constant of the neural gamma IRF in msecs. A
%        value of 50 - 100 msecs was found in early visual areas.
%      epsilonCompression_CTS - compressive non-linearity of response.
%        Reasonable bouds are [0.1:1]. Not used if dCTS model evoked. 
%      tauExpTimeConstant_dCTS - time constant of the low-pass (exponential
%        decay) component (in secs). Reasonable bounds [0.1:1]
%      nCompression_dCTS - compressive non-linearity parameter. Reasonable
%        bounds [1:3], where 1 is no compression.
%      divisiveSigma_dCTS - Adjustment factor to the divisive temporal
%        normalization. Found to be ~0.1 in V1.

amplitude_CTSVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'amplitude_CTS'));
tauGammaIRF_CTSVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'tauGammaIRF_CTS'));
weightGammaIRFNeg_CTSVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'weightGammaIRFNeg_CTS'));

% Extract the elements of the dCTS model
tauExpTimeConstant_dCTSVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'tauExpTimeConstant_dCTS'));
nCompression_dCTSVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'nCompression_dCTS'));
divisiveSigma_dCTSVec=params.paramMainMatrix(:,strcmp(params.paramNameCell,'divisiveSigma_dCTS'));

%% Define basic model features

% derive some basic properties of the stimulus values
numInstances=size(stimulusStruct.values,1);
modelLength = length(stimulusStruct.timebase);

% pre-allocate the responseMatrix variable here for speed
responseMatrix=zeros(numInstances,modelLength);

% pre-allocate the convolution kernels for speed
gammaKernelStruct.timebase=stimulusStruct.timebase;
gammaKernelStruct.values=stimulusStruct.timebase*0;
inhibitoryKernelStruct.timebase=stimulusStruct.timebase;
inhibitoryKernelStruct.values=stimulusStruct.timebase*0;

exponentialKernelStruct.timebase=stimulusStruct.timebase;
exponentialKernelStruct.values=stimulusStruct.timebase*0;

%% We loop through each column of the stimulus matrix
for ii=1:numInstances
    
    %% grab the current stimulus
    signalStruct=stimulusStruct;
    signalStruct.values=signalStruct.values(ii,:);
    
    %% Apply gamma convolution
    % If tauGamma is not zero, applt a gamma function that transforms the
    % stimulus input into a profile of neural activity (e.g., LFP)
    if all(tauGammaIRF_CTSVec==0)
        yNeural=signalStruct.values;
    else
        gammaPositive = gammaKernelStruct;
        gammaPositive.values = gammaPositive.timebase .* exp(-gammaPositive.timebase/tauGammaIRF_CTSVec(ii));
        gammaPositive = normalizeKernelArea(gammaPositive);
        
        gammaNegative = gammaKernelStruct;
        gammaNegative.values = gammaNegative.timebase .* exp(-gammaNegative.timebase/(tauGammaIRF_CTSVec(ii)*1.5));
        gammaNegative = normalizeKernelArea(gammaNegative);
        
        gammaKernel = gammaPositive.values - weightGammaIRFNeg_CTSVec * gammaNegative.values;
        gammaKernelStruct.values = gammaKernel;
        % scale the kernel to preserve area of response after convolution
        gammaKernelStruct=normalizeKernelArea(gammaKernelStruct);
        % Convolve the stimulus struct by the gammaKernel
        yNeural=obj.applyKernel(signalStruct,gammaKernelStruct);
    end
    
    %% Implement the dCTS model.
    % Create the exponential low-pass kernel that defines the time-domain
    % properties of the normalization
    if all(tauExpTimeConstant_dCTSVec==0)
        yNeural = yNeural;
    else
        exponentialKernelStruct.values=exp(-1/(tauExpTimeConstant_dCTSVec(ii)*1000)*exponentialKernelStruct.timebase);
        % scale the kernel to preserve area of response after convolution
        exponentialKernelStruct=normalizeKernelArea(exponentialKernelStruct);
        % Convolve the linear response by the exponential decay
        denominatorStruct=obj.applyKernel(yNeural,exponentialKernelStruct);
        % Apply the compresion and add the semi-saturation constant
        denominatorStruct.values=(divisiveSigma_dCTSVec(ii)^nCompression_dCTSVec(ii)) + ...
            denominatorStruct.values.^nCompression_dCTSVec(ii);
        % Apply the compresion to the numerator
        numeratorStruct.values=yNeural.values.^nCompression_dCTSVec(ii);
        % Compute the final dCTS values
        yNeural.values=numeratorStruct.values./denominatorStruct.values;
    end
    
    %% Apply amplitude gain
    yNeural.values = yNeural.values.*amplitude_CTSVec(ii);
    
    %% Apply temporal shift
    %% DO IT HERE
    
    %% Mean center the output
    yNeural.values = yNeural.values - mean(yNeural.values);
    
    %% Place yNeural into the growing neuralMatrix
    responseMatrix(ii,:)=yNeural.values;
    
end % loop over rows of the stimulus matrix

%% Build the modelResponseStruct to return
modelResponseStruct.timebase=stimulusStruct.timebase;
modelResponseStruct.values=sum(responseMatrix,1);

end