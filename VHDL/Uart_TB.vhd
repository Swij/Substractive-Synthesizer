library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

----------------------------------------

-- Testbench for the Uart

----------------------------------------

ENTITY Uart_TB IS 

END Uart_TB;

ARCHITECTURE Uart_TB_arch OF Uart_TB IS

	SIGNAL Data_in_tb : STD_LOGIC;
	SIGNAL Clock_tb : STD_LOGIC:='0';
	SIGNAL Reset : STD_LOGIC;
	SIGNAL Data_Recieved : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL Clock_period : TIME;
	
	COMPONENT Uart
		PORT ( 
		Data_in		: in STD_LOGIC;
		Reset		: in STD_LOGIC;
		Clock		: in STD_LOGIC;
		
		Data_out	: out STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
	END COMPONENT;
	
BEGIN
	Clock_period <= 32 ns;
	
Test_proc:
	PROCESS
	BEGIN
		
	Data_in_tb <= '1';
	Reset <= '1';
	
	WAIT FOR Clock_period*2;
		Reset <= '0';
	WAIT FOR Clock_period;
		Data_in_tb <= '0';
	WAIT FOR Clock_period;
		Data_in_tb <= '1';
	WAIT FOR Clock_period;
		Data_in_tb <= '0';
	WAIT FOR Clock_period;
		Data_in_tb <= '1';
	WAIT FOR Clock_period;
		Data_in_tb <= '0';
	WAIT FOR Clock_period;
		Data_in_tb <= '1';
	WAIT FOR Clock_period;
		Data_in_tb <= '0';
	WAIT FOR Clock_period;
		Data_in_tb <= '1';
	WAIT FOR Clock_period;
		Data_in_tb <= '0';
	WAIT FOR Clock_period;	
		Data_in_tb <= '1';
	WAIT FOR Clock_period*2;
		ASSERT (Data_Recieved = "01010101")
		REPORT ("Data Recieved is faulty");
END PROCESS test_proc;
Uart_inst: Uart 
	PORT MAP (
		Data_in_tb,
		Reset,
		Clock_tb,
		Data_recieved
	);
	
clk_proc:
	PROCESS
	BEGIN
	
		WAIT FOR 16 ns;
		Clock_tb<=NOT(Clock_tb);
	
	END PROCESS clk_proc;	
	
	
	
END Uart_TB_arch;