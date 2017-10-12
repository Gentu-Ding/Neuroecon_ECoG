close all;
clear;clf;
addpath(genpath('D:/MATLAB/barwitherr')) % add Fieldtrip into the searching path
load data_decoding
load subj_globals 

gb=gamble_trials( bad_trials==0 & timeout_trials==0);
fb=zeros(size(dd,3),6);
band={2:4;4:8;8:12;12:30;30:60;70:200}; % six frequency bands
acc_trial=zeros(23,20,6);
for q=1:4
    for i=1:6
        for j=1:size(dd,3)
            nfft=1000;
            D=dd(ofc_elecs(q),:,j);
            X = fft(D,nfft);
            X = X(band{i});
            % Take the magnitude of fft of x
            mx = abs(X);
            fb(j,i)=mean(mx);
        end
    end
    fb=zscore(fb);
    c=zeros(2,2,20);
    %acc_trial=zeros(23,20,6);
    
    for k=1:50
        
        
        pg = datasample(find(gb==1),85,'Replace',false);
        ps = datasample(find(gb==0),85,'Replace',false);
        p=vertcat(pg,ps);
        ind=1:1:188;
        cv=1-ismember(ind,p);
        cvl=logical(cv);
        
        for bid=1:6
            
            
            fprintf('\nCurrent fold: %d\n',k);
            [acc, conf]=lda_classi(fb,gb,p,cvl,bid);
            
            
            acc_trial(q,k,bid)=acc;
            
            %c(:,:,k)=conf;
            
            
            
        end
    end
    
%     d(q)=mean(acc_trial(:,1));
%     err(q)=sem(acc_trial(:,1));
    figure(q)
    d=mean(acc_trial);
    err=sem(acc_trial);
    fig=barwitherr(err,d,0.4);
    xticklabels({'delta','theta','alpha','beta','gamma','high gamma'})
    title(['Gamble/Safebet Accuracy of LPFC Electrode' num2str(lpfc_elecs(q))]);
    ylabel('Prediction Accuracy (LDA)')
    xlabel('frequency band')
    %saveas(fig,['LPFC Electrode (LDA)' num2str(lpfc_elecs(q)) '.jpg'])
end

function [acc, MdlLinear]=lda_classi(fb,gb,p,cvl,bid)


x=fb(p,bid);
y=gb(p);


MdlLinear = fitcdiscr(x,y);
yhat=predict(MdlLinear,fb(p,bid));

y_pred=yhat;
acc=sum(y_pred==gb(cvl))/length(gb(cvl));

%conf=confusionmat(double(gb(cvl)),double(y_pred));

end

function [SEM] =sem(x)
SEM=std(x)/sqrt(length(x));
end