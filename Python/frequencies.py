#	fn = f0 * (a)n 
#	where
#	f0 = the frequency of one fixed note which must be defined. 
#	A common choice is setting the A above middle C (A4) at f0 = 440 Hz.
#	n = the number of half steps away from the fixed note you are. 
#	If you are at a higher note, n is positive. 
#   If you are on a lower note, n is negative.
#	fn = the frequency of the note n half steps away.
#	a = (2)^1/12 = the twelth root of 2 = the number which when multiplied by itself 12 times equals 2 = 1.059463094359... 

import math

fs = 200000000.0 #Hz
Ts = 1.0/fs

c = 440.0*(2.0**(1.0/12.0))**-57
octaves = 11
notes = ["C", "C♯/D♭", "D", "E♭/D♯", "E", "F", "F♯/G♭", "G", "A♭/G♯", "A", "B♭/A♯", "B"]


lists = []
rounds = []

for n in range(len(notes)):

	temp = []
	temp2 = []
	for i in range(octaves):
		#print(440.0*(2.0**(1.0/12.0))**(-57+n)*(2**i))
		temp2.append(float("{0:.2f}".format(440.0*(2.0**(1.0/12.0))**(-57+n)*(2**i))))
		temp.append(440.0*(2.0**(1.0/12.0))**(-57+n)*(2**i))
	lists.append(temp)
	rounds.append(temp2)
	#print("\n")


print("Frequencies for all tones:")
for n in range(len(notes)):
	print(notes[n])
	print(lists[n])
	print("\n")


# print("Error in seconds when using 200MHz")
# print("Ts = %f" % Ts)
# for n in range(len(notes)):
# 	for i in range(octaves):
# 		Tn = 1/lists[n][i]
# 		error = Tn % Ts
# 		print(error)


print("Table for using 200MHz")
for n in range(len(notes)):
	print("Note: " + notes[n])
	print("Octave \tFrequency \tNEW Frequency \tClock-Dec \tClock-Int \tError")
	#	For all octaves
	#for i in range(octaves):
	#	For octaves 1 to 6
	for i in range(1,7):
		Tn = 1/lists[n][i]
		clk_err = Tn / Ts
		clk_err2 = int(Tn / Ts)
		clk_err2 = math.ceil(clk_err2 / 2.) * 2
		newF = 1.0/(clk_err2*Ts)
		totErr = (lists[n][i]-newF)/lists[n][i]
		print("%i \t%f \t%f \t%f \t%i \t\t%f" % (i,lists[n][i],newF,clk_err,clk_err2,totErr))
	print("\n")


print("\n\n\nAdjusting so mod 4 = 0")
totFreq = 0.0
for n in range(len(notes)):
	print("Note: " + notes[n])
	print("Octave \tFrequency \tNEW Frequency \tClock-Dec \tClock-Int \tError")
	#	For all octaves
	#for i in range(octaves):
	#	For octaves 1 to 6
	for i in range(1,7):
		Tn = 1/lists[n][i]
		clk_err = Tn / Ts
		clk_err2 = int(Tn / Ts)
		clk_err2 = math.ceil(clk_err2 / 2.) * 2
		clk_err2 += clk_err2 % 4
		newF = 1.0/(clk_err2*Ts)
		totErr = (lists[n][i]-newF)/lists[n][i]
		print("%i \t%f \t%f \t%f \t%i \t\t%f" % (i,lists[n][i],newF,clk_err,clk_err2,totErr))
		if i == 6:
			totFreq += newF
	print("\n")
print("Total frequency: %f" %(totFreq))
print("2x: %f bytes: %f" %(totFreq*2,totFreq*2*12/8))
print("Only 1/4 used gives #bytes: %f" %(totFreq*2*12/8/4))



def genIntForPeriods( ):

	print("All int:s printed")
	stri = ""
	for n in range(len(notes)):
		#	For all octaves
		#for i in range(octaves):
		#	For octaves 1 to 6
		for i in range(1,7):
			Tn = 1/lists[n][i]
			clk_err2 = int(Tn / Ts)
			clk_err2 = math.ceil(clk_err2 / 2.) * 2
			stri += (str(clk_err2) + " ")
			print(clk_err2)
	print(stri)
	print(len(stri))

# print("All int:s sorted")
# sortList = []
# for n in range(len(notes)):
# 	#	For all octaves
# 	#for i in range(octaves):
# 	#	For octaves 1 to 6
# 	for i in range(1,7):
# 		Tn = 1/lists[n][i]
# 		clk_err2 = int(Tn / Ts)
# 		clk_err2 = math.ceil(clk_err2 / 2.) * 2
# 		sortList.append(clk_err2)

# sortList = sorted(sortList)

# for n in range(len(sortList)):
# 	print(sortList[n])

# print("Increment between sorted")
# avg = 0.0
# for n in range(len(sortList)):
# 	if not n == (len(sortList)-1):
# 		a = float((sortList[n+1]-sortList[n])/sortList[n])
# 		avg += a
# 		print(a)

# print("Average")
# avg = avg/len(sortList)
# print(avg)





