clear

load subj_globals  % Trial infodrmation, e.g. timestamps for analysis
load behav_globals
load phase_BTH_s03
%load signal
pt=proc2(buttonpress_times,-1,1.5,200,phase(good_elecs,:));
pt=pt(:,1:end-1,bad_trials==0 & timeout_trials==0);
phase_gi=pt(:,:,gamble_ind);
phase_si=pt(:,:,safebet_ind);

phase_time_gi=mean(phase_gi,3);
phase_timebin_gi=timebin(phase_time_gi,10);

phase_time_si=mean(phase_si,3);
phase_timebin_si=timebin(phase_time_si,10);

a1=phase_timebin_gi(:,53);

a2=phase_timebin_si(:,53);

load r2_lpfc_rpe
load HG_band



