--Transmitter code for the I2S protocol
--Used for communicating from digital synthesizer to Class-D amplifier
--Code by Fredrik Treven
--28 March 2016
--Chalmers University of Technology


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity I2S_transmitter is
	generic(WIDTH:INTEGER:=12);
	port(clk:in STD_LOGIC;
	data:in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
	sck:out STD_LOGIC;
	ws:out STD_LOGIC;
	sd:out STD_LOGIC);
end I2S_transmitter;

architecture arch_I2S_transmitter of I2S_transmitter is
signal temp_ws:STD_LOGIC:='0'; --Start in left channel select
signal temp_data:STD_LOGIC_VECTOR(WIDTH-1 downto 0);
begin
process(clk)
	variable counter:INTEGER:=0; --Initialize counter to keep track of where in the message we are
begin
	sck <= clk; --Serial clock is equal to internal clock sent to I2S (clock divider can be handled elsewhere if needed)
	if(RISING_EDGE(clk)) then
		ws <= temp_ws; --Set word select equal to temporary signal
		if(counter = 0) then
			temp_data <= STD_LOGIC_VECTOR(SIGNED(not data) + 1); --Two's complement of input data (retrieve at end of message)
			sd <= temp_data(WIDTH-1-counter); --Send one bit of data at a time (MSB first)
			counter := counter + 1;
		elsif(counter > 0 and counter < WIDTH-2) then --continue with current data
			sd <= temp_data(WIDTH-1-counter); --Send one bit of data at a time (MSB first)
			counter := counter + 1;
		elsif(counter = WIDTH-2) then
			temp_ws <= not(temp_ws);
			sd <= temp_data(WIDTH-1-counter); --Send one bit of data at a time (MSB first)
			counter := counter + 1;
		elsif(counter = WIDTH-1) then --End of current data
			sd <= temp_data(WIDTH-1-counter); --Send one bit of data at a time (MSB first)
			counter := 0; --Reset counter
			temp_data <= STD_LOGIC_VECTOR(SIGNED(not data) + 1); --Two's complement of input data (retrieve at end of message)
		end if;
	end if;
end process;

end arch_I2S_transmitter;