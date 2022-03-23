clc
clear all
load('DissimilarityVector.mat');
%% variables
% thresh=3; %DS for kertosis and probability for channel rejection
% rej_all=zeros(18,60);
% EEG_NR_data=[];
% reg_all_percent=zeros(18,1);
tmin=0;
tmax=250;
model_direction=-1;

EEGdataPath='D:\Project\Data\preprocess\11resample\';
allSubjects=24;
subjectNumbers=1;
ifsingle=0;
if ifsingle==1
	allSubjects=subjectNumbers;
end
    
for subjectIdx = subjectNumbers:allSubjects
    Fname=strcat(EEGdataPath,'AO_Exp1_',num2str(subjectIdx), '_resampled.set');
    EEG = pop_loadset(Fname);
    EEG = eeg_checkset(EEG);
%     a=find(contains({EEG.event.type},'D4'));
    AxDidx=CheckList({EEG.event.type},'D4[0-9][0-9]$');
    ConditionEventIndices = [AxDidx];
    fprintf('\nEpoching to all attended sentences.\n');
	EEG = pop_epoch(EEG,{}, [-0.2, 2.8], 'eventindices', ConditionEventIndices); 
    code_array=cell(size(EEG.data,3),1,1);
    for cell_array_loop=1:size(EEG.data,3)
        q = EEG.event;
        q2 = find([q.epoch]==cell_array_loop);
        tempy = {q(q2).type};
        idx=CheckList(tempy,'D4[0-9][0-9]$');
        code_array{cell_array_loop,1}=tempy{1,idx};
    end
    %finish
    for find_loop=1:size(EEG.data,3)
        out=find(all(ismember(cellfun(@num2str,attended_stim_code,'un',0),cellfun(@num2str,(code_array(find_loop)),'un',0)),2));%this finds out where each epoch (1:size EEG.data) is indexed in the .wav array
        wav_match{find_loop}=nt_normcol((attended_stim{1,out}(1:280,1)));% find the correct wav file to match the data in that row and normalise it
        data_match{find_loop}=nt_normcol(EEG.data(:,21:300,find_loop))';%20:300 is needed to fix the data currently having a baseline
    end
    %     %toolbox
	lambdas=[1e-3,1e-2,1e-1,1,10,1e2,1e3,1e4,1e5,1e6,1e7,1e8];

	[r2,p,~,pred,model]=mTRFcrossval(wav_match,data_match,100,model_direction,tmin,tmax,lambdas);% stimuli [cell{1,trials}(time by features)]%responses [cell{1,trials}(time by channels)]
    
	figure; plot(mean(r2));%show average correlation at each lambda
	[row,col] =max(mean(r2));
	r2_p_Lam_All(subjectIdx,1)=(mean(r2(:,col),1));
	r2_p_Lam_All(subjectIdx,2)=(mean(p(:,col),1));
 	r2_p_Lam_All(subjectIdx,3)=col;
 	r2_p_Lam_All(subjectIdx,4)=lambdas(col);
end