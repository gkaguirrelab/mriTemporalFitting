function [modelResponseStruct] = forwardModelRPRF(obj,params,stimulusStruct, hrfKernelStruct)
%% forwardModelRPRF
%
% This function creates a model of neural response given a vector of
% stimulus input, a vector of time points, and a set of parameters.
%
% The model of neural activity is a step function, controlled by three
% parameters: amplitude, delay, and duration (secs). A kernel is built
% based upon the parameters, and then the stimulus vector is convolved by
% this kernel.
%

xPos=params.paramMainMatrix(:,strcmp(params.paramNameCell,'xPos'));
yPos=params.paramMainMatrix(:,strcmp(params.paramNameCell,'yPos'));
sigmaSize=params.paramMainMatrix(:,strcmp(params.paramNameCell,'sigmaSize'));
amplitude=params.paramMainMatrix(:,strcmp(params.paramNameCell,'amplitude'));

% Derive some parameters of the stimulus movie
xSize = size(stimulusStruct.values,1);
ySize = size(stimulusStruct.values,2);
nSamples = size(stimulusStruct.values,3);

% Pre-allocate the modelResponseStruct
modelResponseStruct.timebase=stimulusStruct.timebase;
modelResponseStruct.values=zeros(1,nSamples);

% Create a Gaussian kernel
[meshX , meshY] = meshgrid(1:ySize,1:xSize);
f = exp (-((meshY-xPos).^2 + (meshX-yPos).^2) ./ (2*sigmaSize.^2));

% Obtain the Gaussian weighted response at each timepoint
for i =1:nSamples
    S = stimulusStruct.values(:,:,i).*f;
    modelResponseStruct.values(i) = sum(S(:));
end

% Convolve the response by the hrf kernel
modelResponseStruct=obj.applyKernel(modelResponseStruct,hrfKernelStruct);

% Set the response to unit amplitude
modelResponseStruct.values=modelResponseStruct.values./max(modelResponseStruct.values);

% Scale by the amplitude parameter
modelResponseStruct.values=modelResponseStruct.values.*amplitude;

% Mean center
modelResponseStruct.values=modelResponseStruct.values - ...
    mean(modelResponseStruct.values);


end