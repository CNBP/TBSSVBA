subjs={'SALI02_tensor_fa','SALI04_tensor_fa',...
    'SALK01_tensor_fa', 'SALK02_tensor_fa',...
    'SALK03_tensor_fa','SALK04_tensor_fa',...
        'SALK05_tensor_fa','SALK06_tensor_fa',...
    'SALL01_tensor_fa','SALL02_tensor_fa',...
    'SALL03_tensor_fa','SALL04_tensor_fa'};

        


FOLDER='SCORES';
files=dir(fullfile(FOLDER,'*.txt'));

data=zeros(length(files),2);
score_matrix=zeros(length(subjs),length(subjs));

for i=1:length(files)
    
    fileID=fopen([FOLDER filesep files(i).name]);
    
    data(i,:)=fscanf(fileID,'%f %f');
    
    
    for s=1:length(subjs)
        for t=1:length(subjs)
            if strfind(files(i).name,[subjs{s} '_to_' subjs{t}])
                score_matrix(s,t)=data(i,1);
               break;
            end
        end
    end
    
    fclose(fileID);
    
end

mean_score=mean(score_matrix);
subjs{mean_score==min(mean_score)}

%% Plot
figure(1)
subplot(2,1,1)
s=imresize(score_matrix,100,'nearest');
imshow(s,[])
colormap jet
colorbar
xlabel('Target subject number')
ylabel('Moving subject number')

subplot(2,1,2)
m=imresize(mean_score,100,'nearest');
imshow(m,[])
colormap jet
colorbar


