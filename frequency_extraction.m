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
    bp_Input=Data.HG_70_200;
    short_bp_Input=double(abs(bp_Input).^2);     
    ft=single(decimate(short_bp_Input,compression));
    %ft=Data.SPEC(band{6},:);
    %frequency(i,:)= mean(ft);
    frequency(i,:)= ft;
end

save frequency_BHG_s03 frequency
    