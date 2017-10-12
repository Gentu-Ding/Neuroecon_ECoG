clear

load signal  % raw signal recording of 64 channels for one subject
load subj_globals  % Trial infodrmation, e.g. timestamps for analysis
band={1:4;5:8;8:12;12:22;22:30;31:41}; % six frequency bands

sampling_rate=1000;
max_freq=200;
compression=1;

for i=1:size(signal,1)
    Input=signal(i,:);
    [Data] = create_spect(Input, sampling_rate, max_freq, compression);
    %pt = single(decimate(double(angle(Data.HG_70_200)),compression));
    
    pt=Data.PHASE(band{4},:);
    phase(i,:,:)= pt';
end
phase_be2=phase(:,:,6:end);
save phase_BE2_s03 phase_be2
    














