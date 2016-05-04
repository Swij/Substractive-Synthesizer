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
        dutyCycle   : in STD_LOGIC_VECTOR (6 downto 0);
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
    signal dutyReg : STD_LOGIC_VECTOR (6 downto 0);
    signal semiReg : STD_LOGIC_VECTOR (4 downto 0);
    
    type stateType is (RESTART,SETUP,RUN);
    signal curr_state : stateType := RESTART;
    --signal next_state : stateType := RESTART;

    signal setupCnt : integer range 0 to 255 := 0;
    signal semiRegT : integer;
    signal semiRegFs : integer; 
    
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
        
        setupCnt <= 0;
        
    elsif rising_edge(clk) then

        case curr_state is
        
        when RESTART =>
        
            noteReg <= note;
            waveReg <= waveForm;
            dutyReg <= dutyCycle;
            semiReg <= semi;
                                   
            semit := to_integer(signed(semi));
            clkCnt <= 0;--getT(to_integer(unsigned(note)))/2 - getT(to_integer(unsigned(note)))/32;
            F_s_clk <= 0;
            triangleState <= '1';
            
            
            --  If positive semi    
            if (to_integer(signed(semi)) > 0 and to_integer(signed(semi)) < 12) and note /= "01011111" then
                T    <= getSemiT(to_integer(unsigned(note)), to_integer(signed(semi)));
                F_s  <= getSemiF(to_integer(unsigned(note)), to_integer(signed(semi)));
                duty <= getSemiD(to_integer(unsigned(note)), to_integer(signed(semi)), to_integer(unsigned(dutyCycle)));
            elsif (to_integer(signed(semi)) < 0 and to_integer(signed(semi)) > -12) and note /= "00000000" then
                T    <= getSemiT(to_integer(unsigned(note)), to_integer(signed(semi)));
                F_s  <= getSemiF(to_integer(unsigned(note)), to_integer(signed(semi)));
                duty <= getSemiD(to_integer(unsigned(note)), to_integer(signed(semi)), to_integer(unsigned(dutyCycle)));
            else
            --if semit = 0 then
                T   <= getT(to_integer(unsigned(note)));
                F_s <= getFs(to_integer(unsigned(note)));
                
                if to_integer(unsigned(dutyCycle)) < 1 or to_integer(unsigned(dutyCycle)) > 99 then
                    duty <= getT(to_integer(unsigned(note))) / 2;
                else            
                    duty <= getT(to_integer(unsigned(note))) / 100 * to_integer(unsigned(dutyCycle));
                end if;
            end if;
            
            --  Square
            if waveForm = SQUARE then
                sum <= 0;        
                squareWave <= ('0',OTHERS => '1');
                output <= squareWave;

        --  Triangle    
            elsif waveForm = TRIANGLE then
                sum <= -2**(11)+1;
                inc <= getInc(0);
                triangleWave <= STD_LOGIC_VECTOR(to_signed(sum,12));                  
                output <= triangleWave;
                
        --  Saw
            elsif waveForm = SAW1 then
                sum <= -2**(11) + 1;
                inc <= getInc(1);
                sawWave <= STD_LOGIC_VECTOR(to_signed(sum,12));
                output <= sawWave;
                
            else --  waveForm = "11" then
                sum <= 2**(11) - 1;
                inc <= getInc(1);
                sawWave <= STD_LOGIC_VECTOR(to_unsigned(sum,12));
                output <= sawWave;
            end if;
            
            curr_state <= SETUP;
            
        when SETUP =>
            
            if setupCnt = 200 
            then curr_state <= RUN; setupCnt <= 0;
            else curr_state <= RUN; setupCnt <= setupCnt + 1;
            end if;
        
        when RUN => 
                    
            if noteReg /= note or waveReg /= waveForm or dutyReg /= dutyCycle or semiReg /= semi 
            then curr_state <= RESTART;
            else curr_state <= RUN;
            end if;
            
            if enable = '1' then
    
            --  Counter increment
                clkCnt <= clkCnt + 1;
                F_s_clk <= F_s_clk + 1;
    
                if waveForm = TRIANGLE or waveForm = SQUARE then
                    
                    --  Set triangle state - down or up
                    if clkCnt = T/2 then                    
                        triangleState <= not triangleState;
                        sum <= 2**(11)-1;                    
                    elsif clkCnt = T then                
                        clkCnt <= 0;
                        F_s_clk <= 0;
                        squareWave <= not squareWave;
                        triangleState <= not triangleState;
                    end if;
                    
                    --  Sample Increment
                    if F_s_clk = F_s then                
                        F_s_clk <= 0;                    
                        if triangleState = '1' 
                        then sum <= sum + inc;                        
                        else sum <= sum - inc;                        
                        end if;                    
                    end if;
                    
                    --  Square wave
                    if clkCnt = duty then                
                        squareWave <= not squareWave;                    
                    end if;
                    
                    triangleWave <= STD_LOGIC_VECTOR(to_signed(sum,12));                
                    
                    if waveForm = SQUARE
                    then output <= squareWave;                    
                    else output <= triangleWave;
                    end if;
                    
    
    --          Saw
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
        end case;
    end if;
end process;
    
end arch_geometric;
