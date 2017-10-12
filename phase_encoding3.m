
clear
close all


load subj_globals
load behav_globals
load frequency_HG_s03
frequency=zscore(frequency,0,2);

rang={1:500;501:1000;1001:1500};
tit={' [-500,0ms]';' [0,500ms]';' [500,1000ms]'};

ftp=proc2(reveal_times,-0.5,1,200,frequency(good_elecs,:));
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
%load band_freq
%load signal



for bind=1:6
    if bind==1
        load phase_BDE_s03
        title1=' HG-Delta';
        figure(1)
    elseif bind==2
        load phase_BTH_s03
        title1=' HG-Theta';
        figure(2)
    elseif bind==3
        load phase_BAL_s03
        title1=' HG-Alpha';
        figure(3)
    elseif bind==4
        load phase_BBE_s03
        title1=' HG-Beta';
        figure(4)
    elseif bind==5
        load phase_BGA_s03
        title1=' HG-Gamma';
        figure(5)
    else
        load phase_BHG_s03
        title1=' HG-HG';
        figure(6)
        
    end
    
    
    
    pt=proc2(reveal_times,-0.5,1,200,phase(good_elecs,:));
    pt1=pt(:,1:end-1,bad_trials==0 & timeout_trials==0);
    bin_num=12;
    phase_bin=-pi:2*pi/bin_num:pi;
    
    % for i=1:size(pt,3)
    %     pt_short(:,:,i)=timebin(pt(:,:,i),10);
    % end
    %load band_freq
    %band_freq=band_freq(:,101:end,:);
    %pt_short=pt_short(:,101:end,:);
    for ij=1:2
        if ij==1
            var=[rpe regret rpe regret];
        else
            var=[win_ind loss_ind win_ind loss_ind];
        end
        for ti=1:3
            subplot(2,3,ti+3*(ij-1))
            tin=rang{ti};
            band_freq=band_freq1(:,tin,:);
            pt=pt1(:,tin,:);
            title2=tit{ti};
            
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
            
            %var=[rpe regret rpe regret];% Specify the Computational Variables
            
            for q=1:size(var,2)
                if ij==1
                    if q==1
                        ampphaa=amppha(:,:,ismember(ele,rpe_eind));
                    elseif q==2
                        ampphaa=amppha(:,:,ismember(ele,re_eind));
                    elseif q==3
                        ampphaa=amppha(:,:,~ismember(ele,rpe_eind));
                    else
                        ampphaa=amppha(:,:,~ismember(ele,re_eind));
                    end
                else
                    if q==1
                        ampphaa=amppha(:,:,ismember(ele,win_eind));
                    elseif q==2
                        ampphaa=amppha(:,:,ismember(ele,loss_eind));
                    elseif q==3
                        ampphaa=amppha(:,:,~ismember(ele,win_eind));
                    else
                        ampphaa=amppha(:,:,~ismember(ele,loss_eind));
                    end
                end
                
                
                for i=1:size(ampphaa,3)
                    %x=HG_band(:,:,i);
                    for j=1:size(ampphaa,2)
                        x=ampphaa(:,j,i);
                        y=double(var(:,q)); % Specify the Computational Variables
                        if sum(isnan(x))>=100
                            
                            hgr2(i,j)=nan;
                            
                        else
                            x=x(isnan(x)==0);
                            y=y(isnan(x)==0);
                            p=logical(1:size(x,1));
                            
                            fprintf('\nCurrent fold: %d\n',k);
                            cvl=1;
                            rsq=R2(y,x,p,cvl);
                            
                            
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
                polarplot(0.04,'w');
                hold on
                h(q)=polarplot([th th(1)],[r1 r1(1)],'-o');
                title(strcat('S03 OFC',title1,title2));
                err=std(hgr2)/sqrt(length(hgr2(:,1)));
                errbar(q,:)=err;
                %scatter(th,r1,'filled')
                hold on
                %errorbar(th,r1,err,'LineStyle','none')
                
            end
        end
        if ij==1
            legend(h(1:4),'Sig-RPE','Sig-Regret','Insig-RPE','Insig-Regret')
        else
            legend(h(1:4),'Sig-Win','Sig-Loss','Insig-Win','Insig-Loss')
        end
    end
end
%legend('Win Index','Loss Index','RPE','Regret')
%title('S03 LPFC Choice R-Squared');

% for q=1:size(var,2)
%     figure(1)
%     h(q)=scatter(thbar(q,:),r1bar(q,:),'filled');
%     errorbar(thbar(q,:),r1bar(q,:),errbar(q,:),'LineStyle','none')
%     hold on
% end
% ylabel('R-Squared')
% xlabel('Phase(radian)')
% %ylim([0.4 0.9]);
% xlim([-pi pi]);
%legend(h(1:4),'Win Index','Loss Index','RPE','Regret')
%title('S03 OFC Outcome R-Squared');
