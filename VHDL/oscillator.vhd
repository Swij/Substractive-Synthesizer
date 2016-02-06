library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity oscillator is
    Port (
        clk         : in STD_LOGIC;
        reset       : in STD_LOGIC;
        enable      : in STD_LOGIC;
        
        frequency   : in STD_LOGIC_VECTOR (12 downto 0);
        wave        : in STD_LOGIC_VECTOR (3 downto 0);
        output      : out STD_LOGIC_VECTOR (11 downto 0)
    );
end oscillator;

architecture arch_oscillator of oscillator is

begin
	
    osc_process:
	process(reset, clk)
    begin
    
    if reset = '0' then

        output <= (OTHERS => '0');
	
    elsif rising_edge(clk) then
    
        if enable = '1' then
        
            output <= (OTHERS => '1');

            --    --  Sine	
            --        if wave = "0001" then

            --    -- 	Square
            --        elsif wave = "0010" then
            --    --  Triangle	
            --        elsif wave = "0011" then
            --    --  Saw 1
            --        elsif wave = "0010" then
            --    --  Saw 2    
            --        elsif wave = "0010" then
            --    --  Noise
            --		elsif wave = "0010" then
            --    --  Off
            --        else
        else
        
            output <= (OTHERS => '0');
        
        end if;
	end if;
	end process;
end arch_oscillator;
