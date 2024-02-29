%バトムンフ　スフバト
%Sukhbat Batmunhk

list={};
LIST={'hamburger' 'other' 'hamburger_noise'};
%LIST={'rose' 'other' 'rose_noise'};
%n=25;
n=50;

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

neg_size = 500;
eval_size = 300;

posimg = list(1:n);   
negimg = list(101 : 100+neg_size);
eval_img = list(100+neg_size+1 : length(list));

newlist={posimg{:} negimg{:} eval_img{:}};
all_size = length(newlist);


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

train_data = [dcnnf(1:n,:); dcnnf(n+1 : all_size - eval_size, :)];
train_label = [ones(n,1); ones(all_size - eval_size -n, 1)*(-1)];

eval_data = [dcnnf(all_size-eval_size + 1:all_size,:)];
eval_label = [ones(eval_size,1)];


%線形カーネル
model = fitcsvm(train_data, train_label,'KernelFunction','linear'); 

[predicted_label, scores] = predict(model, eval_data);


% 降順 ('descent') でソートして，ソートした値とソートインデックスを取得します．
[sorted_score,sorted_idx] = sort(scores(:, 2), 'descend');

% list{:} に画像ファイル名が入っているとして，
% sorted_idxを使って画像ファイル名，さらに
% sorted_score[i](=score[sorted_idx[i],2])の値を出力します．

for i=1:numel(sorted_idx)
  fprintf('%s %f\n',eval_img{sorted_idx(i)},sorted_score(i));
end



%学習に用いた画像の上位の25枚
figure;
%sgtitle('学習に用いた画像の上位の25枚');
for i=1:25
    subplot(5 , 5, i);
    img = imread(posimg{i});
    imshow(img);
    title(string(i));
end




%ランキングした画像の上位25枚
figure;
%sgtitle('ランキングした画像の上位25枚');

for i=1:25
    subplot(5 , 5, i);
    img = imread(eval_img{sorted_idx(i)});
    imshow(img);
    title(string(i));
end

%ランキングした画像の下位の25枚
figure;
%sgtitle('ランキングした画像の下位25枚');

for i=1:25
    subplot(5 , 5, i);
    img = imread(eval_img{sorted_idx(eval_size-i+1)});
    imshow(img);
    title(string(eval_size-i+1));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%正解枚数を数えるとき以下を使う

%ランキングした画像の上位100枚
figure;
sgtitle('ランキングした画像の上位100枚');

for i=1:100
    subplot(10 , 10, i);
    img = imread(eval_img{sorted_idx(i)});
    imshow(img);
    %title(string(i));
end

%ランキングした画像の上位100枚
figure;
sgtitle('ノイズが入った画像の上位100枚');

for i=1:100
    subplot(10 , 10, i);
    img = imread(eval_img{i});
    imshow(img);
    %title(string(i));
end
