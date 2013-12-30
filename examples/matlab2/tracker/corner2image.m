function [crop,crop_norm,crop_mean,crop_std, cov] = corner2image(img, p, tsize)
%   (r1,c1) ***** (r3,c3)            (1,1) ***** (1,cols)
%     *             *                  *           *
%      *             *       ----->     *           *
%       *             *                  *           *
%     (r2,c2) ***** (r4,c4)              (rows,1) **** (rows,cols)
afnv_obj = corners2affine( p, tsize);
map_afnv = afnv_obj.afnv;
img_map = IMGaffine_c(double(img), map_afnv, tsize);
img_map_cov = IMGaffine_c(double(img), map_afnv, [map_afnv(5),map_afnv(6)]);

[C, M] = calculateCovarianceFromImage(img_map_cov);
cov = CholeskyDec(C,M);

[crop,crop_mean,crop_std] = whitening( reshape(img_map, prod(tsize), 1) ); %crop is a vector
crop_norm = norm(crop);
crop = crop/crop_norm;
