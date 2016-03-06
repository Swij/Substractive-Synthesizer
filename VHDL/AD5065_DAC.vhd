library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AD5065_DAC is
    generic(
        totalBits : natural := 32;
        dataBits : natural := 16
    );
    port(
        clk   : in std_logic;
        reset : in std_logic;
        data  : in std_logic_vector(dataBits-1 DOWNTO 0);
        start : in std_logic;
        ready : out std_logic;
         
        SCLK : out std_logic;   
        SYNC : out std_logic;
        SDO  : out std_logic;
        LDAC : out std_logic

    );
end AD5065_DAC;

architecture arch_AD5065_DAC of AD5065_DAC is

    type stateType is (IDLE,  STARTDELAY,HEAD, COMADD, DATAOUT, TAIL, ENDING);--
    signal curr_state, next_state : stateType := IDLE;
    
    signal clkState : std_logic := '0';
    
--    Address Commands
    constant address : std_logic_vector(3 downto 0) := "0011";
--    A3    A2    A1    A0
      
--    0     0     0     0     DAC A
--    0     0     1     1     DAC B
--    0     0     0     1     Reserved
--    0     0     1     0     Reserved
--    1     1     1     1     Both DACs
      
--    Command Definitions
    constant command : std_logic_vector(3 downto 0) := "0000";
--    C3    C2    C1    C0
      
--    0     0     0     0     Write to Input Register n
--    0     0     0     1     Update DAC Register n
--    0     0     1     0     Write to Input Register n, update all (software LDAC)
--    0     0     1     1     Write to and update DAC Channel n
--    0     1     0     0     Power down/power up DAC
--    0     1     0     1     Load clear code register
--    0     1     1     0     Load LDAC register
--    0     1     1     1     Reset (power-on reset)
--    1     0     0     0     Set up DCEN register (daisy-chain enable)
--    1     0     0     1     Reserved
--    1     1     1     1     Reserved
      
    constant commaddress : std_logic_vector(7 downto 0) := command & address;
      
    constant tailData : std_logic_vector(3 downto 0) := "0000";
        
    signal clkReg : std_logic := '0';
      
begin
      
--    Pulsing this pin low allows any or all DAC registers to be updated if the input registers have new data. This
--    allows all DAC outputs to simultaneously update. This pin can be tied permanently low in standalone
--    mode. When daisy-chain mode is enabled, this pin cannot be tied permanently low. The LDAC pin should
--    be used in asynchronous LDAC update mode, as shown in Figure 3, and the LDAC pin must be brought
--    high after pulsing. This allows all DAC outputs to simultaneously update.
    --LDAC <= '0';
      
state_process: process(reset, clk)
variable clkCnt : natural range 0 to 2 := 0;
begin

    if reset = '0' then
    
        clkCnt := 0;
        clkReg <= '0';
        SCLK <= '1';
        
    elsif rising_edge(clk) then
    
        curr_state <= next_state;
        
        if clkState = '1' then
            clkCnt := clkCnt + 1;
            if clkCnt = 2 then
                clkCnt := 0;
                SCLK <= clkReg;
                clkReg <= not(clkReg);
            end if;
        else
            SCLK <= '0';
            clkCnt := 0;
            clkReg <= '0';
        end if;    
        
    end if;
    
end process;    

    
dac_process: process(reset, clk, curr_state)
variable clkCnt : natural range 0 TO 1023 := 0;
variable index  : natural range 0 TO 31 := 0;
variable cnt1   : natural range 0 TO 7  := 0;
variable cnt2   : natural range 0 TO 7  := 0;
variable cnt3   : natural range 0 TO 7  := 0;
begin

    if reset = '0' then
    
        clkCnt := 0;
        index  := 7;
        cnt1   := 0;
        cnt2   := 0;
        cnt3   := 0;
        
        ready <= '0';
        SYNC  <= '0';
        SDO   <= '0';
        LDAC  <= '0';
       
        
    elsif rising_edge(clk) then
        case curr_state is
        
            when IDLE =>
            
                if start = '1' then
                    next_state <= STARTDELAY;
                end if;
 
                clkCnt := 0;
                index  := 7;

                cnt1   := 3;
                cnt2   := 3;
                cnt3   := 3;

                ready <= '1';
                SYNC  <= '1';
                SDO   <= '0';
                LDAC  <= '1';
                
                
            when STARTDELAY =>
            --  Change state
                if clkCnt = 4*2 then
                    clkCnt := 0;
                    next_state <= HEAD;
                else
                    clkCnt := clkCnt + 1;
                end if;
                
            --  Bring down SYNC    
                if clkCnt >= 4 then
                    SYNC <= '0';
                end if;               
                
            --  Starting clock
                if clkCnt >= 6 then
                    clkState <= '1';
                end if;
            
            --  Now it is not ready    
                ready <= '0';
                        
            when HEAD =>
            --  Change state
                if clkCnt = 4*4-1 then
                   clkCnt := 0;
                   next_state <= COMADD;
                else
                   clkCnt := clkCnt + 1;
                end if;

            when COMADD =>
            --  Change state
                if clkCnt = 4*8-1 then
                   clkCnt := 0;
                   next_state <= DATAOUT;
                   
                else
                   clkCnt := clkCnt + 1;
                end if;
            --  Data output
                if cnt1 = 3 then
                    cnt1 := 0;
                    SDO <= commaddress(index);
                    if index /= 0 then
                        index := index - 1;
                    else
                        index := 15;
                        cnt1 := 4;
                    end if;
                else
                    cnt1 := cnt1 + 1;
                end if;

            when DATAOUT =>
                
                if clkCnt = 4*16-1 then
                   clkCnt := 0;
                   next_state <= TAIL;
                else
                   clkCnt := clkCnt + 1;
                end if;
            --  Data output
                if cnt2 = 3 then
                    cnt2 := 0;
                    SDO <= data(index);
                    if index /= 0 then
                        index := index - 1;
                    else
                        index := 3;
                        cnt2 := 4;
                    end if;
                else
                    cnt2 := cnt2 + 1;
                end if;              
            
            when TAIL =>
          
                if clkCnt = 4*4-1 then
                    clkCnt := 0;
                    next_state <= ENDING;
                    clkState <= '0';
                else
                    clkCnt := clkCnt + 1;
                end if;         
            --  Data output
                if cnt3 = 3 then
                    cnt3 := 0;
                    SDO <= tailData(index);
                    if index /= 0 then
                        index := index - 1;
                    else
                        index := 7;
                        cnt3 := 4;
                    end if;
                else
                    cnt3 := cnt3 + 1;
                end if;              
                      
            when ENDING =>
            
                if clkCnt = 4*128-1 then    --  Should be 2µs long
                    clkCnt := 0;
                    next_state <= IDLE;
                else
                    clkCnt := clkCnt + 1;
                end if;      
                
                SYNC  <= '1';
                
                if clkCnt >= 10 then
                    LDAC  <= '1';
                elsif clkCnt >= 5 then
                    LDAC  <= '0';
                else
                    LDAC  <= '1';
                end if;      
                 
        end case;     
    end if;
    
end process;

end arch_AD5065_DAC;