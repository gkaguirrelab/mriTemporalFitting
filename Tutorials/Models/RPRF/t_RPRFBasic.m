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
deltaT = 800; % in msecs
totalTime = 336*1000; % in msecs

%% Load an example stimulus file
stimulusFileName = fullfile(fileparts(mfilename('fullpath')),'pRFpacket_10x10.mat');
load(stimulusFileName);
stimulusStruct = stimulus;

% Create a stimulus movie (xSize x ySize x time)
nInstances=1;
defaultParamsInfo.nInstances=nInstances;

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

% start the packet assembly
thePacket.stimulus = stimulusStruct;
thePacket.kernel = kernelStruct;
thePacket.metaData = [];

% Randomize the order of the stimTypes
thePacket.stimulus.metaData.stimTypes=[1];
thePacket.stimulus.metaData.stimLabels=['demo'];

% Create some params to define the simulated data for this packet
paramsLocal=params0;
paramsLocal.noiseSd=0; % stdev of noise
paramsLocal.noiseInverseFrequencyPower=1; % pink noise
paramsLocal.paramMainMatrix(1,1)=7; % xPos
paramsLocal.paramMainMatrix(1,2)=5; % yPos
paramsLocal.paramMainMatrix(1,3)=1.5; % sigmaSize
paramsLocal.paramMainMatrix(1,4)=1; % amplitude
paramsLocal.paramMainMatrix(1,5)=0.5; % temporal offset of the hrf

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


%% Test the fitter
[paramsFit,fVal,modelResponseStruct] = ...
    tfeHandle.fitResponse(thePacket,...
    'defaultParamsInfo', defaultParamsInfo);

%% Report the output
fprintf('Model parameter from fits:\n');
tfeHandle.paramPrint(paramsFit);
fprintf('\n');

if p.Results.generatePlots
    tfeHandle.plot(modelResponseStruct,'Color',[0 1 0],'NewWindow',false,'DisplayName','model fit');
    legend('show');legend('boxoff');
end

%% Set returned validationData structure
if (nargout > 0)
    validationData.params1 = paramsFit;
    validationData.modelResponseStruct = modelResponseStruct;
    validationData.thePacket = thePacket;
end

end % function
