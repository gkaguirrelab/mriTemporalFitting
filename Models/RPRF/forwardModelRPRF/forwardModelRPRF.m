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
sigmaSize = 1;
amplitude=params.paramMainMatrix(:,strcmp(params.paramNameCell,'amplitude'));

% Obtain the temporal profile of the stimulus at the x, y location
    modelResponseStruct.timebase=stimulusStruct.timebase;
    modelResponseStruct.values=squeeze(stimulusStruct.values(xPos,yPos,:))';

    % Convolve the stimulus by the hrf kernel
    modelResponseStruct=obj.applyKernel(modelResponseStruct,hrfKernelStruct);

    % Make the response have unit amplitude
    modelResponseStruct.values=modelResponseStruct.values./max(modelResponseStruct.values);

    % Scale by the amplitude parameter
    modelResponseStruct.values=modelResponseStruct.values.*amplitude;

end