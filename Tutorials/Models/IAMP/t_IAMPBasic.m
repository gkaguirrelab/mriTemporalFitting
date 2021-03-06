function [ paramsFit ] = t_IAMPBasic(varargin)
% function [ paramsFit ] = t_IAMPBasic(varargin)
%
% Demonstrate function for the IAMP Model.
%
% Optional key/value pairs
%  'generatePlots' - true/fale (default true).  Make plots?

% History:
%   01/05/19  dhb  Add basic test of averageParams method.

%% Parse vargin for options passed here
p = inputParser; p.PartialMatching = false;
p.addParameter('generatePlots',true,@islogical);
p.parse(varargin{:});


%% Construct the model object
temporalFit = tfeIAMP('verbosity','none');

%% Temporal domain of the stimulus
deltaT = 100; % in msecs
totalTime = 330000; % in msecs. This is a 5:30 duration experiment
stimulusStruct.timebase = linspace(0,totalTime-deltaT,totalTime/deltaT);
nTimeSamples = size(stimulusStruct.timebase,2);

%% Specify the stimulus struct.
% We will create a set of impulses of various amplitudes in a stimulus
% matrix. There will be an event every
eventTimes=linspace(1000,321000,21);
nInstances=length(eventTimes);
eventDuration=50; % pulse duration in msecs
defaultParamsInfo.nInstances = nInstances;

for ii=1:nInstances
    stimulusStruct.values(ii,:)=zeros(1,nTimeSamples);
    stimulusStruct.values(ii,eventTimes(ii)/deltaT:eventTimes(ii)/deltaT+eventDuration)=1;
end

%% Define a kernelStruct. In this case, a double gamma HRF
hrfParams.gamma1 = 6;   % positive gamma parameter (roughly, time-to-peak in secs)
hrfParams.gamma2 = 12;  % negative gamma parameter (roughly, time-to-peak in secs)
hrfParams.gammaScale = 10; % scaling factor between the positive and negative gamma componenets

kernelStruct.timebase=linspace(0,15999,16000);

% The timebase is converted to seconds within the function, as the gamma
% parameters are defined in seconds.  It's defined on 1 msec sampling
% timebase.
hrf = gampdf(kernelStruct.timebase/1000, hrfParams.gamma1, 1) - ...
    gampdf(kernelStruct.timebase/1000, hrfParams.gamma2, 1)/hrfParams.gammaScale;
kernelStruct.values=hrf;

% Normalize the kernel to have unit amplitude
[ kernelStruct ] = normalizeKernelArea( kernelStruct );

% When the IAMP model computes the response, it resamples the kernal to the
% same timebase as the response, if they differ.  That's slow.  So we can
% speed things up by doing it once here.
if (deltaT ~= 1)
    nSamples = ceil((kernelStruct.timebase(end)-kernelStruct.timebase(1))/deltaT);
    newKernelTimebase = kernelStruct.timebase(1):deltaT:(kernelStruct.timebase(1)+nSamples*deltaT);
    kernelStruct = temporalFit.resampleTimebase(kernelStruct,newKernelTimebase);
end

%% Get the default forward model parameters
params0 = temporalFit.defaultParams('defaultParamsInfo', defaultParamsInfo);

% Set the amplitude params to a random set of values to create the
% simulated signal
params0.paramMainMatrix=rand(nInstances,1);

fprintf('Default model parameters:\n');
temporalFit.paramPrint(params0);
fprintf('\n');

% Check on averageParams method and also show how to pass an object
% into a function and call methods of the object from that function.
[meanParams,semParams] =  testPassingObj(temporalFit,params0);
fprintf('Mean of params0 three times\n\n:');
temporalFit.paramPrint(meanParams);
fprintf('\n');
if (max(abs(meanParams.paramMainMatrix(:) - params0.paramMainMatrix(:))) > 1e-10)
    error('Something wrong with averaging parameters method');
end

fprintf('SEM of params0 three times\n\n:');
temporalFit.paramPrint(semParams);
fprintf('\n');
if (max(abs(semParams.paramMainMatrix(:))) > 1e-10)
    error('Something wrong with sem of parameters method');
end

%% Create and plot modeled responses

% Set the noise level and report the params
params0.noiseSd = 0.02;
fprintf('Simulated model parameters:\n');
temporalFit.paramPrint(params0);
fprintf('\n');

% First create and plot the response without noise and without convolution
modelResponseStruct = temporalFit.computeResponse(params0,stimulusStruct,[],'AddNoise',false);

if p.Results.generatePlots
    % Create a figure window
    figure;
    temporalFit.plot(modelResponseStruct,'NewWindow',false,'DisplayName','neural response');
    hold on
    % Add the stimulus profile to the plot
    plot(stimulusStruct.timebase/1000,stimulusStruct.values(1,:),'-k','DisplayName','stimulus');
end

% Now plot the response with convolution and noise, as well as the kernel
modelResponseStruct = temporalFit.computeResponse(params0,stimulusStruct,kernelStruct,'AddNoise',true);

if p.Results.generatePlots
    temporalFit.plot(modelResponseStruct,'NewWindow',false,'DisplayName','noisy BOLD response');
    plot(kernelStruct.timebase/1000,kernelStruct.values/max(kernelStruct.values),'-b','DisplayName','kernel');
end

%% Construct a packet and model params
thePacket.stimulus = stimulusStruct;
thePacket.response = modelResponseStruct;
thePacket.kernel = kernelStruct;
thePacket.metaData = [];

% We will fit each average response as a single stimulus in a packet, so
% each packet therefore contains a single stimulus instamce.
defaultParamsInfo.nInstances = nInstances;

%% Test the fitter
[paramsFit,fVal,modelResponseStruct] = ...
    temporalFit.fitResponse(thePacket,...
    'defaultParamsInfo', defaultParamsInfo, ...
    'searchMethod','linearRegression');

%% Report the output
fprintf('Model parameter from fits:\n');
temporalFit.paramPrint(paramsFit);
fprintf('\n');

% Plot of the temporal fit results
if p.Results.generatePlots
    temporalFit.plot(modelResponseStruct,'Color',[0 1 0],'NewWindow',false,'DisplayName','model fit');
    legend('show');legend('boxoff');
    hold off
end

% Plot of simulated vs. recovered parameter values
if p.Results.generatePlots
    figure
    plot(params0.paramMainMatrix,paramsFit.paramMainMatrix,'or')
    xlabel('simulated instance amplitudes') % x-axis label
    ylabel('estimated instance amplitudes') % y-axis label
end

end

% This function demonstrates how to pass and call an object
function [meanParams,semParams] = testPassingObj(theObj,theParams)
    [meanParams,semParams] = theObj.averageParams({theParams ; theParams ; theParams});
end
    