snareDir='~/Desktop/msar-final/res/snare/';
hihatDir='~/Desktop/msar-final/res/hihat/';
kickDir='~/Desktop/msar-final/res/kick/';

tempData=recursiveFileList(hihatDir, 'wav');
waveNum=length(tempData);

for i=1:waveNum
    fprintf('%d/%d: waveFile=%s, \n', i, waveNum, tempData(i).name);
    % ====== Read wave files
    wObj=waveFile2obj(tempData(i).path);
    wObj.signal=mean(wObj.signal, 2);
    oscOpt=wave2osc('defaultOpt');
    % ====== onset detection
    showPlot=1;
    wObj.osc=wave2osc(wObj, oscOpt, showPlot);
    %waveData(i)=wObj;
    
    pause;
end

% ====== Save the collect data
%fprintf('Save waveData to waveData.mat...\n');
%save waveData waveData