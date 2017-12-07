clear 
close all

addpath(genpath('D:/MATLAB/freezeColors'))
addpath(genpath('D:/MATLAB/cm_and_cb_utilities'))
load subj_globals
ge=lpfc_elecs;
gr=ge(ismember(ge,good_elecs));
ind=ismember(elecs,gr);


load wlpcac2_win_s03
pac_win=pcac2.pac(:,:,ind);
%pac_eley=pcac2.BETA(:,:,ind,4);

bwin1=pcac2.BETA(:,:,ind,2);
bwin2=pcac2.BETA(:,:,ind,3);

load wlpcac2_loss_s03
pac_loss=pcac2.pac(:,:,ind);
bloss1=pcac2.BETA(:,:,ind,2);
bloss2=pcac2.BETA(:,:,ind,3);


%load pac2_s05


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
                


band={1:4;5:8;8:12;12:22;22:30;31:41}; % six frequency bands
freqs=create_freqs(1,200,0.8);
thbe=5:20; %specify the phase of lower frequency
ga=33:42; %specify the amplitude of higher frequency

band2={1:3;4:8;8:16};

for i=1:size(pac_win,3)
    figure('units','normalized','outerposition',[0 0 1 1],'Name',num2str(i))
    subplot(1,2,1)
    ho = zeros(1,5);
    mmwin=reshape(pac_win(:,:,i),size(pac_win,1)*size(pac_win,2),1);
    mmloss=reshape(pac_loss(:,:,i),size(pac_loss,1)*size(pac_loss,2),1);
    ttt=ttest(mmwin,mmloss);
    
    for j=1:3
        mwin=reshape(pac_win(band2{j},:,i),size(band2{j},2)*size(pac_win,2),1);
        mloss=reshape(pac_loss(band2{j},:,i),size(band2{j},2)*size(pac_loss,2),1);
        ho(j)=scatter(mloss,mwin);
        tt(j,i)=ttest(mwin,mloss);
        hold on
    end
    legend(ho(1:3),{'Theta','Alpha','Beta'});
    %xlim([0 0.08])
    %ylim([0 0.08])
    hline=refline(1,0);
    [h,p]=corr(mloss,mwin);
    title1=num2str(h);
    title2=num2str(p);
    hline.Color='y';
    title(strcat('Win vs. Loss PAC Corr:',title1,' P-value:',title2));
    xlabel('Loss')
    ylabel('Win')
    
    subplot(1,2,2)
    l1=line([-pi pi], [0 0]);
    l2=line([0 0], [-pi pi]);
    xlim([-pi pi])
    ylim([-pi pi])
    l1.Color='k';
    l2.Color='k';
    hold on
    hp = zeros(1,5);
    for j=1:3
        angw=reshape(angwin(band2{j},:,i),size(band2{j},2)*size(angwin,2),1);
        angl=reshape(angloss(band2{j},:,i),size(band2{j},2)*size(angloss,2),1);
        %         b1=reshape(be1(:,:,i),size(be1,1)*size(be1,2),1);
        %         b2=reshape(be2(:,:,i),size(be2,1)*size(be2,2),1);
        
        hp(j)=scatter(angl,angw);
        hold on
    end
    legend(hp(1:3),{'Theta','Alpha','Beta'});
    
%     l1=line([-0.1 0.1], [0 0]);
%     l2=line([0 0], [-0.1 0.1]);
%     xlim([-0.1 0.1])
%     ylim([-0.1 0.1])
    [h,p]=corr(angl,angw);
    title1=num2str(h);
    title2=num2str(p);
%     l1.Color='k';
%     l2.Color='k';
    title('Angle Win vs. Loss');
    xlabel('Loss Angle')
    ylabel('Win Angle')
    
    
end



% for i=1:size(pac_elex,2)
%     figure('units','normalized','outerposition',[0 0 1 1],'Name',num2str(i))
%     pac=reshape(pac_elex(:,i),size(pac_elex,1),1);
%     pcac=reshape(pac_eley(:,i),size(pac_eley,1),1);
%     scatter(pac,pcac);
%     xlim([0 0.08])
%     ylim([0 0.08])
%     hline=refline(1,0);
%     [h,p]=corr(pac,pcac);
%     title1=num2str(h);
%     title2=num2str(p);
%     hline.Color='y';
%     title(strcat('PAC vs. Interaction Cor:',title1,' P-value:',title2));
%     xlabel('PAC')
%     ylabel('Interaction')
% end

    






