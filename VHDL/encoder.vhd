library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity encoder is
    Port(
        clk         : in STD_LOGIC;
        reset       : in STD_LOGIC;
        
        grayPins    : in STD_LOGIC_VECTOR (1 downto 0);
        btnPin      : in STD_LOGIC;
        
        change      : out STD_LOGIC;
        dir         : out STD_LOGIC;
        btn         : out STD_LOGIC
    );
end encoder;

architecture arch_encoder of encoder is

signal reg : std_logic_vector(1 downto 0);

begin

    encoder_process:
	process(reset, clk)
    begin
    
    if reset = '0' then
    
        change <= '0';
        dir <= '0';              
        reg <= "00";
        
        
    elsif rising_edge(clk) then
    
        if btnPin = '0' then        
            btn <= '1';            
        else        
            btn <= '0';        
        end if;

        if grayPins /= reg then
        
            reg <= grayPins;
            change <= '1';
            
            if grayPins = "00" then     --  Gray 00 01 11 10

                if reg = "01" then
                    dir <= '0';         --  0 = Left
                else
                    dir <= '1';         --  1 = Right
                end if;

            elsif grayPins = "01" then

                if reg = "11" then
                    dir <= '0';
                else
                    dir <= '1';
                end if;        

            elsif grayPins = "11" then

                if reg = "10" then
                    dir <= '0';
                else
                    dir <= '1';
                end if;        

            else --  grayPins = "10"

                if reg = "00" then
                    dir <= '0';
                else
                    dir <= '1';
                end if;
                
            end if;            
            
        else
        
            change <= '0';
        
        end if;

    end if;
    end process;

end arch_encoder;