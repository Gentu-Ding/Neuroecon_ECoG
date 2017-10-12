% Multi_Electrode dynamic Predicion Accuracy on corresponding frequencies
close all;
clear;
addpath(genpath('D:/MATLAB/barwitherr')) % add Fieldtrip into the searching path
load data_pre
load subj_globals
gb=gamble_trials( bad_trials==0 & timeout_trials==0);
%gbr=gb(randperm(length(gb)));
%gb=gb(19:188);
ld=dd(lpfc_elecs,:,:);
sampling_rate=1000;
max_freq=200;
compression=1;
band={1:4;5:8;8:12;12:22;22:30;31:41}; % six frequency bands

for u=1:size(ld,1)
    for i=1:size(ld,3)
        
        
        Input=ld(u,:,i);
        [Data] = create_spect(Input, sampling_rate, max_freq, compression);
        ft=Data.SPEC(band{6},1:end-1);
        sing_fe(i,:)=smoothts(mean(ft),'b',50);
        
    end
    band_freq(:,:,u)=sing_fe;
end
for i=1:size(band_freq,2)
    HG_band(:,:,i)=reshape(band_freq(:,i,:),size(band_freq,1),size(band_freq,3));
end

%[b, dev, stats] =glmfit(x,y,'binomial','link','logit');
bid=0;
save HG_band HG_band


for j=1:size(HG_band,3)
    x=HG_band(:,:,j);
    
    
    bid=0;
    for k=1:20
        
        
        pg = datasample(find(gb==1),65,'Replace',false);
        ps = datasample(find(gb==0),65,'Replace',false);
        p=vertcat(pg,ps);
        ind=1:1:188;
        cv=1-ismember(ind,p);
        cvl=logical(cv);
        
        [B,FitInfo] = lassoglm(x(p,:),gb(p),'binomial',...
            'NumLambda',25,'CV',10);
        
        
        indx = FitInfo.IndexMinDeviance;
        %indx=24;
        B0 = B(:,indx);
        nonzeros = sum(B0 ~= 0);
        ind = find(B0); % indices of nonzero predictors
        x1=x(:,ind);
        elec_ind{k,j}=ind;
        
        if nonzeros==0
            acc_trial(k,j)=0.05.*randn(1,1) + 0.5;
        else 
            fprintf('\nCurrent fold: %d\n',k);
            [acc, conf]=logit_classi(x1,gb,p,cvl,bid);
            acc_trial(k,j)=acc;
        end
        %c(:,:,k)=conf;
        %beta_cof(q,k)=cof;
    end
end
%mean(acc_trial)
%save dyn_acc_Pre_Choice acc_trial
%load dyn_acc_Pre_Choice
%subplot(2,3,q)
save acc_trial_all_elec acc_trial
save electrode_index elec_ind


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




