library IEEE;
library ieee_proposed;
use ieee_proposed.fixed_float_types.all;
use ieee_proposed.fixed_pkg.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.aids.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity top is
    port ( 
        SYSCLK_P  : in STD_LOGIC;
        SYSCLK_N  : in STD_LOGIC;
        GPIO_LED_0 : out STD_LOGIC;
        GPIO_LED_1 : out STD_LOGIC;
        GPIO_LED_2 : out STD_LOGIC;
        GPIO_LED_3 : out STD_LOGIC;
        --FMC1_HPC_HA09_P : in STD_LOGIC;
        --FMC1_HPC_HA09_N : in STD_LOGIC;

        --  DAC
		
		--MIDI IN
		PMOD_0 		: in STD_LOGIC;
		
		--Test
		PMOD_2      : out STD_LOGIC;
		PMOD_1      : out STD_LOGIC);
        
    
end top;

architecture arch_top of top is

    --  Clock signals
    signal clk : STD_LOGIC;
    signal counter : STD_LOGIC_VECTOR(31 downto 0) :=(others => '0');
    signal I : STD_LOGIC;
    signal IB : STD_LOGIC;


    
    signal preClk : STD_LOGIC;
    signal reset : STD_LOGIC;


    
    -- MIDI Interface
	
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
	
	SIGNAL Clock_Enable : STD_LOGIC;
	SIGNAL Uart_send : STD_LOGIC;
	SIGNAL Uart_Dec : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL Note_data : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL Note_ready : STD_LOGIC;
	SIGNAL Note_state : STD_LOGIC;
	SIGNAL Note_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
    --  Next below here...
    --  ...


    --  Test signals and others...
    signal gpioLEDS   : std_logic_vector(3 downto 0);
    
       
begin    
--------------------------------------------------------------------------------
IBUFDS_inst: IBUFDS
generic map (
    --IBUF_LOW_PWR => TRUE,
    IOSTANDARD => "LVDS_25")
port map (
    O => clk,     -- clock buffer output
    I => I,       -- diff_p clock buffer input
    IB => IB      -- diff_n clock buffer input
);

    I <= SYSCLK_P;
    IB <= SYSCLK_N;

--MIDI Instances--
Uart_inst: COMPONENT Uart
	port map(PMOD_0, Reset, Clock_Enable, Uart_send, Uart_Dec);
	
MIDI_dec_inst: COMPONENT MIDI_Decoder
	port map(Uart_Dec, Uart_send, Reset, Clock_Enable, Note_data, Note_ready, Note_state);
	
MIDI_to_osc_inst: COMPONENT MIDI_to_Osc
	port map(Note_data, Note_state, Note_ready, Reset, Clock_Enable, Note_out);
	
ClockEn_inst: COMPONENT ClockEnable
	generic map(DesiredFreq => 312500, ClockFreq => 200000000)
	port map(Clk, Reset, Clock_Enable);

--------------------------------------------------------------------------------
----         GPIO     coupling
--------------------------------------------------------------------------------

    --  Just all LEDs
    GPIO_LED_0 <= gpioLEDS(0);
    GPIO_LED_1 <= gpioLEDS(1);
    GPIO_LED_2 <= gpioLEDS(2);
    GPIO_LED_3 <= gpioLEDS(3);
    
    -- Test
    PMOD_2 <= clk;
    PMOD_1 <= Note_out(0);
    

    
end arch_top;