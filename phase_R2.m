clear
close all


load subj_globals
load behav_globals
load frequency_HG_s03

frequency=zscore(frequency,0,2);

rang={1:500;501:1000;1:1000};
tit={' [-1000,-500ms]';' [-500,0ms]'};
tin=rang{3};

ftp=proc2(reveal_times,0,1,200,frequency(good_elecs,:));
ftp=ftp(:,1:end-1,bad_trials==0 & timeout_trials==0);
for u=1:size(ftp,1)
    for i=1:size(ftp,3)
        %ft=reshape(ftp(u,:,i),1,size(ftp,2));
        ft=ftp(u,:,i);
        %sing_fe(i,:)=timebin(ft,10);
        sing_fe(i,:)=ft;
    end
    band_freq1(:,:,u)=sing_fe;
end
band_freq=band_freq1(:,tin,:);
%load band_freq
%load signal
fig=figure(1);

for k=1:6
    subplot(2,3,k)
    if k==1
        load phase_BDE_s03
        title1=' Delta';
    elseif k==2
        load phase_BTH_s03
        title1=' Theta';
    elseif k==3
        load phase_BAL_s03
        title1=' Alpha';
    elseif k==4
        load phase_BBE_s03
        title1=' Beta';
    elseif k==5
        load phase_BGA_s03
        title1=' Gamma';
    else
        load phase_BHG_s03
        title1=' High-Gamma';
    end
    
    %hold on
    
    %load phase_BBE_s03
    
    pt=proc2(reveal_times,0,1,200,phase(good_elecs,:));
    pt1=pt(:,1:end-1,bad_trials==0 & timeout_trials==0);
    bin_num=6;
    phase_bin=-pi:2*pi/bin_num:pi;
    
    
    
    pt2=pt1(:,tin,:);
    
    ge=ofc_elecs;
    ele=ge(ismember(ge,good_elecs)); %Specify the region
    
    enele=ele(ismember(ele,win_eind));  %Specify the computation
    
    for t=1:size(enele,2)
        
        hg=band_freq(:,:,good_elecs==enele(t));
        
        fp=reshape(pt2(good_elecs==enele(t),:,:),size(pt2,2),size(pt2,3));
        
        fp=fp';
        
        %sp=sin(fp);
        %cp=cos(fp);
        
        %ip=sp+cp;
        
        for i=1:size(hg,2)
            x_phase=fp(:,i);
            for v=1:bin_num
                ind=find(x_phase>phase_bin(v)& x_phase<=phase_bin(v+1));
                catgr_phase(ind,1)=v;
            end
            
            x_win=win_ind;
            Win=x_win;
            HG=hg(:,i);
            Phase_Category=catgr_phase;
            Encoding=table(HG,Win,Phase_Category);
            Encoding.Phase_Category = nominal(Encoding.Phase_Category);
            %x=horzcat(sp(:,i),cp(:,i),double(win_ind),double(win_ind).*sp(:,i),double(win_ind).*cp(:,i));
            %x=horzcat(ip(:,i),double(win_ind),double(win_ind).*ip(:,i));
            %y=hg(:,i);
            %cvl=1;
            %p=logical(1:size(x,1));
            fit = fitlm(Encoding,'HG~Win*Phase_Category');
            %         [rsq,p_win_phase]=R2(x,y,p,cvl);
            %         Rsq(i)=rsq;
            %         p_int(:,i)=p_win_phase;
            Rsq(t,i)=fit.Rsquared.Ordinary;
        end
        RR(k)=sum(Rsq);
        
        for i=1:size(hg,2)
            x_phase=fp(:,i);
            for v=1:bin_num
                ind=find(x_phase>phase_bin(v)& x_phase<=phase_bin(v+1));
                catgr_phase(ind,1)=v;
            end
            
            x_win=win_ind;
            Win=x_win;
            HG=hg(:,i);
            Phase_Category=catgr_phase;
            Encoding=table(HG,Win,Phase_Category);
            Encoding.Phase_Category = nominal(Encoding.Phase_Category);
            %x=horzcat(sp(:,i),cp(:,i),double(win_ind),double(win_ind).*sp(:,i),double(win_ind).*cp(:,i));
            %x=horzcat(ip(:,i),double(win_ind),double(win_ind).*ip(:,i));
            %y=hg(:,i);
            %cvl=1;
            %p=logical(1:size(x,1));
            fit = fitlm(Encoding,'HG~Win+Phase_Category');
            %         [rsq,p_win_phase]=R2(x,y,p,cvl);
            %         Rsq(i)=rsq;
            %         p_int(:,i)=p_win_phase;
            Rsqadd(t,i)=fit.Rsquared.Ordinary;
        end
        RRA(k)=sum(Rsqadd);
        
        
        for i=1:size(hg,2)
            x_phase=fp(:,i);
            for v=1:bin_num
                ind=find(x_phase>phase_bin(v)& x_phase<=phase_bin(v+1));
                catgr_phase(ind,1)=v;
            end
            
            x_win=win_ind;
            Win=x_win;
            HG=hg(:,i);
            Phase_Category=catgr_phase;
            Encoding=table(HG,Win,Phase_Category);
            Encoding.Phase_Category = nominal(Encoding.Phase_Category);
            %x=horzcat(sp(:,i),cp(:,i),double(win_ind),double(win_ind).*sp(:,i),double(win_ind).*cp(:,i));
            %x=horzcat(ip(:,i),double(win_ind),double(win_ind).*ip(:,i));
            %y=hg(:,i);
            %cvl=1;
            %p=logical(1:size(x,1));
            fit = fitlm(Encoding,'HG~Win');
            %         [rsq,p_win_phase]=R2(x,y,p,cvl);
            %         Rsq(i)=rsq;
            %         p_int(:,i)=p_win_phase;
            Rsq2(t,i)=fit.Rsquared.Ordinary;
            
        end
        Rsq2(t,:)=movmean(Rsq2(t,:),20);
        Rsqadd(t,:)=movmean(Rsqadd(t,:),20);
        Rsq(t,:)=movmean(Rsq(t,:),20);
    end
    t=1:1000;
    
    mRsq=mean(Rsq);
    err=std(Rsq)/sqrt(length(Rsq(:,1)));
    h(1)=plot(t,mRsq);
    h(2)=patch([t fliplr(t)],[mRsq+err fliplr(mRsq-err)],0);
    
    hold on;
    mRsqadd=mean(Rsqadd);
    err=std(Rsqadd)/sqrt(length(Rsqadd(:,1)));
    h(3)=plot(t,mRsqadd);
    h(4)=patch([t fliplr(t)],[mRsqadd+err fliplr(mRsqadd-err)],1);
    
    
    
    hold on;
    mRsq2=mean(Rsq2);
    err=std(Rsq2)/sqrt(length(Rsq2(:,1)));
    h(5)=plot(t,mRsq2);
    h(6)=patch([t fliplr(t)],[mRsq2+err fliplr(mRsq2-err)],2);
    
    hold on
    ylim([0 0.3]);
    
    
    
    
    title(strcat('S03-OFC Explained Variance',title1));
    ylabel('R-Squared')
    xlabel('Time(ms) from Outcome')
    
    hold on
%     y = 1.3;
%     h(6)=plot([0,1000],[y,y],'--');
   % legend(h(1:2),'Harmonic','Simple-linear');

end
legend(h([2 4 6]),'Harmonic','Phase-linear','Simple-linear');

saveas(fig,'S03_OFC_Phase_F-test.jpg')
% RR(7)=sum(Rsq2);
% RRA(7)=sum(Rsq2);
% legend(h(1:3),'Harmonic','Phase-linear','Simple-linear');
% %legend(h(1:5),'sin(phase)','cos(phase)','win','win*sin(phase)','win*cos(phase)');
% VR=vertcat(RR,RRA);
% figure(2)
% bar(VR')
% xticklabels({'Delta','Theta','Alpha','Beta','Gamma','HG','Simple-linear'})
% title('Area under R2-adj Curve Post-Outcome S03-OFC42 ');
% ylabel('Adjusted Area')
% legend('Harmonic','Phase-only')

