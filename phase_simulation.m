
clear
close all


load subj_globals
load behav_globals

bin_num=12;
phase_bin=-pi:2*pi/bin_num:pi;


rad=pi/6;
trial_ind=1:188;
x_phase=zeros(188,1);
x_win=double(win_ind);
phase_trial = datasample(1:188,80,'Replace',false);

b=ismember(trial_ind,phase_trial);
x_phase(b)=rad;


d = randi([-180 180],size(trial_ind,2)-sum(b),1);
r=pi*d/180;
x_phase(~b)=r;

err=randn(188,1);
x_phase_c=double(x_phase==rad);
HG=5*x_win+8*x_phase_c+3*x_phase_c.*x_win;
%HG=10*x_phase_c;
catgr_phase=zeros(188,1);
for i=1:bin_num
    ind=find(x_phase>phase_bin(i)& x_phase<=phase_bin(i+1));
    catgr_phase(ind,1)=i;
end
Win=x_win;
Phase_Category=catgr_phase;
Encoding=table(HG,Win,Phase_Category);
Encoding.Phase_Category = nominal(Encoding.Phase_Category);

fit = fitlm(Encoding,'HG~Win*Phase_Category');
%HG=x_win+x_phase;

%x=horzcat(sin(x_phase),cos(x_phase));
%x=horzcat(x_win,x_phase_c,x_phase_c.*x_win);

%x=horzcat(x_win,cos(x_phase),cos(x_phase).*x_win)


