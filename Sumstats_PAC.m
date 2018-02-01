addpath(genpath('D:/MATLAB/barwitherr')) % add Fieldtrip into the searching path
addpath(genpath('D:/MATLAB/CircStat2012a'))
clear 
close all

addpath(genpath('D:/MATLAB/freezeColors'))
addpath(genpath('D:/MATLAB/cm_and_cb_utilities'))
load subj_globals
ge=lpfc_elecs;
gr=ge(ismember(ge,good_elecs));
ind=ismember(elecs,gr);


band={1:4;5:8;8:12;12:22;22:30;31:41}; % six frequency bands
freqs=create_freqs(1,200,0.8);
thbe=5:20; %specify the phase of lower frequency
ga=33:42; %specify the amplitude of higher frequency

band2={1:3;4:8;8:16};

%load wlpcac2_win_s03
load lmepac_winloss_s03

    
%pac_win=pcac2.pcac(:,:,ind);
%pac_eley=pcac2.BETA(:,:,ind,4);

%bwin1=pcac2.BETA(:,:,ind,5)+pcac2.BETA(:,:,ind,2);
%bwin2=pcac2.BETA(:,:,ind,6)+pcac2.BETA(:,:,ind,3);
%pac_win=sqrt(bwin1.^2+bwin2.^2);

%load wlpcac2_loss_s03
%load spcac3_loss_s03

for ii=1:size(pcac2.pac3,4)
    
    pac_re=pcac2.pac3(:,:,ind,ii);
    
    % pac_win=pcac2.pac(:,:,ind,1);
    % pac_med=pcac2.pac(:,:,ind,2);
    % pac_loss=pcac2.pac(:,:,ind,3);
    %bloss1=pcac2.BETA(:,:,ind,2);
    %bloss2=pcac2.BETA(:,:,ind,3);
    %load pac2_s05
    
    %par=pcac2.pcac(:,:,ind);
    
    
    for i=1:size(pac_re,3)
        for j=1:3
            mre=reshape(pac_re(band2{j},:,i),size(band2{j},2)*size(pac_re,2),1);
            re_freq_ele(j,i,ii)=mean(mre);
            
            %         mmed=reshape(pac_med(band2{j},:,i),size(band2{j},2)*size(pac_med,2),1);
            %         med_freq_ele(j,i)=mean(mmed);
            %
            %         mloss=reshape(pac_loss(band2{j},:,i),size(band2{j},2)*size(pac_loss,2),1);
            %         loss_freq_ele(j,i)=mean(mloss);
            
            %         mpar=reshape(par(band2{j},:,i),size(band2{j},2)*size(par,2),1);
            %         par_freq_ele(j,i)=mean(mpar);
            
            
        end
    end
end

mmh=[];
merr=[];
for jj=1:size(re_freq_ele,3)
    m=re_freq_ele(:,:,jj);
    mm=mean(m,2);
    mmerr=std(m,1,2)/sqrt(size(m,2));
    mmh=[mmh mm];
    merr=[merr mmerr];
end

barwitherr(merr,mmh,0.5);
xticklabels({'Theta','Alpha','Beta'});
%legend('Regret/Rejoice: -20','Regret/Rejoice: -15','Regret/Rejoice: -10','Regret/Rejoice: -5','Regret/Rejoice: 5','Regret/Rejoice: 10','Regret/Rejoice: 15','Regret/Rejoice: 20');
legend('Safebet','Gamble Win','Gamble Loss')
title('S03 LPFC Regret & Rejoice PAC (Number of Trials Controlled) ');
xlabel('Phase Frequency')
ylabel('Magnitude of Phase-Amplitude Coupling')


% for j=1:3
%     swin=reshape(pac_win(band2{j},:,:),size(band2{j},2)*size(pac_win,2)*size(pac_win,3),1);
%     stdwin(j,:)=std(swin)/sqrt(size(swin,1));
%     sloss=reshape(pac_loss(band2{j},:,:),size(band2{j},2)*size(pac_loss,2)*size(pac_loss,3),1);
%     stdloss(j,:)=std(sloss)/sqrt(size(sloss,1));
%     spar=reshape(par(band2{j},:,:),size(band2{j},2)*size(par,2)*size(par,3),1);
%     stdpar(j,:)=std(spar)/sqrt(size(spar,1));
% end

% for k=1:size(bwin1,3)
%     for i=1:size(bwin1,1)
%         for j=1:size(bwin1,2)
%             if bwin1(i,j,k)>=0 && bwin2(i,j,k)<=0
%                 angwin(i,j,k)=pi+atan(bwin1(i,j,k)/bwin2(i,j,k));
%                 %angloss(i,j,k)=pi+atan(bloss1(i,j,k)/bloss2(i,j,k));
%             elseif bwin1(i,j,k)<=0 && bwin2(i,j,k)<=0
%                 angwin(i,j,k)=atan(bwin1(i,j,k)/bwin2(i,j,k))-pi;
%                 %angloss(i,j,k)=atan(bloss1(i,j,k)/bloss2(i,j,k))-pi;
%             else
%                 angwin(i,j,k)=atan(bwin1(i,j,k)/bwin2(i,j,k));
%                 %angloss(i,j,k)=atan(bloss1(i,j,k)/bloss2(i,j,k));
%             end
%         end
%     end
% end

% for k=1:size(bloss1,3)
%     for i=1:size(bloss1,1)
%         for j=1:size(bloss1,2)
%             if bloss1(i,j,k)>=0 && bloss2(i,j,k)<=0
%                 %angwin(i,j,k)=pi+atan(bwin1(i,j,k)/bwin2(i,j,k));
%                 angloss(i,j,k)=pi+atan(bloss1(i,j,k)/bloss2(i,j,k));
%             elseif bloss1(i,j,k)<=0 && bloss2(i,j,k)<=0
%                 %angwin(i,j,k)=atan(bwin1(i,j,k)/bwin2(i,j,k))-pi;
%                 angloss(i,j,k)=atan(bloss1(i,j,k)/bloss2(i,j,k))-pi;
%             else
%                % angwin(i,j,k)=atan(bwin1(i,j,k)/bwin2(i,j,k));
%                 angloss(i,j,k)=atan(bloss1(i,j,k)/bloss2(i,j,k));
%             end
%         end
%     end
% end
% 
% for i=1:size(angwin,3)
%     for j=1:3
%         awin=reshape(angwin(band2{j},:,i),size(band2{j},2)*size(angwin,2),1);
%         win_ang(j,i)=circ_mean(awin);
%         win_rang(j,i)=circ_r(awin);
%         aloss=reshape(angloss(band2{j},:,i),size(band2{j},2)*size(angloss,2),1);
%         loss_ang(j,i)=circ_mean(aloss);
%         loss_rang(j,i)=circ_r(aloss);
%         
%         
%     end
% end

figure(1)
subplot(1,2,1)
for j=1:3
  
    fwin=re_freq_ele(j,:,2);
    floss=re_freq_ele(j,:,3);
    ho(j)=scatter(floss,fwin);
        %tt(j,i)=ttest(mwin,mloss);
    hold on
end
hline=refline(1,0);
legend(ho(1:3),{'Theta','Alpha','Beta'});
%[h,p]=corr(mloss,mwin);
%title(strcat('Win vs. Loss PAC Corr:',title1,' P-value:',title2));
title('S03 LPFC Win vs. Loss PAC (Individual electrode) ');
xlabel('Loss PAC')
ylabel('Win PAC')
hold off

subplot(1,2,2)
mmh=[];
merr=[];
for jj=1:size(re_freq_ele,3)
    m=re_freq_ele(:,:,jj);
    mm=mean(m,2);
    mmerr=std(m,1,2)/sqrt(size(m,2));
    mmh=[mmh mm];
    merr=[merr mmerr];
end

barwitherr(merr,mmh,0.5);
xticklabels({'Theta','Alpha','Beta'});
%legend('Regret/Rejoice: -20','Regret/Rejoice: -15','Regret/Rejoice: -10','Regret/Rejoice: -5','Regret/Rejoice: 5','Regret/Rejoice: 10','Regret/Rejoice: 15','Regret/Rejoice: 20');
legend('Safebet','Gamble Win','Gamble Loss')
title('S03 LPFC Trial Type PAC (Average Electrode) ');
xlabel('Phase Frequency')
ylabel('Magnitude of Phase-Amplitude Coupling')

for j=1:3
    rwin=reshape(angwin(band2{j},:,:),size(band2{j},2)*size(angwin,2)*size(angwin,3),1);
    rrwin(j,:)=circ_r(rwin);
    rloss=reshape(angloss(band2{j},:,:),size(band2{j},2)*size(angloss,2)*size(angloss,3),1);
    rrloss(j,:)=circ_r(rloss);
end

figure(3)
pfname={' Theta';' Alpha';' Beta'};
for i=1:3
    subplot(2,3,i)
    wan=win_ang(i,:);
    lan=loss_ang(i,:);
    wr=win_rang(i,:);
    lr=loss_rang(i,:);

    polarscatter(wan,wr,'filled');
    rlim([0 1])
    
    hold on
    polarscatter(lan,lr,'filled')
    rlim([0 1])
    title1=pfname{i};
    title(strcat('S03 OFC PAC Angle: ',title1,' (Individual Electrode)'));
    hold off
    
    subplot(2,3,3+i)
    polarscatter(circ_mean(wan'),rrwin(i),'filled')
    rlim([0 1])
    hold on
    polarscatter(circ_mean(lan'),rrloss(i),'filled')
    title(strcat('S03 OFC PAC Angle: ',title1,' (Average Electrode)'));
    hold off
    
    
    
 
    
end
legend('Win','Loss')
    
    


% function [SEM] =sem(x)
% SEM=std(x)/sqrt(length(x));
% end
% 
% 
% logi=bad_trials==0 & timeout_trials==0;
% 
% sim=randi([1 100],200,1);
% regrej=regret_all+rejoice_all;
% comp=regrej(logi);
% 
% 
% for i=1:size(comp,1)
%     x_comp(i,1:1000)=comp(i,1);
% end
% x_comp=reshape(x_comp',1,size(x_comp,1)*size(x_comp,2));
% 
function [SEM] =sem(x)
SEM=std(x)/sqrt(length(x));
end


clear
close all


load subj_globals
load behav_globals
load signal  % raw signal recording of 64 channels for one subject

band={1:4;5:8;8:12;12:22;22:30;31:41}; % six frequency bands

thbe=5:20; %specify the phase of lower frequency
ga=33:42; %specify the amplitude of higher frequency
pair=[];
for i=1:size(thbe,2)
    for j=1:size(ga,2)
        pair=[pair; thbe(i) ga(j)];
    end
end

sampling_rate=1000;
max_freq=200;
compression=1;

regrej=regret_all+rejoice_all;

level_regrej=unique(regrej);
level_regrej=level_regrej(level_regrej~=0);
for i=1:size(level_regrej,1)
    a(i)=sum(regrej==level_regrej(i));
end


regrej=double(win_ind_all);
regrej(regrej==0 & gamble_ind_all==1)=2;

level_regrej=unique(regrej);

level_regrej=level_regrej(level_regrej~=0);

regrej=double(win_ind_all);
regrej(regrej==0 & gamble_ind_all==1)=2;

level_regrej=unique(regrej);

%level_regrej=level_regrej(level_regrej~=0);

for i=1:size(level_regrej,1)
    a(i)=sum(regrej==level_regrej(i));
end
for j=1:size(level_regrej,1)
    logii=bad_trials==0 & timeout_trials==0 & regrej==level_regrej(j);
    logiim(j)=sum(logii==1);
end


