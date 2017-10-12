% Multi_Electrode dynamic Predicion Accuracy on corresponding frequencies
close all;
clear;
%addpath(genpath('D:/MATLAB/barwitherr')) % add Fieldtrip into the searching path
load data_pre
load subj_globals
load behav_globals
gb=gamble_trials( bad_trials==0 & timeout_trials==0);
%gbr=gb(randperm(length(gb)));
%gb=gb(19:188);
all_elec=horzcat(ofc_elecs,lpfc_elecs,mcx_elecs);
for i=1:size(all_elec,2)
    if i<=4
        
        elec_add{i}='ofc';
        
    elseif i<=27
        elec_add{i}='lpfc';
        
    else
        elec_add{i}='motor';
    end
end
ld=dd(lpfc_elecs,:,:);
sampling_rate=1000;
max_freq=200;
compression=1;
band={1:4;5:8;8:12;12:22;22:30;31:41}; % six frequency bands
y=previous_rpe;
for u=1:size(ld,1)
    for i=1:size(ld,3)
        
        
        Input=ld(u,:,i);
        [Data] = create_spect(Input, sampling_rate, max_freq, compression);
        ft=Data.SPEC(band{6},1:end-1);
        sing_fe(i,:)=timebin(mean(ft),10);
        
    end
    band_freq(:,:,u)=sing_fe;
end
for i=1:size(band_freq,2)
    HG_band(:,:,i)=reshape(band_freq(:,i,:),size(band_freq,1),size(band_freq,3));
end

%save HG_band_10 HG_band

for i=1:size(HG_band,3)
    hg=HG_band(:,:,i);
    for j=1:size(hg,2)
        a = std(hg(:,j));
        b = mean(hg(:,j));
        random_hg(:,j) = a.*randn(188,1) + b;
    end
    random_HG(:,:,i)=random_hg;
end

for j=1:size(HG_band,3)
    x=HG_band(:,:,j);
    
    
    [dev,deverr,elec_ind]=lasso_deviance(x,y);
    electrode_index{j}=elec_ind;
    deviance(j)=dev;
    deviance_error(j)=deverr;
        
 
   
end
%mean(acc_trial)
%save dyn_acc_Pre_Choice acc_trial
%load dyn_acc_Pre_Choice
%subplot(2,3,q)
save dev_HG_pre_rpe deviance
save dev_error_HG_pre_rpe deviance_error
save electrode_index_HG_pre_rpe electrode_index


fig=figure(1);
x=-1999:200;

y=mean(acc_trial);
%y=smoothts(y,'b',50);
y = movmean(y,50);
plot(x,y);
err=std(acc_trial)/sqrt(length(acc_trial(:,1)));
err = movmean(err,50);
patch([x fliplr(x)],[y+err fliplr(y-err)],'green');
band_name={'Delta','Theta','Alpha','Beta','Gamma','High Gamma'};
title('Prediction Accuracy of LPFC Electrode Population in High Gamma ');
ylabel('Prediction Accuracy')
xlabel('Time(ms)')
ylim([0.4 0.9]);
xlim([-1999 200]);
hold on;
ystart = 0.4;
yend = 0.8;
plot([ystart yend],'--');
saveas(fig,'LPFC Electrode.fig')
saveas(fig,'LPFC Electrode Population.jpg')


