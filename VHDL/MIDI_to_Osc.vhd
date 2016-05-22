library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

-- This component acts as a register/interface for note data and status to various components.
-- Should be clocked to the same rate as MIDI_Decoder, 312.500 kHz

ENTITY MIDI_to_Osc IS
	PORT (
		Data_in		: in STD_LOGIC_VECTOR(15 DOWNTO 0);
		Note_on		: in STD_LOGIC;
		Data_ready	: in STD_LOGIC;
		Reset		: in STD_LOGIC;
		Clock		: in STD_LOGIC;
		
		Note_State  : out STD_LOGIC;
		Note		: out STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END ENTITY;	
	
ARCHITECTURE MIDI_to_Osc_arch OF MIDI_to_Osc IS 

	SIGNAL Note_int : INTEGER RANGE 0 to 127;
	SIGNAL Velo_int : INTEGER RANGE 0 to 127;
	SIGNAL Note_state_reg : STD_LOGIC := '0';
BEGIN
	Note_state <= Note_state_reg;
	PROCESS(Clock, Reset)
	BEGIN
		
		IF (Reset = '0') THEN							-- Async reset
			Note <= (OTHERS => '0');
			Note_int <= 0;
			Velo_int <= 0;
			Note_state_reg <= '0';
			
		ELSIF (Data_ready='1') THEN						-- Check when decoder has data ready
			
			IF Note_on = '0' THEN						-- Turn off oscillator and send release to envelope when note turns off
				Note <= (OTHERS => '0');
				Note_state_reg <= '0';
				
			ELSIF (Note_on='1') THEN					-- Forward note number to oscillator and attack message to envelope when note on
				
				Note <= Data_in(15 DOWNTO 8);
				Note_state_reg <= '1';
				
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE;