function [  ] = t_LEAKBasic(varargin)
% function [  ] = t_LEAKBasic(varargin)
%
% Demonstrate the leaky integrator adaptation model
%
% We will model a binary sequence of events.
%
% Optional key/value pairs
%  'generatePlots' - true/fale (default true).  Make plots?

%% Parse vargin for options passed here
p = inputParser;
p.addParameter('generatePlots',true,@islogical);
p.parse(varargin{:});

%% Set the random number generator to default
rng('default');

%% Construct the model object
tfeHandle = tfeBTRM('verbosity','none');

%% Temporal domain of the stimulus
deltaT = 100; % in msecs
totalTime = 120000; % two minutes, in msecs
stimulusStruct.timebase = linspace(0,totalTime-deltaT,totalTime/deltaT);
nTimeSamples = size(stimulusStruct.timebase,2);

% Create the profile of a single event [cosine windowed step]
eventDur=3000;
rampDur=500;
event.timebase=0:deltaT:eventDur-deltaT;
event.values=event.timebase*0+1;
event.values(1,1:rampDur/deltaT) = (cos(pi+linspace(0,rampDur,rampDur/deltaT)/rampDur*pi)+1)/2;
event.values(1,end-rampDur/deltaT+1:end) = fliplr((cos(pi+linspace(0,rampDur,rampDur/deltaT)/rampDur*pi)+1)/2);

% Create the profile of a single event [half-cycle sine]
% eventDur=34000;
% event.timebase=0:deltaT:eventDur-deltaT;
% event.values=event.timebase*0;
% event.values(1,:) = sin(linspace(0,eventDur,eventDur/deltaT)/eventDur*2*pi);
% event.values=max([event.values; event.timebase*0]);

% Create a binary sequence of events
x = randi([0 1],totalTime/eventDur,1);
for ii=1:length(x)
    stimulusStruct.values(1,(ii-1)*(eventDur/deltaT)+1:ii*eventDur/deltaT)=event.values.*x(ii);
end


% Mean center the stimulus
%stimulusStruct.values(1,:)=stimulusStruct.values(1,:)-mean(stimulusStruct.values(1,:));

nInstances=1;
defaultParamsInfo.nInstances=nInstances;

%% Define a kernelStruct. In this case, a double gamma HRF
hrfParams.gamma1 = 6;   % positive gamma parameter (roughly, time-to-peak in secs)
hrfParams.gamma2 = 12;  % negative gamma parameter (roughly, time-to-peak in secs)
hrfParams.gammaScale = 10; % scaling factor between the positive and negative gamma componenets
kernelStruct.timebase=stimulusStruct.timebase;

% The timebase is converted to seconds within the function, as the gamma
% parameters are defined in seconds.
hrf = gampdf(kernelStruct.timebase/1000, hrfParams.gamma1, 1) - ...
    gampdf(kernelStruct.timebase/1000, hrfParams.gamma2, 1)/hrfParams.gammaScale;
kernelStruct.values=hrf;

% prepare this kernelStruct for use in convolution as a BOLD HRF
kernelStruct.values=kernelStruct.values-kernelStruct.values(1);
kernelStruct=normalizeKernelAmplitude(kernelStruct);

% Get the default forward model parameters
params0 = tfeHandle.defaultParams('defaultParamsInfo', defaultParamsInfo);
params0.noiseSd = .0001;
%params0.noiseTau = 0.0005;

% start the packet assembly
thePacket.stimulus = stimulusStruct;
thePacket.kernel = [];%kernelStruct;
thePacket.metaData = [];

% Create some dummy metaAData
thePacket.stimulus.metaData.stimTypes=[1];
thePacket.stimulus.metaData.stimLabels=['event'];

%% Report the modeled params
fprintf('Simulated model parameters:\n');
tfeHandle.paramPrint(params0);
fprintf('\n');

% Generate the simulated response
simulatedResponseStruct = tfeHandle.computeResponse(params0,thePacket.stimulus,thePacket.kernel,'AddNoise',false);

simulatedResponseStruct.values=simulatedResponseStruct.values/max(simulatedResponseStruct.values);

% Add the simulated response to this packet
thePacket.response=simulatedResponseStruct;

tfeHandle.plot(stimulusStruct,'Color',[0 0 1],'DisplayName','Stimulus');
tfeHandle.plot(simulatedResponseStruct,'Color',[1 0 0],'NewWindow',false,'DisplayName','Simulated');

%% Test the fitter
[paramsFit,fVal,modelResponseStruct] = ...
    tfeHandle.fitResponse(thePacket,...
    'defaultParamsInfo', defaultParamsInfo);

%% Report the output
fprintf('Model parameter from fits:\n');
tfeHandle.paramPrint(paramsFit);
fprintf('\n');

tfeHandle.plot(modelResponseStruct,'Color',[0 1 0],'NewWindow',false,'DisplayName','model fit');
legend('show');legend('boxoff');
hold off;

end % function