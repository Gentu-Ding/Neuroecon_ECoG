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
bin_num=6;
phase_bin=-pi:2*pi/bin_num:pi;

H=zeros(bin_num-1,2*bin_num);
for i =1:size(H)
    H(i,i+bin_num+1)=1;
end
%load band_freq

comp={'Win';'Loss';'Regret';'RPE'};
regress=[win_ind loss_ind regret rpe];
electrode={win_eind loss_eind re_eind rpe_eind};
%load signal
for pp=1:size(regress,2)
    
    fig=figure(pp);
    
    for k=1:6
        subplot(2,3,k)
        if k==1
            load phase_BDE_s03
            title1=' Delta ';
        elseif k==2
            load phase_BTH_s03
            title1=' Theta ';
        elseif k==3
            load phase_BAL_s03
            title1=' Alpha ';
        elseif k==4
            load phase_BBE_s03
            title1=' Beta ';
        elseif k==5
            load phase_BGA_s03
            title1=' Gamma ';
        else
            load phase_BHG_s03
            title1=' High-Gamma ';
        end
        
        %hold on
        
        %load phase_BBE_s03
        
        pt=proc2(reveal_times,0,1,200,phase(good_elecs,:));
        pt1=pt(:,1:end-1,bad_trials==0 & timeout_trials==0);
        
        
        
        pt2=pt1(:,tin,:);
        
        ge=ofc_elecs;         %Specify the region
        ele=ge(ismember(ge,good_elecs));
        
        enele=ele(ismember(ele,electrode{pp}));
        
        x_win=regress(:,pp);                     %Specify the computation
        
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
                %Rsq(i)=fit.Rsquared.Ordinary;
                %p_int(:,i)=fit.Coefficients.pValue(8:end);
                
                [p, F] = coefTest(fit, H);
                p_int(i)=p;
            end
            sp_int=movmean(p_int,20,2,'omitnan');
            logp(t,:)=-log10(sp_int);
        end
        
        
        logpp=logp(sum(logp>-log10(0.05),2)>0,:);
        
        
        
        
        %plot(Rsq);
        
        %hold on;
        %plot(Rsq2);
        
        %ylim([0.4 0.9]);
        if size(logpp,1)>1
            num1=string(size(logpp,1));
            num2=string(size(logp,1));
            
            
            mlogp=nanmean(logpp,1);
            
            err=nanstd(logpp)/sqrt(length(logpp(:,1)));
            t=1:1000;
            h(1)=plot(t,mlogp);
            h(2)=patch([t fliplr(t)],[mlogp+err fliplr(mlogp-err)],0);
            title(strcat('OFC ',comp{pp},title1,num1,'/',num2));
            ylabel('-log(p-value)')
            xlabel('Time(ms) from Outcome')
            
            hold on
            y = -log10(0.05);
            h(3)=plot([0,1000],[y,y],'--');
            mt=mean(mlogp);
            hold on
            h(4)=plot([0,1000],[mt,mt],'-');
        end
        
        
    end
    
    %legend(h(1),'F-Test p-value')
    
    saveas(fig,strcat('S03_OFC_',comp{pp},'_Phase_F-test.jpg'))
end

