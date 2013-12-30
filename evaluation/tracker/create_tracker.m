function [tracker] = create_tracker(identifier, command, result_directory, varargin)

linkpath = {};

args = varargin;
for j=1:2:length(args)
    switch varargin{j}
        case 'linkpath', linkpath = args{j+1};
        case 'path', path = args{j+1};
        otherwise, error(['unrecognized argument ' args{j}]);
    end
end


mkpath(result_directory);

tracker = struct('identifier', identifier, 'command', command, ...
        'directory', result_directory, 'linkpath', {linkpath}, 'path', path);

tracker.run = @run_tracker;
