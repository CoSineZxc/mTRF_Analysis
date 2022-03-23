clc
clear

pathIn='D:\Project\Data\preprocess\11resample\';
load('./DissimilarityVector.mat');
cd(pathIn);
ssList=uipickfiles('FilterSpec', '*.set','Prompt','Select the preprocessed .set files');
nID=size(ssList,2);
cd('D:\Project\Code\matlab\mTRF_script_Xuanci');
condition = 'C';
tmin=0;
tmax=250;
model_direction=-1;% 1: forward model, -1: backward model
group = '1'; %1=monolinguals; 2= bilinguals
T1 = readtable('D:\Project\Data\preprocess\sample\Test_r.xlsx');

for i=1:nID
    disp(strcat('nID:',string(i)))
    [filepath,name,ext] = fileparts(ssList{i});
%     names{i:1}=name;
    newname = name(9:end-10);
    setName = [name ext];
    EEG = pop_loadset(setName,filepath);
%     initialVars = who;
    aidx=CheckList({EEG.event.type},[condition,'[1-4][0-9][0-9]$']);
%     bidx=CheckList({EEG.event.type},[condition,'2[0-9][0-9]$']);
%     cidx=CheckList({EEG.event.type},[condition,'3[0-9][0-9]$']);
%     didx=CheckList({EEG.event.type},[condition,'4[0-9][0-9]$']);
    ConditionEventIndices = [aidx];
    EEG = pop_epoch(EEG,{}, [-0.2, 2.8], 'eventindices', ConditionEventIndices); 
    
    code_array=cell(size(EEG.data,3),1,1);
    for cell_array_loop=1:size(EEG.data,3)
        q = EEG.event;
        q2 = find([q.epoch]==cell_array_loop);
        tempy = {q(q2).type};
        idx=CheckList(tempy,[condition, '[1-4][0-9][0-9]$']);
        if ~isempty(idx)
            code_array{cell_array_loop,1}=tempy{1,idx};
        end
    end
    wav_match={};
    data_match={};
    for find_loop=1:size(EEG.data,3)
        out=find(all(ismember(cellfun(@num2str,attended_stim_code,'un',0),cellfun(@num2str,(code_array(find_loop)),'un',0)),2));%this finds out where each epoch (1:size EEG.data) is indexed in the .wav array
        wav_match{find_loop}=nt_normcol((attended_stim{1,out}(1:280,1)));% find the correct wav file to match the data in that row and normalise it
        data_match{find_loop}=nt_normcol(EEG.data(:,21:300,find_loop))';%20:300 is needed to fix the data currently having a baseline
    end
    lambdas=[1e-3,1e-2,1e-1,1,10,1e2,1e3,1e4,1e5,1e6,1e7,1e8];
    
	[r,p,~,pred,model]=mTRFcrossval(wav_match,data_match,100,model_direction,tmin,tmax,lambdas);% stimuli [cell{1,trials}(time by features)]%responses [cell{1,trials}(time by channels)]
    filename=strcat('D:\Project\Data\mTRF\test\',string(i),'DissimilarityVector.mat');
    save(filename,'r');
    
    [row,col] =max(mean(r));        
    values = r(:,col);
    sz = size(values);
    level = strcat(condition);
    
    T = readtable('D:\Project\Data\preprocess\sample\Test_r.xlsx');
    T(:,1) = array2table(code_array); 
	T(:,2) = array2table(values);
    T(:,3) = repmat({level}, size(T,1), 1);
    T(:,4) = repmat({newname}, size(T,1), 1);
    T(:,5) = repmat({group}, size(T,1), 1);
    writetable(T,strcat('D:\Project\Data\mTRF\test\all_epochs_',level,'_',group,'_',string(i),'_all_r.xlsx'));
    T1 = [T1 ; T];

%     clearvars('-except',initialVars{:})
end
writetable(T1,strcat('D:\Project\Data\mTRF\all_epochs_',level,'_',group,'_all_r.xlsx'));







