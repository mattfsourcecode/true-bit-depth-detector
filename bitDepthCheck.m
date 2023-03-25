function [actualDepth conf bitEstimate, trulySmallestDiff, ampDiffs] = bitDepthCheck(fileName, ampThresh, minDur)

% actualDepth is the bit depth associated with the smallest nonzero amplitude change between neighboring samples that we found in the file.

% bitEstimate looks at the number of steps spanned by the signal, regardless of how small the amplitude change is between samples. This number of steps is reported in terms of the smallest nonzero amplitude change between neighboring samples. Once we know how many steps the signal spans, we can find the next lowest and highest actual bit depth steps and report a bit depth in between that is closest to our number of steps found. 

[x, R] = wavread(fileName);


ampDiffs = zeros(64, 1);

for i=1:64,

	ampDiffs(i) = 2/(2^i);

endfor


% here is where you'd run your findSilence function to find regions of the signal x where it's relatively silent. we're looking for noise floor here

% you'll need to pick an ampThresh, like -40dB maybe? and a numMillisec for the minimum duration of silence. I'd try 100 for that.
silences = silenceFunc(x, R, ampThresh, minDur);

% the silences array you get back should have the silence regions listed in SAMPLES, so it's easy to run through that and cehck each region

% check how many rows are in the silences array, and call that numSilences
[numSilences, numCol] = size(silences);

smallestDiffs = zeros(numSilences, 1);

printf("Found %i silences\n\n", numSilences);

for i=1:numSilences,

	startSamp = silences(i, 1);
	endSamp = silences(i, 2);
	
	%printf("silence region %i begins at sample %i and ends at %i\n\n", i, startSamp, endSamp);
	
	smallestDiffs(i) = ampDiffCheck( x(startSamp:endSamp) );

endfor

trulySmallestDiff = min(smallestDiffs);

% now, compare the smallest amplitude difference you found to all of the possible amp differences in ampDiffs.

differences = zeros(64, 1);

for i=1:64

	differences(i) = trulySmallestDiff - ampDiffs(i);

endfor

% the index of the ampDiff that was closest to trulySmallestDiff is also the bit depth
actualDepth = find( differences==min(abs(differences)) );

if actualDepth>1,
	conf = 1 - (abs(differences(actualDepth))/abs(differences(actualDepth-1)));
else
	conf = 0;
endif

%convert to percent
conf = conf*100;


% check the min and max sample values in x to determine the range (dynamic range)
minSamp = min(x);
maxSamp = max(x);

% what's the range of the actual signal
sigRange = maxSamp - minSamp;

% how many steps fit within that range?
stepsUsed = sigRange/trulySmallestDiff;

% starting with 1 bit, begin a while loop to find the first bit depth at which there are more steps than stepsUsed
i=1;
while 2^i < stepsUsed,

	i++;

endwhile

% at the end of the while loop, i is equal to the first bit depth with more steps than stepsUsed

% what's the difference in the number of steps for i bits vs (i-1) bits?
stepsRange = 2^i - 2^(i-1);

% how many more steps beyond (i-1) bits did we go?
stepsBeyond = stepsUsed - 2^(i-1);

% the best estimate of actual bit depth is (i-1) bits plus whatever fractional amount beyond (i-1) bits we went
bitEstimate = (i-1) + stepsBeyond/stepsRange;



endfunction
