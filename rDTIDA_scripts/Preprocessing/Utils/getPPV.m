function vals = getPPV(ppName,ppPath)
% function vals = getPPV(ppName,ppPath)
% read a single parameter value from the procpar file
fp = fopen( ppPath, 'r');
done = 0;
vals = [];

while( done == 0 )
    line = fgetl(fp);
    if (line == -1)
        done = 1;
    else
        %      if ~isletter(line)
        %	 disp(line);
        %         error( 'bad format')
        %      else
        if (strcmp(line(1),ppName(1)))
            [name, attr] = strtok(line);
            if (strcmp(name, ppName))
                
                attr = str2num(attr);
                
                % Read in the values
                line = fgetl(fp);
                %disp(line);
                [cnt, parm] = strtok(line);
                cnt = str2num(cnt);
                
                % REAL_VALS
                if (attr(2) == 1)
                    vals = str2num( parm );
                    % STRING_VALS
                else
                    vals = dbl_quote_extract( parm );
                    while( size(vals,1) ~= cnt )
                        line = fgetl(fp);
                        vals = char(vals, dbl_quote_extract( line ) );
                    end
                end
                
                if (strcmp(name, ppName))
                    break;
                else
                    vals=[];
                end
                
                % Read in the enums
                enum_line = fgetl(fp);
            end
        end
        %     end
    end
end
fclose( fp );
return;
