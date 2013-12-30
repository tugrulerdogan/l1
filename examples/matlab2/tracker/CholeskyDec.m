function [ resRef2 ] = CholeskyDec( Cov2, M2 )

% n = length( M );
% L = zeros( n, n );
% for i=1:n
%     L(i, i) = sqrt( M(i, i) - L(i, :)*L(i, :)' );
% 
%     for j=(i + 1):n
%         L(j, i) = ( M(j, i) - L(i, :)*L(j, :)' )/L(i, i);
%     end
% end


    covC = Cov2 + 0.001*eye(size(Cov2));
    covC = 2*(size(covC,1)+0.1)*covC;
    L = chol(covC);
    li = L(:);
    for kk=1:size(covC,1)*size(covC,1)
%         li(kk) = li(kk)+M2(mod(kk-1,size(covC,1))+1);
        li(kk) = li(kk);
    end
    lj = L(:);
    for kk=1:size(covC,1)*size(covC,1)
%         lj(kk) = M2(mod(kk-1,size(covC,1))+1)-lj(kk);
        lj(kk) = -lj(kk);
    end
%     resRef2 = [M2 li' lj'];
      resRef2 = [li' lj'];
end
