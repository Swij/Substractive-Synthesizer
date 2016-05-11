library IEEE;
library ieee_proposed;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee_proposed.fixed_float_types.all;
use ieee_proposed.fixed_pkg.all;

ENTITY AllPass IS
		-- Delay time in ms
	PORT(
		Sample	: in STD_LOGIC_VECTOR(11 DOWNTO 0);
		Delay	: in INTEGER RANGE 2000 to 0;				-- Echo Delay in ms, <2s
		Gain	: in ufixed(3 DOWNTO -3);					-- Gain of the Echo, atm 1/8 up to 7/8
		clk		: in STD_LOGIC;
		Reset	: in STD_LOGIC;
		
		Output	: Out STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
END AllPass;

ARCHITECTURE AllPass_Arch OF AllPass IS 
	
	TYPE RAM_type IS array (0 to 79999) of STD_LOGIC_VECTOR(11 DOWNTO 0); -- Array type, 80k samples gives a time space of 2s
	SIGNAL CircBuffer : RAM_type := (OTHERS =>(OTHERS=>'0'));			  -- Declare Circular buffer, initialize to zeroes	
	SIGNAL Counter : INTEGER RANGE 79999 to 0:= 0;
	SIGNAL DelayOffset : INTEGER Range 79999 to 0;
	SIGNAL OutBuff : STD_LOGIC_VECTOR(14 DOWNTO 0);
	--SIGNAL Gain : ufixed(0 DOWNTO -12);
	
BEGIN
	DelayOffset <= Delay*40;											  -- Number of steps back in the buffer for x ms delay
Process(clk)
	IF (Reset = '1') THEN												  -- Standard Reset
		CircBuffer <= (OTHERS=>(OTHERS=>'0'));
		Counter <= 0;
		
	ELSIF RISING_EDGE(clk) THEN
		CircBuffer(Counter) <= Sample;									  -- Save Data in to circBuffer
		
		IF (DelayOffset > Counter) THEN									  -- Wrap around for counter
			OutBuff <= CircBuffer(79999-(DelayOffset-Counter));
		ELSE
			OutBuff <= CircBuffer(Counter-DelayOffset);					  -- Load sound from previous Sample (Delay)
		END IF;
		OutBuff <= Shift_right(OutBuff * shift_left(Gain, 3),3);		  -- Multiply with gain
		Output <= OutBuff(11 DOWNTO 0);

		Counter <= Counter + 1;

END PROCESS;
		