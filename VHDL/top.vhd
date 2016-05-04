library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library ieee_proposed;
use ieee_proposed.fixed_float_types.all;
use ieee_proposed.fixed_pkg.all;

use work.aids.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity top is
    port(
        --  SYSTEM CLOCK
        SYSCLK_P  : in STD_LOGIC;
        SYSCLK_N  : in STD_LOGIC;
        
        --  BUTTONS ON PCB
        GPIO_SW_N : in STD_LOGIC;
        GPIO_SW_S : in STD_LOGIC;
        GPIO_SW_W : in STD_LOGIC;
        GPIO_SW_E : in STD_LOGIC;
        GPIO_SW_C : in STD_LOGIC;
        
        --  LED ON PCB
        GPIO_LED_0 : out STD_LOGIC;
        GPIO_LED_1 : out STD_LOGIC;
        GPIO_LED_2 : out STD_LOGIC;
        GPIO_LED_3 : out STD_LOGIC;
        
        --  ENCODER ON PCB
--        ROTARY_INCA : in STD_LOGIC;
--        ROTARY_INCB : in STD_LOGIC;
--        ROTARY_PUSH : in STD_LOGIC;
        
        --  DIP ON PCB
        GPIO_DIP_SW0 : in STD_LOGIC;
        GPIO_DIP_SW1 : in STD_LOGIC;
        GPIO_DIP_SW2 : in STD_LOGIC;
        GPIO_DIP_SW3 : in STD_LOGIC;
        
        --  DAC ON PCB
        XADC_GPIO_0 : out STD_LOGIC;  --  LDAC
        XADC_GPIO_1 : out STD_LOGIC;  --  SCLK
        XADC_GPIO_2 : out STD_LOGIC;  --  DIN
        XADC_GPIO_3 : out STD_LOGIC;  --  SYNC
        
        --  ENCODERS
        FMC1_HPC_HA02_P : in STD_LOGIC;
        FMC1_HPC_HA02_N : in STD_LOGIC;
        FMC1_HPC_HA03_P : in STD_LOGIC;
        FMC1_HPC_HA03_N : in STD_LOGIC;
        FMC1_HPC_HA04_P : in STD_LOGIC;
        FMC1_HPC_HA04_N : in STD_LOGIC;
        FMC1_HPC_HA05_P : in STD_LOGIC;
        FMC1_HPC_HA05_N : in STD_LOGIC;
        FMC1_HPC_HA06_P : in STD_LOGIC;
        FMC1_HPC_HA06_N : in STD_LOGIC;
        FMC1_HPC_HA07_P : in STD_LOGIC;
        FMC1_HPC_HA07_N : in STD_LOGIC;
        FMC1_HPC_HA08_P : in STD_LOGIC;
        FMC1_HPC_HA08_N : in STD_LOGIC;
        FMC1_HPC_HA09_P : in STD_LOGIC;
        FMC1_HPC_HA09_N : in STD_LOGIC;
        FMC1_HPC_HA19_P : in STD_LOGIC;
        FMC1_HPC_HA19_N : in STD_LOGIC;        
        
        FMC1_HPC_HA10_P : out STD_LOGIC;  -- +
        FMC1_HPC_HA10_N : out STD_LOGIC;  -- -
        
        --  LCD (LVCMOS25)
        FMC1_HPC_LA02_P : out STD_LOGIC	--  DB7
--        FMC1_HPC_LA02_N : out STD_LOGIC;	--  ...
--        FMC1_HPC_LA03_P : out STD_LOGIC;	--  ...     
--        FMC1_HPC_LA03_N : out STD_LOGIC;	--  ...
--        FMC1_HPC_LA04_P : out STD_LOGIC;	--  ...
--        FMC1_HPC_LA04_N : out STD_LOGIC;	--  ...
--        FMC1_HPC_LA05_P : out STD_LOGIC;	--  ...
--        FMC1_HPC_LA05_N : out STD_LOGIC;	--  DB0
		
--	      FMC1_HPC_LA06_P : out STD_LOGIC;	--  E
--        FMC1_HPC_LA06_N : out STD_LOGIC;	--  RW
--        FMC1_HPC_LA07_P : out STD_LOGIC;	--  RS
--        FMC1_HPC_LA10_P : out STD_LOGIC
        
    );
end top;

architecture arch_top of top is

    --  Clock signals
    signal clk : STD_LOGIC;
    signal counter : STD_LOGIC_VECTOR(31 downto 0) :=(others => '0');
    signal I : STD_LOGIC;
    signal IB : STD_LOGIC;
    
    signal reset : STD_LOGIC;
    
    --  Oscillator component
    component oscillator is
    port( clk       : in STD_LOGIC;
          reset     : in STD_LOGIC;
          enable    : in STD_LOGIC;
          waveForm  : in WAVE;
          note      : in STD_LOGIC_VECTOR (7 downto 0);
          semi      : in STD_LOGIC_VECTOR (4 downto 0);
          dutyCycle : in STD_LOGIC_VECTOR (6 downto 0);
          output    : out STD_LOGIC_VECTOR (11 downto 0));
    end component;
    
    signal OSC1enable    : STD_LOGIC;
    signal OSC1waveForm  : WAVE;
    signal OSC1note      : STD_LOGIC_VECTOR (7 downto 0) := "01010101";
    signal OSC1semi      : STD_LOGIC_VECTOR (4 downto 0);
    signal OSC1dutyCycle : STD_LOGIC_VECTOR (6 downto 0);
    signal OSC1output    : STD_LOGIC_VECTOR (11 downto 0);
    signal OSC1dutyCycleREG : integer range 0 to 127 := 50;
    
    --  Encoder component
    component encoderTop is
    port( clk    : in STD_LOGIC;
          reset  : in STD_LOGIC;        
          A      : in STD_LOGIC;        
          B      : in STD_LOGIC;                
          C      : in STD_LOGIC;        
          change : out STD_LOGIC;
          dir    : out STD_LOGIC;
          btn    : out STD_LOGIC);
    end component;

    type   encoderArray is array (0 to 5) of std_logic_vector(2 downto 0);
    signal encoders : encoderArray;
    
    --type   encoder std_logic_vector(2 downto 0);

    --  Prescale component
    component prescaler is
    generic( prescale : NATURAL := 4000);
    port( clk    : in STD_LOGIC;
          preClk : out STD_LOGIC
    );
    end component;
    
    signal preClk : STD_LOGIC;
     
    -- IIR filter component
    component IIR is
    generic( WIDTH   : INTEGER := 12;
             F_WIDTH : INTEGER := 12);
    port( clk    : STD_LOGIC;
          fclk   : STD_LOGIC;
          reset  : in STD_LOGIC;
          ftype  : FILTER;
          cutoff : in integer;
          Q      : in sfixed(16 downto -F_WIDTH);
          x      : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
          y      : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
    end component;

    signal cutoff       : integer;
    signal Q            : sfixed(16 downto -12);
    signal ftype        : FILTER := LP;
    signal filterOut    : STD_LOGIC_VECTOR(11 downto 0);
    signal filterIn     : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal enablefilter : STD_LOGIC;
    
    --  DAC component
    component AD5065_DAC is
    generic( totalBits : natural := 32;
             dataBits  : natural := 16 );
    port( clk   : in std_logic;
          reset : in std_logic;
          data  : in std_logic_vector(dataBits-1 DOWNTO 0);
          start : in std_logic;
          ready : out std_logic;
          SCLK  : out std_logic;   
          SYNC  : out std_logic;
          SDO   : out std_logic;
          LDAC  : out std_logic);
    end component;

    signal DACdata  : std_logic_vector(15 DOWNTO 0);
    signal DACstart : std_logic;
    signal DACready : std_logic;

    --  Envelope component
    component ASR is
    generic( WIDTH : integer := 12);
    port( clk      : in std_logic;
          reset    : in std_logic;
          x        : in std_logic_vector(WIDTH-1 downto 0);
          attack   : in std_logic;
          release  : in std_logic;
          atk_time : in std_logic_vector(WIDTH-1 downto 0);
          rls_time : in std_logic_vector(WIDTH-1 downto 0);
          y        : out std_logic_vector(WIDTH-1 downto 0));
    end component;
    
    signal ASR_x        : std_logic_vector(12-1 downto 0);
    signal ASR_attack   : std_logic;
    signal ASR_release  : std_logic;
    signal ASR_atk_time : std_logic_vector(12-1 downto 0);
    signal ASR_rls_time : std_logic_vector(12-1 downto 0);
    signal ASR_y        : std_logic_vector(12-1 downto 0);

    -- LFO component (duty-cycle)
    component LFO_duty is
    port( clk      : in std_logic;
          reset    : in std_logic;
          restart  : in std_logic;
          enable   : in std_logic;
          rate     : in std_logic_vector (7 downto 0);
          depth    : in std_logic_vector (6 downto 0);
          waveForm : in std_logic;
          output   : out std_logic_vector (6 downto 0));
    end component;
    
    signal LFOduty_restart  : std_logic;
    signal LFOduty_enable   : std_logic;
    signal LFOduty_rate     : std_logic_vector (7 downto 0);
    signal LFOduty_depth    : std_logic_vector (6 downto 0);
    signal LFOduty_waveForm : std_logic;
    signal LFOduty_output   : std_logic_vector (6 downto 0);
    signal LFOduty_setting  : std_logic;
    signal LFOduty_rateReg  : integer range 0 to 255 := 198; -- std_logic_vector (7 downto 0);
    signal LFOduty_depthReg : integer range 0 to 127 := 50; -- std_logic_vector (6 downto 0);
    
    -- Button component
    component button is
    port( clk     : in STD_LOGIC;
          reset   : in STD_LOGIC;
          btn_in  : in STD_LOGIC;
          btn_out : out STD_LOGIC);
    end component;
    
    signal btn0_in  : std_logic; 
    signal btn0_out : std_logic;
        
	-- MIDI components
	component Uart is
    port( Data_in   : in std_logic;
          Reset     : in std_logic;
          Clock     : in std_logic;
          Data_send : out std_logic;
          Data_out  : out std_logic_vector(7 downto 0) );
	end component;
	
	component MIDI_Decoder is 
	port( Data_in    : in std_logic_vector(7 downto 0);
          Data_ready : in std_logic;
          Reset      : in std_logic;
          Clock      : in std_logic;
          Data_out   : out std_logic_vector(15 downto 0);
          Data_send  : out std_logic;
          Note_state_out : out std_logic );
	end component;
	
	component MIDI_to_Osc is
	port( Data_in    : in std_logic_vector(15 downto 0);
          Note_on    : in std_logic;
          Data_ready : in std_logic;
          Reset      : in std_logic;
          Clock      : in std_logic;
          Note       : out std_logic_vector(7 downto 0) );
	end component;
	
	component ClockEnable is
    generic( DesiredFreq : integer;
             ClockFreq : integer);
    port(
        ClockIn  : in std_logic;
        Reset    : in std_logic;
        ClockOut : out std_logic );
    end component;
	
    signal Clock_Enable : std_logic;
    signal Uart_send    : std_logic;
    signal Uart_Dec     : std_logic_vector(7 downto 0);
    signal Note_data    : std_logic_vector(15 downto 0);
    signal Note_ready   : std_logic;
    signal Note_state   : std_logic;
    signal Note_out     : std_logic_vector(7 downto 0);
	
    --  LCD component
--    component LCD is
--    port( clk    : in  std_logic;
--    	  reset  : in  std_logic;
--		  LCD_RS : out std_logic;
--		  LCD_RW : out std_logic;
--		  LCD_E  : out std_logic;
--		  DATA   : out std_logic_vector(7 downto 0);
--		  cmd	 : in  std_logic_vector(3 downto 0);
--		  int    : in std_logic_vector(13 downto 0);
--		  write  : in std_logic;
--		  init   : in std_logic;
--		  led    : out std_logic_vector(3 downto 0));     
--	end component;
	
--    signal LCD_RS	 : std_logic;
--    signal LCD_RW	 : std_logic;
--    signal LCD_E	 : std_logic;
--    signal LCD_DATA	 : std_logic_vector(7 downto 0);
--    signal LCD_cmd	 : std_logic_vector(3 downto 0);
--    signal LCD_int	 : std_logic_vector(13 downto 0);
--    signal LCD_write : std_logic;
--    signal LCD_init     : std_logic;
--    signal LCD_clear     : std_logic;
--    signal LCD_led   : std_logic_vector(3 downto 0);

    --  Test signals and others...
    signal gpioLEDS : std_logic_vector(3 downto 0);
    signal waveReg : integer range 0 to 7 := 0;
    signal semiReg : integer range -11 to 11 := 0;
    signal dutyReg : integer range 0 to 100 := 50;
    signal cuttReg : integer range 0 to 5000 := 1000;    
       
begin    

IBUFDS_inst: IBUFDS
    generic map( IOSTANDARD => "LVDS_25" )
    port map ( O => clk, I => I, IB => IB );  -- clock buffer output, diff_p clock buffer input, diff_n clock buffer input 
    I  <= SYSCLK_P;
    IB <= SYSCLK_N;

oscillator_comp:component oscillator
    port map( clk, reset, OSC1enable, OSC1waveForm, Note_out, OSC1semi, OSC1dutyCycle, OSC1output );

encoderTop_comp1:component encoderTop
    port map( clk, '1', FMC1_HPC_HA02_P, FMC1_HPC_HA02_N, FMC1_HPC_HA03_P, encoders(0)(0), encoders(0)(1), encoders(0)(2) );
        
encoderTop_comp2:component encoderTop
    port map( clk, '1', FMC1_HPC_HA03_N, FMC1_HPC_HA04_P, FMC1_HPC_HA04_N, encoders(1)(0), encoders(1)(1), encoders(1)(2) );
    
encoderTop_comp3:component encoderTop
    port map( clk, '1', FMC1_HPC_HA05_P, FMC1_HPC_HA05_N, FMC1_HPC_HA06_P, encoders(2)(0), encoders(2)(1), encoders(2)(2) );
    
encoderTop_comp4:component encoderTop
    port map( clk, '1', FMC1_HPC_HA06_N, FMC1_HPC_HA07_P, FMC1_HPC_HA07_N, encoders(3)(0), encoders(3)(1), encoders(3)(2) );
   
encoderTop_comp5:component encoderTop
    port map( clk, '1', FMC1_HPC_HA08_P, FMC1_HPC_HA08_N, FMC1_HPC_HA09_P, encoders(4)(0), encoders(4)(1), encoders(4)(2) );
    
encoderTop_comp6:component encoderTop
    port map( clk, '1', FMC1_HPC_HA09_N, FMC1_HPC_HA19_P, FMC1_HPC_HA19_N, encoders(5)(0), encoders(5)(1), encoders(5)(2) );

prescale_comp:component prescaler
    generic map ( prescale => 4000 )
    port map ( clk, preClk );

IIR_comp:component IIR
    port map ( preClk, clk, reset, ftype, cutoff, Q, filterIn, filterOut );

DAC_comp:component AD5065_DAC
    port map( clk, reset, DACdata, DACstart, DACready, XADC_GPIO_1, XADC_GPIO_3, XADC_GPIO_2, XADC_GPIO_0 );
    
LFOduty_comp:component LFO_duty
    port map( clk, reset, LFOduty_restart,  LFOduty_enable, LFOduty_rate, LFOduty_depth, LFOduty_waveForm, LFOduty_output );
	
ASR_comp:component ASR
        port map( preClkASR, reset, OSC1output, ASR_attack, ASR_release, ASR_atk_time, ASR_rls_time, ASR_y );
    
btn_comp0:component button
    port map( clk, reset, GPIO_SW_S, btn0_out );

Uart_inst: COMPONENT Uart
	port map(PMOD_0, Reset, Clock_Enable, Uart_send, Uart_Dec);
	
MIDI_dec_inst: COMPONENT MIDI_Decoder
	port map(Uart_Dec, Uart_send, Reset, Clock_Enable, Note_data, Note_ready, Note_state);
	
MIDI_to_osc_inst: COMPONENT MIDI_to_Osc
	port map(Note_data, Note_state, Note_ready, Reset, Clock_Enable, Note_out);
	
ClockEn_inst: COMPONENT ClockEnable
	generic map(DesiredFreq => 312500, ClockFreq => 200000000)
	port map(Clk, Reset, Clock_Enable);
	
--LCD_comp:component LCD
--	--port map( clk, reset, FMC1_HPC_LA07_P, FMC1_HPC_LA06_N, FMC1_HPC_LA06_P, LCD_DATA, LCD_cmd, LCD_int, LCD_write, LCD_init, LCD_led );
--	port map( clk, reset, LCD_RS, LCD_RW, LCD_E, LCD_DATA, LCD_cmd, LCD_int, LCD_write, LCD_init, LCD_led );

Uart_inst: COMPONENT Uart
	port map(PMOD_0, Reset, Clock_Enable, Uart_send, Uart_Dec);
	
MIDI_dec_inst: COMPONENT MIDI_Decoder
	port map(Uart_Dec, Uart_send, Reset, Clock_Enable, Note_data, Note_ready, Note_state);
	
MIDI_to_osc_inst: COMPONENT MIDI_to_Osc
	port map(Note_data, Note_state, Note_ready, Reset, Clock_Enable, Note_out);
	
ClockEn_inst: COMPONENT ClockEnable
	generic map(DesiredFreq => 312500, ClockFreq => 200000000)
	port map(Clk, Reset, Clock_Enable);


--------------------------------------------------------------------------------
---- GPIO coupling
--------------------------------------------------------------------------------

    --  LED
    GPIO_LED_0 <= gpioLEDS(0);
    GPIO_LED_1 <= gpioLEDS(1);
    GPIO_LED_2 <= gpioLEDS(2);
    GPIO_LED_3 <= gpioLEDS(3);
    
    gpioLEDS(0) <= LFOduty_setting;
    --  ENCODERS
    FMC1_HPC_HA10_P <= '1';  --  +
    FMC1_HPC_HA10_N <= '0';  --  -;

    
    --  FILTER
    enablefilter <= GPIO_DIP_SW3;
    cutoff <= cuttReg;   
    --filterIn <= std_logic_vector(to_signed(to_integer(signed(oscOutput))+to_integer(signed(oscOutput2)), 13));
    filterIn <= OSC1output;
    Q <= to_sfixed(0.7071, Q);
        
    --  LFO DUTY
    LFOduty_enable <= GPIO_DIP_SW2;
    LFOduty_rate  <= std_logic_vector(to_unsigned(LFOduty_rateReg,8));
    LFOduty_depth <= std_logic_vector(to_unsigned(LFOduty_depthReg,7));
    
    --  OSCILLATOR 1
    OSC1enable <= '1'; 
    OSC1waveForm <= to_wave(std_logic_vector(to_unsigned(waveReg,3)));
    --OSC1dutyCycle <= std_logic_vector(to_signed(dutyReg,7));
    OSC1semi <= std_logic_vector(to_signed(semiReg,5));
    
    --  LCD Data signal
--    FMC1_HPC_LA06_P <= LCD_E;
--    FMC1_HPC_LA06_N <= LCD_RW--    FMC1_HPC_LA07_P <= LCD_RS ;
        
--    FMC1_HPC_LA05_N <= LCD_DATA(0);
--    FMC1_HPC_LA05_P <= LCD_DATA(1);
--    FMC1_HPC_LA04_N <= LCD_DATA(2);
--    FMC1_HPC_LA04_P <= LCD_DATA(3);--
--    FMC1_HPC_LA03_N <= LCD_DATA(4);-- 0x38
--    FMC1_HPC_LA03_P <= LCD_DATA(5);--
--    FMC1_HPC_LA02_N <= LCD_DATA(6);
--    FMC1_HPC_LA02_P <= LCD_DATA(7);        
--    LCD_DATA(0) <= FMC1_HPC_LA05_N;
--    LCD_DATA(1) <= FMC1_HPC_LA05_P;
--    LCD_DATA(2) <= FMC1_HPC_LA04_N;
--    LCD_DATA(3) <= FMC1_HPC_LA04_P;
--    LCD_DATA(4) <= FMC1_HPC_LA03_N;
--    LCD_DATA(5) <= FMC1_HPC_LA03_P;
--    LCD_DATA(6) <= FMC1_HPC_LA02_N;
--    LCD_DATA(7) <= FMC1_HPC_LA02_P;

--------------------------------------------------------------------------------
---- Constant signals
--------------------------------------------------------------------------------



--    gpioLEDS(0) <= LCD_led(0);
--    gpioLEDS(1) <= LCD_led(1);
--    gpioLEDS(2) <= LCD_led(2);
--    gpioLEDS(3) <= LCD_led(3);
    
top_process:
process(clk)
--variable waveReg : integer range 0 to 7 := 0;
--variable semiReg : integer range -11 to 11 := 0;
--variable dutyReg : integer range 0 to 100 := 50;
--variable cuttReg : integer range 0 to 5000 := 0;
begin

    if rising_edge(clk) then

    --OSC1semi <= (OTHERS => '0');

    
    
        --  RESET
        if GPIO_SW_N = '1' then 
        
            reset <= '0';   
                     
            --gpioLEDS(0) <= '0';
            gpioLEDS(1) <= '0';
            gpioLEDS(2) <= '0';
            gpioLEDS(3) <= '0';
            
            --waveReg <= 0;
            --semiReg <= 0;
            --dutyReg <= 50;
            
            --cuttReg <= 1000;
            
--            LFOduty_rateReg  <=  0;     --  Lowest frequency
--            LFOduty_depthReg <= 50;     --  Starts at 6, to make it count to 50 => set to 44
--            LFOduty_waveForm <= '0';
--            LFOduty_setting  <= '0';
            
            --OSC1dutyCycleREG <= 50;
            
        else
        
            reset <= '1';    

             --if encoders(0)(2) = '1' then
                 --gpioLEDS(0) <= LFOduty_setting;
             --end if;          


            
        --  DAC               
            if preClk = '1' then
                --if DACready = '1' then
                    --DACdata(3 downto 0) <= (OTHERS => '0');
                    if enablefilter = '1' then
                        --DACdata(15 downto 4) <= std_logic_vector(signed(filterOut) + 2048);
                        DACdata(15 downto 9) <= LFOduty_output;
                        DACdata(8 downto 0) <= (OTHERS => '0');
                    else
                        DACdata(15 downto 4) <= std_logic_vector(signed(OSC1output) + 2048);
                        DACdata(3 downto 0) <= "0000";
                    end if;
                    DACstart <= '1';
                --else
                    --DACstart <= '0';
                --end if;
            else
                DACstart <= '0';
            end if;

            
--            if encoders(0)(2) = '1' then
--                LFOduty_setting <= not(LFOduty_setting);
--                gpioLEDS(0) <= not(gpioLEDS(0));
--            end if;
            

            
            
--            signal LFOduty_rate     : std_logic_vector (7 downto 0);
--            signal LFOduty_depth    : std_logic_vector (4 downto 0);
--            signal LFOduty_waveForm : std_logic;
--            signal LFOduty_output   : std_logic_vector (6 downto 0);
                     
        end if;
    end if;
    
end process;

enc_cut_process:
process(clk)
begin

    if GPIO_SW_N = '1' then
    
        cuttReg <= 1000;
        
    elsif rising_edge(clk) then
    
        --  CUTTOFF
        if encoders(1)(0) = '1' then
            if encoders(1)(1) = '1' then
                if cuttReg < 4901 then
                    cuttReg <= cuttReg + 100;
                else
                    cuttReg <= 5000;
                end if;                      
            else
                if cuttReg > 99 then
                    cuttReg <= cuttReg - 100;
                else
                    cuttReg <= 0;
                end if;
            end if;
        end if;
    end if;
end process;

enc_duty_process:
process(clk)
begin

    if GPIO_SW_N = '1' then
    
        dutyReg <= 50;
        
    elsif rising_edge(clk) then
        --  DUTY
        if encoders(2)(0) = '1' then
            if encoders(2)(1) = '1' then
                if dutyReg < 94 then
                    dutyReg <= dutyReg + 1;
                else
                    dutyReg <= 94;
                end if;                      
            else
                if dutyReg > 6 then
                    dutyReg <= dutyReg - 1;
                else
                    dutyReg <= 6;
                end if;    
            end if;
        end if;
        --dutyCycle <= "00110010";
    end if;
end process;

enc_semi_process:
process(clk)
begin

    if GPIO_SW_N = '1' then
    
        semiReg <= 0;
        
    elsif rising_edge(clk) then
            --  SEMI
        if encoders(3)(0) = '1' then
            if encoders(3)(1) = '1' then--increase
                if semiReg < 11 then
                    semiReg <= semiReg + 1;
                else
                    semiReg <= 11;
                    
                end if;                      
            else
                if semiReg > -11 then
                    semiReg <= semiReg - 1;
                else
                    semiReg <= -11;
                end if;    
            end if;
        end if;
    end if;
end process;

enc_wave_process:
process(clk)
begin

    if GPIO_SW_N = '1' then
    
        waveReg <= 0;
        
    elsif rising_edge(clk) then
        --  WAVE, 000=Sine, 001=Cosine, 010=Square, 011=Triangle, 100=Saw1, 101=Saw2, 110=Saw1, 111=Saw2
        if encoders(4)(0) = '1' then
            if encoders(4)(1) = '1' then
                if waveReg < 7 then
                    waveReg <= waveReg + 1;
                else
                    waveReg <= 0;
                end if;    
            else
                if waveReg > 0 then
                    waveReg <= waveReg - 1;
                else
                    waveReg <= 7;
                end if;    
            end if;
        end if;
    end if;
            
end process;

enc_note_process:
process(clk)
begin    --  RESET
    if GPIO_SW_N = '1' then
    
        OSC1note <= "01010101";
        
    elsif rising_edge(clk) then
    
        if encoders(5)(0) = '1' then
            if encoders(5)(1) = '1' then
                if unsigned(OSC1note) < 95 then
                    OSC1note <= std_logic_vector(unsigned(OSC1note) + 1);
                else
                    OSC1note <= std_logic_vector(to_unsigned(95,8));
                end if;    
            else
                if unsigned(OSC1note) > 0 then
                    OSC1note <= std_logic_vector(unsigned(OSC1note) - 1);
                else
                    OSC1note <= (OTHERS => '0');
                end if;    
            end if;
        end if;
    end if;
end process;        
        
LFO1_process:
process(clk)
begin    --  RESET
    if GPIO_SW_N = '1' then 
    
        LFOduty_rateReg  <=  0;     --  Lowest frequency
        LFOduty_depthReg <= 50;     --  Starts at 6, to make it count to 50 => set to 44
        LFOduty_waveForm <= '0';
        LFOduty_setting  <= '0';
        
    elsif rising_edge(clk) then
    
        LFOduty_waveForm <= '0';
        
        --  LFO1: Dutycycle for OSC1
        if encoders(0)(0) = '1' then
            if encoders(0)(1) = '1' then            --  Increase
                if LFOduty_setting = '0' then       --  Rate
                    if LFOduty_rateReg < 198 then
                        LFOduty_rateReg <= LFOduty_rateReg + 1;
                        LFOduty_restart <= '1';
                    end if;
                else                                --  Depth
                    if LFOduty_depthReg < 88 then
                        LFOduty_depthReg <= LFOduty_depthReg + 1;
                        LFOduty_restart <= '1';
                    end if;
                end if;
            else                                    --  Decrease
                if LFOduty_setting = '0' then       --  Rate
                    if LFOduty_rateReg > 0 then
                        LFOduty_rateReg <= LFOduty_rateReg - 1;
                        LFOduty_restart <= '1';
                    end if;
                else                                --  Depth
                    if LFOduty_depthReg > 6 then
                        LFOduty_depthReg <= LFOduty_depthReg - 1;
                        LFOduty_restart <= '1';
                    end if;
                end if;
            end if;
        else
            LFOduty_restart <= '0';
        end if;
        
        if encoders(0)(2) = '1' then
            LFOduty_setting <= not(LFOduty_setting);
        end if;
        
        if LFOduty_enable = '0' then
            OSC1dutyCycle <= std_logic_vector(to_unsigned(dutyReg,7));
        else
            OSC1dutyCycle <= LFOduty_output;
        end if;
            
    end if;
end process;
end arch_top;