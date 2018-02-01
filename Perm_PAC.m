addpath(genpath('D:/MATLAB/barwitherr')) % add Fieldtrip into the searching path
addpath(genpath('D:/MATLAB/CircStat2012a'))
clear 
close all

addpath(genpath('D:/MATLAB/freezeColors'))
addpath(genpath('D:/MATLAB/cm_and_cb_utilities'))
load subj_globals
ge=win_eind(ismember(win_eind,lpfc_elecs));
%ge=loss_eind;
gr=ge(ismember(ge,good_elecs));
ind=ismember(elecs,gr);

pfname={' (Theta)';' (Alpha)';' (Beta)'};
band={1:4;5:8;8:12;12:22;22:30;31:41}; % six frequency bands
freqs=create_freqs(1,200,0.8);
thbe=5:20; %specify the phase of lower frequency
ga=33:42; %specify the amplitude of higher frequency

band2={1:3;4:8;8:16};

%load wlpcac2_win_s03
load  zmfpac_winloss_s03
%pac_win=pcac2.pac(:,:,ind,1);
%pac_eley=pcac2.BETA(:,:,ind,4);

% bwin1=pcac2.BETA(:,:,ind,5)+pcac2.BETA(:,:,ind,2);
% bwin2=pcac2.BETA(:,:,ind,6)+pcac2.BETA(:,:,ind,3);
% pac_win=sqrt(bwin1.^2+bwin2.^2);

%load wlpcac2_loss_s03
%load spcac3_loss_s03
% pac_loss=pcac2.pac(:,:,ind);
% bloss1=pcac2.BETA(:,:,ind,2);
% bloss2=pcac2.BETA(:,:,ind,3);
%load pac2_s05

for tt=1:3
par=pcac2.pac(:,:,ind,tt);
%parll=pcac2.LL(:,:,ind);

for i=1:size(par,3)
    for j=1:3
%         mwin=reshape(pac_win(band2{j},:,i),size(band2{j},2)*size(pac_win,2),1);
%         win_freq_ele(j,i)=mean(mwin);
%         
%         mloss=reshape(pac_loss(band2{j},:,i),size(band2{j},2)*size(pac_loss,2),1);
%         loss_freq_ele(j,i)=mean(mloss);
        
        mpar=reshape(par(band2{j},:,i),size(band2{j},2)*size(par,2),1);
        %mparll=reshape(parll(band2{j},:,i),size(band2{j},2)*size(parll,2),1);
        par_freq_ele(j,i,tt)=mean(mpar);
        %par_freq_elell(j,i)=mean(mparll);
        
        
    end
end
real_par=par_freq_ele;
%real_parll=par_freq_elell;


% figure(1)
% mw=mean(win_freq_ele,2);
% ml=mean(loss_freq_ele,2);
% mp=mean(par_freq_ele,2);
% %mm=[mw ml];
% mm=mp;
% 
% mwerr=std(win_freq_ele,1,2)/sqrt(size(win_freq_ele,2));
% mlerr=std(loss_freq_ele,1,2)/sqrt(size(loss_freq_ele,2));
% mperr=std(par_freq_ele,1,2)/sqrt(size(par_freq_ele,2));
% %err=[mwerr mlerr]; %  err=[stdwin stdloss];
% err=mperr;
% barwitherr(err,mm,0.5);
% xticklabels({'Theta','Alpha','Beta'});
% %legend('Win','Loss');
% title('S03 LPFC Regret & Rejoice PAC (Average electrode) ');
% xlabel('Phase Frequency')
% ylabel('Marginal Effect of PAC')


load zmfpac_winloss_sig_s03

for per=1:size(pcac2.pac,4)
    
    %pac_eley=pcac2.BETA(:,:,ind,4);
    
    % bwin1=pcac2.BETA(:,:,ind,5)+pcac2.BETA(:,:,ind,2);
    % bwin2=pcac2.BETA(:,:,ind,6)+pcac2.BETA(:,:,ind,3);
    % pac_win=sqrt(bwin1.^2+bwin2.^2);
    
    %load wlpcac2_loss_s03
    %load spcac3_loss_s03
    % pac_loss=pcac2.pac(:,:,ind);
    % bloss1=pcac2.BETA(:,:,ind,2);
    % bloss2=pcac2.BETA(:,:,ind,3);
    %load pac2_s05
    
    parll=pcac2.pac(:,:,ind,per,tt);
    
    
    for i=1:size(par,3)
        for j=1:3
            %         mwin=reshape(pac_win(band2{j},:,i),size(band2{j},2)*size(pac_win,2),1);
            %         win_freq_ele(j,i)=mean(mwin);
            %
            %         mloss=reshape(pac_loss(band2{j},:,i),size(band2{j},2)*size(pac_loss,2),1);
            %         loss_freq_ele(j,i)=mean(mloss);
            
            mparll=reshape(parll(band2{j},:,i),size(band2{j},2)*size(parll,2),1);
            par_freq_elell(j,i)=mean(mparll);
            
            
        end
    end
    par_elell(:,:,per,tt)=par_freq_elell;
    
    
    
    %mw=mean(win_freq_ele,2);
    %ml=mean(loss_freq_ele,2);
    %mpll=mean(par_freq_elell,2);
    %mm=[mw ml];
    %mmll(:,per)=mpll;
end
end

for i=1:size(par_elell,1)
    for j=1:size(par_elell,2)
        a1=par_elell(i,j,:,2);
        a1=a1(a1~=0);
        a2=par_elell(i,j,:,3);
        a2=a2(a2~=0);
        [hh,pp]=ttest2(a1,a2,'Vartype','unequal');
        h(i,j)=hh;
        p(i,j)=pp;
    end
end

for i=1:3
    subplot(3,1,i)
    hist(p(i,:))
    title(strcat('S03 OFC Win vs. Loss ',pfname{i}))
    xlabel('P-value of Win vs. Loss')
    ylabel('Number of Electrodes')
end





% for i=1:size(par_elell,1)
%     for j=1:size(par_elell,2)
%         thres(i,j)=prctile(par_elell(i,j,:),95);
%         a=reshape(par_elell(i,j,:),size(par_elell,3),1);
%         [ks(i,j) pp(i,j)]=kstest(a-mean(a)/std(a));
%         [h,ptest(i,j)] = ttest(a,mean(a),0.05,'right');
%         
%         permtest(i,j)=real_parll(i,j)>prctile(par_elell(i,j,:),95);
%     end
% end


pfname={' (Theta)';' (Alpha)';' (Beta)'};
for jj=1:size(real_par,2)
    figure(jj)
    for ii=1:size(real_par,1)
        
        thres=real_par(ii,jj);
        subplot(3,1,ii)
        histo=reshape(par_elell(ii,jj,:),size(par_elell,3),1);
        histo=histo(histo~=0);
        hist(histo);
        hold on;
        x=thres;
        %ylim([0 8])
        %xlim([0 0.018])
        line([x, x], ylim, 'LineWidth', 2, 'Color', 'r');
        %title('S03 LPFC Regret & Rejoice PAC');
        title(strcat('S03 OFC Regret & Rejoice PAC ',pfname{ii}))
        xlabel('PAC Magnitude')
        ylabel('Number of Electrodes')


        %thres(ii,jj)=prctile(par_ele(ii,jj,:),95);
        %permtest(ii,jj)=real_par(ii,jj)>prctile(par_ele(ii,jj,:),95);
    end
end

% for ii=1:size(par_ele,1)
%     for jj=1:size(par_ele,2)
%         thres=mean(mm,2);
%         subplot(3,1,ii)
%         hist(real_par(ii,:))
%         hold on;
%         x=thres(ii);
%         ylim([0 8])
%         xlim([0 0.018])
%         line([x, x], ylim, 'LineWidth', 2, 'Color', 'r');
%         %title('S03 LPFC Regret & Rejoice PAC');
%         title(strcat('S03 OFC Regret & Rejoice PAC ',pfname{ii}))
%         xlabel('PAC Magnitude')
%         ylabel('Number of Electrodes')
% 
% 
%         %thres(ii,jj)=prctile(par_ele(ii,jj,:),95);
%         %permtest(ii,jj)=real_par(ii,jj)>prctile(par_ele(ii,jj,:),95);
%     end
% end


function [SEM] =sem(x)
SEM=std(x)/sqrt(length(x));
end

clear
load carsmall

tbl = table(Weight,Acceleration,Model_Year,MPG,'VariableNames',{'Weight','Acceleration','Model_Year','MPG'});
tbl.Model_Year = categorical(tbl.Model_Year);
lm = fitlm(tbl,'MPG~Weight+Acceleration+Model_Year');

