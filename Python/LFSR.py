# Fibonacci LFSR
def LFSR_fibonacci(seed, taps):
    regs = seed
    runs = 0
    while 1:
        # To do XOR on all taps it Adds all tap bits together
        # and does mod 2 on them to get the result
        tapsum = 0
        for tap in taps:
            tapsum += regs[tap-1]
        nextin = tapsum % 2

        # Shifts the register to the right and inserts the result of the taps
        regs = [nextin]+regs[:-1]
        runs += 1

        # Aborts the run when the cycle repeats itself
        if regs == seed:
            break

    # Prints how many cycles the tap combination gave
    print(len(seed), runs, taps)

# Runs several examples of LFSRS
print("#b","Runs","Taps")
LFSR_fibonacci([1,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0], [16,14,13,11]);
LFSR_fibonacci([1,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0], [16,5,3,2]);
LFSR_fibonacci([1,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0], [16,15,13,4]);
LFSR_fibonacci([1,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0], [16,12,3,1]);
LFSR_fibonacci([1,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0], [16,15,3,1]);
LFSR_fibonacci([1,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0], [16,10]);
LFSR_fibonacci([1,0,0,0, 0,0,0,0, 0,0,0,0], [12,11,10,4]);
