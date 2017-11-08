clear 
close all

addpath(genpath('D:/MATLAB/freezeColors'))
addpath(genpath('D:/MATLAB/cm_and_cb_utilities'))
load subj_globals
load pcac_gamble_s03
load behav_globals
%load pac2_s03

band={1:4;5:8;8:12;12:22;22:30;31:41}; % six frequency bands
freqs=create_freqs(1,200,0.8);
thbe=5:20; %specify the phase of lower frequency
ga=33:42; %specify the amplitude of higher frequency

ge=ofc_elecs;
gr=ge(ismember(ge,good_elecs));
ind=ismember(elecs,gr);
pac_ele=pcac2.pcac(:,:,ind);
%pac_sin=pcac2.bs(:,:,ind);
%pac_cos=pcac2.bc(:,:,ind);


load coe_gamble_s03
%load coe2_s03
sini=coe(:,:,:,ind,5);
cosi=coe(:,:,:,ind,6);


for i=1:size(cosi,4)
    sin_ele=sini(:,:,:,i);
    cos_ele=cosi(:,:,:,i);
    for j=1:size(cosi,1)
        for k=1:size(cosi,2)
            fcos=reshape(cos_ele(j,k,:),size(cosi,3),1);
            fsin=reshape(sin_ele(j,k,:),size(cosi,3),1);
            ftri=[fcos fsin];
            %sig(j,k,i)=vartest(fcos,fsin);
            sig(j,k,i)=-log10(anova1(ftri,[],'off'));
            
        end
    end
end

for i=1:size(pac_ele,3)
    %figure(i)
    figure('units','normalized','outerposition',[0 0 1 1],'Name',num2str(i))
    subplot(1,2,1)
    data=fliplr(pac_ele(:,:,i))';   %Specify the PAC or F-test significance
    x=round(freqs(thbe));
    
    y=fliplr(round(freqs(ga)));
    %yy=electrode(y);
    %imagesc(x,y,data);
    imagesc([x(1) x(end)],[y(1) y(end)],data);
%     ax1=gca;
%     set(ax1, 'YTick', y);
     xlabel('Frequency(Hz)');
     ylabel('Frequency(Hz)');
     title(['S03 Computation-Phase Coupling (GLM)']);
     c=colorbar;
     c.Label.String = 'rPAC';

     caxis([0 0.05])
     freezeColors
     %hold off
     
     subplot(1,2,2)
     
     data=fliplr(sig(:,:,i))';
     x=round(freqs(thbe));
     
     y=fliplr(round(freqs(ga)));
     %yy=electrode(y);
     %imagesc(x,y,data);
     imagesc([x(1) x(end)],[y(1) y(end)],data);
     %     ax1=gca;
     %     set(ax1, 'YTick', y);
     xlabel('Frequency(Hz)');
     ylabel('Frequency(Hz)');
     title(['S03 Computation Coupling Significance(GLM)']);
     c=colorbar;
     c.Label.String = '-log(p-value)';
     caxis([0 3])
     freezeColors
     %colormap(fliplr(gray(256)')');
     
%     
end



