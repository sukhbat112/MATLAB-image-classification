%バトムンフ　スフバト

LIST={'hamburger' 'sandwich'};
%LIST={'pizza' 'rose'};
DIR0='imgdir/';
list = {};

for i=1:length(LIST)
    DIR=strcat(DIR0,LIST(i),'/');
    W=dir(DIR{:});

    for j=1:size(W)
        if (strfind(W(j).name,'.jpg'))
            fn=strcat(DIR{:},W(j).name);

    	    list={list{:} fn};
        end
    end
end

posimg=list(1:100);   
negimg=list(101:200);

newlist={posimg{:} negimg{:}};


%bof histogram expression
features=[];
for i=1:200
  I=rgb2gray(imread(newlist{i}));
  p=createRandomPoints(I, 2000);  %%%random point sampling 
  [f,p2]=extractFeatures(I,p);

  features=[features; f];
end

features=features(randperm(size(features,1),40000),:); %select 40000 randomly to save time (optional)
k = 500;
[idx, codebook]=kmeans(features, k);

n = 200;
bof = zeros(n, k);

for j = 1:n  % each image
    I = rgb2gray(imread(newlist{j}));
    p = createRandomPoints(I, 2000);
    [f, p2] = extractFeatures(I, p);

    for i = 1:size(p2, 1)  % each feature
        
        %euclidean distance
        rep_f = repmat(f(i, :), size(codebook, 1), 1);
        rep_f = (rep_f-codebook).^2;
        sum_rep_f = sum(rep_f, 2);
        d = sqrt(sum_rep_f);
        [~, index] = min(d);

        % update bof histogram
        bof(j, index) = bof(j, index) + 1;
    end
end

%normalization
bof = bof./sum(bof, 2);

%data label
data_pos = bof(1:100,:); %positive bunch
data_neg = bof(101:200,:); %negative bunch

%5 fold cross validation
cv=5;
idx=[1:100];

accuracy=[];
% {idx} is evaluation data the other 4 is training data 

for i=1:cv

    train_pos=data_pos(find(mod(idx,cv)~=(i-1)),:);
    eval_pos =data_pos(find(mod(idx,cv)==(i-1)),:);
    train_neg=data_neg(find(mod(idx,cv)~=(i-1)),:);
    eval_neg =data_neg(find(mod(idx,cv)==(i-1)),:);

    train_data=[train_pos; train_neg];
    eval_data=[eval_pos; eval_neg];

    train_label=[ones(80,1); ones(80,1)*(-1)];
    eval_label =[ones(20,1); ones(20,1)*(-1)];


    %%linear SVM model for the training and prediction
    model = fitcsvm(train_data, train_label,'KernelFunction','rbf','KernelScale','auto');
    [predicted_label, scores] = predict(model, eval_data);

    ac = numel(find(eval_label==predicted_label))/numel(eval_label);
    accuracy=[accuracy ac];
end

accuracy;
avg_accuracy = mean(accuracy)
%%
function PT=createRandomPoints(I,num)
  [sy sx]=size(I);
  sz=[sx sy];
  for i=1:num
    s=0;
    while s<1.6
      s=randn()*3+3;
    end
    p=ceil((sz-ceil(s)*2).*rand(1,2)+ceil(s));
    if i==1
      PT=[SURFPoints(p,'Scale',s)];
    else
      PT=[PT; SURFPoints(p,'Scale',s)];
    end
  end
end
