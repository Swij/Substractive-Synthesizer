library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

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
	CounterMax <= ClockFreq/(2*DesiredFreq);
	ClockOut <= ClockInt;

	PROCESS(ClockIn, Reset)
	BEGIN
		IF (Reset = '0') THEN
			Counter <= 0;
			ClockInt <= '0';

		ELSIF Rising_Edge(ClockIn) THEN
			Counter <= Counter + 1;
			
			IF(Counter = CounterMax-1) THEN
				
				ClockInt <= NOT(ClockInt);
				Counter <= 0;
			
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE;
			