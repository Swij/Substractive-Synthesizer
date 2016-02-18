import math
import stringIncludes as strings

min_ = -57						# -57 == C0
max_ = 74 #- 12*3				#  74 == B10 ; 74 - 12*3 == B7
ref = 440.0 					# The reference is A4

nrOfIncBits = 18  				# Larger span gives better resolution
								# 	although 10 bits will be truncated
								#	for a 12 bit resolution

clk = 200000000.0 				# Hz of the FPGA
Ts = 1.0 / clk 					# Period of that clk

notes = ["C", "C♯/D♭", "D", "E♭/D♯", "E", "F", "F♯/G♭", "G", "A♭/G♯", "A", "B♭/A♯", "B"]
allNames = []

allFrequenciesFloat = []		# All frequencies in float format

allPeriodsFloat = []			# All periods (nr of clk cycles) as floats
allPeriodsInt = []				# ... then rounded of
allPeriodsIntMod2 = []			# ... both to even
allPeriodsIntMod4 = []			# ... and "even-even"

allSampleFreqFloat = []			# The sampling frequencies of them all
allSampleFreqInt = []			# Also has a period as an integer

################################################################################
##  Generate all names
##  Results like: "A♭/G♯7"
################################################################################
nameCnt = 0
octCnt = 0
for n in range(min_,max_+1):
	
	allNames.append(notes[nameCnt] + str(octCnt))
	
	nameCnt += 1
	if nameCnt == 12:
		nameCnt = 0
		octCnt += 1

#print(allNames) # Check!

################################################################################
##  Calculate all frequencies in octave 0 to 10
##	  and calculate the integer period
##	  and round to closest mod2==0 integer, required for "perfect" square
##	  and sampling frequency in integers
################################################################################
for n in range(min_,max_+1):

	frequency = ref * 2.0**(n/12.0)				# The frequency of a note
	allFrequenciesFloat.append(frequency)		# Save that frequency
	T = 1.0 / frequency							# Also save its period
 
	nrOfClks = T / Ts 							# How many clocks is in that period
												# where Ts = 1.0 / 2MHz
	allPeriodsFloat.append(nrOfClks)			# Saving all clocks

	roundedClks = int(round(nrOfClks)) 			# We want them floats
	allPeriodsInt.append(roundedClks)			# 	and as integers

	#  All the tones periods in int, where mod2 = 0
	#  It will round to the closest
	if not roundedClks % 2 == 0:

		diff = nrOfClks - roundedClks
		if diff < 0:
			roundedClks = int(math.floor(nrOfClks))
		else:
			roundedClks = int(math.ceil(nrOfClks))

	allPeriodsIntMod2.append(roundedClks)

	#  All the tones periods in int, where mod4 = 0
	#  It will round to the closest +- 2
	modFour = roundedClks % 4
	if modFour == 0:
		allPeriodsIntMod4.append(roundedClks)
	else:
		if modFour <= 2:
			allPeriodsIntMod4.append(roundedClks - modFour)
		else:
			allPeriodsIntMod4.append(roundedClks + modFour)

	# Sampling frequency period in int
	samFactor = 32.0							# How fast the sampling is done
	samFreq = frequency * (samFactor)				# The sampling frequency..
	samT = 1.0 / samFreq 						# 	and its period
	nrOfClks = samT / Ts 						# How many clocks is in that period
	allSampleFreqFloat.append(nrOfClks)
	roundedClks = int(round(nrOfClks)) 			# We want them floats
	allSampleFreqInt.append(roundedClks)		# 	and as integers

#print(allFrequenciesFloat) # Check!
#print(allPeriodsFloat) #
#print(allPeriodsInt) # 
#print("allPeriodsIntMod2:") # 
#print(allPeriodsIntMod2) # 
#print("NrOfints = %i"%(len(allPeriodsIntMod2)))

################################################################################
##  Sample a triangle, square and saw at the same time
################################################################################
def geometricWaves(detail):

	print("\n\nGenerating geometric waves......................................................\n\n")

	# Needed in LUT

	# 1) period integer
	# 2) the fs
	# 3) the increment

	# Triangle counts up half period then down, starts at zero
	# Square follows the triangle and shifts (+-) at a set counter value
	# Saw 1 and 2 counts different directions and have different starting values

	# 4) Clock start

	print("Notes: %i, Octaves = %i"%(len(allPeriodsIntMod2),len(allPeriodsIntMod2)/12))

	increment = []							# List of increments at every sampling point
	triAmp = 2**(nrOfIncBits)				# Amplitude with extra bits
	sampPoints = 32.0
	increase = int(triAmp/(sampPoints-1))
	incRest = triAmp % increase

	for i in range(len(allPeriodsIntMod2)):
		
		#Fs_tri1 = allSampleFreqInt[i]		# Sampling frequency for the triangle
		

		if detail == 0:

			print(allNames[i] + " = %f Hz, integer period = %i"%
				(allFrequenciesFloat[i],allPeriodsIntMod2[i]))

			#print(("Fs period = %i\tIncrease = %i")%(Fs_tri1,increase))
			#print("Total triAmp1 = %i"%(increase*Fs_tri1))
			#print("Shifted amp = %i\n"%(int(increase*Fs_tri1)>>10))

	if detail == 1:

		print(len(allPeriodsIntMod4))
		print("All the notes periods in integers where mod4 == 0\n")
		print(allPeriodsIntMod4)
		print(len(allPeriodsIntMod4))

		print("\n\nAll the periods for their respective sampling frequencies\n")
		print(allSampleFreqInt)

		print("\n\nThe incrementation at every sampling point\n")
		#print(increase)

	increase2 = (2**(nrOfIncBits-1)-1)/8
	increase2mod = 2**(nrOfIncBits-1)%8
	print("Triangle increase = %i, rest of = %i"%(increase2,increase2mod))
	print("Saw increase = %i, rest of = %i"%(increase,incRest))


	totalSim = 0
	for i in range(len(allPeriodsIntMod4)):
		totalSim += allPeriodsIntMod4[i]
	ns = totalSim * Ts
	print("Total clocks in the simulation = %i = %ss"%(totalSim,ns))
	print(Ts)




################################################################################
##  LFO - Here we go!
################################################################################
def lfoWaves( ):

	triAmp = 2**nrOfIncBits-1				# Amplitude with extra bits

	lfoPeriods = []
	lfoSamplingFrequency = []
	lfoIncrement = []

	lfoFsFactor = 1000.0

	# Step up with scientific pitches...
	lfoMIN = -145
	lfoMAX = -53

	# Step up with +0.1
	r = 0.1
	fs = 100.0

	while r <= 20.0:

		fs = r * lfoFsFactor
		ts = 1.0 / fs

		T = 1.0 / r									# Also save its period
		
		nrOfClks = T / Ts 							# How many clocks is in that period
		roundedClks = int(round(nrOfClks)) 			# We want them floats as integers
		
		nrOfSampClks = ts / Ts 						# How many clocks is in that period
		roundedSampClks = int(round(nrOfSampClks)) 	# We want them floats as integers
	
		if not roundedClks % 2 == 0:

			diff = nrOfClks - roundedClks
			if diff < 0:
				roundedClks = int(math.floor(nrOfClks))
			else:
				roundedClks = int(math.ceil(nrOfClks))


		increase = int(triAmp / fs)

		lfoPeriods.append(roundedClks)
		lfoSamplingFrequency.append(roundedSampClks)
		lfoIncrement.append(increase)

		r += 0.1

	print("LFO periods\n")
	print(lfoPeriods)

	print("\n\nLFO sampling frequencies periods\n")
	print(lfoSamplingFrequency)

	print("\n\nLFO incrementation at every sampling point\n")
	print(lfoIncrement)

	print("\n\nPeriods rewritten:\n")

	highestMods = []
	denumerators = []

	for i in range(len(lfoPeriods)):

		highMod = 1

		for j in range(2,1000):

			if lfoPeriods[i] % j == 0:
				highMod = j

		highestMods.append(highMod)
		denumerators.append(int(lfoPeriods[i]/highMod))

	
	for i in range(len(lfoPeriods)):

		print("%i = %i * %i"%(lfoPeriods[i],highestMods[i],denumerators[i]))


def printMIDI( ):

	# The first data is the note number. There are 128 possible notes on a MIDI device, 
	# numbered 0 to 127 (where Middle C is note number 60). This indicates which note 
	# should be released.

	# MIDI uses octave -1: nope, fuck that shit, offsetting to get rid of it
	# Thus: C(-1) to G9, 4 last (highest) notes in octave 9 is missing
	# (C-1) = 9.72271 Hz
	# G9    = 12543.9 Hz

	print("\n\nHere is MIDI-codes with its respective note\n")

	offset = 12
	for i in range(116):

		print("MIDI: %i\t TONE: %s"%(offset,allNames[i]))

		offset += 1

#def printOutErrorsAndMaybeLaTeXToo( ):

#def generateVHDL( ):
	
def main( ):

	geometricWaves(1)		# 0 = Detailed list, 1 = list form
	#lfoWaves( )
	#printMIDI( )
	#printOutErrors( )
	#print(strings.cp)

if __name__ == "__main__":
	main( )
