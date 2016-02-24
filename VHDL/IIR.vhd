 --Fredrik Treven
--8 February 2016
--IIR filter implementation
--Filter for synthesizer
--Chalmers University of Technology


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


entity IIR is
   generic ( WIDTH : INTEGER:=12);
   port ( clk      : in STD_LOGIC;
          x        : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
          set      : in STD_LOGIC;
          y        : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
          finished : out STD_LOGIC);
end IIR;

architecture arch_IIR of IIR is

signal a1: STD_LOGIC_VECTOR(WIDTH-1 downto 0);
signal a2: STD_LOGIC_VECTOR(WIDTH-1 downto 0);
signal b0: STD_LOGIC_VECTOR(WIDTH-1 downto 0);
signal b1: STD_LOGIC_VECTOR(WIDTH-1 downto 0);
signal b2: STD_LOGIC_VECTOR(WIDTH-1 downto 0);

signal y_temp: STD_LOGIC_VECTOR(2*WIDTH-1 downto 0);
signal y_temp_temp: STD_LOGIC_VECTOR(WIDTH-1 downto 0);

type twodarray is array(4 downto 0) of STD_LOGIC_VECTOR(WIDTH-1 downto 0);
--type Btwodarray is array(2 downto 0) of STD_LOGIC_VECTOR(WIDTH-1 downto 0);

signal cos: twodarray;
signal ins: twodarray;
--signal Ys: Atwodarray;
--signal Xs: Btwodarray;
signal run:STD_LOGIC;


begin
    -- Filter coefficients *1024
    a1 <= "101010111011"; --a1 = -1349
    a2 <= "001010100110"; --a2 =  678
    b0 <= "000000101110"; --b0 =  46
    b1 <= "000001011011"; --b1 =  91
    b2 <= "000000101110"; --b2 =  46
    
    --Assign coefficients to slot in 2D array
    cos(0) <= b0;
    cos(1) <= b1;
    cos(2) <= b2;
    cos(3) <= a1;
    cos(4) <= a2;

   process(clk)
	variable counter:INTEGER:= 0; --Initialize counter to 0
   begin
	if(RISING_EDGE(clk)) then
		if(set = '1') then --Getting set for next calculation
			run <= '0'; --We are not running the addition and multiplication
			finished <= '0';
	
			--Initialize input values
			ins(0) <= (others => '0');
			ins(1) <= (others => '0');
			ins(2) <= (others => '0');
			ins(3) <= (others => '0');
			ins(4) <= (others => '0');
			counter:= 0; -- Reset counter to 0
			y_temp_temp <= (others => '0'); -- Reset buffer of Y values
		elsif(run = '0') then --If we are not ready to compute calculation yet
			finished <= '0'; --Not finished with calculation
			run <= '1'; --Want to start calculation on next clock cycle
			y_temp <= (others => '0'); -- Set temporary sum to 0
			counter := 0; --Reset counter to 0
		
			--Shift samples over 
			ins(2) <= ins(1);
			ins(1) <= ins(0);
			ins(0) <= x; -- X array takes in newest value at index 0 (concatenated to form 12-bit value)
			ins(4) <= ins(3);
			ins(3) <= y_temp_temp;
		elsif(run = '1') then --If we want to make the calculation
			if(counter < 3) then
				finished <= '0';
				if(counter = 0) then
					y_temp <= STD_LOGIC_VECTOR(SIGNED(y_temp) + SIGNED(ins(counter))*SIGNED(cos(counter)));
				else
					y_temp <= STD_LOGIC_VECTOR(SIGNED(y_temp) + SIGNED(ins(counter))*SIGNED(cos(counter)) - SIGNED(ins(counter + 2))*SIGNED(cos(counter + 2)));
				end if;
				y_temp_temp <= STD_LOGIC_VECTOR(SIGNED(y_temp(2*WIDTH-1 downto WIDTH)));
				counter := counter + 1;
			else 
				finished <= '1'; --Calculation complete
				run <= '0'; --No longer want to run calculation
				y <= STD_LOGIC_VECTOR(SIGNED(y_temp(2*WIDTH-1 downto WIDTH)));
			end if;
		end if;
	end if;
   end process;
end arch_IIR;

