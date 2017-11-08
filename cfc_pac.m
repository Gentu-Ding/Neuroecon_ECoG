clear
close all


load subj_globals
load behav_globals
load signal  % raw signal recording of 64 channels for one subject

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

 
for i=1:size(comp,1)
    x_comp(i,1:1000)=comp(i,1);
end
x_comp=reshape(x_comp',1,size(x_comp,1)*size(x_comp,2));



for i=1:size(signal,1)
    Input=signal(i,:);
    [Data] = create_spect(Input, sampling_rate, max_freq, compression);
    
    frequency=Data.SPEC;
    phase=Data.PHASE;
    
%     frequency1=frequency(:,buttonpress_times(1)-2000:buttonpress_times(size(buttonpress_times,1))+2000);
%     frequency2=zscore(frequency1,1,2);
%     frequency(:,buttonpress_times(1)-2000:buttonpress_times(size(buttonpress_times,1))+2000)=frequency2;
    
    sphase=sin(phase);
    cphase=cos(phase);
    
%     sphase1=sphase(:,buttonpress_times(1)-2000:buttonpress_times(size(buttonpress_times,1))+2000);
%     sphase2=zscore(sphase1,1,2);
%     sphase(:,buttonpress_times(1)-2000:buttonpress_times(size(buttonpress_times,1))+2000)=sphase2;
%     
%     cphase1=cphase(:,buttonpress_times(1)-2000:buttonpress_times(size(buttonpress_times,1))+2000);
%     cphase2=zscore(cphase1,1,2);
%     cphase(:,buttonpress_times(1)-2000:buttonpress_times(size(buttonpress_times,1))+2000)=cphase2;
    
    ftp=proc2(reveal_times,0.2,1.2,200,frequency);
    ftp=ftp(:,1:end-1,bad_trials==0 & timeout_trials==0);
    
    cpt=proc2(reveal_times,0.2,1.2,200,cphase);
    cpt=cpt(:,1:end-1,bad_trials==0 & timeout_trials==0);
    
    spt=proc2(reveal_times,0.2,1.2,200,sphase);
    spt=spt(:,1:end-1,bad_trials==0 & timeout_trials==0);
    
    y_a=reshape(ftp,size(ftp,1),size(ftp,2)*size(ftp,3));
    x_s=reshape(spt,size(spt,1),size(spt,2)*size(spt,3));
    x_c=reshape(cpt,size(cpt,1),size(cpt,2)*size(cpt,3));
    
    y_amp=zscore(y_a,1,2);
    x_sin=zscore(x_s,1,2);
    x_cos=zscore(x_c,1,2);
    
    x_com=zscore(x_comp,1,2);
    x_scomp=zscore(x_s.*x_comp,1,2);
    x_ccomp=zscore(x_c.*x_comp,1,2);
    

    for p=1:size(thbe,2)
        for q=1:size(ga,2)
            y=y_amp(ga(q),:)';
            xc=x_cos(thbe(p),:)';
            xs=x_sin(thbe(p),:)';
            xsc=x_scomp(thbe(p),:)';
            xcc=x_ccomp(thbe(p),:)';
            x_co=x_com';
            Encoding=table(y,xs,xc,x_co,xsc,xcc);
            fit = fitlm(Encoding,'y~xs+xc+x_co+xsc+xcc');
            bs=fit.Coefficients.Estimate(2);
            bc=fit.Coefficients.Estimate(3);
            bcs=fit.Coefficients.Estimate(5);
            bcc=fit.Coefficients.Estimate(6);
            pac(p,q,i)=(bs^2+bc^2)^0.5;
            BETA(p,q,i,:)=fit.Coefficients.Estimate;
            pcac(p,q,i)=(bcs^2+bcc^2)^0.5;
            
            
           
        end
    end
    
    
        
        
        
    

end
save pac_s03 pac