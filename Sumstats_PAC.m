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
load spcac2_win_s03
pac_win=pcac2.pcac(:,:,ind);
%pac_eley=pcac2.BETA(:,:,ind,4);

bwin1=pcac2.BETA(:,:,ind,5);
bwin2=pcac2.BETA(:,:,ind,6);

%load wlpcac2_loss_s03
load spcac2_loss_s03
pac_loss=pcac2.pcac(:,:,ind);
bloss1=pcac2.BETA(:,:,ind,5);
bloss2=pcac2.BETA(:,:,ind,6);
%load pac2_s05



for i=1:size(pac_win,3)
    for j=1:3
        mwin=reshape(pac_win(band2{j},:,i),size(band2{j},2)*size(pac_win,2),1);
        win_freq_ele(j,i)=mean(mwin);
        
        mloss=reshape(pac_loss(band2{j},:,i),size(band2{j},2)*size(pac_loss,2),1);
        loss_freq_ele(j,i)=mean(mloss);
        
        
    end
end

for j=1:3
    swin=reshape(pac_win(band2{j},:,:),size(band2{j},2)*size(pac_win,2)*size(pac_win,3),1);
    stdwin(j,:)=std(swin)/sqrt(size(swin,1));
    sloss=reshape(pac_loss(band2{j},:,:),size(band2{j},2)*size(pac_loss,2)*size(pac_loss,3),1);
    stdloss(j,:)=std(sloss)/sqrt(size(sloss,1));
end

for k=1:size(bwin1,3)
    for i=1:size(bwin1,1)
        for j=1:size(bwin1,2)
            if bwin1(i,j,k)>=0 && bwin2(i,j,k)<=0
                angwin(i,j,k)=pi+atan(bwin1(i,j,k)/bwin2(i,j,k));
                %angloss(i,j,k)=pi+atan(bloss1(i,j,k)/bloss2(i,j,k));
            elseif bwin1(i,j,k)<=0 && bwin2(i,j,k)<=0
                angwin(i,j,k)=atan(bwin1(i,j,k)/bwin2(i,j,k))-pi;
                %angloss(i,j,k)=atan(bloss1(i,j,k)/bloss2(i,j,k))-pi;
            else
                angwin(i,j,k)=atan(bwin1(i,j,k)/bwin2(i,j,k));
                %angloss(i,j,k)=atan(bloss1(i,j,k)/bloss2(i,j,k));
            end
        end
    end
end

for k=1:size(bloss1,3)
    for i=1:size(bloss1,1)
        for j=1:size(bloss1,2)
            if bloss1(i,j,k)>=0 && bloss2(i,j,k)<=0
                %angwin(i,j,k)=pi+atan(bwin1(i,j,k)/bwin2(i,j,k));
                angloss(i,j,k)=pi+atan(bloss1(i,j,k)/bloss2(i,j,k));
            elseif bloss1(i,j,k)<=0 && bloss2(i,j,k)<=0
                %angwin(i,j,k)=atan(bwin1(i,j,k)/bwin2(i,j,k))-pi;
                angloss(i,j,k)=atan(bloss1(i,j,k)/bloss2(i,j,k))-pi;
            else
               % angwin(i,j,k)=atan(bwin1(i,j,k)/bwin2(i,j,k));
                angloss(i,j,k)=atan(bloss1(i,j,k)/bloss2(i,j,k));
            end
        end
    end
end

for i=1:size(angwin,3)
    for j=1:3
        awin=reshape(angwin(band2{j},:,i),size(band2{j},2)*size(angwin,2),1);
        win_ang(j,i)=circ_mean(awin);
        win_rang(j,i)=circ_r(awin);
        aloss=reshape(angloss(band2{j},:,i),size(band2{j},2)*size(angloss,2),1);
        loss_ang(j,i)=circ_mean(aloss);
        loss_rang(j,i)=circ_r(aloss);
        
        
    end
end

figure(1)
subplot(1,2,1)
for j=1:3
  
    fwin=win_freq_ele(j,:);
    floss=loss_freq_ele(j,:);
    ho(j)=scatter(floss,fwin);
        %tt(j,i)=ttest(mwin,mloss);
    hold on
end
hline=refline(1,0);
legend(ho(1:3),{'Theta','Alpha','Beta'});
[h,p]=corr(mloss,mwin);
%title(strcat('Win vs. Loss PAC Corr:',title1,' P-value:',title2));
title('S03 OFC Win vs. Loss PAC (Individual electrode) ');
xlabel('Loss PAC')
ylabel('Win PAC')
hold off

subplot(1,2,2)
mw=mean(win_freq_ele,2);
ml=mean(loss_freq_ele,2);
mm=[mw ml];

mwerr=std(win_freq_ele,1,2)/sqrt(size(win_freq_ele,2));
mlerr=std(loss_freq_ele,1,2)/sqrt(size(loss_freq_ele,2));
err=[mwerr mlerr]; %  err=[stdwin stdloss];
barwitherr(err,mm,0.5);
xticklabels({'Theta','Alpha','Beta'});
legend('Win','Loss');
title('S03 OFC Win vs. Loss PAC (Average electrode) ');
xlabel('Phase Frequency')
ylabel('PAC')

for j=1:3
    rwin=reshape(angwin(band2{j},:,:),size(band2{j},2)*size(angwin,2)*size(angwin,3),1);
    rrwin(j,:)=circ_r(rwin);
    rloss=reshape(angloss(band2{j},:,:),size(band2{j},2)*size(angloss,2)*size(angloss,3),1);
    rrloss(j,:)=circ_r(rloss);
end

figure(2)
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
    
    


function [SEM] =sem(x)
SEM=std(x)/sqrt(length(x));
end



