allSubjects=24;
subjectNumbers=1;
ifsingle=0;

if ifsingle==1
    allSubjects=subjectNumbers;
end
    
for subjectIdx = subjectNumbers:allSubjects
	disp(subjectIdx); 
        
    EEG = pop_loadset(['D:\Project\Data\preprocess\sample\EEGdata_Exp1\AOExp1_', num2str(subjectIdx), '_resampled_attended.set']);
    for eventIdx = 1 : size(EEG.event, 2)
        if regexp(EEG.event(eventIdx).type,'A[A-D][0-9][0-9][0-9]$')==1
            EEG.event(eventIdx).type=EEG.event(eventIdx).type(2:end);
        end
    end
    for epochIdx=1:size(EEG.epoch,2)
        for eventIdx=1:size(EEG.epoch(epochIdx).eventtype,2)
            if regexp(char(EEG.epoch(epochIdx).eventtype(eventIdx)),'A[A-D][0-9][0-9][0-9]$')==1
                str=char(EEG.epoch(epochIdx).eventtype(eventIdx));
                EEG.epoch(epochIdx).eventtype(eventIdx)=cellstr(str(2:end));
            end
        end
    end
    pop_saveset(EEG, ['D:\Project\Data\preprocess\Exp1\J_EEG\AO_Exp1_', num2str(subjectIdx), '_resampled.set']);
end
% 
% EEG = pop_loadset(['D:\Project\Data\preprocess\sample\EEGdata_Exp2\AOExp2_2_epochedAttended.set']);
% for eventIdx = 1 : size(EEG.event, 2)
% 	if regexp(EEG.event(eventIdx).type,'A[A-D][0-9][0-9][0-9]$')==1
%         EEG.event(eventIdx).type=EEG.event(eventIdx).type(2:end);
%     end
% end
% for epochIdx=1:size(EEG.epoch,2)
%     for eventIdx=1:size(EEG.epoch(epochIdx).eventtype,2)
%         if regexp(char(EEG.epoch(epochIdx).eventtype(eventIdx)),'A[A-D][0-9][0-9][0-9]$')==1
%             str=char(EEG.epoch(epochIdx).eventtype(eventIdx));
%             EEG.epoch(epochIdx).eventtype(eventIdx)=cellstr(str(2:end));
%         end
%     end
% end
% pop_saveset(EEG, ['D:\Project\Data\preprocess\Exp2\8RejectBadTrial\AO_Exp2_2_epoched_Samelength.set']);
