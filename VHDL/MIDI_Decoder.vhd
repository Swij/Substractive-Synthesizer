library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

-----------------------------------

-- Component decoding the bytes recieved from the Uart connected to the MIDI
-- Should operate on 312.500 kHz clock freq

-----------------------------------

ENTITY MIDI_Decoder IS 
	PORT (
		Data_in 	: in STD_LOGIC_VECTOR(7 DOWNTO 0);
		Data_ready	: in STD_LOGIC;
		Reset		: in STD_LOGIC;
		Clock		: in STD_LOGIC;
		
		Data_out		: out STD_LOGIC_VECTOR(15 DOWNTO 0);
		Data_send		: out STD_LOGIC;
		Note_state_out	: out STD_LOGIC
	);
END MIDI_Decoder;

ARCHITECTURE MIDI_Decoder_arch OF MIDI_Decoder IS

	TYPE States IS (Idle, Recieve, Send);
	SIGNAL Data_acc 			: STD_LOGIC_VECTOR(15 DOWNTO 0);	-- Accumulates incoming data bytes
	SIGNAL Note_state			: STD_LOGIC;						-- 1 if note on, 0 if note off
	SIGNAL MIDI_Decoder_State 	: States;							-- Different states of the encoder
	SIGNAL Byte_cnt				: INTEGER Range 0 to 2;				-- Number of data byte for the corresponding status byte
	SIGNAL Prev_note_reg		: STD_LOGIC_VECTOR(7 DOWNTO 0);		-- Register for the previous note recieved
BEGIN
	
PROCESS(Clock,Reset)
BEGIN
	IF(Reset = '0') THEN											-- Asynchronous reset
		
		Data_acc <= (OTHERS => '0');
		Data_out <= (OTHERS => '0');
		Note_state <= '0';
		Note_state_out <= '0';
		MIDI_Decoder_state <= Idle;
		Data_send <= '0';
		Prev_note_reg <= (OTHERS => '0');
		
	ELSIF (RISING_EDGE(Clock)) THEN
	
		CASE MIDI_Decoder_State IS
	
		WHEN Idle =>												-- Waiting for incoming data
			
			Data_acc <= (OTHERS => '0');							-- Clear accumulated data
			Data_out <= (OTHERS => '0');
			Byte_cnt <= 0;
			Data_send <= '0';
			
			IF (Data_ready = '1') THEN
			
				CASE Data_in(7 DOWNTO 4) IS						--Determines MIDI message type, more can be added
			
				WHEN "1000" =>									-- Note off message
					
					Byte_cnt <= 2;								-- Two data bytes
					MIDI_Decoder_State <= Recieve;				-- Prepare to recieve data
					Note_state <= '0';							-- Note should turn off
	
				WHEN "1001" =>									-- Note on message
 	
					Byte_cnt <= 2;								-- Two data bytes
					Note_state <= '1';							-- Note should turn on
					MIDI_Decoder_State <= Recieve;				-- Prepare to recieve data
				
					
					
				WHEN Others =>
					
					IF(Data_in = Prev_note_reg) THEN			-- When the same key is pressed repeatedly, no new status byte is generated.
						Byte_cnt <= 1;							-- This part checks for the same note number incoming without status byte, if yes then invert note status
						Note_state <= NOT(Note_state);
						MIDI_Decoder_state <= Recieve;
						Data_acc(15 DOWNTO 8) <= Prev_note_reg;

					ELSE
	
						MIDI_Decoder_state <= Idle;				-- If none of the above, revert to idle state
					END IF;

				END CASE;
			
			END IF;
			
		WHEN Recieve =>											--Accumulates MIDI data bytes
			
			IF (Data_ready = '1') & (Data_in(7)='0') THEN		-- Activate on Data_ready, check if byta is data
				
				IF (Byte_cnt = 2) THEN							-- Accumulates incoming data byte nr 1, usually note number
					Data_acc(15 DOWNTO 8) <= Data_in;
					Byte_cnt <= 1;
					Prev_note_reg <= Data_in;
				
				ELSIF (Byte_cnt = 1) THEN						-- Accumulates data byte nr 2, usually note velocity
					
					IF (Data_in = "00000000") THEN				-- Velocity = 0 => note off
					   Note_state <= '0';
					END IF;
					
					Data_acc(7 DOWNTO 0) <= Data_in;
					Byte_cnt <= 0;
						
					MIDI_Decoder_state <= Send;					-- Got to the send state	
					
				END IF;
			ELSE 
				MIDI_Decoder_State <= Idle;						-- If not data, revert to idle stage
			END IF;
				
		WHEN Send =>											--Sends MIDI Data
			
			Data_out <= Data_acc;								
			Note_state_out <= Note_state;
			Data_send <= '1';
			MIDI_Decoder_State <= Idle;							-- Revert to Idle state when data has been sent
			
		END CASE;
	END IF;
END PROCESS;
END ARCHITECTURE;
	