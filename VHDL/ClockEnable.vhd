library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

ENTITY ClockEnable IS
	GENERIC(DesiredFreq : INTEGER := 31250);
	PORT(
		ClockIn 	: IN STD_LOGIC;
		Reset		: IN STD_LOGIC;
		ClockOut	: OUT STD_LOGIC
	);
END ENTITY;

ARCHITECTURE ClockEnable_ARCH of ClockEnable IS

	SIGNAL Counter : INTEGER := 0;
	SIGNAL CounterMax : INTEGER;
	SIGNAL ClockFreq : INTEGER := 200000000;
	
BEGIN
	CounterMax = ClockFreq/(2*DesiredFreq);
	
	PROCESS(ClockIn, Reset)
	BEGIN
		IF (Reset = '1') THEN
			Counter <= 0;
			ClockOut <= '0';

		ELSIF Rising_Edge(ClockIn) THEN
			Counter = Counter + 1;
			
			IF(Counter == CounterMax) THEN
				
				ClockOut <= NOT(ClockOut);
				Counter <= 0;
			
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE;
			