function mriTemporalFittingLocalHook
% mriTemporalFitting
%
% Configure things for working on the IBIOColorDetect project.
%
% For use with the ToolboxToolbox.  If you copy this into your
% ToolboxToolbox localToolboxHooks directory (by defalut,
% ~/localToolboxHooks) and delete "LocalHooksTemplate" from the filename,
% this will get run when you execute tbUse({'IBIOColorDetect'}) to set up for
% this project.  You then edit your local copy to match your local machine.
%
% The thing that this does is add subfolders of the project to the path as
% well as define Matlab preferences that specify input and output
% directories.
%
% You will need to edit the project location and i/o directory locations
% to match what is true on your computer.

%% Say hello
fprintf('Running mriTemporalFitting local hook\n');

%% Put project toolbox onto path
%
% Specify project name and location
projectName = 'mriTemporalFitting';
projectUrl = 'https://github.com/gkaguirrelab/mriTemporalFitting.git';
projectBaseDir = '/Users/Shared/Matlab/Analysis';

% declare the project git repo and two subfolders that we want on the path
withTMRIToolbox = tbToolboxRecord( ...
    'name', 'mriTemporalFitting', ...
    'type', 'git', ...
    'url', projectUrl, ...
    'subfolder', 'TMRIToolbox');
withBDCMToolbox = tbToolboxRecord( ...
    'name', 'mriTemporalFitting', ...
    'type', 'git', ...
    'url', projectUrl, ...
    'subfolder', 'BDCMToolbox');
withQCMToolbox = tbToolboxRecord( ...
    'name', 'mriTemporalFitting', ...
    'type', 'git', ...
    'url', projectUrl, ...
    'subfolder', 'QCMToolbox');
withPRFToolbox = tbToolboxRecord( ...
    'name', 'mriTemporalFitting', ...
    'type', 'git', ...
    'url', projectUrl, ...
    'subfolder', 'PRFToolbox');

% Obtain or update the git repo and add subfolders to the Matlab path
config = [withTMRIToolbox withBDCMToolbox withQCMToolbox withPRFToolbox];
tbDeployToolboxes('config', config, 'toolboxRoot', projectBaseDir, 'runLocalHooks', false);

%% Set preferences for project output
% %
% %outputBaseDir = '/Users/dhb/DropboxLab/IBIO_analysis';
% outputBaseDir = '/Volumes/Users1/DropboxLab/IBIO_analysis';
% 
% % Make base directory if it doesn't exist
% if (~exist(outputBaseDir))
%     mkdir(outputBaseDir);
% end
% 
% % This project's dir under the base dir
% theDir = fullfile(outputBaseDir,projectName);
% 
% % Set the preference
% setpref('IBIOColorDetect','outputBaseDir',theDir);
