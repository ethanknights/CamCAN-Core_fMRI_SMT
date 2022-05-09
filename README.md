# CamCAN_fMRI-SMT_events
This repository logs changes (2022 onwards) for Matlab analysis code of Cam-CAN's fMRI SMT task. <br>
Specifically, new appended code (see git commit history) generates
new event files (to match Cam-CAN MEG SMT task) 
that include event onsets for button presses (i.e. Reaction Times; RTs).


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
