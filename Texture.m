im_1=imread(".\Dataset\transfer\rice.jpg");
im_2=imread(".\Dataset\transfer\bill.jpg");

alpha=0.1;
block_size=16;
N=3;
for i=1:N
    im_2=Texture_Transfer(im_1,im_2,block_size,alpha);
    %alpha=0.1+0.8*(i)/(N-1);
    block_size=block_size/2;
    figure;
    imshow(im_2);
end

