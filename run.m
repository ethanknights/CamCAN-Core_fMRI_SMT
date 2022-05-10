clear

CCIDList = dir('/imaging/camcan/cc700-rawdata/MRI/data/CC*'); CCIDList = {CCIDList.name}';

for s = 1:length(CCIDList)
  
ccid = CCIDList{s};
%ccid = 'CC110033'


raw_dir = '/imaging/camcan/cc700-rawdata'
scored_dir = '/imaging/camcan/sandbox/ek03/fixCC700/SMT_RT/analysis_scripts/scored'; %mkdir(scored_dir)
owflag = false;

[R fname errmsg] = MRI_wrapper_script(ccid,raw_dir,scored_dir,owflag)

end

return


%% Notes
%% ========================================================================
%Failing subjects:
%'CC410222'
%This subject had no events file in 2019 BIDS either. Everyones event order
%is the same... but time and RTs do vary


%% Move New Data to Cam-CAN central space
%% ========================================================================
!mkdir /imaging/camcan/cc700-scored/MRI/release002
!mv /imaging/camcan/sandbox/ek03/fixCC700/SMT_RT/* /imaging/camcan/cc700-scored/MRI/release002

