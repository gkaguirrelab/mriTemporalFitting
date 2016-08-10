function plotLinModelFitsWrap(timebase, avgTS, stdTS, MSE, modelTS, idCell, startTimesSorted_A, stimValuesSorted_A, startTimesSorted_B, stimValuesSorted_B)

% function plotLinModelFitsWrap(timebase, avgTS, stdTS, MSE, modelTS, idCell, startTimesSorted_A, stimValuesSorted_A, startTimesSorted_B, stimValuesSorted_B)
%
% wrapper function for BOLD fits--specialized for BDCM

figure;
set(gcf,'Position',[156 372 1522 641])

for i = 1:size(avgTS,1)
    % determine the run order
   if strfind(char(idCell(i)),' A')
        startTimesSorted = startTimesSorted_A;
        stimValuesSorted = stimValuesSorted_A;
   elseif strfind(char(idCell(i)),' B')
        startTimesSorted = startTimesSorted_B;
        stimValuesSorted = stimValuesSorted_B;
   else
      error('plotLinModelFitsWrap: unknown stimulus type');
   end
   % make a cell
   stimValuesMatSorted_cell = {} ;
   for j = 1:length(stimValuesSorted)
      stimValuesMatSorted_cell{j} = num2str(stimValuesSorted(j)) ; 
   end
   
   subplot(3,2,i)
   plotLinModelFits(timebase,avgTS(i,:),modelTS(i,:), ...
                     startTimesSorted,stimValuesMatSorted_cell,stimValuesSorted,stdTS(i,:),MSE(i,:));
   title(idCell(i)); xlabel('Time / s'); ylabel('% signal change');
   
end

end