library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.geometryPackage.all;

entity geometric is
    generic(accSize : natural := 22);
    port( 
        clk         : in STD_LOGIC;
        reset       : in STD_LOGIC;
        enable      : in STD_LOGIC;

        waveForm    : in STD_LOGIC_VECTOR (1 downto 0);
        note        : in STD_LOGIC_VECTOR (7 downto 0);
        dutyCycle   : in STD_LOGIC_VECTOR (7 downto 0);
        
        restart     : in STD_LOGIC;
        output      : out STD_LOGIC_VECTOR (11 downto 0)
    );
end geometric;

architecture arch_geometric of geometric is

signal squareWave   : STD_LOGIC_VECTOR(11 downto 0);
signal triangleWave : STD_LOGIC_VECTOR(accSize-1 downto 0);
signal sawWave      : STD_LOGIC_VECTOR(accSize-1 downto 0);

signal triangleState : STD_LOGIC;

signal T        : integer range 0 to 2**31 - 1;
signal F_s      : integer range 0 to 2**31 - 1;
signal F_s_clk  : integer range 0 to 2**31 - 1;
signal duty     : integer range 0 to 2**31 - 1;

signal inc      : integer range 0 to 2**31 - 1;
signal sum      : integer range 0 to 2**31 - 1;

signal clkCnt   : integer range 0 to 2**31 - 1;

begin

    geometric_process:
	process(reset, clk)
    begin
    if reset = '0' then
    
        output <= (OTHERS => '1');
                
        squareWave <= (OTHERS => '0');
        triangleWave <= (OTHERS => '0');
        sawWave <= (OTHERS => '0');

        triangleState <= '1';

        T <= 0;
        F_s <= 0;
        inc <= 0;
        duty <= 0;
        
        --works <= STD_LOGIC_VECTOR(to_unsigned(T(input),32));
        
    elsif rising_edge(clk) then

-------------------------------------------------------------------------------
--
--      RESTART
--
-------------------------------------------------------------------------------
        if restart = '1' then
    
            T <= getT(to_integer(unsigned(note)));
            F_s <= getFs(to_integer(unsigned(note)));
            inc <= getInc(to_integer(unsigned(note)));
            F_s_clk <= 0;
            sum <= 0;

        -- 	Square
            if waveForm = "00" then

                clkCnt <= 0;
                duty <= getT(to_integer(unsigned(note))) / 100 * to_integer(unsigned(dutyCycle));
                squareWave <= ('0',OTHERS => '1');
                output <= squareWave;

        --  Triangle	
            elsif waveForm = "01" then

                --clkCnt <= to_integer(shift_right(getT(to_integer(unsigned(note))),1));
                clkCnt <= getT(to_integer(unsigned(note)))/2;
                triangleState <= '1';
                triangleWave <= ('1',OTHERS => '0');
                output <= triangleWave(accSize-1 downto 10);

        --  Saw
            elsif waveForm = "10" or waveForm = "11" then

                clkCnt <= 0;
                sawWave <= ('1',OTHERS => '0');
                output <= sawWave(accSize-1 downto 10);

            end if;
-------------------------------------------------------------------------------
--
--      ENABLED
--
-------------------------------------------------------------------------------
        elsif enable = '1' then

        --  Counter increment
            clkCnt <= clkCnt + 1;
            F_s_clk <= F_s_clk + 1;

-------------------------------------------------------------------------------
--          Triangle + Square
-------------------------------------------------------------------------------
            if waveForm = "01" then
                
                --  Set triangle down or up
                if clkCnt = T then
                    
                    clkCnt <= 0;
                    triangleState <= not triangleState;
                  
                end if;
                
                --  Increment
                if F_s_clk = F_s then
                
                    F_s_clk <= 0;
                    
                    if triangleState = '1' then
                    
                        sum <= sum + inc;
                        
                    else
                    
                        sum <= sum - inc;
                        
                    end if;
                    
                end if;
                
                --  Square wave
                if clkCnt = duty then
                
                    squareWave <= not squareWave;
                    
                end if;
                
                triangleWave <= STD_LOGIC_VECTOR(to_unsigned(sum,22));
                
-------------------------------------------------------------------------------
--          Saw
-------------------------------------------------------------------------------
            elsif waveForm = "10" or waveForm = "11" then
            
                --  Set triangle down or up
                if clkCnt = T then
                
                    --F_s_clk <= 0;                                             -- TODO: Necessary?
                
                    if waveForm = "10" then
                    
                        --sum <= MIN;
                        
                    else
                    
                        --sum <= MAX;
                        
                    end if;
                    
                --  Increment
                elsif F_s_clk = F_s then
                
                    F_s_clk <= 0;
                    
                    if waveForm = "10" then
                    
                        sum <= sum + inc;
                        
                    else
                    
                        sum <= sum - inc;
                        
                    end if;
                
                    sawWave <= STD_LOGIC_VECTOR(to_unsigned(sum,22));
                
                end if;                
                
                
-------------------------------------------------------------------------------
--          Off
-------------------------------------------------------------------------------              
            else
            
                output <= (OTHERS => '0');
            
            end if;
            
        end if;
        
    end if;
    end process;
    
end arch_geometric;
