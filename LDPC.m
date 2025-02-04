clc;
clear;
close all;

codeRate = 1/2; % 1/4, 1/3, 1/2, 2/3
H = dvbs2ldpc(codeRate); % Get standard DVB-S2 LDPC matrix

K = size(H,2) - size(H,1); % Extract K from the parity-check matrix
N = size(H,2); % Total codeword length
H_rows = N - K; % Number of parity bits
M = 360; % Periodicity used in IRA encoding

% Generate Random Input Message
input_bits = randi([0, 1], K, 1); % Column vector format for MATLAB encoder

% Step 1: Compute Parity Bits Using Standard H-Matrix
% Parity bits are computed using the LDPC parity check matrix (DVB-S2 structure)
s = mod(H(:,1:K) * input_bits, 2); % Multiply input bits with parity check matrix

% Step 2: Accumulate to Compute Parity Bits (IRA method)
parity_bits = zeros(H_rows, 1); % Initialize parity bits
parity_bits(1) = s(1);
for i = 2:H_rows
    parity_bits(i) = mod(s(i) + parity_bits(i-1), 2); % Accumulate
end

% Construct the Final Codeword
custom_encoded = [input_bits; parity_bits]; % Combine input and parity bits

% Compare with MATLAB's DVB-S2 LDPC Encoder
encoder = comm.LDPCEncoder(H); % Create DVB-S2 LDPC Encoder

matlab_encoded = step(encoder, input_bits); % Encode using MATLAB built-in function

% Extract parity bits from MATLAB's encoded result
matlab_parity = matlab_encoded(K+1:end);

% Display Results
disp('Custom IRA Encoding Parity Bits:');
disp(parity_bits(1:50).'); % Display first 50 parity bits

disp('MATLAB DVB-S2 LDPC Parity Bits:');
disp(matlab_parity(1:50).'); % Display first 50 parity bits

% Check if Outputs Match
if isequal(parity_bits, matlab_parity)
    disp('IRA Algorithm Output Matches MATLAB DVB-S2 LDPC Encoder!');
else
    disp('Outputs Do NOT match. Encoding structures are different.');
end
