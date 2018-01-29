function ssh_conn=install_remote_workspace( conn )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%Dossier du pipeline
globaldir='rDTIDA';
COMMAND = ['if [ ! -d ' globaldir ' ]; then mkdir ' globaldir '; fi '];
ssh_conn=ssh2_command(conn,COMMAND,1);

%Dossiers principaux(dans rDTIDA)
datadir='data';
scriptsdir='scripts';
resultsdir='results';

COMMAND= ['cd rDTIDA; mkdir ' datadir ' ' scriptsdir ' ' resultsdir ];
ssh_conn=ssh2_command(conn,COMMAND,1);

%Dossiers data
masksdir='masks';
scmapsdir='scmaps';
atlasdir='atlas';

COMMAND= ['cd rDTIDA/data; mkdir ' masksdir ' ' scmapsdir ' ' atlasdir ];
ssh_conn=ssh2_command(conn,COMMAND,1);

return
end

