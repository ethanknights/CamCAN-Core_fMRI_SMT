# CamCAN_fMRI-SMT_events
This repository logs changes (2022 onwards) for Matlab analysis code of Cam-CAN's fMRI SMT task. <br>
Specifically, new appended code (see git commit history) generates
new event files (to match Cam-CAN MEG SMT task) 
that include event onsets for button presses (i.e. Reaction Times; RTs).
<br>
<br>

# Example Output

```sub-<CCID>_ses-smt_task-smt_events.tsv```

| onset  |      duration      |  trial_type |
|----------|:-------------:|------:|
| 4.13 | 0.3 | AudVid1200 |
| 4.41 | 0 | button |
6.147 |	0.3 |	AudVid300 |
6.428 |	0 |	button |
| ... | ... | ... |
| 504.063 | 0.3 | AudVid300 |
| 504.323 | 0 | button |

<br>

# For Your Analysis
Ensure you screen for 0ms RT. An example function ```cleanEvents.m``` can be found in the utilities directory:

```c
%% Purpose: Remove any 0ms RTs from an events data table.
%%
%% Arguments:
%% FileName = 'sub-CC110033_ses-smt_task-smt_events.tsv';
%% ========================================================================

function [cleanEvents] = clean_events(FileName)

  d = readtable(FileName,'FileType','text')

  idx = find(strcmp(d.trial_type,'button'));
  for i = 1:length(idx); check(i) = (d.onset(idx(i)) - d.onset(idx(i)-1)) == 0; end

  cleanEvents = d;
  cleanEvents(idx(check),:) = []; %drop RTs that equal 0

end
```