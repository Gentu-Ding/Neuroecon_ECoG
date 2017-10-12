% LASSO Logistic Regression on muilti-electrodes
close all;
clear;
addpath(genpath('D:/MATLAB/barwitherr')) % add Fieldtrip into the searching path
load data_decoding
load subj_globals 
ld=dd(lpfc_elecs,:,19:188);
gb=gamble_trials( bad_trials==0 & timeout_trials==0);
gb=gb(19:188);
ldg=ld(:,:,gb);
lds=ld(:,:,~gb);
sd=smoothts(lds,'b',50);

comelct=nchoosek(lpfc_elecs,2);
for k=1:size(comelct,1)
    [y,p]=corcof(sd,find(lpfc_elecs==comelct(k,1)),find(lpfc_elecs==comelct(k,2)));
    CC(:,k)=y;
end
%save safebetCC gamblecc
gamblecc=CC';
load safebetCC
openfig('figure_safe.fig');
hold on;
legend('Safebet','Gamble');
hold on;
x=1:1001;
gamblecc=safebetcc;
y=mean(gamblecc);
plot(x,y);
err=std(gamblecc)/sqrt(length(gamblecc(:,1)));
patch([x fliplr(x)],[y+err fliplr(y-err)],'green');
legend('Safebet','Gamble');
hold on;
%legend('','Gamble');

%figure(1)

title('Correlation Coefficients of LFP Signal of LPFC during Gamble');
ylabel('Correlation Coefficient')
xlabel('Time(ms)')
ylim([0.2 0.8]);
xlim([0 1000]);

saveas(figure(1),'figure_safe');
openfig('figure_safe.fig');


function [SEM] =sem(x)
SEM=std(x)/sqrt(length(x));
end



