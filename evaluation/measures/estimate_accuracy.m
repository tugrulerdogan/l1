function [accuracy] = estimate_accuracy(trajectory, sequence, varargin)

burnin = 0;

args = varargin;
for j=1:2:length(args)
    switch varargin{j}
        case 'burnin', burnin = max(0, args{j+1});
        case 'seq', seq=args{j+1};
        case 'rep', rep=args{j+1};
        case 'dir', result_directory=args{j+1};
        otherwise, error(['unrecognized argument ' args{j}]);
    end
end

if burnin > 0
    
    mask = trajectory(:, 4) == -1; % determine initialization frames
    
    if is_octave()
        se = logical([zeros(burnin - 1, 1); ones(burnin, 1)]);
    else
        se = strel('arbitrary', [zeros(burnin - 1, 1); ones(burnin, 1)]);
    end;
    
    % ignore the next 'burnin' frames
    mask = imdilate(mask, se);

    trajectory(mask, 4) = 0;
    
end;

trajectory(trajectory(:, 4) <= 0, :) = NaN; % do not estimate overlap where the tracker was initialized

overlap = calculate_overlap(trajectory, get_region(sequence, 1:sequence.length));

overlap = overlap(~isnan(overlap)); % filter-out illegal values



h=figure;
plot(overlap);
saveas(h,sprintf('%s\\%s_%d_%d.jpg', result_directory, sequence.name,seq,rep),'jpg');
close(h);


accuracy = mean(overlap);

