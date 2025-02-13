function [parity_bits, codeword] = ira_encoder_simple(info_bits, M, q, n, k, base_matrix)

    % Step 1: Initialize S values
    S = zeros(1, q * M); % S vector to store intermediate values

    % Step 2: Compute S values using the formula
    for r = 1:q
        for j = 1:k/M
            % Extract the coefficient from the base matrix
            a_rj = base_matrix(r, j);

            % Compute the index of the information bits
            info_index = (j-1)*M + 1 : j*M;

            % Extract the corresponding information bits
            info_segment = info_bits(info_index);

            % Compute S_r using the formula
            S((r-1)*M + 1 : r*M) = mod(S((r-1)*M + 1 : r*M) + a_rj * info_segment, 2);
        end
    end

    % Step 3: Compute parity bits recursively
    parity_bits = zeros(1, n-k); % Initialize parity bits

    % Compute the first parity bit
    parity_bits(1) = S(1);

    % Compute the remaining parity bits
    for r = 2:(n-k)
        if r <= length(S)
            parity_bits(r) = mod(parity_bits(r-1) + S(r), 2);
        else
            % If S(r) is out of bounds, continue with the previous parity bit
            parity_bits(r) = parity_bits(r-1);
        end
    end

    % Step 4: Form the complete codeword
    codeword = [info_bits, parity_bits];
end
