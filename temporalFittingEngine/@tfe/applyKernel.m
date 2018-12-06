function [outputStruct,kernelStruct] = applyKernel(obj,inputStruct,kernelStruct,varargin)
% [outputStruct,kernelStruct] = applyKernel(obj,modelResponseStruct,kernelStruct,varargin)
%
% Apply a convolution kernel to a modeled response. In a typical
% application, this will be a hemodynamic response function applied to
% a model of neural activity to produce a BOLD fMRI response.
%
% The outputStruct's values field has the result of the convolution, and
% its timebase matches that of the input struct.
%
% The returned kernelStruct is the input, but if necessary its timebase has
% and values have been resampled to have the same delta time as the
% inputStruct's timebase.  The duration of the resampled kernel is at least
% as long as the original, and can be a little longer if the resampling
% requires an extension to produce an integer number of resampled times.
% This is returned mostly for debugging and checking purposes.
%
% Both modelResponseStruct and kernelStruct arguments are structures, containing
% timebase and values fields.  The timebases do not need to be the same, but
% each must be regularly sampled.
%
% Optional key/value pairs
%   'method' - string (default 'interp1_linear').  How to resample kernel timebase,
%      if needed.  This is passed onto method resampleTimebase.
%     'interp1_linear' - Use Matlab's interp1, linear method.

%% Parse vargin for options passed here
%
% Setting 'KeepUmatched' to true means that we can pass the varargin{:})
% along from a calling routine without an error here, if the key/value
% pairs recognized by the calling routine are not needed here.
p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('inputStruct',@isstruct);
p.addRequired('kernelStruct',@(x)(isempty(x) | isstruct(x)));
p.parse(inputStruct,kernelStruct,varargin{:});

%% Propagate all fields forward
outputStruct = inputStruct;

%% If empty matrix is passed for kernel, return
if (isempty(kernelStruct) || isempty(kernelStruct.values))
    return;
end

%% Get how many rows are in the the inputStruct value, and check
[nRows,nCols] = size(inputStruct.values);
if (size(inputStruct.timebase,2) ~= nCols)
    error('Badly formed response structure, length of timebase and values not the same.');
end
check = diff(inputStruct.timebase);
responseDeltaT = check(1);
if (any(abs(check - check(1)) > 1e-6))
    error('Response structure timebase is not regularly sampled');
end

%% Similar check on convolution kernel
if (length(kernelStruct.timebase) ~= length(kernelStruct.values))
    error('Badly formed kernel structure, length of timebase and values not the same.');
end
check = diff(kernelStruct.timebase);
kernelDeltaT = check(1);
if (any(abs(check - check(1)) > 1e-6))
    error('Kernel structure timebase is not regularly sampled');
end

%% Resample kernel to same delta time as response
if (responseDeltaT ~= kernelDeltaT)
    nSamples = ceil((kernelStruct.timebase(end)-kernelStruct.timebase(1))/responseDeltaT);
    newKernelTimebase = kernelStruct.timebase(1):responseDeltaT:(kernelStruct.timebase(1)+nSamples*responseDeltaT);
    kernelStruct = obj.resampleTimebase(kernelStruct,newKernelTimebase,varargin{:});
end

%% Loop over rows for the convolution
for ii=1:nRows
    % Convolve a row of inputStruct.values with the kernel.  The
    % convolutoin is a discrete approximation to an intergral, so we
    % explicitly include the factor of responseDeltaT.
    
    % old method
    valuesRowConv = conv(inputStruct.values(ii,:),kernelStruct.values, 'full')*responseDeltaT;
    
    % new nan-safe method
    valuesRowConv = nanconv_local(inputStruct.values(ii,:),kernelStruct.values, '1d')*responseDeltaT;
    
    
    % Cut off extra conv values
    outputStruct.values(ii,:) = valuesRowConv(1:length(inputStruct.timebase));
end

%% Local function nanconv
% from matlab central, with a few modifications to force the shape of the
% convolution be 'full', rather than 'same' which is all the built-in
% capacity the initial function has
    function c = nanconv_local(a, k, varargin)
        % NANCONV Convolution in 1D or 2D ignoring NaNs.
        %   C = NANCONV(A, K) convolves A and K, correcting for any NaN values
        %   in the input vector A. The result is the same size as A (as though you
        %   called 'conv' or 'conv2' with the 'same' shape).
        %
        %   C = NANCONV(A, K, 'param1', 'param2', ...) specifies one or more of the following:
        %     'edge'     - Apply edge correction to the output.
        %     'noedge'   - Do not apply edge correction to the output (default).
        %     'nanout'   - The result C should have NaNs in the same places as A.
        %     'nonanout' - The result C should have ignored NaNs removed (default).
        %                  Even with this option, C will have NaN values where the
        %                  number of consecutive NaNs is too large to ignore.
        %     '2d'       - Treat the input vectors as 2D matrices (default).
        %     '1d'       - Treat the input vectors as 1D vectors.
        %                  This option only matters if 'a' or 'k' is a row vector,
        %                  and the other is a column vector. Otherwise, this
        %                  option has no effect.
        %
        %   NANCONV works by running 'conv2' either two or three times. The first
        %   time is run on the original input signals A and K, except all the
        %   NaN values in A are replaced with zeros. The 'same' input argument is
        %   used so the output is the same size as A. The second convolution is
        %   done between a matrix the same size as A, except with zeros wherever
        %   there is a NaN value in A, and ones everywhere else. The output from
        %   the first convolution is normalized by the output from the second
        %   convolution. This corrects for missing (NaN) values in A, but it has
        %   the side effect of correcting for edge effects due to the assumption of
        %   zero padding during convolution. When the optional 'noedge' parameter
        %   is included, the convolution is run a third time, this time on a matrix
        %   of all ones the same size as A. The output from this third convolution
        %   is used to restore the edge effects. The 'noedge' parameter is enabled
        %   by default so that the output from 'nanconv' is identical to the output
        %   from 'conv2' when the input argument A has no NaN values.
        %
        % See also conv, conv2
        %
        % AUTHOR: Benjamin Kraus (bkraus@bu.edu, ben@benkraus.com)
        % Copyright (c) 2013, Benjamin Kraus
        % $Id: nanconv.m 4861 2013-05-27 03:16:22Z bkraus $
        
        % Process input arguments
        for arg = 1:nargin-2
            switch lower(varargin{arg})
                case 'edge'; edge = true; % Apply edge correction
                case 'noedge'; edge = false; % Do not apply edge correction
                case {'same','full','valid'}; shape = varargin{arg}; % Specify shape
                case 'nanout'; nanout = true; % Include original NaNs in the output.
                case 'nonanout'; nanout = false; % Do not include NaNs in the output.
                case {'2d','is2d'}; is1D = false; % Treat the input as 2D
                case {'1d','is1d'}; is1D = true; % Treat the input as 1D
            end
        end
        
        % Apply default options when necessary.
        if(exist('edge','var')~=1); edge = false; end
        if(exist('nanout','var')~=1); nanout = false; end
        if(exist('is1D','var')~=1); is1D = false; end
        if(exist('shape','var')~=1); shape = 'same';
        elseif(~strcmp(shape,'same'))
            error([mfilename ':NotImplemented'],'Shape ''%s'' not implemented',shape);
        end
        shape = 'full'
        
        % Get the size of 'a' for use later.
        sza = size(a);
        
        % If 1D, then convert them both to columns.
        % This modification only matters if 'a' or 'k' is a row vector, and the
        % other is a column vector. Otherwise, this argument has no effect.
        if(is1D);
            if(~isvector(a) || ~isvector(k))
                error('MATLAB:conv:AorBNotVector','A and B must be vectors.');
            end
            a = a(:); k = k(:);
        end
        
        % Flat function for comparison.
        o = ones(size(a));
        
        % Flat function with NaNs for comparison.
        on = ones(size(a));
        
        % Find all the NaNs in the input.
        n = isnan(a);
        
        % Replace NaNs with zero, both in 'a' and 'on'.
        a(n) = 0;
        on(n) = 0;
        
        % Check that the filter does not have NaNs.
        if(any(isnan(k)));
            error([mfilename ':NaNinFilter'],'Filter (k) contains NaN values.');
        end
        
        % Calculate what a 'flat' function looks like after convolution.
        if(any(n(:)) || edge)
            flat = conv2(on,k,shape);
            flat = flat(1:length(a));
        else flat = o;
        end
        
        % The line above will automatically include a correction for edge effects,
        % so remove that correction if the user does not want it.
        if(any(n(:)) && ~edge);
            flatScaler = conv2(o,k,shape);
            flatScaler = flatScaler(1:length(a));
            flat = flat./flatScaler;
        end
        
        % Do the actual convolution
        c = conv2(a,k,shape);
        c = c(1:length(a));
        c = c./flat;
        
        % If requested, replace output values with NaNs corresponding to input.
        if(nanout); c(n) = NaN; end
        
        % If 1D, convert back to the original shape.
        if(is1D && sza(1) == 1); c = c.'; end
        
    end


end


