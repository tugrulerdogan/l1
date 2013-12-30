function [gly_crop, gly_inrange, gly_cov] = crop_candidates(img_frame, curr_samples, template_size, tCov)
%create gly_crop, gly_inrange

nsamples = size(curr_samples,1);
c = prod(template_size);
gly_inrange = zeros(nsamples,1);
gly_crop = zeros(c,nsamples);
% gly_cov = zeros(tCov*tCov*2+tCov,nsamples);
gly_cov = zeros(tCov*tCov*2,nsamples);

for n = 1:nsamples
    curr_afnv = curr_samples(n, :);    
    
    %    [img_cut, gly_inrange(n)] = IMGaffine_r(img_frame, curr_afnv, template_size);
    [img_cut, gly_inrange(n)] = IMGaffine_c(img_frame, curr_afnv, template_size);
    img_cut_cov= IMGaffine_c(img_frame, curr_afnv, [curr_afnv(5), curr_afnv(6)]);
    [C, M] = calculateCovarianceFromImage(img_cut_cov);
    gly_cov(:,n) = CholeskyDec(C,M);
    
    gly_crop(:,n) = reshape(img_cut, c , 1);
end
