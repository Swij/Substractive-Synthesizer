import math
Fs = 40000
Q = 0.7071

a1 = []
a2 = []
b0 = []
b1 = []
b2 = []

for n in range(48):
    n = 9;
    #Frequency of note
    f = 2**((n-13)/12)*440
    w0 = 2*math.pi*f/Fs
    w0d = w0*180/math.pi
    sinout = math.sin(w0);
    alpha = math.sin(w0)/(2*Q)
    a0 = 1+alpha
    a1.insert(n ,(-2*math.cos(w0))/a0)
    a2.insert(n ,(1-alpha)/a0)
    b0.insert(n ,((1-math.cos(w0))/2)/a0)
    b1.insert(n ,(1-math.cos(w0))/a0)
    b2.insert(n ,((1-math.cos(w0))/2)/a0)
    print("{0}: \t{2:.4f},  \t{1:.4f}".format(n, sinout, w0d))

# print("signal a1 : regCoeffs := (")
# for n in range(132):
#     print("\"{0:.16f}\",".format(a1[n]))
# print(");")
#
# print("signal a1 : regCoeffs := (")
# for n in range(132):
#     print("\"{0:.16f}\",".format(a2[n]))
# print(");")
#
# print("signal a1 : regCoeffs := (")
# for n in range(132):
#     print("\"{0:.16f}\",".format(b0[n]))
# print(");")
#
# print("signal a1 : regCoeffs := (")
# for n in range(132):
#     print("\"{0:.16f}\",".format(b1[n]))
# print(");")
#
# print("signal a1 : regCoeffs := (")
# for n in range(132):
#     print("\"{0:.16f}\",".format(b2[n]))
# print(");")


#print("-- f0: {}, Q: {}, Fs: {}, w0: {}".format(f0, Q, Fs, (f0/Fs)))
#print("b0 <= to_sfixed({}, b0);".format(b0))
#print("b1 <= to_sfixed({}, b1);".format(b1))
#print("b2 <= to_sfixed({}, b2);".format(b2))
#print("a1 <= to_sfixed({}, a1);".format(a1))
#print("a2 <= to_sfixed({}, a2);".format(a2))
