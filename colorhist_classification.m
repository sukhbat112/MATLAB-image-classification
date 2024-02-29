%report1_colorhist.m
%バトムンフ　スフバト　2110733

list={};
LIST={'hamburger' 'sandwich'};
%LIST={'pizza' 'rose'};
DIR0='imgdir/';

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

data_colorh=[];
for i=1:length(list)
    X=imread(list{i});

    RED=X(:,:,1); GREEN=X(:,:,2); BLUE=X(:,:,3);
    X_64=floor(double(RED)/64) *4*4 + floor(double(GREEN)/64) *4 + floor(double(BLUE)/64);

    X_64_vec=reshape(X_64,1,numel(X_64));
    h=histc(X_64_vec,(0:63));

    h = h / sum(h);      % 要素の合計が１になるように正規化します．
    data_colorh=[data_colorh; h];
end


data_pos = data_colorh(1:100,:);
data_neg = data_colorh(101:200,:);

cv=5;
idx=[1:100];

accuracy=[];
% idx番目(idxはcvで割った時の余りがi-1)が評価データ
% それ以外は学習データ
for i=1:cv

    train_pos=data_pos(find(mod(idx,cv)~=(i-1)),:);
    eval_pos =data_pos(find(mod(idx,cv)==(i-1)),:);
    train_neg=data_neg(find(mod(idx,cv)~=(i-1)),:);
    eval_neg =data_neg(find(mod(idx,cv)==(i-1)),:);

    train_data=[train_pos; train_neg];
    eval_data=[eval_pos; eval_neg];

    train_label=[ones(80,1); ones(80,1)*(-1)];
    eval_label =[ones(20,1); ones(20,1)*(-1)];


    %%線形カーネルを用いる
    model = fitcsvm(train_data, train_label,'KernelFunction','linear');
    [predicted_label, scores] = predict(model, eval_data);

    ac = numel(find(eval_label==predicted_label))/numel(eval_label);
    accuracy=[accuracy ac];
end

accuracy;
avg_accuracy = mean(accuracy)