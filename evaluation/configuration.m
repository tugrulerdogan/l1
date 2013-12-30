
global track_properties;

track_properties.directory = 'D:\\mtest\';

% Enable more verbose output
% track_properties.debug = 1;

% Disable result caching
% track_properties.cache = 0;

% Disable result packaging
% track_properties.pack = 0;

tracker_identifier = 'L1';
track_properties.repeat = 2;
path = 'D:\vot6\examples\matlab2'

tracker_command = ['D:\matlab\bin\matlab.exe -wait -nodesktop -nosplash -r "addpath(' path '); wrapper"'];

tracker_linkpath = {}; % A cell array of custom library directories used by the tracker executable.

% For classical executables this is usually just a full path to the executable plus
% some optional arguments
%
% tracker_command = fullfile(pwd, '..', 'examples', 'c', 'static');
%
% For MATLAB scripts use the following template:
% 
% tracker_command = '<TODO: path to Matlab installation>/bin/matlab -wait -nodesktop -nosplash -r wrapper' % Windows version
% tracker_command = '<TODO: path to Matlab installation>/bin/matlab -nodesktop -nosplash -r wrapper' % Linux and OSX version
