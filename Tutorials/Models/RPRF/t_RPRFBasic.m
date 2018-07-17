function validationData = t_RPRFBasic(varargin)
% validationData = t_RPRFBasic(varargin)
%
% Demonstrate pRF model
%
% We will model a single event.
%
% Optional key/value pairs
%  'generatePlots' - true/fale (default true).  Make plots?

%% Parse vargin for options passed here
p = inputParser;
p.addParameter('generatePlots',true,@islogical);
p.parse(varargin{:});

%% Construct the model object
tfeHandle = tfeRPRF('verbosity','none');

%% Spatial and Temporal definition of the stimulus
deltaT = 3000; % in msecs
totalTime = 300000; % in msecs
xSize = 10;
ySize = 10;
stimulusStruct.timebase = linspace(0,totalTime-deltaT,totalTime/deltaT);
nTimeSamples = size(stimulusStruct.timebase,2);

% Create a stimulus movie (xSize x ySize x time)
nInstances=1;
defaultParamsInfo.nInstances=nInstances;
stimulusStruct.values=zeros(xSize,ySize,nTimeSamples);

% Have a stimulus bar drift upwards over the time
for tt = 1:nTimeSamples
    xPos = mod(tt,xSize)+1;
    stimulusStruct.values(xPos,:,tt)=1;
end

%% Define a kernelStruct. In this case, a double gamma HRF
hrfParams.gamma1 = 6;   % positive gamma parameter (roughly, time-to-peak in secs)
hrfParams.gamma2 = 12;  % negative gamma parameter (roughly, time-to-peak in secs)
hrfParams.gammaScale = 10; % scaling factor between the positive and negative gamma componenets

kernelStruct.timebase = linspace(0,totalTime-deltaT,totalTime/deltaT);

% The timebase is converted to seconds within the function, as the gamma
% parameters are defined in seconds.
hrf = gampdf(kernelStruct.timebase/1000, hrfParams.gamma1, 1) - ...
    gampdf(kernelStruct.timebase/1000, hrfParams.gamma2, 1)/hrfParams.gammaScale;
kernelStruct.values=hrf;

% prepare this kernelStruct for use in convolution as a BOLD HRF
kernelStruct.values=kernelStruct.values-kernelStruct.values(1);
kernelStruct=normalizeKernelArea(kernelStruct);

% Get the default forward model parameters
params0 = tfeHandle.defaultParams('defaultParamsInfo', defaultParamsInfo);
params0.noiseSd = 0.01;

% start the packet assembly
thePacket.stimulus = stimulusStruct;
thePacket.kernel = kernelStruct;
thePacket.metaData = [];

% Randomize the order of the stimTypes
thePacket.stimulus.metaData.stimTypes=[1];
thePacket.stimulus.metaData.stimLabels=['demo'];

% Create some params to define the simulated data for this packet
paramsLocal=params0;
paramsLocal.paramMainMatrix(1,1)=2; % xPos
paramsLocal.paramMainMatrix(1,2)=5; % yPos
paramsLocal.paramMainMatrix(1,3)=3; % amplitude

%% Report the modeled params
fprintf('Simulated model parameters:\n');
tfeHandle.paramPrint(paramsLocal);
fprintf('\n');

% Generate the simulated response
simulatedResponseStruct = tfeHandle.computeResponse(paramsLocal,thePacket.stimulus,thePacket.kernel,'AddNoise',true);

% Add the simulated response to this packet
thePacket.response=simulatedResponseStruct;

if p.Results.generatePlots
    tfeHandle.plot(simulatedResponseStruct,'DisplayName','Simulated');
end


end % function
