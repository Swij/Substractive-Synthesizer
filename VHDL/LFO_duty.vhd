library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use work.aids.ALL;
use work.geometryPackage.ALL;

entity LFO_duty is
    port(
        clk      : in std_logic;
        reset    : in std_logic;
        restart  : in std_logic;
        enable   : in std_logic;        
        rate     : in std_logic_vector (7 downto 0);
        depth    : in std_logic_vector (6 downto 0);        
        waveForm : in std_logic;        
        output   : out std_logic_vector (6 downto 0));
        
end LFO_duty;

architecture arch_LFO_duty of LFO_duty is
 
    type stateType is (START,SETUP,RUN);
    signal curr_state : stateType := START;
    
    signal T           : integer range 0 to 2**31 - 1;
    signal F_s         : integer range 0 to 2**31 - 1;
    signal numerator   : integer range 0 to 2**31 - 1;
    signal denominator : integer range 0 to 2**31 - 1;
    signal F_s_clk     : integer range 0 to 2**31 - 1;
    signal clkCnt      : integer range 0 to 2**31 - 1;
    
    signal sum     : integer range 0 to 127;
    
    signal rateReg  : STD_LOGIC_VECTOR (7 downto 0);
    signal depthReg : STD_LOGIC_VECTOR (6 downto 0);
    signal waveReg  : STD_LOGIC;
    
    signal depthCnt : integer range 0 to 255 := 0;
    signal setupCnt : integer range 0 to 1023 := 0;
    
begin

    output <= std_logic_vector(to_unsigned(sum,7));

lfo_process:
process(reset, clk)
begin

    if reset = '0' then

        --triangleState <= '1';
        rateReg <= (OTHERS => '0');
        waveReg <= '0';
        T       <= 0;
        F_s     <= 0;
        clkCnt  <= 0;
        F_s_clk <= 0;
        sum     <= 6;
        depthCnt <= 0;
        
        curr_state <= START;
        setupCnt <= 0;
    elsif rising_edge(clk) then

        case curr_state is
            when START =>
            
                sum      <= 6;
                T        <= 0;
                F_s      <= 0;
                clkCnt   <= 0;
                F_s_clk  <= 0;
                sum      <= 6;
                depthCnt <= 0;
                
                rateReg  <= rate;
                waveReg  <= waveForm;
                depthReg <= depth;    
                            
                numerator <= getLFO_T(to_integer(unsigned(rate)));
                
--                if waveForm = '0' 
--                then denominator <= 2*to_integer(unsigned(depth));  --  Triangle
--                else denominator <= 1+to_integer(unsigned(depth));  --  Saw
--                end if;
                
                
                T   <= getLFO_T(to_integer(unsigned(rate)));
               
                if waveForm = '0' 
                then F_s <= getLFO_T(to_integer(unsigned(rate))) / (2*to_integer(unsigned(depth)));  --  Triangle
                else F_s <= getLFO_T(to_integer(unsigned(rate))) / (1+to_integer(unsigned(depth)));  --  Saw
                end if;

                curr_state <= SETUP;
                setupCnt <= 0;
                
            when SETUP =>
                
--                if setupCnt = 0 
--                then T   <= getLFO_T(to_integer(unsigned(rate)));
--                     F_s <= numerator / denominator;
--                     setupCnt <= setupCnt + 1;
--                els
                if setupCnt = 1023 
                then setupCnt <= 0; curr_state <= RUN;
                else setupCnt <= setupCnt + 1;
                end if;
                
            when RUN =>    
                
                if rateReg /= rate or waveReg /= waveForm or depthReg /= depth or restart = '1'
                then curr_state <= START;
                else curr_state <= RUN;
                end if;
                        
                --if restart = '0' then
        
                    clkCnt  <= clkCnt  + 1;
                    F_s_clk <= F_s_clk + 1;
        
                    if waveForm = '0' then
                    
                        if clkCnt = T 
                        then clkCnt <= 0; depthCnt <= 0; F_s_clk <= 0; sum <= 6;
                        elsif F_s_clk = F_s 
                        then F_s_clk <= 0; depthCnt <= depthCnt + 1;
                            
                            if depthCnt < to_integer(unsigned(depthReg)) 
                            then sum <= sum + 1;                        
                            else sum <= sum - 1; 
                            end if;           
                        end if;
                    else
                        if clkCnt = T 
                        then F_s_clk <= 0; clkCnt <= 0; sum <= 6;
                        elsif F_s_clk = F_s 
                        then F_s_clk <= 0; sum <= sum + 1;
                        end if;
                    end if;
                --else sum <= 50;
                --end if;
                --else
                --    curr_state <= START;
                --end if;
        end case;
    end if;
end process;
end arch_LFO_duty;
--                if rateReg /= rate or waveReg /= waveForm or depthReg /= depth then

--    rateReg  <= rate;
--    waveReg  <= waveForm;
--    depthReg <= depth;
    
--    clkCnt  <= 0;
--    F_s_clk <= 0;
--    --triangleState <= '1';

--    T <= getLFO_T(to_integer(unsigned(rate)));

--    if waveForm = '0' then  --  Triangle
--        F_s <= getLFOFs_Tri(to_integer(unsigned(rate)), 2*to_integer(unsigned(depth)));  -- return LFO(rate)/2/depth
--        sum <= 6;
--    else  --  Saw
--        F_s <= getLFOFs_Saw(to_integer(unsigned(rate)), 1+to_integer(unsigned(depth)));
--        sum <= 6;
--    end if;
        
--elsif enable = '1' then

--    clkCnt  <= clkCnt  + 1;
--    F_s_clk <= F_s_clk + 1;

--    if waveForm = '0' then
    
----                if depthCnt = to_integer(unsigned(depth)) then
        
----                    triangleState <= not triangleState;
        
----                end if;    
        
--        if clkCnt = T then
        
--            clkCnt <= 0;
--            F_s_clk <= 0;
--            --triangleState <= not triangleState;
--            --F_s_clk <= 0;
--            sum <= 6;
--            depthCnt <= 0;
            
--        end if;
        
--        if F_s_clk = F_s then
        
--            F_s_clk <= 0;
--            depthCnt <= depthCnt + 1;
            
--            if depthCnt < to_integer(unsigned(depth)) 
--            then sum <= sum + 1;                        
--            else sum <= sum - 1; 
--            end if;  
                              
--        end if;
--    else
--        if clkCnt = T then
--            F_s_clk <= 0;
--            clkCnt <= 0;                    
--            sum <= 6;
--            --depthCnt <= 0;
--        elsif F_s_clk = F_s then
--            F_s_clk <= 0;
--            sum <= sum + 1;
--        end if;
--    end if;
--else
--    sum <= 6;
--end if;
