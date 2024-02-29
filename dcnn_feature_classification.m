%バトムンフ　スフバト
%Suhbat Batmunkh

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


net = alexnet;

% network, 入力画像を準備します．
layer = 'fc7';

IM = [];
for i=1:size(newlist, 2)

    img = imread(newlist{i});
    reimg = imresize(img,net.Layers(1).InputSize(1:2)); 
    
    IM=cat(4,IM,reimg);
end


% activationsを利用して中間特徴量を取り出します．
dcnnf = activations(net,IM,layer);  

% squeeze関数で，ベクトル化します．
dcnnf = squeeze(dcnnf);

% L2ノルムで割って，L2正規化．
dcnnf = dcnnf/norm(dcnnf);
dcnnf = dcnnf';  %行列転置

data_pos = dcnnf(1:100,:);
data_neg = dcnnf(101:200,:);

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
