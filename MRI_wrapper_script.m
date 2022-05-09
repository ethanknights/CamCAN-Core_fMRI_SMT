
function [R fname errmsg] = MRI_wrapper_script(ccid,raw_dir,scored_dir,owflag)

% Wrapper script for running MRI analysis. 
%
% INPUT
%  ccid         - CamCAN ID ('CC######')
%  raw_dir      - Path to raw data (def: /imaging/jt03/.../Repository/cc-rawdata)
%  scored_dir   - Path to scored (def: /imaging/jt03/.../Repository/cc-scored)
%  owflag       - overwrite scored file if exists? (def=1)
%
% OUTPUT
%  R            - variable containing scored results
%  fname        - name of scored data file
%  errmsg       - error message generated during analysis
%
% Jason Taylor 30 Mar 2011
%

%% Parameters:

expt    = 'MRI';
release = 'release001';

% Initialise outputs:
R       = struct;
fname   = '';
errmsg  = '';

% Input:
if ~exist('raw_dir','var')
    raw_dir = '/imaging/camcan/cc700-rawdata';
end
if ~exist('scored_dir','var')
    scored_dir = '/imaging/camcan/cc700-scored';
end
if ~exist('owflag','var') || isempty(owflag)
    owflag = 1;
end


%% Run Analysis Script:

% Get directories:
raw_dir    = sprintf('%s/%s/data/%s',raw_dir,expt,ccid);
scored_dir = sprintf('%s/%s/%s/data/%s',scored_dir,expt,release,ccid);

% Run:
[R fname errmsg] = MRI_analysis_script(ccid,'MRI*DATA.txt',raw_dir,scored_dir,owflag);

% Report errors:
if ~isempty(errmsg)
    errmsg = sprintf('%s %s: ',expt,ccid,errmsg);
    fprintf('\n%s\n',errmsg);
end

return
