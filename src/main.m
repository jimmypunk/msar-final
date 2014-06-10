function main(filename)


[signalHar, signalPer, filenameHar, filenamePer,fs] = HPSeparation(filename);

wObj=waveFile2obj(filenamePer);
wObj.signal=mean(wObj.signal, 2);
oscOpt=wave2osc('defaultOpt');
showPlot = 1;
wObj.osc=wave2osc(wObj, oscOpt, showPlot);

[peaks, loc] = findpeaks(wObj.osc.signal);

for i=1:length(loc),
    idx = loc(i);
    beat_time = wObj.osc.time(idx);
    startIdx = floor((beat_time) * wObj.fs);
    % take 150 ms (0.15 sec) period as frame 
    endIdx = floor((beat_time + 0.15) * wObj.fs);
    endIdx = min(endIdx, length(wObj.signal))
    frame = wObj.signal(startIdx:endIdx);
    frame2mfcc(frame, wObj.fs, 20, 12, 1);
    ret = 'y';
    while(ret == 'y'),
        soundsc(frame, wObj.fs);
        ret = input('replay?[y/n]');
    end
    

end