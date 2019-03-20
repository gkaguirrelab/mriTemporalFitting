%% Say hello
fprintf('Zhou et al., 2017. (Fig 1A-ish) - Step function stimulus subjected to the dCTS model with params from V1.\n');
fprintf('  In blue is the stimulus, in grey the simulated response, in red the model fit.\n\n');

%% Housekeeping and setup
clear all; close all;
stimulusStruct=[];
thePacket=[];
modelResponseStruct=[];
params=[];

temporalFit = tfeDynamicNormalization('verbosity','none'); % Construct the model object

%% Create a 500 msec step stimulus
deltaT = 1; % in msecs
totalTime = 1250; % in msecs
stimulusStruct.timebase = linspace(0,totalTime-deltaT,totalTime/deltaT);
stimulusStruct.values = zeros(1,length(stimulusStruct.timebase));
stimulusStruct.values(1,250:750)=1;
defaultParamsInfo.nInstances = 1;

%% We use the dCTS, and minimize the Zaidi component
params=temporalFit.defaultParams('defaultParamsInfo',defaultParamsInfo);
params.paramMainMatrix(1)=15; % broadband power
params.paramMainMatrix(2)=90; % gamma IRF time constant in msecs
params.paramMainMatrix(3)=8; % 8 second time constant of leaky negative integrator
params.paramMainMatrix(4)=0; % the inhibitory component is 0% of the positive effect
params.paramMainMatrix(5)=1.8; % compression in the dCTS
params.paramMainMatrix(6)=0.1; % adaptive time constant (in seconds)
params.paramMainMatrix(7)=0.1; % sigma saturation constant

params.noiseSd=1; % stdev of noise
params.noiseInverseFrequencyPower=0; % white noise

%% Plot stimulus profile
% Create a figure window
figure;

% plot the stimulus profile and a refline
plot(stimulusStruct.timebase/1000,stimulusStruct.values(1,:)*params.paramMainMatrix(1),'-b','DisplayName','stimulus');
hold on
refline(0,0);

%% create the simulated response
modelResponseStruct = temporalFit.computeResponse(params,stimulusStruct,[],'AddNoise',true);

%% Plot simulated response
temporalFit.plot(modelResponseStruct,'NewWindow',false,'Color',[0.5 0.5 0.5],'DisplayName','broad band power');

%% Construct a packet for fitting
thePacket.stimulus = stimulusStruct;
thePacket.response = modelResponseStruct;
thePacket.kernel = []; thePacket.metaData = [];

%% Fit the simulated data
[paramsFit.demo3,fVal,modelResponseStruct] = ...
    temporalFit.fitResponse(thePacket,...
    'defaultParamsInfo', defaultParamsInfo);

%% Plot fit
temporalFit.plot(modelResponseStruct,'NewWindow',false,'Color',[1 0.25 0.25],'DisplayName','fit');