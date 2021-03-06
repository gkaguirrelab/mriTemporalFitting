function varargout = v_tfeApplyKernel(varargin)
% varargout = v_tfeApplyKernel(varargin)
%
% Works by running t_tfeApplyKernel with various arguments and comparing
% results with those stored.
%
% Validate applyKernel method of tfe parent class.

    varargout = UnitTest.runValidationRun(@ValidationFunction, nargout, varargin);
end

%% Function implementing the isetbio validation code
function ValidationFunction(runTimeParams)
    
    
    %% Basic validation
    UnitTest.validationRecord('SIMPLE_MESSAGE', '***** v_tfeApplyKernel *****');
    validationData1 = t_tfeApplyKernel('generatePlots',runTimeParams.generatePlots);
    UnitTest.validationData('validationData1',validationData1);
    
    %% Change kernel timebase deltaT
    UnitTest.validationRecord('SIMPLE_MESSAGE', '***** v_tfeApplyKernel(''kernelDeltaT'',0.5) *****');
    validationData2 = t_tfeApplyKernel('kernelDeltaT',0.5,'generatePlots',runTimeParams.generatePlots);
    UnitTest.validationData('validationData2',validationData2);
    
    %% Change kernel timebase deltaT to an odd value
    UnitTest.validationRecord('SIMPLE_MESSAGE', '***** v_tfeApplyKernel(''kernelDeltaT'',0.8) *****');
    validationData3 = t_tfeApplyKernel('kernelDeltaT',0.8,'generatePlots',runTimeParams.generatePlots);
    UnitTest.validationData('validationData3',validationData3);
    
end



