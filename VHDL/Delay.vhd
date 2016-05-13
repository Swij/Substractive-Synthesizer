library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


ENTITY Delay IS
		-- Delay time in ms
	PORT(
		Sample	: in STD_LOGIC_VECTOR(11 DOWNTO 0);
		Delay	: in INTEGER RANGE 0 to 2000;				-- Echo Delay in ms, <2s
		Gain	: in INTEGER Range 0 to 7;				-- Gain of the Echo, 0/8 to 7/8
		clk		: in STD_LOGIC;
		Reset	: in STD_LOGIC;
		
		Output	: Out STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
END Delay;

ARCHITECTURE Delay_Arch OF Delay IS 
	
	TYPE RAM_type IS array (0 to 79999) of STD_LOGIC_VECTOR(11 DOWNTO 0); -- Array type, 80k samples gives a time space of 2s
	SIGNAL CircBuffer : RAM_type := (OTHERS =>(OTHERS=>'0'));			  -- Declare Circular buffer, initialize to zeroes	
	SIGNAL Counter : INTEGER RANGE 0 to 79999:= 0;
	SIGNAL DelayOffset : INTEGER Range 0 to 79999;
	SIGNAL OutBuff : STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL OutBuffInt : INTEGER RANGE  -2048 to 2047;
	SIGNAL Outvect : STD_LOGIC_VECTOR(14 DOWNTO 0);
	
BEGIN
	DelayOffset <= Delay*40;											  -- Number of steps back in the buffer for x ms delay
Process(clk)
    BEGIN
	IF (Reset = '1') THEN												  -- Standard Reset
		CircBuffer <= (OTHERS=>(OTHERS=>'0'));
		Counter <= 0;
		
	ELSIF RISING_EDGE(clk) THEN
		CircBuffer(Counter) <= Sample;									  -- Save Data in to circBuffer
		
		IF (DelayOffset > Counter) THEN									  -- Wrap around for counter
			OutBuff(11 DOWNTO 0) <= CircBuffer(79999-(DelayOffset-Counter));
		ELSE
			OutBuff(11 DOWNTO 0) <= CircBuffer(Counter-DelayOffset);					  -- Load sound from previous Sample (Delay)
		END IF;
		OutBuffInt <= (To_integer(Signed(OutBuff)) * Gain);					  -- Multiply with gain
		Outvect <= std_logic_vector(OutBuffInt);
        	Output <= Outvect(14 DOWNTO 3);
		IF (Counter = 79999) THEN 
			Counter <= 0;
		ELSE
		Counter <= Counter + 1;
		END IF;
    END IF;
END PROCESS;
END ARCHITECTURE;		