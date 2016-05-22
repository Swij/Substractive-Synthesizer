library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
-- Scales the clock to the desired frequency. Generic to system clock and output frequency
ENTITY ClockEnable IS
	GENERIC(DesiredFreq : INTEGER := 31250;
			ClockFreq : INTEGER := 200000000);
	PORT(
		ClockIn 	: IN STD_LOGIC;
		Reset		: IN STD_LOGIC;
		ClockOut	: OUT STD_LOGIC
	);
END ENTITY;

ARCHITECTURE ClockEnable_ARCH of ClockEnable IS

	SIGNAL Counter : INTEGER := 0;
	SIGNAL CounterMax : INTEGER;
	SIGNAL ClockInt : STD_LOGIC := '0';
	
BEGIN
	CounterMax <= ClockFreq/(2*DesiredFreq);			-- Calculate ratio for current to desired frequency
	ClockOut <= ClockInt;								-- Connect internal clock signal to output

	PROCESS(ClockIn, Reset)
	BEGIN
		IF (Reset = '0') THEN							-- Async reset
			Counter <= 0;
			ClockInt <= '0';

		ELSIF Rising_Edge(ClockIn) THEN					

			
			IF(Counter = CounterMax-1) THEN				-- Invert clock if counter = countermax and reset counter
				
				ClockInt <= NOT(ClockInt);
				Counter <= 0;
			ELSE										-- Else increment counter
				Counter <= Counter + 1;	
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE;
			