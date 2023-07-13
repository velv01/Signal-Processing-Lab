function output = overlapSave(input, impulseResponse, blockLength)
    % Pad the impulse response with zeros to match the block length
    impulseResponse = [impulseResponse; zeros(blockLength - length(impulseResponse), 1)];
    
    % Calculate the length of the input signal
    inputLength = length(input);
    
    % Calculate the length of the impulse response
    responseLength = length(impulseResponse);
    
    % Calculate the overlap length
    overlapLength = responseLength - 1;
    
    % Calculate the block hop size
    hopSize = blockLength - overlapLength;
    
    % Calculate the number of blocks
    numBlocks = ceil(inputLength / hopSize);
    
    % Pad the input signal with zeros to have integer number of blocks
    input = [zeros(responseLength - 1, 1); input; zeros(numBlocks * hopSize - inputLength, 1)];
    
    % Initialize the output signal
    output = zeros(numBlocks * hopSize, 1);
    
    % Perform overlap-save processing block by block
    for i = 1:numBlocks
        % Extract the current block from the input signal
        block = input((i-1)*hopSize + 1 : (i-1)*hopSize + blockLength);
        
        % Perform circular convolution
        convResult = ifft(fft(block, blockLength) .* fft(impulseResponse, blockLength));
        
        % Save the overlap portion of the current block
        if i > 1
            output((i-1)*hopSize + 1 : (i-1)*hopSize + overlapLength) = convResult(1:overlapLength) + output((i-1)*hopSize + 1 : (i-1)*hopSize + overlapLength);
        end
        
        % Save the non-overlap portion of the current block
        output((i-1)*hopSize + overlapLength + 1 : i*hopSize) = convResult(overlapLength + 1:end);
    end
    
    % Trim the output signal to the original length
    output = output(1:inputLength);
end
