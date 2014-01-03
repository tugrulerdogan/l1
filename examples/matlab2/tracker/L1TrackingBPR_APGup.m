function [track_res,output] = L1TrackingBPR_APGup(s_frames, paraT)
 

%% Initialize templates T
%-Generate T from single image
init_pos = paraT.init_pos;
n_sample=paraT.n_sample;
sz_T=paraT.sz_T;
rel_std_afnv = paraT.rel_std_afnv;
nT=paraT.nT;

tCov = 7;
s1_p = 1/50;
s2_p = 1/(2^28);

%generate the initial templates for the 1st frame
img = imread(s_frames{1});
if(size(img,3) == 3)
    img = rgb2gray(img);
end
[T,T_norm,T_mean,T_std, T2] = InitTemplates(sz_T,nT,img,init_pos, tCov);
norms = T_norm.*T_std; %template norms
occlusionNf = 0;

%% L1 function settings
angle_threshold = paraT.angle_threshold;
para.Lambda = paraT.lambda;
para.nT = paraT.nT;
para.Lip = paraT.Lip;
para.Maxit = paraT.Maxit;

dim_T	= size(T,1);	%number of elements in one template, sz_T(1)*sz_T(2)=12x15 = 180
A		= [T2]; %data matrix is composed of T, positive trivial T.
alpha = 0.5;%this parameter is used in the calculation of the likelihood of particle filter
aff_obj = corners2affine(init_pos, sz_T); %get affine transformation parameters from the corner points in the first frame
map_aff = aff_obj.afnv;
aff_samples = ones(n_sample,1)*map_aff;

T_id	= -(1:nT);	% template IDs, for debugging
fixT = T2(:,1)/nT; % first template is used as a fixed template

%Temaplate Matrix
Temp = [A fixT];
Dict = Temp'*Temp;
Temp1 = [T2,fixT]*pinv([T2,fixT]);

%% Tracking

% initialization
nframes	= length(s_frames);
track_res	= zeros(6,nframes);
Time_record = zeros(nframes,1);
Coeff = zeros(size([A fixT],2),nframes);
Min_Err = zeros(nframes,1);
count = zeros(nframes,1);
Time = zeros(n_sample,1); % L1 norm time recorder
ratio = zeros(nframes,1);% energy ratio

for t = 1:nframes
    fprintf('Frame number: %d \n',t);
    
    img_color	= imread(s_frames{t});
    if(size(img_color,3) == 3)
        img     = double(rgb2gray(img_color));
    else
        img     = double(img_color);
    end
    
    tic
    %-Draw transformation samples from a Gaussian distribution
    sc			= sqrt(sum(map_aff(1:4).^2)/2);
    std_aff		= rel_std_afnv.*[1, sc, sc, 1, sc, sc];
    map_aff		= map_aff + 1e-14;
    aff_samples = draw_sample(aff_samples, std_aff); %draw transformation samples from a Gaussian distribution
    
    %-Crop candidate targets "Y" according to the transformation samples
    [Y, Y_inrange, Y2] = crop_candidates(im2double(img), aff_samples(:,1:6), sz_T, tCov);
    
    rect= round(aff2image(map_aff', sz_T));
    inp	= reshape(rect,2,4);

% %     topleft_r = inp(1,1);
% %     topleft_c = inp(2,1);
% %     botleft_r = inp(1,2);
% %     botleft_c = inp(2,2);
% %     topright_r = inp(1,3);
% %     topright_c = inp(2,3);
% %     botright_r = inp(1,4);
% %     botright_c = inp(2,4);
%         
%     driftX = 50;
%     driftY=50;
%     
%     centX = (inp(2,4)-inp(2,1))/2 - driftX/2+inp(2,1);
%     centY = (inp(1,4)- inp(1,1))/2 - driftY/2+inp(1,1);
%     
%     resultBin = zeros([driftX,driftY]);
%     
%     arr = [centY-driftY/2,centY+driftY+driftY/2,centY-driftY/2;centX-driftX/2,centX-driftX/2,centX+driftX+driftX/2];
%     arr(1,find(arr(1,:)>size(img,1)))=size(img,1);
%     arr(2,find(arr(2,:)>size(img,2)))=size(img,2);
% 
%     affEq = corners2affine(arr, [driftX,driftY]);
% %             affEq
%     [Yorig, Y_inrangebuf, Ybuf2] = crop_candidates(im2double(img), affEq.afnv, [2*driftX,2*driftY], tCov);
%     
%     figure(3);
%    
%     subplot(1,2,2);
%     imshow(uint8(reshape(Yorig,[2*driftX,2*driftY])));
%         
%     for dy=1:driftX
%         for dx=1:driftY
%             
%             arr = [centY+dy,centY+dy+driftY,centY+dy;centX+dx,centX+dx,centX+dx+driftX];
%             arr(1,find(arr(1,:)>size(img,1)))=size(img,1);
%             arr(2,find(arr(2,:)>size(img,2)))=size(img,2);
%             
%             affEq = corners2affine(arr, [driftX,driftY]);
% %             affEq
%             [Ybuf, Y_inrangebuf, Ybuf2] = crop_candidates(im2double(img), affEq.afnv, [driftX,driftY], tCov);
%             
%             [code] = APGLASSOup(Temp'*Ybuf2,Dict,para);
%         
%             Diff_s = (Ybuf2 - [A(:,1:nT) fixT]*[code(1:nT); code(end)]).^2;%reconstruction error
% %             sum(Diff_s)
% %             rError = exp(-(alpha/10000)*(sum(Diff_s)^(1)));
%              rError = exp(((-(alpha)*(sum(Diff_s)))/(10^36))^3);
%             resultBin(dx,dy)=rError;
%             
%             
%         end        
%     end
%     
%     resultBin = (resultBin/max(max(resultBin)))*255;    
%     figure(3);
%     subplot(1,2,1);
%     imshow(uint8(resultBin));
% %     subplot(1,2,2);
% %     imshow(uint8(Yorig));
% %     

fnum =0;

 while 1 == 1
     
            figure(fnum*2+1)
         imshow(img_color);
         
         hold on
         
        
         
         [x,y] = ginput(4)
        plot(x,y)
        color = [0 1 0];
        for ln =0:3
%             ln
%             pl = line([x(mod(ln,4)+1), x(mod(ln+1,4)+1)], [y(mod(ln,4)+1), y(mod(ln+1,4)+1)]);
%             set(pl, 'Color', color); set(pl, 'LineWidth', 1); set(pl, 'LineStyle', '-');
            figure(fnum*2+1)
            plot([x(mod(ln,4)+1), x(mod(ln+1,4)+1)], [y(mod(ln,4)+1), y(mod(ln+1,4)+1)],'Color','r','LineWidth',2)

        end
        
        arr = [y(1),y(3),y(1);x(1),x(1),x(3)];
         affEq = corners2affine(arr, [x(3)-x(1),y(3)-y(1)]);
% %             affEq
            [Ybuf, Y_inrangebuf, Ybuf2, covvr] = crop_candidates(im2double(img), affEq.afnv, [x(3)-x(1),y(3)-y(1)], tCov);
      
            figure(fnum*2+2)
            subplot(1,2,1);
        imagesc( covvr);
        colormap(hsv)
        
        subplot(1,2,2);
        imagesc( reshape(Ybuf2,7,14));
        colormap(hsv)
            
            [code] = APGLASSOup(Temp'*Ybuf2,Dict,para);
        
            Diff_s = (Ybuf2 - [A(:,1:nT) fixT]*[code(1:nT); code(end)]).^2;%reconstruction error
%             sum(Diff_s)
%             rError = exp(-(alpha/10000)*(sum(Diff_s)^(1)));

%                'Error  = '
              rError = exp(-alpha*(sum(Diff_s)))
              
               '\n\n\n'
%              rError = exp(((-(alpha)*(sum(Diff_s)))/(10^36))^3);
        
        fnum = mod(fnum+1,2);
 end
    
            
    
    if(sum(Y_inrange==0) == n_sample)
        sprintf('Target is out of the frame!\n');
    end
    
%     [Y,Y_crop_mean,Y_crop_std] = whitening(Y);	 % zero-mean-unit-variance
%     [Y, Y_crop_norm] = normalizeTemplates(Y); %norm one
    
    %-L1-LS for each candidate target
    eta_max	= -inf;
    q   = zeros(n_sample,1); % minimal error bound initialization
   
    figure(2);
    merged = mMergeIm(Y,sz_T);
    imshow(uint8(merged));
    
    % first stage L2-norm bounding    
    for j = 1:n_sample
        if Y_inrange(j)==0 || sum(abs(Y2(:,j)))==0
            continue;
        end
        
        % L2 norm bounding
        q(j) = norm(Y2(:,j)-Temp1*Y2(:,j));
        q(j) = exp(-alpha*q(j));
    end
    %  sort samples according to descend order of q
    [q,indq] = sort(q,'descend');    
    
    % second stage
    p	= zeros(n_sample,1); % observation likelihood initialization
    n = 1;
    tau = 0;
    while (n<n_sample)&&(q(n)>=tau)        

        [c] = APGLASSOup(Temp'*Y2(:,indq(n)),Dict,para);
        
        D_s = (Y2(:,indq(n)) - [A(:,1:nT) fixT]*[c(1:nT); c(end)]).^2;%reconstruction error
        p(indq(n)) = exp(-alpha*(sum(D_s)^(s2_p))); % probability w.r.t samples
%         p(indq(n)) = -sum(D_s);
        tau = tau + p(indq(n))/(2*n_sample-1);%update the threshold
        
        if(sum(c(1:nT))<0) %remove the inverse intensity patterns
            continue;
        elseif(p(indq(n))>eta_max)
            id_max	= indq(n);
            c_max	= c;
            eta_max = p(indq(n));
            Min_Err(t) = sum(D_s);
        end
        n = n+1;
    end
    
    count(t) = n;           
    
%     p = p - min(p);
%     [maxV, id_max] = max(p);
%     [c_max] = APGLASSOup(Temp'*Y2(:,indq(id_max)),Dict,para);
    
    % resample according to probability
    map_aff = aff_samples(id_max,1:6); %target transformation parameters with the maximum probability
    a_max	= c_max(1:nT);
    [aff_samples, ~] = resample(aff_samples,p,map_aff); %resample the samples wrt. the probability
    [~, indA] = max(a_max);
    min_angle = images_angle(Y2(:,id_max),A(:,indA));
    ratio(t) = norm(c_max(nT:end-1));
    Coeff (:,t) = c_max;    
    
     %-Template update
     occlusionNf = occlusionNf-1;
     level = 0.03;
%     if( min_angle > angle_threshold && occlusionNf<0 )        
%         disp('Update!')
%         trivial_coef = c_max(nT+1:end-1);
%         trivial_coef = reshape(trivial_coef, sz_T);
%         
%         trivial_coef = im2bw(trivial_coef, level);
% 
%         se = [0 0 0 0 0;
%             0 0 1 0 0;
%             0 1 1 1 0;
%             0 0 1 0 0'
%             0 0 0 0 0];
%         trivial_coef = imclose(trivial_coef, se);
%         
%         cc = bwconncomp(trivial_coef);
%         stats = regionprops(cc, 'Area');
%         areas = [stats.Area];
%         
%         % occlusion detection 
%         if (max(areas) < round(0.25*prod(sz_T)))        
%             % find the tempalte to be replaced
%             [~,indW] = min(a_max(1:nT));
%         
%             % insert new template
%             T(:,indW)	= Y(:,id_max);
%             T_mean(indW)= Y_crop_mean(id_max);
%             T_id(indW)	= t; %track the replaced template for debugging
%             norms(indW) = Y_crop_std(id_max)*Y_crop_norm(id_max);
%         
%             [T, ~] = normalizeTemplates(T);
%             A(:,1:nT)	= T;
%         
%             %Temaplate Matrix
%             Temp = [A fixT];
%             Dict = Temp'*Temp;
%             Temp1 = [T,fixT]*pinv([T,fixT]);
%         else
%             occlusionNf = 5;
%             % update L2 regularized term
%             para.Lambda(3) = 0;
%         end
%     elseif occlusionNf<0
        para.Lambda(3) = paraT.lambda(3);
%     end
    
    Time_record(t) = toc;

    %-Store tracking result
    track_res(:,t) = map_aff';
    
    paraT.bDebug=1
    
    %-Demostration and debugging
    if paraT.bDebug
        s_debug_path = paraT.s_debug_path;
%         % print debugging information
%         fprintf('minimum angle: %f\n', min_angle);
%         fprintf('Minimum error: %f\n', Min_Err(t));
%         fprintf('T are: ');
%         for i = 1:nT
%             fprintf('%d ',T_id(i));
%         end
%         fprintf('\n');
%         fprintf('coffs are: ');
%         for i = 1:nT
%             fprintf('%.3f ',c_max(i));
%         end
%         fprintf('\n\n');
%         
        
        
%%         draw tracking results
        img_color	= double(img_color);
%         img_color	= showTemplates(img_color, T, T_mean, norms, sz_T, nT);

		figure(1);

        imshow(uint8(img_color));
        text(5,10,num2str(t),'FontSize',18,'Color','r');
        color = [1 0 0];
        drawAffine(map_aff, sz_T, color, 2);
        drawnow;
		
% 		figure(2);
%         subplot(1,2,1);
%         imagesc( reshape(fixT,21,10));
%         colormap(hsv)
        
%         subplot(1,2,2);
%         imagesc( reshape(Y2(:,id_max),21,10));
%         colormap(hsv)
        
        if ~exist(s_debug_path,'dir')
            fprintf('Path %s not exist!\n', s_debug_path);
        else
            s_res	= s_frames{t}(1:end-4);
            s_res	= fliplr(strtok(fliplr(s_res),'/'));
            s_res	= fliplr(strtok(fliplr(s_res),'\'));
            s_res	= [s_debug_path s_res '_L1_APG.jpg'];
            saveas(gcf,s_res)
        end
     end
end
 
output.time = Time_record; % cpu time of APG method for each frame
output.minerr = Min_Err; % reconstruction error for each frame
output.coeff = Coeff;  % best coefficients for each frame
output.count = count;  % particles used to calculate the L1 minimization in each frame
output.ratio = ratio;  % the energy of trivial templates
