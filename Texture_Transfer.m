function resultimage_og=Texture_Transfer(im_11,im_22,block_size,alpha)
    %For Grayscale images
    %[im_11,mp]=imread(".\Dataset\transfer\neworange.gif");
	%im_2=ind2rgb(im_22,mp);


	%Images converted to ycbcr to map the luminiscence
	im_1=rgb2ycbcr(im_11);
	
	%luminiscence is obtained then equalised for both the images
	im_1c=im_1(:,:,1);
	im_1c=histeq(im_1c);
	im_1(:,:,1)=im_1c;

	im_1=im2double(im_1);
	im_11=im2double(im_11);
	
	im_2=rgb2ycbcr(im_22);

	im_2c=im_2(:,:,1);
	im_2c=histeq(im_2c);
	im_2(:,:,1)=im_2c;

	im_2=im2double(im_2);
	im_22=im2double(im_22);
	
	[x_dim,y_dim,z_dim]=size(im_1);
	[x_dim1,y_dim1,z_dim1]=size(im_2);
	
	overlap_size=floor(block_size/4);
	
	%resultimage is for the mapped image(luminiscence)
	%resultimage_og is for the orignal image
	resultimage=im_2;
	resultimage_og=im_22;
	
	for i=1:floor((x_dim1/block_size-1)*4/3+1)
		for j=1:floor((y_dim1/block_size-1)*4/3+1)
			if i==1
				if j==1
					top_left_corner=im_2(1:block_size,1:block_size,:);
					err=500;
					arr1=[1,1];
					for m=1:x_dim-block_size+1
						for n=1:y_dim-block_size+1
							temp_img=im_1(m:m+block_size-1,n:n+block_size-1,:);
							error_with_source=(temp_img-top_left_corner).^2;
							error_with_source=rms(error_with_source,"all");
							[M,I]=min([err,error_with_source]);
							err=M;
							if I==2
								arr1=[m,n];
							end
						end
					end
					m=arr1(1);
					n=arr1(2);
					min_err_block_texture=im_1(m:m+block_size-1,n:n+block_size-1,:);
					resultimage(1:block_size,1:block_size,:)=min_err_block_texture;
					
					min_err_block_texture=im_11(m:m+block_size-1,n:n+block_size-1,:);
					resultimage_og(1:block_size,1:block_size,:)=min_err_block_texture;
				else
					left_block=resultimage(i:i+block_size-1,1+(j-2)*floor(3*block_size/4):1+(j-2)*floor(3*block_size/4)+block_size-1,:);
					left_block_og=resultimage_og(i:i+block_size-1,1+(j-2)*floor(3*block_size/4):1+(j-2)*floor(3*block_size/4)+block_size-1,:);
					current_block=im_2(1+(i-1)*floor(3*block_size/4):1+(i-1)*floor(3*block_size/4)+block_size-1,1+(j-1)*floor(3*block_size/4):1+(j-1)*floor(3*block_size/4)+block_size-1,:);
					block_ov=left_block(i:i+block_size-1,size(left_block,2)-overlap_size+1:size(left_block,2),:);
					err=500;
					arr1=[1,1];
					for m=1:x_dim-block_size+1
						for n=1:y_dim-block_size+1
							texture_block_selected=im_1(m:m+block_size-1,n:n+overlap_size-1,:);
							temp_img=im_1(m:m+block_size-1,n:n+block_size-1,:);
							error_overlap=(texture_block_selected-block_ov).^2;
							error_with_source=(temp_img-current_block).^2;
							error_overlap=rms(error_overlap,"all");
							error_with_source=rms(error_with_source,"all");

							total_error=alpha*error_overlap+(1-alpha)*error_with_source;
							[M,I]=min([err,total_error]);
							err=M;
							if I==2
							arr1=[m,n];
							end
						end
					end
					m=arr1(1);
					n=arr1(2);
					min_err_block_texture=im_1(m:m+block_size-1,n:n+block_size-1,:);
					left_block2=Border(left_block,min_err_block_texture);
					resultimage(i:i+block_size-1,1+(j-2)*floor(3*block_size/4):1+(j-2)*floor(3*block_size/4)+floor(7*block_size/4)-1,:)=left_block2;
					
					min_err_block_texture=im_11(m:m+block_size-1,n:n+block_size-1,:);
					left_block2=Border(left_block_og,min_err_block_texture);
					resultimage_og(i:i+block_size-1,1+(j-2)*floor(3*block_size/4):1+(j-2)*floor(3*block_size/4)+floor(7*block_size/4)-1,:)=left_block2;


				end
			   
			else
				if j==1
					right_img=resultimage(1+(i-2)*floor(3*block_size/4):1+(i-2)*floor(3*block_size/4)+block_size-1,1:block_size,:);
					right_img_og=resultimage_og(1+(i-2)*floor(3*block_size/4):1+(i-2)*floor(3*block_size/4)+block_size-1,1:block_size,:);
					target_img=im_2(1+(i-1)*floor(3*block_size/4):1+(i-1)*floor(3*block_size/4)+block_size-1,1+(j-1)*floor(3*block_size/4):1+(j-1)*floor(3*block_size/4)+block_size-1,:);
					block_ov=right_img(size(right_img,1)-overlap_size+1:size(right_img,1),:,:);
					err=500;
					arr1=[1,1];
					for m=1:x_dim-block_size+1
						for n=1:y_dim-block_size+1
							texture_block_selected=im_1(m:m+overlap_size-1,n:n+block_size-1,:);
							temp_img=im_1(m:m+block_size-1,n:n+block_size-1,:);
							error_overlap=(texture_block_selected-block_ov).^2;
							error_with_target=(temp_img-target_img).^2;
							error_overlap=rms(error_overlap,"all");
							error_with_target=rms(error_with_target,"all");
							total_error=alpha*error_overlap+(1-alpha)*error_with_target;
							[M,I]=min([err,total_error]);
							err=M;
							if I==2
							arr1=[m,n];
							end
						end
					end
					m=arr1(1);
					n=arr1(2);
					min_err_block_texture=im_1(m:m+block_size-1,n:n+block_size-1,:);
					quilted_img=Border(rot90(right_img),rot90(min_err_block_texture));
					quilted_img=rot90(quilted_img,3);
					
					resultimage(1+(i-2)*floor(3*block_size/4):1+(i-2)*floor(3*block_size/4)+floor(7*block_size/4)-1,1:block_size,:)=quilted_img;
					min_err_block_texture=im_11(m:m+block_size-1,n:n+block_size-1,:);
					quilted_img=Border(rot90(right_img_og),rot90(min_err_block_texture));
					quilted_img=rot90(quilted_img,3);
					
					resultimage_og(1+(i-2)*floor(3*block_size/4):1+(i-2)*floor(3*block_size/4)+floor(7*block_size/4)-1,1:block_size,:)=quilted_img;

				else
					im_temp=resultimage(1+(i-2)*floor(3*block_size/4):1+(i-2)*floor(3*block_size/4)+block_size-1,1+(j-1)*floor(3*block_size/4):1+(j-1)*floor(3*block_size/4)+block_size-1,:);
					im_temp_og=resultimage_og(1+(i-2)*floor(3*block_size/4):1+(i-2)*floor(3*block_size/4)+block_size-1,1+(j-1)*floor(3*block_size/4):1+(j-1)*floor(3*block_size/4)+block_size-1,:);
					im1_temp=resultimage(1+(i-1)*floor(3*block_size/4):1+(i-1)*floor(3*block_size/4)+block_size-1,1+(j-2)*floor(3*block_size/4):1+(j-2)*floor(3*block_size/4)+block_size-1,:);
					im1_temp_og=resultimage_og(1+(i-1)*floor(3*block_size/4):1+(i-1)*floor(3*block_size/4)+block_size-1,1+(j-2)*floor(3*block_size/4):1+(j-2)*floor(3*block_size/4)+block_size-1,:);
					im2_temp=im_2(1+(i-1)*floor(3*block_size/4):1+(i-1)*floor(3*block_size/4)+block_size-1,1+(j-1)*floor(3*block_size/4):1+(j-1)*floor(3*block_size/4)+block_size-1,:);
					block_ov=im_temp(size(im_temp,1)-overlap_size+1:size(im_temp,1),:,:);
					block_ov1=im1_temp(:,size(im_temp,2)-overlap_size+1:size(im_temp,2),:);
					err=500;
					arr1=[1,1];
					for m=1:x_dim-block_size+1
						for n=1:y_dim-block_size+1
							texture_block_selected=im_1(m:m+overlap_size-1,n:n+block_size-1,:);
							error_overlap=(texture_block_selected-block_ov).^2;
							error_overlap=rms(error_overlap,"all");

							texture_block_selected1=im_1(m:m+block_size-1,n:n+overlap_size-1,:);
							error_with_target=(texture_block_selected1-block_ov1).^2;
							error_with_target=rms(error_with_target,"all");

							temp_img=im_1(m:m+block_size-1,n:n+block_size-1,:);
							total_error=(temp_img-im2_temp).^2;
							total_error=rms(total_error,"all");

							error_overlap3=alpha*(error_overlap+error_with_target)+(1-alpha)*total_error;
							[M,I]=min([err,error_overlap3]);
							err=M;

							if I==2
								arr1=[m,n];
							end
						end
					end
					m=arr1(1);
					n=arr1(2);
					min_err_block_texture=im_1(m:m+block_size-1,n:n+block_size-1,:);
					quilt_top=Border(rot90(im_temp),rot90(min_err_block_texture));
					quilt_left=Border(im1_temp,min_err_block_texture);
					quilt_top=rot90(quilt_top,3);

					resultimage(1+(i-1)*floor(3*block_size/4):1+(i-1)*floor(3*block_size/4)+block_size-1,1+(j-2)*floor(3*block_size/4):1+(j-2)*floor(3*block_size/4)+floor(7*block_size/4)-1,:)=quilt_left;
					resultimage(1+(i-2)*floor(3*block_size/4):1+(i-2)*floor(3*block_size/4)+block_size-1,1+(j-1)*floor(3*block_size/4):1+(j-1)*floor(3*block_size/4)+block_size-1,:)=quilt_top(1:block_size,:,:);
					min_err_block_texture=im_11(m:m+block_size-1,n:n+block_size-1,:);
					quilt_top=Border(rot90(im_temp_og),rot90(min_err_block_texture));
					quilt_left=Border(im1_temp_og,min_err_block_texture);
					quilt_top=rot90(quilt_top,3);

					resultimage_og(1+(i-1)*floor(3*block_size/4):1+(i-1)*floor(3*block_size/4)+block_size-1,1+(j-2)*floor(3*block_size/4):1+(j-2)*floor(3*block_size/4)+floor(7*block_size/4)-1,:)=quilt_left;
					resultimage_og(1+(i-2)*floor(3*block_size/4):1+(i-2)*floor(3*block_size/4)+block_size-1,1+(j-1)*floor(3*block_size/4):1+(j-1)*floor(3*block_size/4)+block_size-1,:)=quilt_top(1:block_size,:,:);

				end
			end

		end
	end
	%figure;
	%imshow(resultimage_og);
end