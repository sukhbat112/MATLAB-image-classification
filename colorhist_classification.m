%バトムンフ　スフバト

list={}; 
LIST={'hamburger' 'sandwich'}; % list of categories
%LIST={'pizza' 'rose'};
DIR0='imgdir/'; % directory containing each dataset

%loop through each category names to create new list of all filenames
for i=1:length(LIST)
    DIR=strcat(DIR0,LIST(i),'/'); % create category directory
    W=dir(DIR{:}); 
    % loop through directory contents
    for j=1:size(W)
        if (strfind(W(j).name,'.jpg')) 
            fn=strcat(DIR{:},W(j).name); 
            
            list={list{:} fn}; 
        end
    end
end

posimg=list(1:100); % positive images names
negimg=list(101:200); % negative image names

newlist={posimg{:} negimg{:}}; % combine

data_colorh=[]; % color histogram
% loop through images

for i=1:length(list)
    X=imread(list{i}); 
    
    RED=X(:,:,1); GREEN=X(:,:,2); BLUE=X(:,:,3); % RGB channels
    X_64=floor(double(RED)/64) *4*4 + floor(double(GREEN)/64) *4 + floor(double(BLUE)/64); % color to 4 base numbers
    
    X_64_vec=reshape(X_64,1,numel(X_64)); 
    h=histc(X_64_vec,(0:63)); % compute histogram

    h = h / sum(h); 
    data_colorh=[data_colorh; h]; % add histogram to data ( color histograms of all images)
end

data_pos = data_colorh(1:100,:); % positive
data_neg = data_colorh(101:200,:); % negative

% 5 fold cross validation
cv=5; 
idx=[1:100]; 

accuracy=[]; 

% cross-validation loop
for i=1:cv
    train_pos=data_pos(find(mod(idx,cv)~=(i-1)),:); 
    eval_pos =data_pos(find(mod(idx,cv)==(i-1)),:); 
    train_neg=data_neg(find(mod(idx,cv)~=(i-1)),:); 
    eval_neg =data_neg(find(mod(idx,cv)==(i-1)),:); 

    train_data=[train_pos; train_neg]; 
    eval_data=[eval_pos; eval_neg]; 

    train_label=[ones(80,1); ones(80,1)*(-1)]; % training labels
    eval_label =[ones(20,1); ones(20,1)*(-1)]; % evaluation labels

    % train linear SVM model
    model = fitcsvm(train_data, train_label,'KernelFunction','linear');
    [predicted_label, scores] = predict(model, eval_data); % Predict labels

    ac = numel(find(eval_label==predicted_label))/numel(eval_label); % compute accuracy
    accuracy=[accuracy ac]; 
end

accuracy; 
avg_accuracy = mean(accuracy) % compute average accuracy
