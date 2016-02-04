import math

min_ = -57						# -57 == C0
max_ = 74 #- 12*3				#  74 == B10 ; 74 - 12*3 == B7
ref = 440.0 					# The reference is A4

nrOfIncBits = 22  				# Larger span gives better resolution
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
	samFactor = 10.0							# How fast the sampling is done
	samFreq = frequency * samFactor				# The sampling frequency..
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

	print("Notes: %i, Octaves = %i"%(len(allPeriodsIntMod2),len(allPeriodsIntMod2)/12))

	increment = []							# List of increments at every sampling point
	triAmp = 2**nrOfIncBits-1				# Amplitude with extra bits

	for i in range(len(allPeriodsIntMod2)):
		
		Fs_tri1 = allSampleFreqInt[i]		# Sampling frequency for the triangle
		increase = int(triAmp/Fs_tri1)
		increment.append(increase)

		if detail == 0:

			print(allNames[i] + " = %f Hz, integer period = %i"%
				(allFrequenciesFloat[i],allPeriodsIntMod2[i]))

			print(("Fs period = %i\tIncrease = %i")%(Fs_tri1,increase))
			print("Total triAmp1 = %i"%(increase*Fs_tri1))
			print("Shifted amp = %i\n"%(int(increase*Fs_tri1)>>10))

	if detail == 1:

		print("All the notes periods in integers where mod4 == 0\n")
		print(allPeriodsIntMod4)

		print("\n\nAll the periods for their respective sampling frequencies\n")
		print(allSampleFreqInt)

		print("\n\nThe incrementation at every sampling point\n")
		print(increment)


#def lfoWaves( ):

#def printOutErrors( ):
	
def main( ):

	geometricWaves(0)		# 0 = Detailed list, 1 = list form
	#lfoWaves( )
	#printOutErrors( )


if __name__ == "__main__":
	main()


	################################################################################

	# Fsout = 150000.0
	# T = 1.0 / Fsout
	# clksFs = T / Ts

	# print("Period in INT, increment in INT and step in INT")
	# print("fs = %f, T = %f, clksFs = %f"%(Fsout,T,clksFs))

		# Fs_tri1 = allSampleFreqInt[i]
		# Fs_tri2 = Fs_tri1

		# safetyFirst = 0
		# fail = ""

		# while((allPeriodsIntMod4[i]/2 % Fs_tri1 != 0) and safetyFirst < 20000):

		# 	Fs_tri1 += 1
		# 	safetyFirst += 1

		# increase = triAmp/Fs_tri1
		# increase2 = triAmp/Fs_tri2

		# if(safetyFirst >= 9999):
		# 	fail = "FAIL"
		# else:
		# 	fail = " "

		# print(allNames[i] + " = %f Hz, integer period = %i"%(allFrequenciesFloat[i],allPeriodsIntMod2[i]))
		# print(("Fs period1 (original) = %i\tIncrease1 = %i\tFs period2 = %i\tIncrease2 = %i %s")%(Fs_tri1,increase,Fs_tri2,increase2,fail))
		# print("Total triAmp1 = %i\tTotal triAmp2 = %i"%(increase*Fs_tri1,increase2*Fs_tri2))
		# print("Shifted amp = %i\n"%(int(increase2*Fs_tri2)>>10))

		################################################################################

		# Ftri = allFrequenciesFloat[i]*OSR
		# Fdiffer = Fsout / Ftri
		# #print("Int / Minsamp = %f / %f = %f"%(Fsout,Ftri,Ftri))

		# print(allNames[i] + " = %f Hz"%(allFrequenciesFloat[i]))


		# step = allPeriodsIntMod2[i] / Ftri
		# print("Increase = Int / (2*fs) = %i / %f = %f"%(allPeriodsIntMod2[i],Ftri,step))


		# intDiv4096 = allPeriodsIntMod2[i] / 2.0 / 2047.0
		# print("Int / 2047 = %f\n"%(intDiv4096))

		#nrOfSteps.append(allPeriodsIntMod2[i]/clksFs)
		#increment.append(4096/1)

	#print(allSampleFreqInt)
	#print(allPeriodsIntMod2)
	

	# print(allPeriodsIntMod4)
	# #print(nrOfSteps)
	