library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

ENTITY UART_to_Osc_TB IS

END ENTITY;	

ARCHITECTURE UART_to_Osc_TB_arch OF UART_to_Osc_TB IS

	SIGNAL MIDI_input_TB : std_logic;
	SIGNAL Received_note_TB : std_logic_vector(7 DOWNTO 0);
	SIGNAL Reset_TB : std_logic;
	Signal Clock_TB : std_logic := '0';
	
	SIGNAL Uart_to_Dec_TB : std_logic_vector(7 DOWNTO 0);
	SIGNAL Uart_to_Dec_Send_TB : std_logic;
	
	SIGNAL Dec_to_int_TB : std_logic_vector(15 DOWNTO 0);
	SIGNAL Dec_to_int_Send_TB : std_logic;
	SIGNAL Dec_to_int_NoteState_TB : std_logic;
	
	SIGNAL Clock_period : TIME;
	SIGNAL Clock_Enable_TB: STD_LOGIC;
	SIGNAL New_byte : STD_LOGIC := '0';
	SIGNAL Note_state_rec : STD_LOGIC;
	
	COMPONENT Uart IS
		PORT ( 
		Data_in		: in STD_LOGIC;
		Reset		: in STD_LOGIC;
		Clock		: in STD_LOGIC;
		Data_send	: out STD_LOGIC;
		Data_out	: out STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
	END COMPONENT;
	
	COMPONENT MIDI_Decoder IS 
	PORT (
		Data_in 	: in STD_LOGIC_VECTOR(7 DOWNTO 0);
		Data_ready	: in STD_LOGIC;
		Reset		: in STD_LOGIC;
		Clock		: in STD_LOGIC;
		
		Data_out		: out STD_LOGIC_VECTOR(15 DOWNTO 0);
		Data_send		: out STD_LOGIC;
		Note_state_out	: out STD_LOGIC
	);
	END COMPONENT;
	
	COMPONENT MIDI_to_Osc IS
	PORT (
		Data_in		: in STD_LOGIC_VECTOR(15 DOWNTO 0);
		Note_on		: in STD_LOGIC;
		Data_ready	: in STD_LOGIC;
		Reset		: in STD_LOGIC;
		Clock		: in STD_LOGIC;
		
		Note_state	: out STD_LOGIC;
		Note		: out STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
	END COMPONENT;
	
	COMPONENT ClockEnable IS
		GENERIC(DesiredFreq : INTEGER;
				ClockFreq : INTEGER);
		PORT(
			ClockIn 	: IN STD_LOGIC;
			Reset		: IN STD_LOGIC;
			ClockOut	: OUT STD_LOGIC
		);
	END COMPONENT;
	
BEGIN



MIDI_Dec_inst: MIDI_Decoder
PORT MAP(
	Uart_to_Dec_TB,
	Uart_to_Dec_Send_TB,
	Reset_TB,
	Clock_enable_TB,
	Dec_to_int_TB,
	Dec_to_int_Send_TB,
	Dec_to_int_NoteState_TB
);

Uart_inst: Uart
PORT MAP(
	MIDI_input_TB,
	Reset_TB,
	Clock_enable_TB,
	Uart_to_Dec_Send_TB,
	Uart_to_Dec_TB
	);

MIDI_int_inst: MIDI_to_Osc
PORT MAP(
	Dec_to_int_TB,
	Dec_to_int_NoteState_TB,
	Dec_to_int_Send_TB,
	Reset_TB,
	Clock_enable_TB,
	Note_state_rec,
	Received_note_TB
);

ClockEnable_inst : ClockEnable
GENERIC MAP(DesiredFreq => 312500,
			ClockFreq => 250000000)
PORT MAP(
		Clock_TB,
		Reset_TB,
		Clock_Enable_TB
);

Clock_period <= 32 us;
	
Test_proc:
	PROCESS
	BEGIN
		
	MIDI_input_TB <= '1';
	Reset_TB <= '1';
	
	
	WAIT FOR 200 us;
		Reset_TB <= '0';
		New_byte <= '1';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
		New_byte <= '0';
		
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '1';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '1';
		
	WAIT FOR Clock_period;	
		MIDI_input_TB <= '1';
		New_byte <= '1';
	WAIT FOR Clock_period;	
		MIDI_input_TB <= '0';
		New_byte <= '0';
		
	WAIT FOR Clock_period;
		MIDI_input_TB <= '1';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '1';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '1';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';

	WAIT FOR Clock_period;	
		MIDI_input_TB <= '1';
		New_byte <= '1';
	WAIT FOR Clock_period;	
		MIDI_input_TB <= '0';
		New_byte <= '0';
		
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '1';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '1';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';	
	
	WAIT FOR Clock_period;	
		MIDI_input_TB <= '1';
		New_byte <= '1';
	WAIT FOR Clock_period;	
		MIDI_input_TB <= '0';
		New_byte <= '0';
	
	----------------------------
	
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '1';
		
	WAIT FOR Clock_period;	
		MIDI_input_TB <= '1';
		New_byte <= '1';
	WAIT FOR Clock_period;	
		MIDI_input_TB <= '0';
		New_byte <= '0';
		
	WAIT FOR Clock_period;
		MIDI_input_TB <= '1';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '1';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '1';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
		
	WAIT FOR Clock_period;	
		MIDI_input_TB <= '1';
		New_byte <= '1';
	WAIT FOR Clock_period;	
		MIDI_input_TB <= '0';
		New_byte <= '0';
		
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '1';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '1';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
		
	WAIT FOR Clock_period;	
		MIDI_input_TB <= '1';
		New_byte <= '1';
	WAIT FOR Clock_period;	
		MIDI_input_TB <= '0';
		New_byte <= '0';
		
	WAIT FOR Clock_period;
		MIDI_input_TB <= '1';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '1';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '1';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
		
	WAIT FOR Clock_period;	
		MIDI_input_TB <= '1';
		New_byte <= '1';
	WAIT FOR Clock_period;	
		MIDI_input_TB <= '0';
		New_byte <= '0';
		
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '1';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '1';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
	WAIT FOR Clock_period;
		MIDI_input_TB <= '0';
		
	WAIT FOR Clock_period;
		MIDI_input_TB <= '1';

	
	WAIT FOR Clock_period*3;
		ASSERT (Received_note_TB = "00101001")
		REPORT ("Wrong Note recieved");	
	
	--WAIT FOR Clock_period*5;
		--Reset_TB <= '1';
END PROCESS Test_proc;

clk_proc:
	PROCESS
	BEGIN
	
		WAIT FOR 2 ns;
		Clock_tb<=NOT(Clock_tb);
	
	END PROCESS clk_proc;	
	
END UART_to_Osc_TB_arch;