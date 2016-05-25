library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity debounce is 
	port(clk : in std_logic;
	     A   : in std_logic;
	     B   : out std_logic
	);
end debounce;

architecture arch_debounce of debounce is
     
    signal reg : std_logic_vector(16-1 downto 0) := (others => '0');

begin	  

--  A different kind of debouncer, not using a counter.
--  Using a register that shifts in a value from a button and always keeps the last bit as the output.
--  If the incoming bit varies from the last it gets shifted in, and if that value is hold long enough
--  it will be the last eventually and the output as well.
    B <= reg(0);

debounce_process: 
process(clk)
begin
	if rising_edge(clk) then
		if A /= reg(0) 
		then reg <= A & reg(16-1 downto 1);
		else reg <= (others => A);
		end if;
	end if;
end process;
end arch_debounce;