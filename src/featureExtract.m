function featureExtract(dirname)

pureDrumDir='~/Desktop/msar-final/pure_drum/'
annoDir='~/Desktop/msar-final/annotation/'

tempData=recursiveFileList(pureDrumDir, 'wav');
waveNum=length(tempData);

for i=1:waveNum
    fprintf('%d/%d: waveFile=%s, \n', i, waveNum, tempData(i).name);
    % ====== Read wave files ======
    
    wObj=waveFile2obj(tempData(i).path);
    wObj.signal=mean(wObj.signal, 2);
    
    % ====== Read groundtruth files
    gt_name = [tempData(i).name(1:end-3) 'txt'];
    [annoDir gt_name]
    [dtime, dtype] = textread(['../annotation/' gt_name],'%f %s');
    gtObj.name = gt_name;
    gtObj.time = dtime;
    gtObj.dtype = dtype;

    % ====== onset detection
    %showPlot=1;
    %oscOpt=wave2osc('defaultOpt');
    %wObj.osc=wave2osc(wObj, oscOpt, showPlot);
    

    mgtObj.acc_idx = 1;
    prev_time = -1;
    prev_idx = -1;
    for i = 1:length(gtObj.time),
        curr_time = gtObj.time(i);
        % if two beats are within 10 ms, merge
        if curr_time - prev_time < 0.01,
            prev_insert_idx = mgtObj.acc_idx - 1;
            % append the data type to the previous insert index
            data_len = length(mgtObj.dtype(prev_insert_idx));
            mgtObj.dtype{prev_insert_idx}(data_len + 1) = gtObj.dtype(i);
            
        else,
            insert_idx = mgtObj.acc_idx;
            mgtObj.time(insert_idx) = curr_time;
            % turn char to cell for further append
            mgtObj.dtype(insert_idx) = {gtObj.dtype(i)};
            mgtObj.acc_idx = mgtObj.acc_idx + 1;
            prev_time = curr_time;
            prev_idx = i;
        end

    end

    fs = wObj.fs;
    filename = [gt_name(1:end-4) '.f']
    fid = fopen(filename, 'w');
    fid
    mgtObj.mfcc = zeros(length(mgtObj.time), 12);
    for i = 1:length(mgtObj.time),
        beat_time = mgtObj.time(i);
        
        startIdx = floor((beat_time) * wObj.fs);
        % take 150 ms (0.15 sec) period as frame 
        endIdx = floor((beat_time + 0.15) * wObj.fs);
        endIdx = min(endIdx, length(wObj.signal));
        frame = wObj.signal(startIdx:endIdx);
        mfcc = frame2mfcc(frame, wObj.fs, 20, 12);
        
        
        
        str = [cell2str(mgtObj.dtype{i}) ' ' num2str(mfcc','%d,')];
        fprintf(fid, '%s\n', str(1:end-1));  
        
    end
    fclose(fid);
    clear mgtObj;
    clear gtObj;
    
    
    
end
