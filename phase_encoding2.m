
clear
close all

load phase_BDE_s25

load subj_globals
load behav_globals
load frequency_HG_s25

ftp=proc2(reveal_times,0,1.5,200,frequency(good_elecs,:));
ftp=ftp(:,1:end-1,bad_trials==0 & timeout_trials==0);
for u=1:size(ftp,1)
    for i=1:size(ftp,3)
        %ft=reshape(ftp(u,:,i),1,size(ftp,2));
        ft=ftp(u,:,i);
        %sing_fe(i,:)=timebin(ft,10);
        sing_fe(i,:)=ft;
    end
    band_freq(:,:,u)=sing_fe;
end
%load band_freq
%load signal
pt=proc2(reveal_times,0,1.5,200,phase(good_elecs,:));
pt=pt(:,1:end-1,bad_trials==0 & timeout_trials==0);
bin_num=12;
phase_bin=-pi:2*pi/bin_num:pi;

% for i=1:size(pt,3)
%     pt_short(:,:,i)=timebin(pt(:,:,i),10);
% end
%load band_freq
%band_freq=band_freq(:,101:end,:);
%pt_short=pt_short(:,101:end,:);

band_freq=band_freq(:,501:1000,:);
pt=pt(:,501:1000,:);

% Run the Polar Analysis
ge=ofc_elecs;
ele=ge(ismember(ge,good_elecs)); %Specify the region

for i=1:size(ele,2)
    for j=1:size(band_freq,1)
        tp=pt(good_elecs==ele(i),:,j);
        hga=band_freq(j,:,good_elecs==ele(i));
        for k=1:bin_num
            ind=find(tp>phase_bin(k) & tp<=phase_bin(k+1));
            ampha(j,k)=mean(hga(ind));
        end
        
        
    end
    amppha(:,:,i)=ampha;
end

var=[win_ind loss_ind rpe regret];% Specify the Computational Variables
figure(1)
for q=1:size(var,2)
    for i=1:size(amppha,3)
        %x=HG_band(:,:,i);
        for j=1:size(amppha,2)
            x=amppha(:,j,i);
            y=var(:,q); % Specify the Computational Variables
            if sum(isnan(x))>=100
                
                hgr2(i,j)=nan;
                
            else
                x=x(isnan(x)==0);
                y=y(isnan(x)==0);
                p=logical(1:size(x,1));
                
                fprintf('\nCurrent fold: %d\n',k);
                cvl=1;
                rsq=R2(x,y,p,cvl);
                
                
                if rsq<=0
                    rcv=0;
                else
                    rcv=rsq;
                end
                
                
                hgr2(i,j)=mean(rcv);
            end
            
            
            
        end
        
    end



thm =movmean(phase_bin,2);
th=thm(2:end);
thbar(q,:)=th+0.04*q;
r1 = nanmean(hgr2);
r1bar(q,:)=r1;
%polarscatter(th,r1,'filled')
err=std(hgr2)/sqrt(length(hgr2(:,1)));
errbar(q,:)=err;
%scatter(th,r1,'filled')
hold on
%errorbar(th,r1,err,'LineStyle','none')

end

%legend('Gamble Index','Win Probability','Risk','Chosen Value')
%title('S03 LPFC Choice R-Squared');

for q=1:size(var,2)
    figure(1)
    h(q)=scatter(thbar(q,:),r1bar(q,:),'filled');
    errorbar(thbar(q,:),r1bar(q,:),errbar(q,:),'LineStyle','none')
    hold on
end
ylabel('R-Squared')
xlabel('Phase(radian)')
%ylim([0.4 0.9]);
xlim([-pi pi]);
legend(h(1:4),'Win Index','Loss Index','RPE','Regret')
title('S25 OFC Outcome R-Squared');
