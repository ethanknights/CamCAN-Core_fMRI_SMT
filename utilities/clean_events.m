%% Purpose: Remove any 0ms RTs from an events data table.
%%
%% Arguments:
%% FileName = 'sub-CC110033_ses-smt_task-smt_events.tsv';
%% ========================================================================

function [cleanEvents] = clean_events(FileName)

  d = readtable(FileName,'FileType','text');

  idx = find(strcmp(d.trial_type,'button'));
  for i = 1:length(idx); check(i) = (d.onset(idx(i)) - d.onset(idx(i)-1)) == 0; end

  cleanEvents = d;
  cleanEvents(idx(check),:) = [];% drop RTs that equal 0

end