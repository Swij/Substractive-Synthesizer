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
        Data_send    : out STD_LOGIC;
        LED    : out STD_LOGIC;
		Data_out	: out STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END Uart;

ARCHITECTURE Uart_Arch OF Uart IS

	TYPE States IS (Idle, Synch, Recieve, Send, Sleep);
	
	SIGNAL Uart_state : States;
	SIGNAL Data_acc : STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	SIGNAL Bit_counter : INTEGER RANGE 0 to 8;
	SIGNAL Scalar : INTEGER RANGE 0 to 11 := 0;
	SIGNAL Sample : INTEGER RANGE 0 to 11 := 0;
	signal uart_led : std_logic;
BEGIN
    
    LED <= uart_led;

PROCESS(Clock, Reset)

	BEGIN
	IF (RESET = '0') THEN							-- Asyncronous Reset of state and accumulated Data
		
		Uart_state <= Idle;							
		Data_acc <= (OTHERS => '0');
		Data_out <= (Others => '0');
		Bit_counter <= 0;
		Data_send <= '0';
		Scalar <= 0;
		uart_led <= '0';
	
	ELSIF rising_edge(Clock) THEN					-- Triggering once every sent bit
			
		CASE Uart_state IS
			
		WHEN Idle =>								-- Wait for low input to indicate the start of a Byte
			
			Data_send <= '0';
			Bit_counter <= 0;
			Scalar <= 0;
			Data_acc <= (Others => '0');

			
			IF (Data_in = '0') THEN
				
				Uart_state <= Synch;
				
			END IF;
		WHEN Synch =>
			Scalar <= Scalar + 1;
			IF (Scalar = 4) THEN 
				Scalar <= 0;
				Uart_state <= Recieve;
			END IF;
			
		WHEN Recieve =>								-- Accumulate 8 consecutive bits into one Byte
			Data_out <= (Others => '0');
			Scalar <= Scalar + 1;
			IF (Scalar = 9) THEN
				
				Data_acc(Bit_counter) <= Data_in;
				Bit_counter <= Bit_counter + 1;
				Scalar <= 0;
				IF (Bit_counter = 7) THEN				-- Receive finished when Byte is full
				
					Uart_state <= Send;
				
				END IF;
			END IF;
			
		WHEN Send =>								-- Send the Accumulated byte to the MIDI Interface and revert to Idle state
			
			Bit_counter <= 0;
			Scalar <= 0;
			Data_out <= Data_acc;
			Uart_state <= Sleep;
			
		WHEN Sleep =>
			
			Scalar <= Scalar + 1;
			IF (Scalar = 9) THEN
				Scalar <= 0;
				Uart_state <= Idle;
				Data_send <= '1';
			    uart_led <= not(uart_led);				
			END IF;
			
		END CASE;
	END IF;
END PROCESS;

END Uart_Arch;		
			
			
			
			
			
			
			
			
			
			
			

			
			
			
			