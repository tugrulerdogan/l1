function wrapper()
%% VOT integration example for MeanShift tracker

% *************************************************************
% VOT: Always call exit command at the end to terminate Matlab!
% *************************************************************
onCleanup(@() 1+2 );

% *************************************************************
% VOT: Set random seed to a different value every time.
% *************************************************************

load(fullfile(fileparts(mfilename('fullpath')), 'cur.mat'));
% cd(currentFolder);
RandStream.setGlobalStream(RandStream('mt19937ar', 'Seed', sum(clock)));

tracker_directory = fullfile(fileparts(mfilename('fullpath')), 'tracker');
% rmpath(tracker_directory);
addpath(tracker_directory);

% **********************************
% VOT: Read input data
% **********************************
[images, region] = vot_initialize();

%% Initialize tracker variables
index_start = 1;
% Similarity Threshold
f_thresh = 0.16;
% Number max of iterations to converge
max_it = 5;

count = size(images,1);

im0 = imread(images{1});
height = size(im0,1);
width = size(im0,2);

results = zeros(count, 4);

results(1, :) = region;

T = imcrop(im0, region);
x = region(1);
y = region(2);
W = region(3);
H = region(4);



% parameters setting for tracking
% para.lambda = [0.2,0.001,10]; % lambda 1, lambda 2 for a_T and a_I respectively, lambda 3 for the L2 norm parameter
% % set para.lambda = [a,a,0]; then this the old model
% para.angle_threshold = 40;
% para.Lip	= 8;
% para.Maxit	= 5;
% para.nT		= 10;%number of templates for the sparse representation
% para.rel_std_afnv = [0.01,0.0000,0.0000,0.01,1,1];%diviation of the sampling of particle filter
para.lambda = [0.2,0.001,10]; % lambda 1, lambda 2 for a_T and a_I respectively, lambda 3 for the L2 norm parameter
% set para.lambda = [a,a,0]; then this the old model
para.angle_threshold = 40;
para.Lip	= 8;
para.Maxit	= 5;
para.nT		= 10;%number of templates for the sparse representation
para.rel_std_afnv = [0.03,0.0005,0.0005,0.03,1,1];%diviation of the sampling of particle filter
para.n_sample	= 100;		%number of particles
sz_T =[12,15];
% init_pos= [55,140,53;
%                    65,64,170];
init_pos = [y,y+H,y;x,x,x+W];
%    init_pos = [189,   239,   189;
%    328  , 328   ,381]
% init_pos= round(aff2image(init_pos', sz_T));
para.sz_T		= sz_T;
para.init_pos	= init_pos;
res_path='results\';
para.bDebug		= 0;		%debugging indicator
bShowSaveImage	= 1;       %indicator for result image show and save after tracking finished
para.s_debug_path = res_path;

%% Run the Mean-Shift algorithm
% % % % % % [k,gx,gy] = Parzen_window(H, W, 1, 'Gaussian', 0);
% % % % % % [I, map] = rgb2ind(im0, 65536);
% % % % % % Lmap = length(map) + 1;
% % % % % % T = rgb2ind(T,map);
% % % % % % % Estimation of the target PDF
% % % % % % q = Density_estim(T,Lmap,k,H,W,0);
% % % % % % % Flag for target loss
% % % % % % loss = 0;
% % % % % % % Similarity evolution along tracking
% % % % % % f = zeros(1, (count-1) * max_it);
% % % % % % % Sum of iterations along tracking and index of f
% % % % % % f_indx = 1;
% % % % % % % Draw the selected target in the first frame
% % % % % % 
% % % % % % % From 2nd frame to last one
% % % % % % for t=2:count
% % % % % % 
% % % % % %     if loss == 1
% % % % % % 		results(t, :) = NaN;
% % % % % % 		continue;
% % % % % %     else
% % % % % % 		% Apply the Mean-Shift algorithm to move (x,y)
% % % % % % 		% to the target location in the next frame.
% % % % % % 		[x,y,loss,f,f_indx] = MeanShift_Tracking(q, ...
% % % % % % 			rgb2ind(imread(images{t}), map),Lmap,...
% % % % % % 		    height,width,f_thresh,max_it,x,y,H,W,k,gx,...
% % % % % % 		    gy,f,f_indx,loss);
% % % % % %     end
% % % % % % 	results(t, :) = [x, y, W, H];
% % % % % % 
% % % % % % end

[tracking_res,output]  = L1TrackingBPR_APGup(images, para);
results=zeros(count,4);

for t = 1:count
    afnv	= tracking_res(:,t)';

    rect= round(aff2image(afnv', sz_T));
    inp	= reshape(rect,2,4);
    
%     results(t,1)=inp(1,1)+H/2;
%     results(t,2)=inp(2,1)+W/2;
%     results(t,3)=inp(1,4)-inp(1,1);
%     results(t,4)=inp(2,4)-inp(2,1);
    
    results(t,1)=round(mean(inp(2,:)));
    results(t,2)=round(mean(inp(1,:)));
    results(t,4)=inp(1,4)-inp(1,1);
    results(t,3)=inp(2,4)-inp(2,1);

    results
 
end

% results=[1,2,3,4]

% save('d:\l1.mat', 'results');
csvwrite(output_file, results);
% vot_deinitialize(results);

