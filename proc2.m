function tt=proc2(times,t1,t2,num_trial,signal)
for i = 1: num_trial
    if times(i)>0
        tt(:,:,i)=signal(:,(times(i)+1000*t1):(times(i)+1000*t2));
    end
end
end