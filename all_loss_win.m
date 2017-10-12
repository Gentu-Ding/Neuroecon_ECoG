addpath(genpath('D:/MATLAB/barwitherr')) % add Fieldtrip into the searching path

clear;
load subj_globals 

load egcs_choice_p.mat
s=egc;
s.error(326:351)=0;
s.error(:,2)=s.error(:,1);
clear egc;

load egcg_choice_p.mat
g=egc;
g.error(341:351)=0;
g.error(:,2)=g.error(:,1);
clear egc;

load egcs_iti.mat
l=egc;
l.error(334:351)=0;
l.error(:,2)=l.error(:,1);
clear egc;

load egcg_iti.mat
w=egc;
w.error(331:351)=0;
w.error(:,2)=w.error(:,1);
clear egc;
[h,p,stats]=fishoverlap(w,g)
% Fisher-test of Significant Overlappingf
tp=length(w.sig_p(w.sig_p==1 & g.sig_p==1));
fp=length(w.sig_p(w.sig_p==1 & g.sig_p==0 & g.error==0));
fn=length(w.sig_p(w.sig_p==0 & g.sig_p==1 & w.error==0));
tn=length(w.sig_p(w.sig_p==0 & g.sig_p==0 & w.error==0 & g.error==0));

gol=table([tp;fn],[fp;tn]);
[h,p,stats] = fishertest(gol);
% within LPFC--1 % within OFC--2 % LPFC to OFC--3 % OFC to LPFC--4

[prop_loss,l]=prop_topo(l,lpfc_elecs,ofc_elecs);
[prop_win,w]=prop_topo(w,lpfc_elecs,ofc_elecs);
figure(1)
c = categorical({'within-LPFC','within-OFC','LPFC-to-OFC','OFC-to-LPFC'});
wl=horzcat(prop_win',prop_loss');
bar(c,wl,0.75);
title('Proportion of Significant Causal Influence during Choice Stage');
legend('gamble','safebet')
xlabel('Direction')
ylabel('Proportion of Causal Influence')

col=['g'; 'b'; 'r'; 'k'];
for i=1:4
    
    win_F=[];
    loss_F=[];
    
    win_F=w.F(w.sig_p==1 & l.sig_p==1 & w.topo==i );
    loss_F=l.F(w.sig_p==1 & l.sig_p==1 & w.topo==i );
    
    
    figure(2)
    scatter(win_F,loss_F,col(i));
    hold on;
    

    
end
xlim([0 0.12])
ylim([0 0.12])
hline=refline(1,0);
hline.Color='y';
legend('Within LPFC','Within OFC', 'LPFC to OFC', 'OFC to LPFC');

title('Granger Causality of Gamble vs. Safebet during Choice Stage');
xlabel('Granger Causality of Gamble Trial')
ylabel('Granger Causality of Safebet Trial')

win_F1=w.F(w.sig_p==1 & l.sig_p==1 & w.topo==1 );
loss_F1=l.F(w.sig_p==1 & l.sig_p==1 & w.topo==1 );
%[h,p] = ttest2(win_F,loss_F);
win_F2=w.F(w.sig_p==1 & l.sig_p==1 & w.topo==2 );
loss_F2=l.F(w.sig_p==1 & l.sig_p==1 & w.topo==2 );
win_F3=w.F(w.sig_p==1 & l.sig_p==1 & w.topo==3 );
loss_F3=l.F(w.sig_p==1 & l.sig_p==1 & w.topo==3 );
win_F4=w.F(w.sig_p==1 & l.sig_p==1 & w.topo==4 );
loss_F4=l.F(w.sig_p==1 & l.sig_p==1 & w.topo==4 );

g_F=g.F(w.sig_p==1 & g.sig_p==1 & w.topo==2 );
w_F=w.F(w.sig_p==1 & g.sig_p==1 & w.topo==2 );

s_F=s.F(s.sig_p==1 & l.sig_p==1& w.topo==1 );
l_F=l.F(s.sig_p==1 & l.sig_p==1& w.topo==1 );

c = categorical({'within-LPFC','within-OFC','LPFC-to-OFC','OFC-to-LPFC'});
d1=mean(loss_F1-win_F1);
d2=mean(loss_F2-win_F2);
d3=mean(loss_F3-win_F3);
d4=mean(loss_F4-win_F4);
sem1=sem(loss_F1-win_F1);
sem2=sem(loss_F2-win_F2);
sem3=sem(loss_F3-win_F3);
sem4=sem(loss_F4-win_F4);

d1=mean(win_F1);
d2=mean(win_F2);
d3=mean(win_F3);
d4=mean(win_F4);
sem1=sem(win_F1);
sem2=sem(win_F2);
sem3=sem(win_F3);
sem4=sem(win_F4);

figure(3)
%bar([d1 d2 d3 d4], 'grouped');
d=[d1; d2; d3; d4];
err=[sem1; sem2; sem3; sem4];
barwitherr(err,d,0.4);
%bar_xtick = errorbar_groups([d1 d2 d3 d4],err); % returns the X coordinates for the center
% of each group of bars.
xticklabels({'within-LPFC','within-OFC','LPFC-to-OFC','OFC-to-LPFC'})
%(c,[d1 d2 d3 d4],err)
%errorbar([sd1 sd2 sd3 sd4]);
hold on;
title('Granger Causality of Directional Groups during Win ');
ylabel('Mean of GC Magnitude during Win')

function [SEM] =sem(x)
SEM=std(x)/sqrt(length(x));
end

function[prop,l]=prop_topo(l,lpfc_elecs,ofc_elecs)
for i=1:length(l.index)
    if ismember(l.index(i,1),lpfc_elecs) && ismember(l.index(i,2),lpfc_elecs)
        l.topo(i,1)=1; 
        l.topo(i,2)=1;
    elseif ismember(l.index(i,1),ofc_elecs) && ismember(l.index(i,2),ofc_elecs)
        l.topo(i,1)=2; 
        l.topo(i,2)=2;
    elseif ismember(l.index(i,1),lpfc_elecs) && ismember(l.index(i,2),ofc_elecs)
        l.topo(i,1)=3; 
        l.topo(i,2)=4;
    end
end


% Loss trial proportion in terms of the topography
prop(1)=sum(l.sig_p(l.topo==1))/length(l.topo(l.topo==1));
prop(2)=sum(l.sig_p(l.topo==2))/length(l.topo(l.topo==2));
prop(3)=sum(l.sig_p(l.topo==3))/length(l.topo(l.topo==3));
prop(4)=sum(l.sig_p(l.sig_p==1 &l.topo==4))/length(l.topo(l.topo==4));
end

        
        
        
        
        
        