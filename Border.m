function resultimage=Border(im_1,im_2)

	[x_dim,y_dim,~]=size(im_1);
	
	% Calculating the error matrix e by finding difference of intensities of overlap images
	e=(im_1(:,floor(3*y_dim/4):y_dim,:)-im_2(:,1:y_dim-floor(3*y_dim/4)+1,:)).^2;
	
	% Taking mean squared error in the three RGB components
	e=(e(:,:,1)+e(:,:,2)+e(:,:,3))./3;
	
	%matrix which stores the minimum path for corresponding pixel to the top of the overlap region
	
	path_to_top=zeros(size(e,1),size(e,2));
	path_to_top(1,:,1)=1:y_dim-floor(3*y_dim/4)+1;
	
	%pad 1 on the top, left and right
	padd=ones(size(e,1),size(e,2)+2).*255;
	padd(:,2:size(padd,2)-1)=e;
	e=padd;
	
	for i=2:x_dim
		for j=2:size(e,2)-1
			%finding min error in the 3 adjacent columns for the row above
			[M,I]=min([e(i-1,j-1),e(i-1,j),e(i-1,j+1)]);
			e(i,j)=e(i,j)+M; %calculating E matrix
			path_to_top(i,j-1,1:i-1)=path_to_top(i-1,j-3+I,1:i-1);
			path_to_top(i,j-1,i)=j-1;
		end
	end

	[M1,I1]=min(e(size(e,1),2:size(e,2)-1)); %Last row contains the sum of errors of all paths, so min of that
	
	arr=path_to_top(size(e,1),I1,:);
	resultimage=zeros(size(im_1,1),size(im_1,2)+floor(3*y_dim/4),3);
	
	%loop to store the final image (left & right of the path)
	for i=1:size(im_1,1)
		resultimage(i,1:floor(3*y_dim/4)-1+arr(1,1,i),:)=im_1(i,1:floor(3*y_dim/4)-1+arr(1,1,i),:);
		resultimage(i,floor(3*y_dim/4)+arr(1,1,i):y_dim+floor(3*y_dim/4),:)=im_2(i,arr(1,1,i):size(im_1,2),:);

	end
end





