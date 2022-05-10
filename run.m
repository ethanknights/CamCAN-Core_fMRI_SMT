%% Purpose: Run original analysis routine that additionally writes RT files.
%% ========================================================================

clear

CCIDList = dir('/imaging/camcan/cc700-rawdata/MRI/data/CC*'); CCIDList = {CCIDList.name}';

for s = 1:length(CCIDList)
  
  ccid = CCIDList{s};
  
  raw_dir = '/imaging/camcan/cc700-rawdata';
  scored_dir = '/imaging/camcan/cc700-scored/MRI/release002/data'; %mkdir(scored_dir)
  owflag = false;
  
  [R fname errmsg] = MRI_wrapper_script(ccid,raw_dir,scored_dir,owflag);
  
end

return

%% Notes
%% ========================================================================
%Failing subjects:
%'CC410222'
%This subject had no events file in 2019 BIDS either.