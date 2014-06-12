function [signalHar, signalPer, filenameHar, filenamePer, fs] = HPSeparation(filename)

frameSize = 4096;
hopsize = 1024;
lh = 17;
lp = 17;
p = 2;
hlh = floor(lh/2) + 1;

[signal, fs] = wavread(filename);
signalPer = zeros(length(signal), 1);
signalHar = zeros(length(signal), 1);
window = hanning(frameSize, 'periodic');
overlap = frameSize - hopsize;
frameMat = enframe(signal, frameSize, overlap);

buffer = zeros(frameSize, lh);
buffercomplex = zeros(frameSize, lh);
frameNum=size(frameMat, 2);
for i=1:frameNum,
    frame=frameMat(:,i);
    frame = frame .* window;
    fc = fft(fftshift(frame));
    fa = abs(fc);
    buffercomplex(:,1:lh-1) = buffercomplex(:,2:lh);
    buffercomplex(:,lh) = fc;
    buffer(:,1:lh-1) = buffer(:,2:lh);
    buffer(:,lh) = fa;
    Per = medfilt1(buffer(:,hlh),lp);
    Har = median(buffer,2);
    maskHar = (Har.^p) ./ (Har.^p + Per.^p);
    maskPer = (Per.^p) ./ (Har.^p + Per.^p);

    % get the middle frame as curframe
    curfframe = buffercomplex(:, hlh);
    perfframe = curfframe .* maskPer;
    harfframe = curfframe .* maskHar;

    perframe = fftshift(real(ifft(perfframe))) .* window;
    harframe = fftshift(real(ifft(harfframe))) .* window;
    
    begin = hopsize*(i-1);
    if begin+frameSize > length(signalPer)
        break;
    end 
    signalPer(begin+1:begin+frameSize) = ...
        signalPer(begin+1:begin+frameSize) + perframe;
    signalHar(begin+1:begin+frameSize) = ...
        signalHar(begin+1:begin+frameSize) + harframe;

end

signalHar = signalHar((hopsize * (hlh-1)):length(signalHar))/max(abs(signalHar));
signalPer = signalPer((hopsize * (hlh-1)):length(signalHar))/max(abs(signalPer));
filenameHar = [filename(1:end-4) '_har' '.wav'];
filenamePer = [filename(1:end-4) '_per' '.wav'];
wavwrite(signalHar, fs, filenameHar);
wavwrite(signalPer, fs, filenamePer);