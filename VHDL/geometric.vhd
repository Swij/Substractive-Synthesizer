library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.aids.ALL;

use work.geometryPackage.all;

entity geometric is
    generic(
        accSize : natural := 12;
        dacWidth : natural := 12
    );
    port( 
        clk         : in STD_LOGIC;
        reset       : in STD_LOGIC;
        enable      : in STD_LOGIC;

        waveForm    : in WAVE;
        note        : in STD_LOGIC_VECTOR (7 downto 0);
        dutyCycle   : in STD_LOGIC_VECTOR (7 downto 0);
        semi        : in STD_LOGIC_VECTOR (4 downto 0);
        
        output      : out STD_LOGIC_VECTOR (11 downto 0)
    );
end geometric;

architecture arch_geometric of geometric is

    signal squareWave   : STD_LOGIC_VECTOR(11 downto 0);
    signal triangleWave : STD_LOGIC_VECTOR(11 downto 0);
    signal sawWave      : STD_LOGIC_VECTOR(11 downto 0);
    
    signal triangleState : STD_LOGIC;
    
    signal T       : integer range 0 to 2**31 - 1;
    signal F_s     : integer range 0 to 2**31 - 1;
    signal F_s_clk : integer range 0 to 2**31 - 1;
    signal duty    : integer range 0 to 2**31 - 1;
    
    signal inc     : integer range 0 to 2**31 - 1;
    signal sum     : integer;-- range -2**(accSize) to (2**(accSize)-1);
    
    signal clkCnt  : integer range 0 to 2**31 - 1;
    signal noteReg : STD_LOGIC_VECTOR (7 downto 0);
    signal waveReg : WAVE;

begin

geometric_process:
process(reset, clk)
variable semit : integer;
begin
    
    if reset = '0' then
                    
        squareWave   <= (OTHERS => '0');
        triangleWave <= (OTHERS => '0');
        sawWave      <= (OTHERS => '0');

        triangleState <= '1';

        T <= 0;
        F_s <= 0;
        inc <= 0;
        duty <= 0;
        
        noteReg <= (OTHERS => '0');
        waveReg <= TRIANGLE;
        
    elsif rising_edge(clk) then

-------------------------------------------------------------------------------
--      RESTART
-------------------------------------------------------------------------------
        if noteReg /= note or waveReg /= waveForm then
        
            noteReg <= note;
            waveReg <= waveForm;             
            semit := to_integer(unsigned(semi));
        
            if semit = 0 then    
                F_s <= getFs(to_integer(unsigned(note)));
                F_s_clk <= 0;
    
            --  Square
                if waveForm = SQUARE then    
                    clkCnt <= 0;
                    sum <= 0;
                    T <= getT(to_integer(unsigned(note)));                
                    duty <= getT(to_integer(unsigned(note))) / 100 * to_integer(unsigned(dutyCycle));                    
                    squareWave <= ('0',OTHERS => '1');
                    output <= squareWave;
    
            --  Triangle    
                elsif waveForm = TRIANGLE then
                --  Phase shift the clock
                    clkCnt <= 0;    --getT(to_integer(unsigned(note)))/2 - getT(to_integer(unsigned(note)))/32;
                    sum <= -2**(11)+1;
                    T <= getT(to_integer(unsigned(note)));
                    inc <= getInc(0);                    
                    triangleState <= '1';                    
                    triangleWave <= STD_LOGIC_VECTOR(to_signed(sum,12));                  
                    output <= triangleWave;
                    
            --  Saw
                elsif waveForm = SAW1 then
                    clkCnt <= 0;
                    sum <= -2**(11)+1;
                    T <= getT(to_integer(unsigned(note)));
                    inc <= getInc(1);                    
                    sawWave <= STD_LOGIC_VECTOR(to_signed(sum,12));
                    output <= sawWave;
                    
                else --  waveForm = "11" then    
                    clkCnt <= 0;
                    sum <= 2**(11)-1;
                    T <= getT(to_integer(unsigned(note)));
                    inc <= getInc(1);                    
                    sawWave <= STD_LOGIC_VECTOR(to_unsigned(sum,12));
                    output <= sawWave;
                    
                end if;
            
            --  If negative semi
            elsif semit < 0 and semit > -12 then 
                
                T <= 0;
                
            --  If positive semi    
            elsif semit > 0 and semit < 12 then     
                
                T <= getT(to_integer(unsigned(note)))-getT(to_integer(unsigned(note))+1)/12*semit;
            
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
            if waveForm = TRIANGLE or waveForm = SQUARE then
                
                ----------------------------------------------------------------
                --  Set triangle state - down or up
                ----------------------------------------------------------------
                if clkCnt = T/2 then
                    
                    triangleState <= not triangleState;
                    sum <= 2**(11)-1;
                    
                elsif clkCnt = T then
                
                    clkCnt <= 0;
                    F_s_clk <= 0;
                    squareWave <= not squareWave;
                    triangleState <= not triangleState;
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
                
                triangleWave <= STD_LOGIC_VECTOR(to_signed(sum,12));
                
                if waveForm = SQUARE then
                
                    output <= squareWave;
                    
                else
                
                    output <= triangleWave;--(17 downto 6);
                    
                end if;
                
-------------------------------------------------------------------------------
--          Saw
-------------------------------------------------------------------------------
            elsif waveForm = SAW1 or waveForm = SAW2 then
            
                --  Set triangle down or up
                if clkCnt = T then
                
                    F_s_clk <= 0;
                    clkCnt <= 0;
                    
                    if waveForm = SAW1 then                    
                        sum <= -2**(11);
                    else
                        sum <= 2**(11)-1;
                    end if;
                    
                --  Increment
                elsif F_s_clk = F_s then
                
                    F_s_clk <= 0;
                    
                    if waveForm = SAW1 then
                        sum <= sum + inc;
                    else
                        sum <= sum - inc;
                    end if;
                
                end if;
                
                sawWave <= STD_LOGIC_VECTOR(to_signed(sum,12));
                output <= sawWave;--(17 downto 6);--18-1 to 18-12 = 17 to 6
                
                
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
