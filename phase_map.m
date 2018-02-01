clear
close all


load subj_globals
load behav_globals
load signal  % raw signal recording of 64 channels for one subject
rrname={' Safebet';' Win';' Loss'};
band={1:4;5:8;8:12;12:22;22:30;31:41}; % six frequency bands

freqs=create_freqs(1,200,0.8);

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
safe_loss=(rejoice>0)-win_ind;
safe_win=(regret<0)-loss_ind;
optm=rejoice>0;
suboptm=regret<0;
win_gs=win_ind+safe_win;
loss_gs=loss_ind+safe_loss;


comp=optm;
%regrej=regret_all+rejoice_all;
regrej=double(win_ind_all);
regrej(regrej==0 & gamble_ind_all==1)=2;

level_regrej=unique(regrej);

 
for i=1:size(comp,1)
    x_comp(i,1:1000)=comp(i,1);
end
x_comp=reshape(x_comp',1,size(x_comp,1)*size(x_comp,2));

ge=ofc_elecs;
gr=ge(ismember(ge,good_elecs));
%ind=ismember(elecs,gr);
for rr=1:3
for i=1:size(gr,2)
    dp=[];
    mdp=[];
    sdp=[];
    Input=signal(gr(i),:);
    [Data] = create_spect(Input, sampling_rate, max_freq, compression);
    data=Data.TH_4_8;
    %short_bp_Input=double(abs(data));                  % calculate amplitude

    %Data.MN(i)=mean(short_bp_Input);                        % calculate the mean of the data in a freq band 
    %Data.STD(i)=std(short_bp_Input);                        % calculate the std of the data in a freq band 
    %Data.SPEC(i,:)=single(decimate(short_bp_Input,compression));  % compress the spectogram  
    PHASE_TH = single(decimate(double(angle(data)),compression));
    
    frequency=Data.SPEC;
    phase=Data.PHASE;
    phase_th=PHASE_TH;
    
    pth=proc2(reveal_times,-2,1,200,phase_th);
    pth=pth(:,1:end-1,bad_trials==0 & timeout_trials==0 & regrej==rr-1);
    pth=reshape(pth,size(pth,2),size(pth,3));
    pth=pth';
    
    for ii=1:size(pth,1)
        for j=1:size(pth,2)-1
            if pth(ii,j+1)<pth(ii,j)
                dp(ii,j)=pth(ii,j+1)+pi+pi-pth(ii,j);
            else
                dp(ii,j)=pth(ii,j+1)-pth(ii,j);
            end
        end
    end
        
%     for k=1:size(pth,1)
%         for j=1:size(pth,2)
%             x=pth(k,j);
%             if x>=-pi && x<0
%                 tpth(k,j)=pi+x;
%             else
%                 tpth(k,j)=pi-x;
%             end
%         end
%     end
    %imagesc([x(1) x(end)],[y(1) y(end)],data);
    %figure(1)
    %imagesc(dp);
    for q=1:size(dp,2)
        for p=1:size(dp,1)
            if dp(p,q)>1
                dp(p,q)=nan;
            end
        end
        mdp(q)=nanmean(dp(:,q));
        sdp(q)=nanstd(dp(:,q));
    end
    
    mean_ind_elec(i,:)=mdp;
    std_ind_elec(i,:)=sdp;
%     line([2000, 2000],ylim, 'LineWidth', 2, 'Color', 'r');
%     c=colorbar;
%     c.Label.String = 'phase difference(radian)';
%     lim = caxis;
%     caxis([0 0.05])
end

figure(1)
subplot(3,1,rr);
%plot(mean(mean_ind_elec))
x=linspace(0,2999,2999);
y=mean(mean_ind_elec);
err=std(mean_ind_elec);
x=timebin(x,10);
y=timebin(y,10);
err=timebin(err,10);
patch([x fliplr(x)],[y+err fliplr(y-err)],'blue','EdgeAlpha',0.2);
alpha(0.2) 
hold on;
plot(x,y,'blue','LineWidth',2)
hold on
line([2000, 2000],ylim, 'LineWidth', 2, 'Color', 'r');
title(strcat('S03 OFC during ', rrname{rr},' (electrode population)'))
xlabel('Time (Outcome: 2000ms)')
ylabel('Phase Difference')
%plot(std_ind_elec')
end


    
    
    
   