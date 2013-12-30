function [trajectory, time] = run_tracker(tracker, sequence, start, context)
% RUN_TRACKER  Generates input data for the tracker, runs the tracker and
% validates results.
%
%   [TRAJECTORY, TIME] = RUN_TRACKER(TRACKER, SEQUENCE, START, CONTEXT)
%              Runs the tracker on a sequence that with a specified offset.
%
%   See also RUN_TRIAL, SYSTEM.

% create temporary directory and generate input data
global track_properties;

working_directory = prepare_trial_data(sequence, start, context);

output_file = fullfile(working_directory, 'output.txt')
output_file
output_file
output_file


library_path = '';

output = [];

% run the tracker
old_directory = pwd;
try

    print_debug(['INFO: Executing "', tracker.command, '" in "', working_directory, '".']);

    cd(working_directory);

    if is_octave()
        tic;
        [status, output] = system(tracker.command, 1);
        time = toc;
    else

		% Save library paths
		library_path = getenv('LD_LIBRARY_PATH');

        % Make Matlab use system libraries
        if ~isempty(tracker.linkpath)
            userpath = tracker.linkpath{end};
            if length(tracker.linkpath) > 1
                userpath = [sprintf(['%s', pathsep], tracker.linkpath{1:end-1}), userpath];
            end;
            setenv('LD_LIBRARY_PATH', [userpath, pathsep, getenv('PATH')]);
        else
		    setenv('LD_LIBRARY_PATH', getenv('PATH'));
        end;

		if verLessThan('matlab', '7.14.0')
		    tic;
		    [status, output] = system(tracker.command);
		    time = toc;
		else
		    tic;
            currentFolder = pwd;
            addpath(currentFolder);
            save([tracker.path '\cur.mat'], 'output_file');
            cd(tracker.path);
            
% 		    [status, output] = system(tracker.command, '');
            status =0;
             wrapper();
		    time = toc;
		end;
    end;
        
    if status ~= 0 
        print_debug('WARNING: System command has not exited normally.');
    end;

catch e

	% Reassign old library paths if necessary
	if ~isempty(library_path)
		setenv('LD_LIBRARY_PATH', library_path);
	end;

    print_debug('ERROR: Exception thrown "%s".', e.message);
end;

cd(old_directory);

% validate and process results
trajectory = load_trajectory(output_file);

n_frames = size(trajectory, 1);

time = time / (sequence.length-start);

if (n_frames ~= (sequence.length-start) + 1)
    print_debug('WARNING: Tracker did not produce a valid trajectory file.');
    
    if ~isempty(output)
        print_text('Printing command line output:');
        print_text('-------------------- Begin raw output ------------------------');
        disp(output);
        print_text('--------------------- End raw output -------------------------');
    end;
    
    if isempty(trajectory)
        error('No result produced by tracker. Stopping.');
    else
        error('The number of frames is not the same as in groundtruth. Stopping.');
    end;
end;

if track_properties.cleanup
    % clean-up temporary directory
    recursive_rmdir(working_directory);
end;

