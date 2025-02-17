clc;
clear;
close all;

codeRate = 1/2; 
frameLength = 16200; 
q = 360; 

H = dvbs2ldpc(codeRate);

% Get matrix dimensions
N = size(H, 2); 
K = N * codeRate; 
H_rows = N - K; 

if mod(K, q) ~= 0
    error('K must be divisible by q. Adjust codeRate or frameLength.');
end


info_bits = randi([0, 1], K, 1);

% Reshape into groups of 360 bits
t = K / q;
info_groups = reshape(info_bits, q, t);

%Index-Alpha Table
alpha_index_table = [
    5, 0; 9, 26; 19, 222; 1, 125; 2, 132; 2, 323; 6, 0; 
    3, 217; 3, 248; 4, 112; 7, 0; 14, 45;
    1, 107; 4, 280; 8, 0; 17, 239; 0, 106; 9, 0; 
    6, 246; 10, 0; 13, 237; 11, 0; 13, 176;
    2, 220; 12, 0; 18, 318; 0, 154; 8, 314; 13, 0; 14, 175;
    5, 83; 14, 0; 15, 205; 4, 313; 15, 0; 16, 3;
    0, 198; 0, 265; 16, 0; 19, 64;
    0, 318; 0, 332; 7, 352; 17, 0;
    2, 263; 4, 310; 18, 0; 18, 121;
    1, 237; 8, 223; 17, 330; 19, 0;
    2, 233; 4, 155; 10, 349;
    3, 317; 6, 358;
    3, 174; 4, 171; 11, 302; 12, 271;
    1, 259; 2, 213; 15, 86;
    2, 350; 7, 93;
    0, 0; 0, 159; 3, 180; 12, 48;
    1, 168; 2, 0; 4, 101; 9, 184;
    1, 131; 1, 267; 3, 0;
    3, 148; 3, 183; 4, 10; 10, 124; 11, 199
];

S = zeros(q, H_rows / q);


for j = 1:(H_rows / q)
    S_j = zeros(q, 1);
    for idx = 1:size(alpha_index_table, 1)
        m = alpha_index_table(idx, 1); % Group index
        alpha = alpha_index_table(idx, 2); % Rotation value
        
        % Ensure indexing is valid
        if m + 1 > t
            error('Alpha-indexing error: m exceeds info_groups.');
        end
        
        % Apply right cyclic shift to the bits
        rotated_bits = circshift(info_groups(:, m + 1), -alpha); 
        S_j = mod(S_j + rotated_bits, 2);
    end
    S(:, j) = S_j;
end


P = zeros(q, H_rows / q);

% Compute parity bits 
for j = 1:(H_rows / q)
    if j == 1
        P(:, j) = S(:, j);
    else
        P(:, j) = mod(P(:, j - 1) + S(:, j), 2);
    end
end

parity_bits = P(:);

%Construct final codeword
codeword = [info_bits; parity_bits];



% Compare parity bits
disp('Custom QC Encoding Parity Bits (First 50):');
disp(parity_bits(1:50)');
