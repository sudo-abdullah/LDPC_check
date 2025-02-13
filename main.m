clc;
clear;
close all;


codeRate = 1/2; 

H = dvbs2ldpc(codeRate); 


N = size(H, 2); 
K = N * codeRate;   

H_rows = N - K; 


info_bits = randi([0, 1], K, 1); % Column vector format


A = cell(1, K); % Initialize cell array to store non-zero indices for each column
for c = 1:K
    A{c} = find(H(:, c)); % Find non-zero indices for the current column
end

S = zeros(H_rows, 1); % S vector to store intermediate values

for c = 1:K
  
    non_zero_indices = A{c};

    % Update S values using the information bits
    for r = 1:length(non_zero_indices)
        S(non_zero_indices(r)) = mod(S(non_zero_indices(r)) + info_bits(c), 2);
    end
end


parity_bits = zeros(H_rows, 1); % Initialize parity bits

% Compute the first parity bit
parity_bits(1) = S(1);

% Compute the remaining parity bits
for r = 2:H_rows
    parity_bits(r) = mod(parity_bits(r - 1) + S(r), 2);
end


codeword = [info_bits; parity_bits];

encoder = comm.LDPCEncoder(H); 

if exist('step', 'file') == 2
    
    matlab_encoded = step(encoder, info_bits);
else
    
    matlab_encoded = encoder(info_bits);
end


matlab_parity = matlab_encoded(K+1:end);


disp('Custom IRA Encoding Parity Bits:');
disp(parity_bits(:).'); 

disp('MATLAB DVB-S2 LDPC Parity Bits:');
disp(matlab_parity(:).'); 


if isequal(parity_bits, matlab_parity)
    disp('IRA Algorithm Output Matches MATLAB DVB-S2 LDPC Encoder!');
else
    disp('Outputs Do NOT match. Encoding structures are different.');
end
