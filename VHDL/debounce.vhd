library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity debounce is 
	port(clk : in STD_LOGIC;
	     A   : in STD_LOGIC;
	     B   : out std_logic
	);
end debounce;

architecture arch_debounce of debounce is
     
    signal reg : std_logic_vector(16-1 downto 0) := (others => '0');

begin	  

debounce_process: 
process(clk)
begin

    B <= reg(0);

	if rising_edge(clk) then
		
		if A /= reg(0) then
			reg <= A & reg(16-1 downto 1);
		else
			reg <= (others => A);
		end if;
		
	end if;
	
	
end process;

end arch_debounce;