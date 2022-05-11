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

%% Also run the output events file through clean_events.m to remove missing 
%% button presses
%% ========================================================================
addpath utilities

for s = 1:length(CCIDList); CCID = CCIDList{s};
  
  scored_dir = '/imaging/camcan/cc700-scored/MRI/release002/data';
  fileName = fullfile(scored_dir,CCID,['sub-',CCID,'_ses-smt_task-smt_events.tsv']);
   
  if exist(fileName,'file')
    
    [cleanEvents] = clean_events(fileName);
    
    writetable(cleanEvents,fileName,'FileType','text');
    
  end
  
end

%% Notes
%% ========================================================================
%Failing subjects:
%'CC410222'
%This subject had no events file in 2019 BIDS either.