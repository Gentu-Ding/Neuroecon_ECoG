% Single_Electrode dynamic Predicion Accuracy on corresponding frequencies
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
u=5;
for u=1:23
    figure(u)
    for j=1:6
        for i=1:size(ld,3)
            
            Input=ld(u,:,i);
            [Data] = create_spect(Input, sampling_rate, max_freq, compression);
            ft=Data.SPEC(band{j},1:end-1);
            sing_fe(i,:)=smoothts(mean(ft),'b',50);
            
        end
        band_freq{j}=sing_fe;
    end
    
    
    %[b, dev, stats] =glmfit(x,y,'binomial','link','logit');
    bid=0;
    
    for q=1:6
        sing_fe=band_freq{q};
        
        for j=1:size(sing_fe,2)
            x=sing_fe(:,j);
            for k=1:20
                
                
                pg = datasample(find(gb==1),65,'Replace',false);
                ps = datasample(find(gb==0),65,'Replace',false);
                p=vertcat(pg,ps);
                ind=1:1:188;
                cv=1-ismember(ind,p);
                cvl=logical(cv);
                
                
                
                
                fprintf('\nCurrent fold: %d\n',k);
                [acc, conf]=logit_classi(x,gb,p,cvl,bid);
                
                
                acc_trial(k,j)=acc;
                 
                %c(:,:,k)=conf;
                %beta_cof(q,k)=cof;
            end
        end
        %mean(acc_trial)
        %save dyn_acc_Pre_Choice acc_trial
        %load dyn_acc_Pre_Choice
        subplot(2,3,q)
        
        x=-1999:200;
        
        y=mean(acc_trial);
        %y=smoothts(y,'b',50);
        y = movmean(y,50);
        plot(x,y);
        err=std(acc_trial)/sqrt(length(acc_trial(:,1)));
        err = movmean(err,50);
        patch([x fliplr(x)],[y+err fliplr(y-err)],'green');
        band_name={'Delta','Theta','Alpha','Beta','Gamma','High Gamma'};
        title(['Prediction Accuracy of LPFC' num2str(lpfc_elecs(u)) ' in ',band_name{q}]);
        ylabel('Prediction Accuracy')
        xlabel('Time(ms)')
        ylim([0.4 0.9]);
        xlim([-1999 200]);
        hold on;
        ystart = 0.4;
        yend = 0.8;
        plot([ystart yend],'--');
    end
    saveas(fig,['LPFC Electrode' num2str(lpfc_elecs(u)) '.fig'])
    saveas(fig,['LPFC Electrode' num2str(lpfc_elecs(u)) '.jpg'])
end

function [acc, conf]=logit_classi(fb,gb,p,cvl,bid)

yc=zeros(1,58);
x=fb(p,:);
y=gb(p);

b = glmfit(x,y,'binomial','link','logit');
%cof=b;
yhat=glmval(b,fb(cvl,:),'logit');

yc(yhat>0.5)=1;
yc(yhat<0.5)=0;
yc(yhat==0.5)=randi([0,1]);
y_pred=yc';
acc=sum(y_pred==gb(cvl))/length(gb(cvl));

conf=confusionmat(double(gb(cvl)),y_pred);

end
