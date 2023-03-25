function smallestAmp = ampDiffCheck(x)

lenX = length(x);

smallestAmp = 999;

for i=2:lenX,

	diff = abs(x(i) - x(i-1));

	% ignore amplitude differences of 0 since they tell us nothing	
	if diff==0,
		diff = 999;
	endif
	
	if diff < smallestAmp,
		smallestAmp = diff;
	endif
	
endfor