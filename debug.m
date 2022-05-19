%% 4 CCIDs where onset creation fails:
%  120065      221755      410222      610146
%% ========================================================================

%% Setup
raw_dir = '/imaging/camcan/cc700-rawdata';
scored_dir = '/imaging/camcan/cc700-scored/MRI/release002/data'; %mkdir(scored_dir)
owflag = false;

%% Case1
ccid = 'CC120065';
[R fname errmsg] = MRI_wrapper_script(ccid,raw_dir,scored_dir,owflag);
%% Eprime was aborted. 
%Notice logframe ends at level 5 (not level 1): 
%/imaging/camcan/cc700-rawdata/MRI/data/CC120065/MRI_CC120065_CBU120434_120421_1241_DATA.txt

%% Case2
ccid = 'CC221755';
[R fname errmsg] = MRI_wrapper_script(ccid,raw_dir,scored_dir,owflag);
%% Eprime was aborted. 
%Notice logframe ends at level 4 (not level 1): 
%/imaging/camcan/cc700-rawdata/MRI/data/CC221755/MRI_CC221755_CBU130340_130406_1211_DATA.txt

%% Case3
ccid = 'CC410222';
[R fname errmsg] = MRI_wrapper_script(ccid,raw_dir,scored_dir,owflag);
%% Two times the scan was aborted (no trigger files) 
%% 3rd time eprime was aborted 
%Notice no level 5 event exists so error thrown. Note I moved attempt 1+2 files to 'ignore' folder as totally useless.
%/imaging/camcan/cc700-rawdata/MRI/data/CC410222/MRI_CC410222_CBU110593_110518_1442_DATA.txt

%% Case4
ccid = 'CC610146';
[R fname errmsg] = MRI_wrapper_script(ccid,raw_dir,scored_dir,owflag);
%% Subject was aborted. 
%Notice logframe ends in the middle of an event!:
%/imaging/camcan/cc700-rawdata/MRI/data/CC610146/MRI_CC610146_CBU110666_110608_1354_DATA.txt