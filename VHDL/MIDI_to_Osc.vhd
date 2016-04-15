library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

ENTITY MIDI_to_Osc IS
	PORT (
		Data_in		: in STD_LOGIC_VECTOR(15 DOWNTO 0);
		Note_on		: in STD_LOGIC;
		Data_ready	: in STD_LOGIC;
		Reset		: in STD_LOGIC;
		Clock		: in STD_LOGIC;
		
		Note		: out STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END ENTITY;	
	
ARCHITECTURE MIDI_to_Osc_arch OF MIDI_to_Osc IS 

	SIGNAL Note_int : INTEGER RANGE 0 to 127;
	SIGNAL Velo_int : INTEGER RANGE 0 to 127;
	
BEGIN

	PROCESS(Clock, Reset)
	BEGIN
		
		IF (Reset = '1') THEN
			Note <= (OTHERS => '0');
			Note_int <= 0;
			Velo_int <= 0;
			
		ELSIF (Data_ready='1') THEN
			
			Velo_int <= TO_INTEGER(SIGNED(Data_in(7 DOWNTO 0)));
			
			IF Velo_int = 0 OR Note_on = '0' THEN
				Note <= (OTHERS => '0');
				
			ELSIF (Note_on='1') THEN
				
				Note <= Data_in(15 DOWNTO 8);
				
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE;