function silences = silenceFunc(x, R, ampThresh, numMillisec);

x = x(:,1);

lenX = length(x);

N = 1024;

durationThreshInWindows = round(((numMillisec/1000) * R)/N);

numWindows = floor(lenX/N);

ampThresh = myDb2rms(ampThresh);
disp(ampThresh);

measurements = zeros(numWindows, 1);
peakMeasurements = zeros(numWindows, 1);

flag = 0;
winCount = 0;
silences = [];

silenceStartSamp = -1;

for i=1:numWindows,

	startSamp = (i-1) * N + 1;
	endSamp = startSamp + (N-1);

	measurements(i) = rmsAmp( x(startSamp:endSamp) );
	
	currentAmp=measurements(i);
	
	%printf("Window %i amp: %f. Flag: %i. winCount: %i\n", i, currentAmp, flag, winCount);	
	
	
	if currentAmp < ampThresh && flag==0,
		%disp("HIT");

		flag=1;
		silenceStartSamp = startSamp;
		winCount = winCount + 1;
		
	elseif currentAmp < ampThresh && flag==1,
		%disp("INCREASE");

		if i==numWindows && winCount > durationThreshInWindows,
			% this is a special case for the end of the file, in case it never goes back above the amp thresh before the file is over
			silences=[silences; silenceStartSamp endSamp];

			flag = 0;
			winCount=0;
		else
			winCount=winCount + 1;
		endif
				
	elseif currentAmp >= ampThresh && flag==1,

		if winCount > durationThreshInWindows,
			silences=[silences; silenceStartSamp endSamp];
		endif
		
		flag = 0;
		winCount=0;
	
	endif
	
endfor
