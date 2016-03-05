midiToFrequencyHEAD = """
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

PACKAGE geometricWaves IS

FUNCTION midi2Frequency (input : STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR;

END geometricWaves;

PACKAGE BODY geometricWaves IS

    FUNCTION midi2Frequency (input : STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR IS
    BEGIN
                  
        IF input = "0000" THEN
            RETURN "11000000;"

        ELSIF input = "0001" THEN
            RETURN "11111001";"
        
        ELSE RETURN "00000000";
      
        ELSE RETURN "11111110";
            
        END IF;

    END midi2Frequency;
    
END geometricWaves;
"""

geoMetricHead = """
\\begin{longtable}{|c|c|c|c|c|c|c|c|}
\\caption{A simple longtable assome.\\label{long}}\\\\\\
\\hline
\\textbf{Tone} & \\textbf{f(original)} & \\textbf{f(mod1)} & \\textbf{f(mod2)} & \\textbf{f(mod4)} & \\textbf{Error 1} & \\textbf{Error 2} & \\textbf{Error 4}\\\\
\\hline
\\endfirsthead
\\multicolumn{8}{c}%
{\\tablename\\ \\thetable\ -- \\textit{Continued from previous page}} \\\\
\\hline
\\textbf{Tone} & \\textbf{f(original)} & \\textbf{f(mod1)} & \\textbf{f(mod2)} & \\textbf{f(mod4)} & \\textbf{Error 1} & \\textbf{Error 2} & \\textbf{Error 4}\\\\
\\hline
\\endhead
\\hline \\multicolumn{8}{r}{\\textit{Continued on next page}} \\\\
\\endfoot
\\hline
\\endlastfoot
""" 

geoMetricTail = """ 
\end{longtable}

"""