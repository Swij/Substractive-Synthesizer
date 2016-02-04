import math



min_ = -57
max_ = 74 - 12*3
ref = 440.0 
nrOfBits = 12  # ADC/DAC
nrOfIncBits = 22  # ADC/DAC
amp = 2**(nrOfBits)/2

clk = 200000000.0 #Hz
Ts = 1.0/clk

notes = ["C", "C♯/D♭", "D", "E♭/D♯", "E", "F", "F♯/G♭", "G", "A♭/G♯", "A", "B♭/A♯", "B"]

allNames = []
allFrequenciesFloat = []
allPeriodsFloat = []
allPeriodsInt = []
allPeriodsIntMod2 = []

################################################################################
##  Generate all names
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
################################################################################
for n in range(min_,max_+1):

	frequency = ref*2.0**(n/12.0)
	allFrequenciesFloat.append(frequency)
	T = 1 / frequency

	nrOfClks = T / Ts
	allPeriodsFloat.append(nrOfClks)

	roundedClks = int(round(nrOfClks))
	allPeriodsInt.append(roundedClks)
	
	if not roundedClks % 2 == 0:

		diff = nrOfClks - roundedClks
		if diff < 0:
			roundedClks = int(math.floor(nrOfClks))
		else:
			roundedClks = int(math.ceil(nrOfClks))

	allPeriodsIntMod2.append(roundedClks)

# print(allFrequenciesFloat) # Check!
# print(allPeriodsFloat) #
# print(allPeriodsInt) # 
#print("allPeriodsIntMod2:") # 
#print(allPeriodsIntMod2) # 
# print("NrOfints = %i"%(len(allPeriodsIntMod2)))

################################################################################
##  Sample a sine wave
################################################################################
def sine_wave(frequency=3200.0, framerate=10000, amplitude=1.0, positive=True):
#def sine_wave(frequency=440.0, framerate=44100, amplitude=1.0):

# 1 Hz = 2π rad/s = 6.2831853 rad/s
# or
# 1 rad/s = 1/2π Hz = 0.1591549 Hz


	sineSamples = []
	period = int(framerate / frequency)

	for i in range(framerate):

		sample = float(amplitude)*math.sin(2.0*math.pi*float(frequency)*float(i)/float(framerate))
		if positive:
			sample += 1.0
		sineSamples.append(sample)
		#print(sample)

	#print(sineSamples)		#  Check!

def sampleTriangleWave( ):

	# Tint / Fs 	should end upp in an int
	# 


	Fsout = 150000.0
	T = 1.0 / Fsout
	clksFs = T / Ts

	print("Generating triangle wave")
	print("Period in INT, increment in INT and step in INT")
	print("fs = %f, T = %f, clksFs = %f"%(Fsout,T,clksFs))

	nrOfSteps = []
	increment = []
	OSR = 3.0
	triAmp = 2**nrOfIncBits-1

	print("STEPS")

	for i in range(len(allPeriodsIntMod2)):
		

		# Find a sample frequency that is divisible by both
		# the period in integer and 

		# Increase = MAX / Fs
		# Therefore the Fs should be a multiple of i.e 4095
		# But the increase the risks of being a float, so we could have a 
		# wider bit length with the last bits representing "decimals"

		# Needed in LUT

		# 1) period integer
		# 2) the fs
		# 3) the increment

		# Sampling frequency for the triangle
		Fs_tri = int(round(OSR * allFrequenciesFloat[i]))

		safetyFirst = 0

		while((allPeriodsIntMod2[i]/2 % Fs_tri != 0) and safetyFirst < 10000):

			Fs_tri += 1
			safetyFirst += 1

			if(safetyFirst == 9999):
				print("CHRACH BOOOOM BAAANG!")

		increase = triAmp/Fs_tri

		print(allNames[i] + " = %f Hz"%(allFrequenciesFloat[i]))
		print("Fs period = %i, Increase = %i"%(Fs_tri,increase))
		print("Total triAmp = %i"%(increase*Fs_tri))


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


	#print(nrOfSteps)
	print(allPeriodsIntMod2)

def main( ):
    
	#sine_wave()
	sampleTriangleWave()

if __name__ == "__main__":
    main()
