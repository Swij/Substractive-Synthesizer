library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use work.aids.ALL;
use work.geometryPackage.ALL;

entity LFO_duty is
    port(
        clk      : in std_logic;
        reset    : in std_logic;
        enable   : in std_logic;
        
        rate     : in std_logic_vector (7 downto 0);
        depth    : in std_logic_vector (4 downto 0);
        
        waveForm : in WAVE;
        
        output   : out std_logic_vector (6 downto 0));
        
end LFO_duty;

architecture arch_LFO_duty of LFO_duty is
 
    signal triangleState : STD_LOGIC;
    
    signal T       : integer range 0 to 2**31 - 1;
    signal F_s     : integer range 0 to 2**31 - 1;
    signal F_s_clk : integer range 0 to 2**31 - 1;
    
    signal sum     : integer range 0 to 127;
    
    signal clkCnt  : integer range 0 to 2**31 - 1;
    signal rateReg : STD_LOGIC_VECTOR (7 downto 0);
    signal waveReg : WAVE;
    
begin

    output <= std_logic_vector(to_unsigned(sum,7));

lfo_process:
process(reset, clk)
begin

    if reset = '0' then

        triangleState <= '1';
        rateReg <= (OTHERS => '0');
        waveReg <= TRIANGLE;
        T <= 0;
        F_s <= 0;
        clkCnt <= 0;
        F_s_clk <= 0;
        output <= "0000010";  --  As 2 is the minimum duty cycle.
        
        
    elsif rising_edge(clk) then

-------------------------------------------------------------------------------
--      RESTART
-------------------------------------------------------------------------------
        if rateReg /= rate or waveReg /= waveForm then
        
            rateReg <= rate;
            waveReg <= waveForm;
            
            clkCnt <= 0;
            F_s_clk <= 0;
            triangleState <= '1';

            T <= getLFO_T(to_integer(unsigned(rate)));

            output <= "0000010";
        
        --  Triangle
            if waveForm = TRIANGLE then
        
                F_s <= getLFOFs_Tri(to_integer(unsigned(rate)), to_integer(unsigned(depth)));
                sum <= 2;
        
        --  Saw
            elsif waveForm = SAW1 then
            
                F_s <= getLFOFs_Tri(to_integer(unsigned(rate)), to_integer(unsigned(depth)));
                sum <= 2;
                
            else --  waveForm = "11" then
            
                F_s <= getLFOFs_Tri(to_integer(unsigned(rate)), to_integer(unsigned(depth)));
                sum <= 98;
            end if;
                
--      ENABLED
        elsif enable = '1' then

        --  Counter increment
            clkCnt  <= clkCnt  + 1;
            F_s_clk <= F_s_clk + 1;

            if waveForm = TRIANGLE then
            
                --  Set triangle state - down or up
                if clkCnt = T/2 then
                
                    triangleState <= not triangleState;
                    
                elsif clkCnt = T then
                
                    clkCnt <= 0;
                    F_s_clk <= 0;
                    triangleState <= not triangleState;
                    
                end if;
                
                --  Sample Increment
                if F_s_clk = F_s then
                             
                    F_s_clk <= 0;       
                                 
                    if triangleState = '1' then                    
                        sum <= sum + 1;                        
                    else                    
                        sum <= sum - 1;                        
                    end if;                    
                end if;
                
                
            elsif waveForm = SAW1 or waveForm = SAW2 then
            
                --  Set triangle down or up
                if clkCnt = T then
                
                    F_s_clk <= 0;
                    clkCnt <= 0;
                    
                    if waveForm = SAW1 then                    
                        sum <= 2;
                    else
                        sum <= 98;
                    end if;
                    
                --  Increment
                elsif F_s_clk = F_s then
                
                    F_s_clk <= 0;
                    
                    if waveForm = SAW1 then
                        sum <= sum + 1;
                    else
                        sum <= sum - 1;
                    end if;
                
                end if;
                
-------------------------------------------------------------------------------
--          Off
-------------------------------------------------------------------------------              
            else
            
                sum <= 2;
            
            end if;
            
        end if;
        
    end if;
 
end process;
end arch_LFO_duty;
