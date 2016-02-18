library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.geometryPackage.all;

entity geometric is
    generic(
        accSize : natural := 18;
        dacWidth : natural := 12
    );
    port( 
        clk         : in STD_LOGIC;
        reset       : in STD_LOGIC;
        enable      : in STD_LOGIC;

        waveForm    : in STD_LOGIC_VECTOR (1 downto 0);
        note        : in STD_LOGIC_VECTOR (7 downto 0);
        dutyCycle   : in STD_LOGIC_VECTOR (7 downto 0);
        --semi        : in STD_LOGIC_VECTOR (4 downto 0);
        
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
signal sum      : integer range -2**(accSize) to (2**(accSize)-1);

signal clkCnt   : integer range 0 to 2**31 - 1;

begin

    geometric_process:
    
    process(reset, clk)
    begin
    
    if reset = '0' then
                    
        squareWave <= (OTHERS => '0');
        triangleWave <= (OTHERS => '0');
        sawWave <= (OTHERS => '0');

        triangleState <= '1';

        T <= 0;
        F_s <= 0;
        inc <= 0;
        duty <= 0;
        
    elsif rising_edge(clk) then

-------------------------------------------------------------------------------
--
--      RESTART
--
-------------------------------------------------------------------------------
        if restart = '1' then
    
            F_s <= getFs(to_integer(unsigned(note)));
            F_s_clk <= 0;

        --  Square
            if waveForm = "00" then

                clkCnt <= 0;
                sum <= 0;
                T <= getT(to_integer(unsigned(note)));
            
                duty <= getT(to_integer(unsigned(note))) / 100 * to_integer(unsigned(dutyCycle));
                
                squareWave <= ('0',OTHERS => '1');
                output <= squareWave;

        --  Triangle    
            elsif waveForm = "01" then

                --  Phase shift the clock
                clkCnt <= getT(to_integer(unsigned(note)))/2 - getT(to_integer(unsigned(note)))/32;
                sum <= 0;
                T <= getT(to_integer(unsigned(note)));
                inc <= getInc(2);
                
                triangleState <= '1';
                
                triangleWave <= ('0',OTHERS => '0');
                
                output <= triangleWave(17 downto 6); -- 17 - 6
                --output <= triangleWave(accSize-1 downto accSize-dacWidth); -- 17 - 6

        --  Saw
            elsif waveForm = "10" then
            
                clkCnt <= 0;
                sum <= -2**(accSize-1);
                T <= getT(to_integer(unsigned(note)));
                inc <= getInc(1);
                
                sawWave <= STD_LOGIC_VECTOR(to_signed(sum,accSize));                
                --output <= sawWave(17 downto 6);
                --output <= ('1',OTHERS => '0');
                output <= sawWave(accSize-1 downto accSize-dacWidth);
                
            else --  waveForm = "11" then

                clkCnt <= 0;
                sum <= 2**(accSize-1)-1;
                T <= getT(to_integer(unsigned(note)));
                inc <= getInc(1);
                
                sawWave <= STD_LOGIC_VECTOR(to_unsigned(sum,accSize));
                output <= sawWave(17 downto 6);
                --output <= sawWave(accSize-1 downto accSize-dacWidth);
                
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
            if waveForm = "00" or waveForm = "01" then
                
                ----------------------------------------------------------------
                --  Set triangle state - down or up
                ----------------------------------------------------------------
                if clkCnt = T/4 then
                    
                    triangleState <= not triangleState;
                    
                elsif clkCnt = 3*T/4 then
                
                    triangleState <= not triangleState;
                
                elsif clkCnt = T then
                
                    clkCnt <= 0;                    
                                        
                end if;
                ----------------------------------------------------------------
                --  Sample Increment
                ----------------------------------------------------------------
                if F_s_clk = F_s then
                
                    F_s_clk <= 0;
                    
                    if triangleState = '1' then
                    
                        sum <= sum + inc;
                        
                    else
                    
                        sum <= sum - inc;
                        
                    end if;
                    
                end if;
                ----------------------------------------------------------------
                --  Square wave
                ----------------------------------------------------------------
                if clkCnt = duty then
                
                    squareWave <= not squareWave;
                    
                end if;
                
                triangleWave <= STD_LOGIC_VECTOR(to_signed(sum,accSize));
                
                if waveForm = "00" then
                
                    output <= squareWave;
                    
                else
                
                    output <= triangleWave(17 downto 6);
                    
                end if;
                
-------------------------------------------------------------------------------
--          Saw
-------------------------------------------------------------------------------
            elsif waveForm = "10" or waveForm = "11" then
            
                --  Set triangle down or up
                if clkCnt = T then
                
                    F_s_clk <= 0;
                    clkCnt <= 0;
                    
                    if waveForm = "10" then
                    
                        sum <= -2**(accSize-1);
                        
                    else
                        
                        sum <= 2**(accSize-1)-1;
                        
                    end if;
                    
                --  Increment
                elsif F_s_clk = F_s then
                
                    F_s_clk <= 0;
                    
                    if waveForm = "10" then
                    
                        sum <= sum + inc;
                        
                    else
                    
                        sum <= sum - inc;
                        
                    end if;
                
                end if;
                
                sawWave <= STD_LOGIC_VECTOR(to_signed(sum,accSize));
                output <= sawWave(17 downto 6);--18-1 to 18-12 = 17 to 6
                
                
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