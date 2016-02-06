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