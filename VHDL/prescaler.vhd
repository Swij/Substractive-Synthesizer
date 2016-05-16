library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity prescaler is
    generic (prescale : NATURAL := 4);
    port ( 
        clk : IN STD_LOGIC;
        preClk : OUT STD_LOGIC
    );
end prescaler;

architecture arch_prescaler of prescaler is

signal clkReg : std_logic := '0';

begin

--  Not really a pre scaler but a bit-enable.
--  When the counter has reached a certain value it outputs the preClk as high.

prescale_process:
process(clk)
variable cnt : natural range 0 to (prescale-1);
begin

    if rising_edge(clk) then

        if cnt = (prescale-1) then
            cnt := 0;
            preClk <= '1';--not(clkReg);
        else
            preClk <= '0';--not(clkReg);
            cnt := cnt + 1;
        end if;
        
    end if;

end process;    
end arch_prescaler;