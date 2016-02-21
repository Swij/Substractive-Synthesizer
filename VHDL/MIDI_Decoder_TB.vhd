library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

------------------------------------
--Testbench for the MIDI_Decoder
------------------------------------

ENTITY MIDI_Decoder_TB IS

END ENTITY;

ARCHITECTURE MIDI_Decoder_TB_arch OF MIDI_Decoder_TB IS

	SIGNAL Data_in_tb : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL Data_Ready_TB : STD_LOGIC;
	SIGNAL Clock_tb : STD_LOGIC:='1';
	SIGNAL Reset_tb : STD_LOGIC:='1';
	SIGNAL Data_Recieved : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL Clock_period : TIME;
	
	COMPONENT MIDI_Decoder IS 
		PORT (
		Data_in 	: in STD_LOGIC_VECTOR(7 DOWNTO 0);
		Data_ready	: in STD_LOGIC;
		Reset		: in STD_LOGIC;
		Clock		: in STD_LOGIC;
		
		Data_out			: out STD_LOGIC_VECTOR(15 DOWNTO 0)
		);
	END COMPONENT;
	
BEGIN
	Clock_period <= 32 ns;
	
Test_proc:
	PROCESS
	BEGIN
	
	WAIT FOR 64 ns;
	Reset_tb <= '0';
	WAIT FOR Clock_period;
	Data_Ready_TB <= '1';
	Data_in_tb <= "10010000";
	WAIT FOR Clock_period;
	Data_Ready_TB <= '0';
	WAIT FOR Clock_period*7;
	Data_Ready_TB <= '1';
	Data_in_tb <= "01100110";
	WAIT FOR Clock_period;
	Data_Ready_TB <= '0';
	WAIT FOR Clock_period*7;
	Data_Ready_TB <= '1';
	Data_in_tb <=  "01111000";
	WAIT FOR Clock_period;
	Data_Ready_TB <= '0';

	WAIT FOR 16 ns;
			ASSERT (Data_Recieved = "0110011001111000")
		REPORT ("Data Recieved is faulty");

	WAIT FOR 16 ns;
	Reset_tb <= '1';
	
END PROCESS test_proc;
MIDI_Decoder_inst: MIDI_Decoder 
	PORT MAP (
		Data_in_tb,
		Data_Ready_TB,
		Reset_tb,
		Clock_tb,
		Data_recieved
	);
	
clk_proc:
	PROCESS
	BEGIN
	
		WAIT FOR 16 ns;
		Clock_tb<=NOT(Clock_tb);
	
	END PROCESS clk_proc;	

END ARCHITECTURE;