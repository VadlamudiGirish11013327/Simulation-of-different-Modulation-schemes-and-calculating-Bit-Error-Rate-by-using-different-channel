

M = 8;           % Modulation order
bps = log2(M);   % Bits per symbol
N = 7;           % RS codeword length
K = 5;           % RS message length

pskModulator = comm.PSKModulator('ModulationOrder',M,'BitInput',true);
pskDemodulator = comm.PSKDemodulator('ModulationOrder',M,'BitOutput',true);
awgnChannel = comm.AWGNChannel('BitsPerSymbol',bps);
errorRate = comm.ErrorRate;


rsEncoder = comm.RSEncoder('BitInput',true,'CodewordLength',N,'MessageLength',K);
rsDecoder = comm.RSDecoder('BitInput',true,'CodewordLength',N,'MessageLength',K);
%% 
% Set the range of $E_b/N_0$ values. Initialize the error statistics matrix.

ebnoVec = (3:0.5:8)';
errorStats = zeros(length(ebnoVec),3);
%% 
% Estimate the bit error rate for each $E_b/N_0$ value. The simulation runs 
% until either 100 errors or $10^7$ bits is encountered. The main simulation loop 
% processing includes encoding, modulation, demodulation, and decoding. 

for i = 1:length(ebnoVec)
    awgnChannel.EbNo = ebnoVec(i);
    reset(errorRate)
    while errorStats(i,2) < 100 && errorStats(i,3) < 1e7
        data = randi([0 1],1500,1);                 % Generate binary data
        encData = rsEncoder(data);                  % RS encode
        modData = pskModulator(encData);            % Modulate
        rxSig = awgnChannel(modData);               % Pass signal through AWGN
        rxData = pskDemodulator(rxSig);             % Demodulate
        decData = rsDecoder(rxData);                % RS decode
        errorStats(i,:) = errorRate(data,decData);  % Collect error statistics
    end
end
%% 
% Fit a curve to the BER data using |berfit|. Generate an estimate of 8-PSK 
% performance without coding using the |berawgn| function.

berCurveFit = berfit(ebnoVec,errorStats(:,1));
berNoCoding = berawgn(ebnoVec,'psk',8,'nondiff');
%% 
% Plot the BER data, the BER curve fit, and the estimated performance without 
% RS coding.

semilogy(ebnoVec,errorStats(:,1),'b*', ...
ebnoVec,berCurveFit,'c-',ebnoVec,berNoCoding,'r')
ylabel('BER')
xlabel('Eb/No (dB)')
legend('Data','Curve Fit','No Coding')
grid
%% 
% The (7,5) RS code improves the $E_b/N_0$ required to achieve a $10^{-2}$ bit 
% error rate by, approximately, 1.4 dB.
% 
% _Copyright 2012 The MathWorks, Inc._