[im_1,map]=imread(".\Dataset\synth\apples.gif");
im_1=ind2rgb(im_1,map);
[x_dim,y_dim,z_dim]=size(im_1);
block_size=48;
b=floor(block_size/4);
for i=1:10
    for j=1:10
        if i==1
            if j==1
                resultimage=im_1(1:block_size,1:block_size,:);
            else
                im_temp=resultimage(:,1+(j-2)*floor(3*block_size/4):1+(j-2)*floor(3*block_size/4)+block_size-1,:);
                block_ov=im_temp(:,size(im_temp,2)-b+1:size(im_temp,2),:);
                err=500;
                arr1=[1,1];
                for m=1:x_dim-block_size+1
                    for n=1:y_dim-block_size+1
                        block_temp=im_1(m:m+block_size-1,n:n+b-1,:);
                        overlap_error=(block_temp-block_ov).^2;
                        overlap_error=rms(overlap_error,"all");
                        [M,I]=min([err,overlap_error]);
                        err=M;
                        if I==2
                        arr1=[m,n];
                        end
                    end
                end
                m=arr1(1);
                n=arr1(2);
                im_temp1=im_1(m:m+block_size-1,n:n+block_size-1,:);
                im_temp2=Border(im_temp,im_temp1);
                resultimage(:,1+(j-2)*floor(3*block_size/4):1+(j-2)*floor(3*block_size/4)+floor(7*block_size/4)-1,:)=im_temp2;


            end
           
        else
            if j==1
                im_temp=resultimage(1+(i-2)*floor(3*block_size/4):1+(i-2)*floor(3*block_size/4)+block_size-1,1:block_size,:);
                block_ov=im_temp(size(im_temp,1)-b+1:size(im_temp,1),:,:);
                err=500;
                arr1=[1,1];
                for m=1:x_dim-block_size+1
                    for n=1:y_dim-block_size+1
                        block_temp=im_1(m:m+b-1,n:n+block_size-1,:);
                        overlap_error=(block_temp-block_ov).^2;
                        overlap_error=rms(overlap_error,"all");
                        [M,I]=min([err,overlap_error]);
                        err=M;
                        if I==2
                        arr1=[m,n];
                        end
                    end
                end
                m=arr1(1);
                n=arr1(2);
                im_temp1=im_1(m:m+block_size-1,n:n+block_size-1,:);
                im_temp2=Border(rot90(im_temp),rot90(im_temp1));
                im_temp2=rot90(im_temp2,3);
                
                resultimage(1+(i-2)*floor(3*block_size/4):1+(i-2)*floor(3*block_size/4)+floor(7*block_size/4)-1,1:block_size,:)=im_temp2;

            else
                im_temp=resultimage(1+(i-2)*floor(3*block_size/4):1+(i-2)*floor(3*block_size/4)+block_size-1,1+(j-1)*floor(3*block_size/4):1+(j-1)*floor(3*block_size/4)+block_size-1,:);
                im1_temp=resultimage(1+(i-1)*floor(3*block_size/4):1+(i-1)*floor(3*block_size/4)+block_size-1,1+(j-2)*floor(3*block_size/4):1+(j-2)*floor(3*block_size/4)+block_size-1,:);
                block_ov=im_temp(size(im_temp,1)-b+1:size(im_temp,1),:,:);
                block_ov1=im1_temp(:,size(im_temp,2)-b+1:size(im_temp,2),:);
                err=500;
                arr1=[1,1];
                for m=1:x_dim-block_size+1
                    for n=1:y_dim-block_size+1
                        block_temp=im_1(m:m+b-1,n:n+block_size-1,:);
                        overlap_error=(block_temp-block_ov).^2;
                        overlap_error=rms(overlap_error,"all");

                        block_temp1=im_1(m:m+block_size-1,n:n+b-1,:);
                        error_with_target=(block_temp1-block_ov1).^2;
                        error_with_target=rms(error_with_target,"all");

                        total_error=overlap_error+error_with_target;
                        [M,I]=min([err,total_error]);
                        err=M;

                        if I==2
                        arr1=[m,n];
                        end
                    end
                end
                m=arr1(1);
                n=arr1(2);
                im_temp1=im_1(m:m+block_size-1,n:n+block_size-1,:);
                im_temp2=Border(rot90(im_temp),rot90(im_temp1));
                im_temp3=Border(im1_temp,im_temp1);
                im_temp2=rot90(im_temp2,3);

                resultimage(1+(i-1)*floor(3*block_size/4):1+(i-1)*floor(3*block_size/4)+block_size-1,1+(j-2)*floor(3*block_size/4):1+(j-2)*floor(3*block_size/4)+floor(7*block_size/4)-1,:)=im_temp3;
                resultimage(1+(i-2)*floor(3*block_size/4):1+(i-2)*floor(3*block_size/4)+block_size-1,1+(j-1)*floor(3*block_size/4):1+(j-1)*floor(3*block_size/4)+block_size-1,:)=im_temp2(1:block_size,:,:);

            end
        end

    end
end
imshow(resultimage)