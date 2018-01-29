function outStr = dbl_quote_extract( inStr )
% function outStr = dbl_quote_extract( inStr )
% Extract String from between pair of Double Quotes
dqIdx = strfind(inStr, '"');
dqCnt = size(dqIdx,2);

if ((dqCnt == 0) || (1 == mod(dqCnt,2)))
    error( 'Bad string double quote balance')
end

for idx = 1:2:dqCnt
    off = [dqIdx(idx) + 1, dqIdx(idx+1) - 1];
    if (idx == 1)
        outStr = inStr(off(1):off(2));
    else
        outStr = char(outStr, inStr(off(1):off(2)));
    end
end
return;