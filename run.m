%   cd /imaging/camcan/cc700-rawdata/MRI/data/CC110033
%   cd /imaging/camcan/cc700-scored/MRI/release001/data/CC110033
%   cd /imaging/camcan/cc700-scored/MRI/release001/analysis_scripts


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