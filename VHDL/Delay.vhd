library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


ENTITY Delay IS
		-- Delay time in ms
	PORT(	clk		: in STD_LOGIC;
		reset	: in STD_LOGIC;
		--clk_enable:in STD_LOGIC;
		Sample	: in STD_LOGIC_VECTOR(11 DOWNTO 0);
		Delay_time	: in INTEGER RANGE 0 to 1999;				-- Echo Delay in ms, <2s
		Gain	: in STD_LOGIC_VECTOR(11 DOWNTO 0);				-- Gain of the Echo, 0/8 to 7/8
		Output	: Out STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
END Delay;

ARCHITECTURE Delay_Arch OF Delay IS 
	
	TYPE RAM_type IS array (0 to 79999) of STD_LOGIC_VECTOR(11 DOWNTO 0); -- Array type, 80k samples gives a time space of 2s
	SIGNAL CircBuffer : RAM_type := (OTHERS =>(OTHERS=>'0'));			  -- Declare Circular buffer, initialize to zeroes	
	SIGNAL Counter : INTEGER RANGE 0 to 79999:= 0;
	SIGNAL DelayOffset : INTEGER Range 0 to 79999;
	SIGNAL OutBuff : STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL OutBuffInt : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL Outvect : STD_LOGIC_VECTOR(11 DOWNTO 0);
	
BEGIN

Process(clk)
    BEGIN
	IF (Reset = '0') THEN												  -- Standard Reset
		CircBuffer <= (OTHERS=>(OTHERS=>'0'));
		Counter <= 0;
		
	ELSIF (RISING_EDGE(clk)) THEN
		CircBuffer(Counter) <= Sample;	                                  -- Save Data in to circBuffer
		DelayOffset <= Delay_time*40;									  -- Number of steps back in the buffer for x ms delay								
		
		IF (DelayOffset > Counter) THEN									  -- Wrap around for counter
			OutBuff(11 DOWNTO 0) <= CircBuffer(79999-(DelayOffset-Counter));
		ELSE
			OutBuff(11 DOWNTO 0) <= CircBuffer(Counter-DelayOffset);					  -- Load sound from previous Sample (Delay)
		END IF;
		OutBuffInt <= STD_LOGIC_VECTOR(SIGNED(OutBuff) * SIGNED(Gain));					  -- Multiply with gain
		Outvect <= STD_LOGIC_VECTOR(SIGNED(Sample) + SIGNED(OutBuffInt(23 downto 12)));
        --Output <= OutBuffInt(23 DOWNTO 12);
		Output <= Outvect;
		IF (Counter = 79999) THEN 
			Counter <= 0;
		ELSE
		    Counter <= Counter + 1;
		END IF;
    END IF;
END PROCESS;
END ARCHITECTURE;		
