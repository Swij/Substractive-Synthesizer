library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

---------------------------------------------

-- UART to de-serialize MIDI data into bytes
-- then send them on to the MIDI Decoder

-- Incoming clockrate should be equal to
-- MIDI transfer rate, aka 31.250 kHz

---------------------------------------------

ENTITY Uart IS 
	PORT ( 
		Data_in		: in STD_LOGIC;
		Reset		: in STD_LOGIC;
		Clock		: in STD_LOGIC;
		
		Data_out	: out STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END Uart;

ARCHITECTURE Uart_Arch OF Uart IS

	TYPE States IS (Idle, Recieve, Send);
	
	SIGNAL Uart_state : States;
	SIGNAL Data_acc : STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	SIGNAL Bit_counter : INTEGER RANGE 0 to 7;
	
BEGIN
PROCESS(clk, Reset)

	BEGIN
	IF (RESET = '1') THEN							-- Asyncronous Reset of state and accumulated Data
		
		Uart_state <= Idle;							
		Data_acc <= (OTHERS => '0');
		Bit_counter <= 0;
	
	ELSIF rising_edge(Clock) THEN					-- Triggering once every sent bit
			
		CASE Uart_state IS
			
		WHEN Idle =>								-- Wait for low input to indicate the start of a Byte
			
			IF (Data_in = '0') THEN
				
				Bit_counter <= 0;
				Uart_state <= Recieve;
				
			END IF;
		
		WHEN Recieve =>								-- Accumulate 8 consecutive bits into one Byte
			
			Data_acc(Bit_counter) <= Data_in;
			Bit_counter++
			
			IF (Bit_counter = 7) THEN				-- Receive finished when Byte is full
				
				Uart_state <= Send;
				
			END IF
			
		WHEN Send =>								-- Send the Accumulated byte to the MIDI Interface and revert to Idle state
			
			Data_out <= Data_acc;
			Uart_state <= Idle;
		
		END CASE;
	END IF;
END PROCESS;

END Uart_Arch;		
			
			
			
			
			
			
			
			
			
			
			

			
			
			
			