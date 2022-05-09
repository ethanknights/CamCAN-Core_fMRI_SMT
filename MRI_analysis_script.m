function [D fnames errmsg] = MRI_analysis_script(ccid,datafname,raw_dir,scored_dir,owflag)

% CamCAN 700: Convert fMRI A/V Task E-Prime output to onset and duration
% files and score the behavioural data.
%
%  Input:
%    ccid        - subject's CamCAN ID ('CC######')
%    datafname   - file name for E-Prime .txt data file (cc700: 'MRI_*_DATA.txt')
%    raw_dir     - input (rawdata) directory
%    scored_dir  - output (scored) directory
%    owflag      - overwrite scored file if exists? (def=1)
%
%  Output:
%    D           - E-Prime data structure
%    fnames      - Output data filenames (scored, notes, onsets, durations)
%    errmsg      - error message produced during analysis
%
% by Jason Taylor (03 Mar 2011)
% + jt (02 Apr 2011) added scored output, notes processing
% + jt (13 May 2011) made consistent with other behav scripts
% + jt (24 May 2011) added owflag, errmsg; changed some var names
%                    (subj->ccid, indir->raw_dir, outdir->scored_dir)
% + jt (03 May 2013) allow for multiple data files (read all)
% + linda geerligs (25 June 2014) add trimmed and inverse RT values to
% output, as well as coefficient of variation and missing and anticipatory
% responses. Made sure that a behavioral scored file (but not onset and duration 
% file) is outputted even if an error occurs, add a column with the errormessage, 
% and added column with participant inclusion criteria according to James Rowe 
% (same criteria as RT simple and RTchoice). 



%% Parameters:

% Path to read_eprime_log.m:
commondir = '/imaging/camcan/cc700-scored/_Common/release001';
addpath(commondir);

% Initialise output:
Dall   = {};
D      = [];
fnames = {};
errmsg = NaN;
printnan=0; %set to one if an error occurs

% Input:
expt = 'MRI';
ndummies = 2;

% CCID (prompt if not given):
if ~exist('ccid','var') || isempty(ccid) || length(ccid)~=8
    ccid = 'CC';
    warn1 = '';
    while length(ccid)~=8
        dlg_title = 'Startup Info for Analysis';
        prompt = {sprintf('%s\nCCID (eg, CC123456)',warn1)};
        num_lines = 1;
        def = {ccid};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        ccid = answer{1};
        if length(ccid)~=8
            warn1 = 'CCID MUST BE 8 CHARACTERS LONG!';
            ccid = 'CC';
        else
            warn1 = '';
        end
    end
end

if ~exist('datafname','var') || isempty(datafname)
    datafname = 'MRI_*_DATA.txt';
end

if ~exist('raw_dir','var') || isempty(raw_dir)
    raw_dir = sprintf('/imaging/camcan/cc700-rawdata/%s/data/%s',expt,ccid);  %#ok<NASGU>
end

if ~exist('scored_dir','var') || isempty(scored_dir)
    dlg_title = 'Startup Info for Analysis';
    prompt = {'What release number?'};
    num_lines = 1;
    def = {'1'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    release = str2double(answer{1});
    scored_dir = sprintf('/imaging/camcan/cc700-scored/%s/release%03d/data',expt,release);
end

if ~exist('owflag','var') || isempty(owflag)
    owflag = 1;
end


%% Begin:

% Subject-specific in/output dirs: (now supplied @ input)
%scored_dir = sprintf('%s/%s',scored_dir,ccid);

if ~exist(scored_dir,'dir');
    mkdir(scored_dir);
    fprintf(1,'+ Creating output directory: %s\n',scored_dir);
else
    fprintf(1,'+ Output directory will be: %s\n',scored_dir);
end
%raw_dir = sprintf('%s/%s',raw_dir,ccid);


%% MRI SESSION NOTES:

% input:
notefile = dir(sprintf('%s/*NOTE*.txt',raw_dir));
if ~isempty(notefile)
    notefile = notefile.name;
end

% output:
notesfname = sprintf('MRI_%s_notes.txt',ccid);
fnames{end+1} = notesfname;

% do it:
try
    notetxt = read_eprime_notes(sprintf('%s/%s',raw_dir,notefile),sprintf('%s/%s',scored_dir,notesfname));
catch
    notetxt = '';
    fprintf(1,'\nNo notes found in %s\n..this is not catastrophic.',raw_dir);
end


%% DATA:

% Get data filename in input directory:
flist = dir(sprintf('%s/%s*',raw_dir,datafname));
if length(flist)>1
    fprintf(1,'\nNote: %d data files found in %s\n',length(flist),raw_dir);
    %fprintf(1,'\n..using last one: %s\n',flist(end).name);
    fprintf(1,'\n..will read all\n');
elseif length(flist)<1
    errmsg = sprintf('NO data file in %s',raw_dir);
    printnan=1;
end

if printnan==0 %only do this if no error has occured yet
    %datafname = flist(end).name; % hack: assumes last one is correct!
    datafnames = {flist.name}';
    
    % Read it (/them)!
    for f=1:length(datafnames)
        [Dall{f} readerr] = read_eprime_log(fullfile(raw_dir,filesep,datafnames{f}));
        if readerr>0
            errmsg = sprintf('Error reading eprime log file: %d',readerr);
            printnan=1;
        end
    end
end

%% Determine which (if any) data files are valid:

if printnan==0 %only do this if no error has occured yet
    % Filter out irrelevant levels, practice trials & dummies:
    usefortask = [];
    for f=1:length(Dall)
        dall{f} = Dall{f};
        level = [dall{f}.level];
        dall{f} = dall{f}(level==5);
        %if length(d)==0 %#ok<ISMT>
        %    errmsg = sprintf('No valid trials found in %s',datafname);
        %    fprintf(1,'Quitting without completing analysis.\n');
        %    return
        %end
        if length(dall{f})>0
            pracmode = [dall{f}.PracticeMode];
            dall{f} = dall{f}(pracmode==0);
            
            % Task:
            tasktype = {dall{f}.Running_LogLevel5}';
            taskind = strmatch('ScanTrialList',tasktype);
            if any(taskind)
                if length(taskind) > 200 % I think should be 255 ?!
                    usefortask = f; % if >1 complete, will take last
                    dall{f} = dall{f}(taskind);
                    ntrials_task = length(taskind);
                end
            end
        end
    end
    
    if ~any(usefortask)
        errmsg = sprintf('Task data incomplete or not present in %s\n',datafnames{:});
        printnan=1;
    end
end

if printnan==0 %only do this if no error has occured yet
    %% Process task:
    D = Dall{usefortask};
    d = dall{usefortask};
    
    % Dummies:
    tr = unique([d.TrialDur]);
    if length(tr)>1
        errmsg = sprintf('More than one TR (d.TrialDur) in %s',datafnames{f});
        printnan=1;
    end
end

if printnan==0 %only do this if no error has occured yet
    tlim = ndummies*tr;
    
    % Start time:
    try
        startms = unique([D.InstructGetReadyScan_RTTime]);
    catch
        errmsg = sprintf('Cannot read scan start time (D.InstructGetReadyScan_RTTime) in %s',datafnames{f});
        printnan=1;
    end
end

if printnan==0 %only do this if no error has occured yet
    if length(startms)>1
        errmsg = sprintf('More than one start time (D.InstructGetReadyScan_RTTime) in %s',datafnames{f});
        printnan=1;
    end
end

if printnan==0 %only do this if no error has occured yet
    
    % Create proper condition labels:
    condname = {d.SlideStateCond}';
    condfreq = {d.SoundFreq}';
    cond = {zeros(length(d),1)};
    for i=1:length(d)
        switch condname{i}
            case {'AudOnly','VidOnly','Null'}
                cond{i} = condname{i};  % leave out frequency
            case 'AudVid'
                cond{i} = [condname{i} num2str(condfreq{i})];
        end
    end
    
    % Get onset times for each condition, write to file
    %  (also collect RT data for scored file):
    
    E = struct; RT=[];
    condtypes = unique(cond);
    for c=1:length(condtypes)
        condtype = condtypes{c};
        if ~strcmpi('Null',condtype)
            ind = strmatch(condtype,cond);
            tms = [d(ind).DisplayStim_OnsetTime]';
            if any(tms<tlim)
                warning('event appears to have occurred during dummies!'); % ugly!
            end
            tsec = (tms - startms)./1000;
            dsec = .3*(ones(length(tsec),1));
            
            % Write to files:
            onsetfname = sprintf('onsets_%s.txt',condtype);
            fnames{end+1} = onsetfname;
            fid = fopen(sprintf('%s/%s',scored_dir,onsetfname),'w');
            fprintf(fid,'%.3f\n',tsec);
            fclose(fid);
            
            durationfname = sprintf('durations_%s.txt',condtype);
            fnames{end+1} = durationfname;
            fid = fopen(sprintf('%s/%s',scored_dir,durationfname),'w');
            fprintf(fid,'%.3f\n',dsec);
            fclose(fid);
            
            % Store it:
            E.(condtype).onsets = tsec;
            E.(condtype).durations = dsec;
            E.(condtype).N = length(tsec);
            E.(condtype).onsetfname = onsetfname;
            E.(condtype).durationfname = durationfname;
            
            % Write summary to screen:
            fprintf(1,'\n+ Wrote onsets for %d %s events to file %s',length(tsec),condtype,onsetfname);
            
            % Extract response times:
            if ~strcmpi('AudOnly',condtype) && ~strcmpi('VidOnly',condtype)
                RT = [RT [d(ind).DisplayStim_RT]];
            end
            
        end % if not Null
    end
    RT = RT';
    
    
    %% Write scored data file:
    
    % Info:
    RAinit       = D(1).RAinit;
    Radiographer = D(1).Radiographer;
    
    % Collect number of trials, RT:
    Ntrials      = length(RT);
    RT           = RT(RT>0);
    Nmissing  = Ntrials - length(RT);
    RT           = RT(RT>100);
    Nanticipatory = Ntrials - Nmissing - length(RT);
    Ncorrect = length(RT);
    PctCorrect=Ncorrect/(Ntrials-Nanticipatory);
    mRT          = mean(RT);
    mdnRT        = median(RT);
    stdRT        = std(RT);
    cvRT=stdRT./mRT;
    
    
    % trim
    thresh = 3;
    rt_trim = RT(RT<(mRT+stdRT*thresh) & RT>(mRT-stdRT*thresh));
    Ntrials_trim=length(rt_trim);
    mRT_trim = mean(rt_trim);
    mdnRT_trim = median(rt_trim);
    stdRT_trim = std(rt_trim);
    cvRT_trim=stdRT_trim./mRT_trim;
    
    % Inverse:
    rt_inv = 1./RT*1000;
    mRT_inv = mean(rt_inv);
    mdnRT_inv = median(rt_inv);
    stdRT_inv   = std(rt_inv);
    cvRT_inv=stdRT_inv./mRT_inv;
    
    % Trim inverse:
    rt_inv_trim = rt_inv(rt_inv<(mRT_inv+stdRT_inv*thresh) & rt_inv>(mRT_inv-stdRT_inv*thresh));
    Ntrials_inv_trim=length(rt_inv_trim);
    mRT_inv_trim = mean(rt_inv_trim);
    mdnRT_inv_trim = median(rt_inv_trim);
    stdRT_inv_trim   = std(rt_inv_trim);
    cvRT_inv_trim=stdRT_inv_trim./mRT_inv_trim;
    
end

%check James's inclusion criteria and indicate inclusion in seperate column
include=1;
if printnan==1
    include=0;
elseif Ncorrect==0 || Nmissing==Ntrials
    include=0;
    errmsg = 'No accurate responses recorded';
elseif Nmissing>120*0.1;
    include=0;
   errmsg = 'Too many missing responses, more than 10%';;
end


% Determine scored file name:
scoredfname = sprintf('MRI_%s_scored.txt',ccid);
fnames{end+1} = scoredfname;

% Check whether scored data file exists:
if exist(scoredfname,'file')
    if owflag
        fprintf(1,'!! File exists: overwriting\n');
    else
        errmsg = sprintf('ERROR: file exists, owflag=0 %s',scoredfname);
        fprintf(1,'Quitting without completing analysis.\n');
        return
    end
end

% OPEN FILE:
sfid = fopen(sprintf('%s/%s',scored_dir,scoredfname),'w');

% WRITE HEADER:
fprintf(sfid,'RAinit\tRadiographer\tinclude_participant\tNtrials\tNmissing\tNanticipatory\tNcorrect\tPctCorrect\tNtrialsexpected\tmRT\tmdnRT\tstdRT\tcvRT\tNtrials_trim\tmRT_trim\tmdnRT_trim\tstdRT_trim\tcvRT_trim\tmRT_inv\tmdnRT_inv\tstdRT_inv\tcvRT_inv\tNtrials_inv_trim\tmRT_inv_trim\tmdnRT_inv_trim\tstdRT_inv_trim\tcvRT_inv_trim\tErrorMessage\n');

Na=NaN;
if printnan==0 %only do this if no error has occured yet
    % WRITE DATA:
    fprintf(sfid,'%s\t%s\t%d\t%d\t%d\t%d\t%d\t%d\t120\t%f\t%f\t%f\t%f\t%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%d\t%f\t%f\t%f\t%f\t%s\n',....
        RAinit,Radiographer,include,Ntrials,Nmissing,Nanticipatory,Ncorrect,PctCorrect,mRT,mdnRT,stdRT,cvRT,Ntrials_trim,mRT_trim,mdnRT_trim,stdRT_trim,cvRT_trim,mRT_inv,mdnRT_inv,stdRT_inv,cvRT_inv,Ntrials_inv_trim,mRT_inv_trim,mdnRT_inv_trim,stdRT_inv_trim,cvRT_inv_trim,errmsg);
    
elseif printnan==1 %if there was an error, write only NaNs
    fprintf(sfid,'%s\t%s\t%d\t%d\t%d\t%d\t%d\t%d\t120\t%f\t%f\t%f\t%f\t%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%d\t%f\t%f\t%f\t%f\t%s\n',....
        Na,Na,include,Na,Na,Na,Na,Na,Na,Na,Na,Na,Na,Na,Na,Na,Na,Na,Na,Na,Na,Na,Na,Na,Na,Na,errmsg);
end

% CLOSE FILE:
fclose(sfid);

% Report:
fprintf(1,'\n\n+ Wrote scored data to file %s\n\n',scoredfname);

% Done
fnames = fnames';
fprintf(1,'\n\n ++ Done! ++\n\n');

return
