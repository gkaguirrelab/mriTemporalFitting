function paramPrint(obj,params,varargin)
% print(obj,params,varargin)
%
% Print out the parameters to the command window
%
% Key/value pairs
%   'PrintType'
%     'parameters' (default)
 
% Parse input. At the moment this does type checking on the params input
% and has an optional key value pair that does nothing, but is here for us
% as a template.
p = inputParser; p.PartialMatching = false;
p.addRequired('params',@isstruct);
p.addParameter('PrintType','parameters',@ischar);
p.parse(params,varargin{:});
params = p.Results.params;

% print the parameters
fprintf('Number of stimuli specified: %d\n',params.matrixRows);
fprintf('Number of parameter cols: %d\n',params.matrixCols);
for ii = 1:params.matrixCols
    fprintf('\tParameter %d: %s = %g\n',ii,params.paramNameCell{ii},params.paramMainMatrix(1,ii));
end
fprintf('Noise sd: %0.2f\n',params.noiseSd);


end