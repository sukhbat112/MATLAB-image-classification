%バトムンフ　スフバト　
%Sukhbat Batmunkh

LIST={'pizza' 'hamburger' 'rose' 'sandwich' 'rose_noise' 'hamburger_noise'};

DIR0='imgdir/';

urllists = {'urllist_pizza.txt' 'urllist_hamburger.txt' 'urllist_rose.txt' 'urllist_sandwich.txt' 'urllist_rose_noise.txt' 'urllist_hamburger_noise.txt'};

% Loop through categories
for i=1:length(LIST)
    OUTDIR=strcat(DIR0,LIST{i},'/');   % output directory
    mkdir(OUTDIR);                     % create directory
    
    list=textread(urllists{i},'%s'); % read URL list
    
    % lop through URLs
    for j=1:size(list,1)
        fname=strcat(OUTDIR,num2str(j,'%04d'),'.jpg'); % img file name
        websave(fname,list{j}); % download img
    end
end
