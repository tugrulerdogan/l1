function [img] = mMergeIm(T, sz)
     for i=1:size(T,2)


        g = reshape(T(:,i), sz);

    %     g= rgb2gray(g);
        g = double(g);

    %     imshow(uint8(g));



        [height, width] = size(g);

        if  mod(i,20) == 1
            sumG = g;
        else
            sumG = cat(2, sumG, g);
            if mod(i,20) == 0
                if i == 20
                    sumV = sumG;
                else
                    sumV = cat(1, sumV, sumG);
                end
           end
        end

     end  
     img = sumV;  
end
