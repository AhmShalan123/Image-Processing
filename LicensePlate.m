img=imread('Dr.TestCase/Total image.jpg');

%Turning image to gray scale
gImg=rgb2gray(img);
binImg=~imbinarize(gImg);
filldImg=imfill(binImg,'holes');
opemedImg = bwareaopen(filldImg,200);

platesP =regionprops(opemedImg,'Orientation','BoundingBox');

count = numel(platesP);
platesBB = [];
plateAngel = [];
%Getting the bounding box and orientation of each plate in image 
 for i=1:count
     platesBB = [platesBB platesP(i).BoundingBox];
     plateAngel = [plateAngel platesP(i).Orientation];
 end

if length(platesBB) > 4
    croppedPlates = cell(4,1);
    rgbPlates = cell(4,1);
    for i=1 :length(croppedPlates)
        croppedPlates{i,1} = imcrop(binImg, platesBB(4*i-3:4*i));
        rgbPlates{i,1} = imcrop(img, platesBB(4*i-3:4*i));
    end
    platesNumber = 4;
else
    croppedPlates = cell(1,1);
    rgbPlates = cell(1,1);
    croppedPlates{1,1} = imcrop(binImg, platesBB(:));
    rgbPlates{1,1} = imcrop(img, platesBB(:));
    platesNumber = 1;
end

for i=1 :length(croppedPlates)
    if plateAngel(i)> 5 && plateAngel(i) < 20 || plateAngel(i)<-5 && plateAngel(i) > -20
        angle=plateAngel(i);
        croppedPlates{i,1}=imrotate(croppedPlates{i,1},-angle,'crop');
        rgbPlates{i,1}=imrotate(rgbPlates{i,1},-angle,'crop');
    elseif plateAngel(i)> 20 || plateAngel(i)<-20
        angle=plateAngel(i);
        croppedPlates{i,1}=imrotate(croppedPlates{i,1},-angle/2,'crop');
        rgbPlates{i,1}=imrotate(rgbPlates{i,1},-angle/2,'crop');
    else
        croppedPlates{i,1}=croppedPlates{i,1};
        rgbPlates{i,1} = rgbPlates{i,1};
    end

end
   

LetterPath='CharacterImages\\Charcter\\'; 
NumberPath='CharacterImages\\numbers\\'; 


numberImgs = dir(strcat(NumberPath,'*.bmp'));
letterImgs=dir(strcat(LetterPath,'*.bmp'));


 %Read template Image
 charctersTemplate=cell(length(numberImgs)+length(letterImgs),1);
 
 for i=1:length(numberImgs)
     charctersTemplate{i}=imread(strcat(NumberPath,numberImgs(i).name));
     if(size(charctersTemplate{i},3)>1)
         charctersTemplate{i}=rgb2gray(charctersTemplate{i});
     end
     charctersTemplate{i}=imresize(charctersTemplate{i},[42 24]);
 end
 
 for i=1:length(letterImgs)
     charctersTemplate{length(numberImgs)+i}=imread(strcat(LetterPath,letterImgs(i).name));
     charctersTemplate{length(numberImgs)+i}=imresize(charctersTemplate{length(numberImgs)+i},[42 24]);
     if(size(charctersTemplate{length(numberImgs)+i},3)>1)
         charctersTemplate{length(numberImgs)+i}=rgb2gray(charctersTemplate{length(numberImgs)+i});
     end
 end
 
 lettP = cell(platesNumber,1);
 croppedLett = cell(platesNumber,1);

  for i=1 :platesNumber
       c=size(croppedPlates{i,1},1);
       croppedPlates{i,1}= croppedPlates{i,1}(ceil(0.37*c):c,:);
       
       se=strel('disk',1);
       croppedPlates{i,1}=imdilate(croppedPlates{i,1},se);
       croppedPlates{i,1}=bwareafilt(croppedPlates{i,1},[10 250]);
       
       lettP{i,1}=regionprops(croppedPlates{i,1},'BoundingBox');
       croppedLett{i,1}=cell(length(lettP{i,1}),1);
       numFeatures=cell(length(lettP{i,1}),1);
       charFeatures=cell(length(lettP{i,1}),1);
       numCount=0;
       hold on
       for j = 1 : length(lettP{i,1})
           
           charBB = lettP{i,1}(j).BoundingBox;
           rectangle('Position', [charBB(1),charBB(2),charBB(3),charBB(4)],'EdgeColor','g','LineWidth',2) ;
           croppedLett{i,1}{j}=imcrop(croppedPlates{i,1},charBB);
           croppedLett{i,1}{j}=imerode(croppedLett{i,1}{j},se);
           croppedLett{i,1}{j}=imresize(croppedLett{i,1}{j},[42 24]);

           numFeatures{j}=zeros(length(numberImgs),1);
           charFeatures{j}=zeros(length(letterImgs),1);
           for b=1:length(numberImgs)
                  numFeatures{j}(b)=corr2(charctersTemplate{b},croppedLett{i,1}{j});
           end
           for t=1:length(letterImgs)
                  charFeatures{j}(t)=corr2(charctersTemplate{length(numberImgs)+t},croppedLett{i,1}{j});
           end
           [m1,index1]=max(numFeatures{j});
           [m2,index2]=max(charFeatures{j});
           if(m1>m2)
               index=index1;
               numCount=numCount+1;
           else
               index=length(numberImgs)+index2;
           end
       end
          if length(lettP{i,1}) == 6 && numCount == 3
              disp('Governorate of vehicle: Cairo')
          elseif length(lettP{i,1}) == 6 && numCount == 4
              disp('Governorate of vehicle: Giza')
          else
              disp('Other Governorate')
          end
  end

for i=1:platesNumber
    

    colorHeight = size(rgbPlates{i,1});
    rgbPlates{i,1} = rgbPlates{i,1}(1:ceil(0.1*colorHeight),:,:);
    redColor = rgbPlates{i,1}(:,:,1) ;
    greenColor= rgbPlates{i,1}(:,:,2);
    blueColor = rgbPlates{i,1}(:,:,3);
    outRed = redColor>150 & greenColor < 50 & blueColor < 50;
    outOrange = redColor>250 & greenColor>50 & greenColor<130 & blueColor<20;
    outGray = redColor>100 & greenColor>100& blueColor>100 & redColor <150 & greenColor<150 & blueColor<150;
    outLightBlue = redColor<90 & greenColor>86 & greenColor<228 & blueColor >130 & blueColor <251;
    
    avgRed=mean(outRed(:));
    avgOrange=mean(outOrange(:));
    avgLightBlue=mean(outLightBlue(:));
    avgGray=mean(outGray(:));
    
    avgColorArr=[avgRed,avgLightBlue,avgOrange,avgGray];
    trueColor=max(avgColorArr);
    
    if trueColor==avgLightBlue
         disp("Owners car");
    elseif trueColor==avgRed
        disp("Transport");
    elseif trueColor==avgGray
        disp("Government car");
    elseif trueColor==avgOrange
        disp("Taxi");
    end
    

end
clf
for j=1:platesNumber
    subplot(1,platesNumber,j)
    imshow(croppedPlates{j,1})
    numberImgs=length(lettP{j,1});
    numberImgs=int2str(numberImgs);
    title(strcat('Number of charcters',numberImgs));
    hold on
  for K = 1 : length(lettP{j})
       charBB = lettP{j,1}(K).BoundingBox;
       rectangle('Position', [charBB(1),charBB(2),charBB(3),charBB(4)],'EdgeColor','g','LineWidth',1) ;

  end
end

