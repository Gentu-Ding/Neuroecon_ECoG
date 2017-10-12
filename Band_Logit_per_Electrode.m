%%Logistic Regression---Average High Gamma Power(70Hz-200Hz) on Multi-channel Data
close all;
clear;
addpath(genpath('D:/MATLAB/barwitherr')) % add Fieldtrip into the searching path
load data_decoding
load subj_globals 

gb=gamble_trials( bad_trials==0 & timeout_trials==0);
%gb=gb(19:end);
%dd=dd(:,:,19:end);
sampling_rate=1000;
max_freq=200;
compression=1;
fb=zeros(size(dd,3),6);
ld=dd(lpfc_elecs,:,:);
band={1:4;5:8;8:12;12:22;22:30;31:41}; % six frequency bands
for q=1:2
    sing_fe=[];
    for i=1:size(ld,3)
        Input=ld(q,:,i);
        [Data] = create_spect(Input, sampling_rate, max_freq, compression);
        
        sing_fe(i,:)=mean(Data.SPEC(:,201:1200),2);
        
    end
    sing_fe=sing_fe(:,1:end-1);
    
    for j=1:6
        fb(:,j)=mean(sing_fe(:,band{j}),2);

        
    end
    
    %fb=zscore(fb);
    %c=zeros(2,2,20);
    %acc_trial=zeros(20,6);
    
    for k=1:20
        
        
        pg = datasample(find(gb==1),65,'Replace',false);
        ps = datasample(find(gb==0),65,'Replace',false);
        p=vertcat(pg,ps);
        ind=1:1:188;
        cv=1-ismember(ind,p);
        cvl=logical(cv);
        
        for bid=1:6
            
            
            fprintf('\nCurrent fold: %d\n',k);
            [acc, cof]=logit_classi(fb,gb,p,cvl,bid);
            
            
            acc_trial(k,bid)=acc;
            
            
            
            %c(:,:,k)=conf;
            
            
            
        end
        %beta_cof(q,k)=cof;
    end
    
%     d2(q)=mean(acc_trial);
%     err(q)=sem(acc_trial);
    fig=figure(q);
    d=mean(acc_trial);
    err=sem(acc_trial);
    barwitherr(err,d,0.4);
    xticklabels({'delta','theta','alpha','beta','gamma','high-gamma'})
    title(['Gamble/Safebet Accuracy of LPFC Electrode' num2str(lpfc_elecs(q))]);
    ylabel('Prediction Accuracy (Logistic Regression)')
    xlabel('frequency band')
    saveas(fig,['LPFC Electrode' num2str(lpfc_elecs(q)) '.fig'])
end

function [acc, cof]=logit_classi(fb,gb,p,cvl,bid)

yc=zeros(1,58);
x=fb(p,bid);
y=gb(p);

b = glmfit(x,y,'binomial','link','logit');
cof=b(2);
yhat=glmval(b,fb(cvl,bid),'logit');

yc(yhat>0.5)=1;
yc(yhat<0.5)=0;
yc(yhat==0.5)=randi([0,1]);
y_pred=yc';
acc=sum(y_pred==gb(cvl))/length(gb(cvl));

%conf=confusionmat(double(gb(cvl)),y_pred);

end

function [SEM] =sem(x)
SEM=std(x)/sqrt(length(x));
end