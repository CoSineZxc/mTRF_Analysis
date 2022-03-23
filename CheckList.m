function [Idx] = CheckList(truetypeslist,Regexr)
    A1Aidx=regexp(truetypeslist,Regexr);
    Idx=[];
    for i = 1:size(truetypeslist,2)
        if A1Aidx{i}==1
            Idx=[Idx,i];
        end
    end
end

