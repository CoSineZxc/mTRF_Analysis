%% make array of wav envelopes
clc
clear
close all

SingleSentencePath='D:\Project\Data\preprocess\Exp1\1_InsertMarkers\WordAligner\';
ParagraphPath='D:\Project\Data\stimuli_SemanticDissimilarity\';
SamplingRate=100;
SingleSentenceDirOutput=dir(fullfile(SingleSentencePath,'*.mat'));
SentenceNumber=size(SingleSentenceDirOutput,1);
SingleSentencefileNames={SingleSentenceDirOutput.name}';
ParagraphFileName='None';
for NR = 1:SentenceNumber
    %% 
%     if NR==876
%         disp(NR)
%     end
    
    if ~strcmp(ParagraphFileName,SingleSentencefileNames{NR}(1:2))
        ParagraphFileName=SingleSentencefileNames{NR}(1:2);
        WordPointer=0;
        ParagraphWordList=load([ParagraphPath,ParagraphFileName,'_WholeSentence.mat'],'wordlist');
        ParagraphWordDis=load([ParagraphPath,ParagraphFileName,'_WholeSentence.mat'],'WordVec');
    end
    name=SingleSentencefileNames{NR}(1:4);
    SingleSentenceWordList=load([SingleSentencePath,SingleSentencefileNames{NR}],'wordlist');
    SingleSentenceTimeList=load([SingleSentencePath,SingleSentencefileNames{NR}],'timelist');
    DissimilarityList=[];
    for WordNR=1:size(SingleSentenceWordList.wordlist,1)
        DissimilarityList(WordNR)=ParagraphWordDis.WordVec(WordPointer+WordNR);
    end
    MeanDissimilarity=mean(DissimilarityList);
    WordPointer=WordPointer+size(SingleSentenceWordList.wordlist,1);
    env_stim=[];
    for WordNR=1:size(SingleSentenceWordList.wordlist,1)
        if WordNR~=1 && SingleSentenceTimeList.timelist(WordNR-1,2)<SingleSentenceTimeList.timelist(WordNR,1)
            PointAmount=uint8(100*(SingleSentenceTimeList.timelist(WordNR,1)-SingleSentenceTimeList.timelist(WordNR-1,2)));
            GapTimePointList=repelem(MeanDissimilarity,PointAmount);
            env_stim=[env_stim GapTimePointList];
        end
        if WordNR==1 && SingleSentenceTimeList.timelist(WordNR,1)~=0
            PointAmount=uint8(100*(SingleSentenceTimeList.timelist(WordNR,1)-0));
            GapTimePointList=repelem(MeanDissimilarity,PointAmount);
            env_stim=[env_stim GapTimePointList];
        end
        PointAmount=uint8(100*(SingleSentenceTimeList.timelist(WordNR,2)-SingleSentenceTimeList.timelist(WordNR,1)));
        WordTimePointList=repelem(DissimilarityList(WordNR),PointAmount);
        env_stim=[env_stim WordTimePointList]; 
    end
    if SingleSentenceTimeList.timelist(end,2)<2.8
        PointAmount=uint8(100*(2.8-SingleSentenceTimeList.timelist(end,2)));
        GapTimePointList=repelem(MeanDissimilarity,PointAmount);
        env_stim=[env_stim GapTimePointList];
    end 
    %% create cell array of wav envelop files
    attended_stim_code{NR,1}=name;
    attended_stim{NR}=env_stim';
end

save('DissimilarityVector_WholeSentence.mat','attended_stim_code','attended_stim')