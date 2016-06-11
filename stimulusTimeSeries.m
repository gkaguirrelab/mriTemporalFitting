%%

% PLOTS TIME SERIES AND STIMULUS TOGETHER AS FUNCTIONS. SPECIFY THE SUBJECT 
% AND DATE BELOW. THE dirPath AND dirPathTimeSeries VARIABLES WILL ALSO NEED
% TO BE CHANGED TO RUN THIS ON CLUSTER. MAKES PLOTS ONE BY ONE--PRESS ANY 
% KEY TO CYCLE THROUGH THEM
%% SPECIFY SUBJECT AND SESSION
subj_name = 'HERO_asb1';
%     'HERO_asb1' 
%     'HERO_gka1'


session = '041416';
%     '041416' ...
%     '041516' ...
%%
% ORDER IN WHICH TIME SERIES DATA WAS COLLECTED, FOR FIGURING OUT WHICH
% TIME SERIES' TO PLOT WITH WHICH STIMULUS
tsFolderNamesASB1_DAY1 = { ...
    'bold_1.6_P2_mb5_LightFlux_A_run1' ...
    'bold_1.6_P2_mb5_L_minus_M_A_run1' ...
    'bold_1.6_P2_mb5_S_A_run1' ...
    'bold_1.6_P2_mb5_S_B_run1' ...
    'bold_1.6_P2_mb5_L_minus_M_B_run1' ...
    'bold_1.6_P2_mb5_LightFlux_A_run2' ...
    'bold_1.6_P2_mb5_L_minus_M_A_run2' ...
    'bold_1.6_P2_mb5_S_B_run2' ...
    'bold_1.6_P2_mb5_L_minus_M_B_run2' ...
    'bold_1.6_P2_mb5_LightFlux_B_run2'
};

tsFolderNamesASB1_DAY2 = { ...    
    'bold_1.6_P2_mb5_LightFlux_A_run3' ...
    'bold_1.6_P2_mb5_L_minus_M_A_run3' ...
    'bold_1.6_P2_mb5_S_A_run3' ...
    'bold_1.6_P2_mb5_S_B_run3' ...
    'bold_1.6_P2_mb5_L_minus_M_B_run3' ...
    'bold_1.6_P2_mb5_LightFlux_B_run3' ...
    'bold_1.6_P2_mb5_LightFlux_A_run4' ...
    'bold_1.6_P2_mb5_L_minus_M_A_run4' ...
    'bold_1.6_P2_mb5_S_A_run4' ...
    'bold_1.6_P2_mb5_S_B_run4' ...
    'bold_1.6_P2_mb5_L_minus_M_B_run4' ...
    'bold_1.6_P2_mb5_LightFlux_B_run4' ...   
    'bold_1.6_P2_mb5_LightFlux_A_run5' ...
    'bold_1.6_P2_mb5_L_minus_M_A_run5' ...
    'bold_1.6_P2_mb5_S_A_run5' ...    
    'bold_1.6_P2_mb5_S_B_run5' ...
    'bold_1.6_P2_mb5_L_minus_M_B_run5' ...
    'bold_1.6_P2_mb5_LightFlux_B_run5' ...
    'bold_1.6_P2_mb5_LightFlux_A_run6' ...
    'bold_1.6_P2_mb5_L_minus_M_A_run6' ...
    'bold_1.6_P2_mb5_S_A_run6' ...
    'bold_1.6_P2_mb5_S_B_run6' ...
    'bold_1.6_P2_mb5_L_minus_M_B_run6' ...
    'bold_1.6_P2_mb5_LightFlux_B_run6' ...
    'bold_1.6_P2_mb5_LightFlux_B_run1' ...
    'bold_1.6_P2_mb5_S_A_run2' ...
};

tsFolderNamesGKA1_DAY1 = { ...
    'bold_1.6_P2_mb5_LightFlux_A_run1' ...
    'bold_1.6_P2_mb5_L_minus_M_A_run1' ...
    'bold_1.6_P2_mb5_S_A_run1' ...
    'bold_1.6_P2_mb5_S_B_run1' ...
    'bold_1.6_P2_mb5_L_minus_M_B_run1' ...
    'bold_1.6_P2_mb5_LightFlux_B_run1' ...
    'bold_1.6_P2_mb5_LightFlux_A_run2' ...
    'bold_1.6_P2_mb5_L_minus_M_A_run2' ...
    'bold_1.6_P2_mb5_S_A_run2' ...
    'bold_1.6_P2_mb5_S_B_run2' ...    
    'bold_1.6_P2_mb5_L_minus_M_B_run2' ...
    'bold_1.6_P2_mb5_LightFlux_B_run2' ...
    'bold_1.6_P2_mb5_LightFlux_A_run3' ...
    'bold_1.6_P2_mb5_L_minus_M_A_run3' ...
    'bold_1.6_P2_mb5_S_A_run3' ...
    'bold_1.6_P2_mb5_S_B_run3' ...
    'bold_1.6_P2_mb5_L_minus_M_B_run3' ...
    'bold_1.6_P2_mb5_LightFlux_B_run3' ...
    'bold_1.6_P2_mb5_LightFlux_A_run4' ...
    'bold_1.6_P2_mb5_L_minus_M_A_run4' ...
    'bold_1.6_P2_mb5_S_A_run4' ...
};

tsFolderNamesGKA1_DAY2 = { ...
    'bold_1.6_P2_mb5_S_B_run4' ...
    'bold_1.6_P2_mb5_L_minus_M_B_run4' ...
    'bold_1.6_P2_mb5_LightFlux_B_run4' ...
    'bold_1.6_P2_mb5_LightFlux_A_run5' ...
    'bold_1.6_P2_mb5_L_minus_M_A_run5' ...
    'bold_1.6_P2_mb5_S_A_run5' ...
    'bold_1.6_P2_mb5_S_B_run5' ...
    'bold_1.6_P2_mb5_L_minus_M_B_run5' ...
    'bold_1.6_P2_mb5_LightFlux_B_run5' ...
    'bold_1.6_P2_mb5_LightFlux_A_run6' ...
    'bold_1.6_P2_mb5_L_minus_M_A_run6' ...
    'bold_1.6_P2_mb5_S_A_run6' ...
    'bold_1.6_P2_mb5_S_B_run6' ...
    'bold_1.6_P2_mb5_L_minus_M_B_run6' ...
    'bold_1.6_P2_mb5_LightFlux_B_run6 ' ...
};

% DEFINE PATH TO FOLDER FOR ONE SUBJECT ON ONE DATE
dirPath = ['/Users/benchin/Desktop/MELA_data/' subj_name '/' session '/' 'Stimuli/'];

% LOAD ALL CONTENTS OF DIRECTORY
files1 = dir(dirPath);

% NUMBER OF STIMULUS FOLDERS
numberOfFolders = length(files1);

% INITIALIZE CELL CONTAINING ALL STIMULUS FOLDER NAMES
folderNameCell = {};

% DURATION OF STIMULUS (ALWAYS THE SAME)
stimTime = 12;

% LOOP OVER NUMBER OF STIMULUS FOLDERS, AND CREATE CELL WITH ALL THEIR
% NAMES
for i = 1:numberOfFolders
   miniFolderName = files1(i).name;
   if length(miniFolderName)>4 & strcmp(miniFolderName(1:4),'HERO');
       folderNameCell{length(folderNameCell)+1} = miniFolderName;
   end
end

% DEFINE PATH TO TIME SERIES DATA
dirPathTimeSeries = ['/Users/benchin/Desktop/MELA_data/' subj_name '/' 'TimeSeries/'];

% SUBJECT AND DATE DETERMINE WHICH TIME SERIES FILES WE LOAD, AND THE ORDER
% THEY ARE PLOTTED IN
if strcmp(subj_name,'HERO_asb1') & strcmp(session,'041416')
    currentTimeSeriesFolder = tsFolderNamesASB1_DAY1;
elseif strcmp(subj_name,'HERO_asb1') & strcmp(session,'041516')
    currentTimeSeriesFolder = tsFolderNamesASB1_DAY2;
elseif strcmp(subj_name,'HERO_gka1') & strcmp(session,'041416')
    currentTimeSeriesFolder = tsFolderNamesGKA1_DAY1;
elseif strcmp(subj_name,'HERO_gka1') & strcmp(session,'041516')
    currentTimeSeriesFolder = tsFolderNamesGKA1_DAY2;
else
    error('stimulusTimeSeries ERROR: INPUT SUBJECT / DATE DOES NOT EXIST');
end

% GET THE CONTENTS OF THE TIME SERIES FOLDER
timeSeriesDir = dir(dirPathTimeSeries);

% GET A CELL CONTAINING THEIR NAMES BY LOOPING OVER
timeSeriesDirNames = {};

for i = 1:length(timeSeriesDir)
   tsFileName = timeSeriesDir(i).name;
   if length(tsFileName)>15
       timeSeriesDirNames{length(timeSeriesDirNames)+1} = tsFileName;
   end
end

% INITIALIZE MATRICES FOR STORING TIME SERIES 
LHtsMat = [];
RHtsMat = [];

% LOOK AT EACH FILE IN THE TIME SERIES FOLDER
for i = 1:length(currentTimeSeriesFolder)
    % CURRENT TIME SERIES FILE
    currentTSfileName = char(currentTimeSeriesFolder(i));
    % FIND ALL FILES CONTAINING THE FILE NAME WE WANT, AS DETERMINED BY THE
    % README FILE--GET THEIR LOCATIONS IN THE FOLDER
    tsFilesLHRH = strfind(timeSeriesDirNames,currentTSfileName);
    locationsInTSfolder = find(~cellfun(@isempty,tsFilesLHRH));
    % LOAD THE LEFT HEMISPHERE DATA, THEN THE RIGHT HEMISPHERE
    LHtsStruct = load([dirPathTimeSeries char(timeSeriesDirNames(locationsInTSfolder(1)))]);
    RHtsStruct = load([dirPathTimeSeries char(timeSeriesDirNames(locationsInTSfolder(2)))]);
    LHts = LHtsStruct.avgTC;
    RHts = RHtsStruct.avgTC;
    % STORE FOR PLOTTING LATER
    LHtsMat(i,:) = LHts;
    RHtsMat(i,:) = RHts;
end

% INITIALIZE ARRAYS FOR STORING STIMULUS PLOT DATA
timeValuesAllPlots = [];
stimValuesAllPlots = [];

% LOOP OVER STIMULUS FOLDER NAMES
for i = 1:length(folderNameCell)
   % LOOK IN EACH RUN'S FOLDER 
   currentDirPath = [dirPath char(folderNameCell(i))]; 
   % GET ALL THEIR CONTENTS
   runFiles = dir(currentDirPath);
   
   timeValuesMat = [];
   
   stimValuesMat = [];
   
   % LOOP OVER FILES IN EACH FOLDER
   for j = 1:length(runFiles)
       lengthOfCurFile = length(runFiles(j).name);
       curFile = runFiles(j).name;
       
       % WE ARE ONLY INTERESTED IN HZ_ALL FILES
       if length(curFile)>10 & strcmp(curFile(length(curFile)-9:length(curFile)),'Hz_all.txt')
          % EXTRACT THE TEMPORAL FREQ OF THE STIMULUS FROM THE FILE NAME
          stimFile = load([currentDirPath '/' curFile]); 
          freqValueTxt = curFile(length(curFile)-11:length(curFile)-10);
          
          % SOMETIMES IT IS A TWO-DIGIT NUMBER, AND OTHER TIMES A ONE-DIGIT
          % NUMBER (0,2,4,8,16,32,OR 64)
          if str2num(freqValueTxt)
              freqValueNum = str2num(freqValueTxt);
              
          else
              freqValueNum = str2num(freqValueTxt(2));            
          end
          
          % INITIALIZE MATRICES FOR STORING THE ACTUAL DATA POINTS
          timeValues = [];
          
          stimValues = [];
          
         % LOOP OVER ENTRIES IN EACH FILE 
         for k = 1:size(stimFile,1)
            % ALL THE STIMULUS STARTING TIMES ARE IN THE FIRST COLUMN
            curTimeValue = stimFile(k,1);
            % CREATE DATA POINTS--BOX-LIKE FUNCTION
            timeValues = [timeValues [curTimeValue curTimeValue+1e-10 ...
                          curTimeValue+stimTime curTimeValue+stimTime+1e-10]]; 
            stimValues = [stimValues [0 freqValueNum freqValueNum 0]];
         end
          
          % STORE
          timeValuesMat = [timeValuesMat timeValues];       
          stimValuesMat = [stimValuesMat stimValues];  
          
          % IF THE FILE CONTAINS ATTENTION TASK DATA
       elseif length(curFile)>20 & strcmp(curFile(length(curFile)-16:length(curFile)),'attentionTask.txt')
           attnFile = load([currentDirPath '/' curFile]); 
           
           attnTimeValues = [];
           attnStimValues = [];
           
           % ATTENTION TASK IS JUST A DIRAC DELTA FUNCTION TYPE DEAL
           for k = 1:size(attnFile,1)
                curTimeValue = attnFile(k,1);
                attnTimeValues = [attnTimeValues [curTimeValue curTimeValue+1e-10 curTimeValue+1e-8]]; 
                attnStimValues = [attnStimValues [0 96 0]];
           end
       end
       
   end
%    timeValuesAllPlots(i,:) = timeValuesMat;
%    stimValuesAllPlots(i,:) = stimValuesMat;
%   display(num2str(length(timeValuesMat)));
%    display(num2str(length(stimValuesMat)));
   figure;
   set(gcf,'Position',[439 222 1029 876]);
   subplot(3,1,3);
   plot(timeValuesMat,stimValuesMat); hold on
   plot(attnTimeValues,attnStimValues);
   subplot(3,1,2);
   plot(LHtsMat(i,:));
   subplot(3,1,1);
   plot(RHtsMat(i,:));
   pause;
   close;
end

[sortedTimeValues, indSortedTimeValues] = sort(timeValuesMat);

sortedStimValues = stimValuesMat(indSortedTimeValues);
