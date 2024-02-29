%data_collect.m
%バトムンフ　スフバト　2110733

LIST={'pizza' 'hamburger' 'rose' 'sandwich' 'rose_noise' 'hamburger_noise'};

DIR0='imgdir/';

urllists = {'urllist_pizza.txt' 'urllist_hamburger.txt' 'urllist_rose.txt' 'urllist_sandwich.txt' 'urllist_rose_noise.txt' 'urllist_hamburger_noise.txt'};


for i=1:length(LIST)

    OUTDIR=strcat(DIR0,LIST{i},'/');
    mkdir(OUTDIR);
    
    list=textread(urllists{i},'%s');

    for j=1:size(list,1)
        fname=strcat(OUTDIR,num2str(j,'%04d'),'.jpg')
        websave(fname,list{j});
    end

end