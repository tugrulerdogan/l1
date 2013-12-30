function vot_deinitialize(results)

if size(results, 2) ~= 4
	error('Illegal result format');
end;

pwd

% csvwrite('d:\output.txt', results);
csvwrite('output.txt', results);



