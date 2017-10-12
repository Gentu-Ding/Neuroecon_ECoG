clear
close all

addpath(genpath('D:/MATLAB/CircStat2012a'))
load subj_globals
load behav_globals
%load frequency_HG_s25

col=[0 1];
rang={1:500;501:1000;1:2000};
tit={' [-1000,-500ms]';' [-500,0ms]'};

%load band_freq
%load signal
ele=lpfc_elecs; %Specify the region

figure(1)
for p=1:4
    subplot(2,2,p)
    if p==1
        load phase_DE_s03
        title1= ' Delta';
    elseif p==2
        load phase_TH_s03
        title1= ' Theta';
    elseif p==3
        load phase_AL_s03
        title1= ' Alpha';
    else
        load phase_BE_s03
        title1= ' Beta';
    end
    for q=1:2
        if q==1
            eleind=ismember(good_elecs,rpe_eind);
        else
            eleind=~ismember(good_elecs,rpe_eind);
        end
        
        for k=1:size(phase,3)
            phase1=phase(:,:,k);
            pt=proc2(reveal_times,-1,1,200,phase1(good_elecs,:));
            pt1=pt(:,1:end-1,bad_trials==0 & timeout_trials==0);
            %bin_num=12;
            %phase_bin=-pi:2*pi/bin_num:pi;
            % for i=1:size(pt,3)
            %     pt_short(:,:,i)=timebin(pt(:,:,i),10);
            % end
            
            
            
            pt2=pt1(ismember(good_elecs,ele)&eleind,:,:);
            
            %gb=gamble_trials( bad_trials==0 & timeout_trials==0);
            
            for i=1:size(pt2,3)
                pv(i,:)=circ_var(pt2(:,:,i));
            end
            
            pvk(:,:,k)=pv;
        end
        
        %wtr=pv(gamble_ind==1,:);
        %ltr=pv(gamble_ind==0,:);
        x=-999:1000;
        y1=mean(pvk,3);
        h(q)=plot(x,mean(y1));
        err=std(y1)/sqrt(length(y1(:,1)));
        hold on
        %err = movmean(err,50);
        h(q+2)=patch([x fliplr(x)],[mean(y1)+err fliplr(mean(y1)-err)],col(q));
        %hold on
        %plot(x,mean(ltr))
        
        
    end
  
    
    title(strcat('S03 LPFC Phase',title1));
    ylabel('Phase Variance')
    xlabel('Time(ms) zeroed on Outcome')
    
    hold on
    ystart = 0.4;
    yend = 0.8;
    h(10)=plot([ystart yend],'--');
    %ylim([0.4 0.9]);
    xlim([-999 1000]);
    legend(h(3:4),'Sig-RPE Electrode','NonSig-RPE Electrode')
   
end

