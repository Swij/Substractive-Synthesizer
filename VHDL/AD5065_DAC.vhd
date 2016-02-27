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

    type stateType is (IDLE, STARTDELAY, HEAD, COMADD, DATAOUT, TAIL, ENDING);
    signal curr_state, next_state : stateType := IDLE;
    
    signal clkState : std_logic := '0';
    
--    Address Commands
    constant address : std_logic_vector(3 downto 0) := "1010";
--    A3    A2    A1    A0
    
--    0     0     0     0     DAC A
--    0     0     1     1     DAC B
--    0     0     0     1     Reserved
--    0     0     1     0     Reserved
--    1     1     1     1     Both DACs
    
--    Command Definitions
    constant command : std_logic_vector(3 downto 0) := "1010";
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
    
    signal watchClk : natural;
    signal watchCmdCnt : natural;
    signal watchIndexCnt : natural;
        
    signal clkReg : std_logic := '0';

begin

--    Pulsing this pin low allows any or all DAC registers to be updated if the input registers have new data. This
--    allows all DAC outputs to simultaneously update. This pin can be tied permanently low in standalone
--    mode. When daisy-chain mode is enabled, this pin cannot be tied permanently low. The LDAC pin should
--    be used in asynchronous LDAC update mode, as shown in Figure 3, and the LDAC pin must be brought
--    high after pulsing. This allows all DAC outputs to simultaneously update.
    LDAC <= '0';
    
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
            SCLK <= '1';
            clkCnt := 0;
        end if;    
        
    end if;
    
end process;    

    
dac_process: process(clk,curr_state)
variable clkCnt : natural range 0 TO 255:= 0;
variable cmdCnt : natural range 0 TO 255:= 0;
variable index : natural range 0 TO 255 := 0;
begin

    if rising_edge(clk) then
    watchClk <= clkCnt;
    watchCmdCnt <= cmdCnt;
    watchIndexCnt <= index;
    
    case curr_state is
    
        when IDLE =>
        
            clkCnt := 0;
            cmdCnt := 0;
            index := 7;
            
            if start = '1' then
                next_state <= STARTDELAY;
                SYNC <= '0';
            else
                SYNC <= '1';               
            end if;
            
            SDO  <= '1';
            ready <= '0';
            clkState <= '0';
            
        when STARTDELAY =>
            
            if clkCnt = 4 then
                clkCnt := 0;
                next_state <= HEAD;
                SDO  <= '0';
            else
                clkCnt := clkCnt + 1;
            end if;
                    
        when HEAD =>

            if clkCnt = 4*4 then
                clkCnt := 0;
                next_state <= COMADD;
                cmdCnt := 3;
            else
                clkCnt := clkCnt + 1;
            end if;
            clkState <= '1';
            
        when COMADD =>
        
            if clkCnt = 4*8-1 then
                clkCnt := 0;
                next_state <= DATAOUT;
                index := 15;
                cmdCnt := 3;
            else
                clkCnt := clkCnt + 1;      
                if next_state /= DATAOUT then      
                    if cmdCnt = 3 then                
                        SDO <= commaddress(index);
                        cmdCnt := 0;
                        if index /= 0 then
                            index := index - 1;
                        end if;
                    else
                        cmdCnt := cmdCnt + 1;
                    end if;
                end if;
            end if;
        
        when DATAOUT =>

            if clkCnt = 4*dataBits-1 then
                clkCnt := 0;
                next_state <= TAIL;
            else
                clkCnt := clkCnt + 1;
                if cmdCnt = 3 then
                       
                    SDO <= data(index);
                    cmdCnt := 0;
                    if index /= 0 then
                        index := index - 1;
                    end if;
                
                else
                    cmdCnt := cmdCnt + 1;
                end if;
            end if;
        
        when TAIL =>
        
            if clkCnt = 4*4-1 then
                clkCnt := 0;
                next_state <= ENDING;
                SYNC <= '1';
                
            else
                clkCnt := clkCnt + 1;
            end if;
        
        when ENDING =>
            if clkCnt = 400 then        --  
                clkCnt := 0;
                next_state <= IDLE;
                ready <= '1';
            else
                clkCnt := clkCnt + 1;
            end if;
            
             
    end case;     
    end if;
end process;

end arch_AD5065_DAC;