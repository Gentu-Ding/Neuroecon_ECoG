clear;
close all;

load electrode_index_mcx

load subj_globals 
electrode=mcx_elecs;

for j=1:size(elec_ind,2)
    aa=cat(1,elec_ind{:,j});
    for i=1:size(electrode,2)
        data(i,j)=sum(aa==i);
    end
end

x=linspace(-1999,200,220); 
y=1:size(electrode,2); 
yy=electrode(y);
imagesc(x,y,data);
ax1=gca;
set(ax1, 'YTick', 1:length(y), 'YTickLabel',string(yy));
xlabel('Time(ms) Zeroed on Choice Time');
ylabel('Motor Electrode Index');
title('Lasso Motor Electrode Selection');
c=colorbar;
c.Label.String = 'Number of Times Selected';


