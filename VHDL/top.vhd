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
        SYSCLK_P  : in std_logic;
        SYSCLK_N  : in std_logic;
        
        --  BUTTONS ON PCB
        GPIO_SW_N : in std_logic;
        GPIO_SW_S : in std_logic;
        GPIO_SW_W : in std_logic;
        GPIO_SW_E : in std_logic;
        GPIO_SW_C : in std_logic;
        
        --  LED ON PCB
        GPIO_LED_0 : out std_logic;
        GPIO_LED_1 : out std_logic;
        GPIO_LED_2 : out std_logic;
        GPIO_LED_3 : out std_logic;
        
        --  ENCODER ON PCB
--        ROTARY_INCA : in std_logic;
--        ROTARY_INCB : in std_logic;
--        ROTARY_PUSH : in std_logic;
        
        --  DIP ON PCB
        GPIO_DIP_SW0 : in std_logic;
        GPIO_DIP_SW1 : in std_logic;
        GPIO_DIP_SW2 : in std_logic;
        GPIO_DIP_SW3 : in std_logic;
        
        --  DAC ON PCB
        XADC_GPIO_0 : out std_logic;  --  LDAC
        XADC_GPIO_1 : out std_logic;  --  SCLK
        XADC_GPIO_2 : out std_logic;  --  DIN
        XADC_GPIO_3 : out std_logic;  --  SYNC
        
        --  ENCODERS 1
        FMC1_HPC_HA02_P : in std_logic;
        FMC1_HPC_HA02_N : in std_logic;
        FMC1_HPC_HA03_P : in std_logic;
        FMC1_HPC_HA03_N : in std_logic;
        FMC1_HPC_HA04_P : in std_logic;
        FMC1_HPC_HA04_N : in std_logic;
        FMC1_HPC_HA05_P : in std_logic;
        FMC1_HPC_HA05_N : in std_logic;
        FMC1_HPC_HA06_P : in std_logic;
        FMC1_HPC_HA06_N : in std_logic;
        FMC1_HPC_HA07_P : in std_logic;
        FMC1_HPC_HA07_N : in std_logic;
        FMC1_HPC_HA08_P : in std_logic;
        FMC1_HPC_HA08_N : in std_logic;
        FMC1_HPC_HA09_P : in std_logic;
        FMC1_HPC_HA09_N : in std_logic;
        FMC1_HPC_HA19_P : in std_logic;
        FMC1_HPC_HA19_N : in std_logic;        
        
        FMC1_HPC_HA10_P : out std_logic;  -- +
        FMC1_HPC_HA10_N : out std_logic;  -- -
        
        --  ENCODERS 2
        FMC1_HPC_LA10_P : in std_logic;
        FMC1_HPC_LA10_N : in std_logic;
        FMC1_HPC_LA11_P : in std_logic;
        FMC1_HPC_LA11_N : in std_logic;
        FMC1_HPC_LA12_P : in std_logic;
        FMC1_HPC_LA12_N : in std_logic;
        --FMC1_HPC_LA13_P : in std_logic;
        --FMC1_HPC_LA13_N : in std_logic;
        FMC1_HPC_LA14_P : in std_logic;
        FMC1_HPC_LA14_N : in std_logic;
        --FMC1_HPC_LA15_P : in std_logic;
        --FMC1_HPC_LA15_N : in std_logic;
        
        FMC1_HPC_LA16_P : out std_logic;
        FMC1_HPC_LA16_N : out std_logic;

        --  ENC2
        FMC1_HPC_HA11_P : in std_logic;
        FMC1_HPC_HA11_N : in std_logic;
        FMC1_HPC_HA13_P : in std_logic;
        FMC1_HPC_HA13_N : in std_logic;
        
        --  MIDI IN
        PMOD_0          : in std_logic;
        
        --  LCD (LVCMOS25)
        FMC1_HPC_LA02_P : out std_logic	--  DB7
--        FMC1_HPC_LA02_N : out std_logic;	--  ...
--        FMC1_HPC_LA03_P : out std_logic;	--  ...     
--        FMC1_HPC_LA03_N : out std_logic;	--  ...
--        FMC1_HPC_LA04_P : out std_logic;	--  ...
--        FMC1_HPC_LA04_N : out std_logic;	--  ...
--        FMC1_HPC_LA05_P : out std_logic;	--  ...
--        FMC1_HPC_LA05_N : out std_logic;	--  DB0
		
--	      FMC1_HPC_LA06_P : out std_logic;	--  E
--        FMC1_HPC_LA06_N : out std_logic;	--  RW
--        FMC1_HPC_LA07_P : out std_logic;	--  RS
        
    );
end top;

architecture arch_top of top is

    --  Clock signals
    signal clk : std_logic;
    signal counter : std_logic_vector(31 downto 0) :=(others => '0');
    signal I : std_logic;
    signal IB : std_logic;
    
    signal reset : std_logic;
    
    --  Oscillator component
    component oscillator is
    port( clk       : in std_logic;
          reset     : in std_logic;
          enable    : in std_logic;
          waveForm  : in WAVE;
          note      : in std_logic_vector (7 downto 0);
          semi      : in std_logic_vector (4 downto 0);
          dutyCycle : in std_logic_vector (6 downto 0);
          output    : out std_logic_vector (11 downto 0));
    end component;
    
    signal OSC1enable    : std_logic;
    signal OSC1waveForm  : WAVE;
    signal OSC1note      : std_logic_vector (7 downto 0) := std_logic_vector(to_unsigned(36,8));
    signal OSC1semi      : std_logic_vector (4 downto 0);
    signal OSC1dutyCycle : std_logic_vector (6 downto 0);
    signal OSC1output    : std_logic_vector (11 downto 0);
    signal OSC1dutyCycleREG : integer range 0 to 127 := 50;
    
    --  Encoder component
    component encoderTop is
    port( clk    : in std_logic;
          reset  : in std_logic;        
          A      : in std_logic;        
          B      : in std_logic;                
          C      : in std_logic;        
          change : out std_logic;
          dir    : out std_logic;
          btn    : out std_logic);
    end component;

    type   encoderArray is array (0 to 5) of std_logic_vector(2 downto 0);
    signal encoders : encoderArray;
    signal encoders2 : encoderArray;
        
    --type   encoder std_logic_vector(1 downto 0);

    --  Prescale component
    component prescaler is
    generic( prescale : NATURAL := 4000);
    port( clk    : in std_logic;
          preClk : out std_logic
    );
    end component;
    
    signal preClk : std_logic;
    signal preClkASR : std_logic;
       
    -- IIR filter component
    component IIR is
    generic( WIDTH   : INTEGER := 12;
             F_WIDTH : INTEGER := 12);
    port( clk    : std_logic;
          fclk   : std_logic;
          reset  : in std_logic;
          ftype  : FILTER;
          cutoff : in integer;
          Q      : in sfixed(16 downto -F_WIDTH);
          x      : in std_logic_vector(WIDTH-1 downto 0);
          y      : out std_logic_vector(WIDTH-1 downto 0));
    end component;

    signal cutoff       : integer;
    signal Q            : sfixed(16 downto -12);
    signal ftype        : FILTER := LP;
    signal filterOut    : std_logic_vector(11 downto 0);
    signal filterIn     : std_logic_vector(11 downto 0) := (others => '0');
    signal enablefilter : std_logic;
    
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
    signal Note_state   : std_logic;
    signal ASR_atk_time : std_logic_vector(12-1 downto 0);
    signal ASR_rls_time : std_logic_vector(12-1 downto 0);
    signal ASR_y        : std_logic_vector(12-1 downto 0);
    signal ASR_led      : std_logic;
    signal ASR_atk_timeReg : integer range 0 to 4095 := 4095;
    signal ASR_rls_timeReg : integer range 0 to 4095 := 4095;
    
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
		  Note_state : out std_logic;
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
	
    signal Clock_Enable 	: std_logic;
    signal Uart_send    	: std_logic;
    signal Uart_Dec     	: std_logic_vector(7 downto 0);
    signal Note_data    	: std_logic_vector(15 downto 0);
    signal Note_ready   	: std_logic;
    signal Note_state_int   : std_logic;
	signal Note_state		: std_logic;
    signal Note_out     	: std_logic_vector(7 downto 0);
	
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
    
    signal key_state_atk : std_logic;
    signal key_state_rel : std_logic; 
    signal preDebug : std_logic;  
               
begin    

IBUFDS_inst: IBUFDS
    generic map( IOSTANDARD => "LVDS_25" )
    port map ( O => clk, I => I, IB => IB );  -- clock buffer output, diff_p clock buffer input, diff_n clock buffer input 
    I  <= SYSCLK_P;
    IB <= SYSCLK_N;

oscillator_comp: component oscillator
    port map( clk, reset, OSC1enable, OSC1waveForm, OSC1note, OSC1semi, OSC1dutyCycle, OSC1output );

encoderTop_comp1: component encoderTop
    port map( clk, '1', FMC1_HPC_HA02_P, FMC1_HPC_HA02_N, FMC1_HPC_HA03_P, encoders(0)(0), encoders(0)(1), encoders(0)(2) );
        
encoderTop_comp2: component encoderTop
    port map( clk, '1', FMC1_HPC_HA03_N, FMC1_HPC_HA04_P, FMC1_HPC_HA04_N, encoders(1)(0), encoders(1)(1), encoders(1)(2) );
    
encoderTop_comp3: component encoderTop
    port map( clk, '1', FMC1_HPC_HA05_P, FMC1_HPC_HA05_N, FMC1_HPC_HA06_P, encoders(2)(0), encoders(2)(1), encoders(2)(2) );
    
encoderTop_comp4: component encoderTop
    port map( clk, '1', FMC1_HPC_HA06_N, FMC1_HPC_HA07_P, FMC1_HPC_HA07_N, encoders(3)(0), encoders(3)(1), encoders(3)(2) );
   
encoderTop_comp5: component encoderTop
    port map( clk, '1', FMC1_HPC_HA08_P, FMC1_HPC_HA08_N, FMC1_HPC_HA09_P, encoders(4)(0), encoders(4)(1), encoders(4)(2) );

encoderTop_comp6: component encoderTop
    port map( clk, '1', FMC1_HPC_HA09_N, FMC1_HPC_HA19_P, FMC1_HPC_HA19_N, encoders(5)(0), encoders(5)(1), encoders(5)(2) );
     
encoderTop_comp7: component encoderTop
    port map( clk, '1', FMC1_HPC_LA10_P, FMC1_HPC_LA10_N, '1', encoders2(0)(0), encoders2(0)(1), encoders2(0)(2) );
        
encoderTop_comp8: component encoderTop
    port map( clk, '1', FMC1_HPC_LA11_P, FMC1_HPC_LA11_N, '1', encoders2(1)(0), encoders2(1)(1), encoders2(1)(2) );
    
encoderTop_comp9: component encoderTop
    port map( clk, '1', FMC1_HPC_LA12_P, FMC1_HPC_LA12_N, '1', encoders2(2)(0), encoders2(2)(1), encoders2(2)(2) );
    
encoderTop_comp10: component encoderTop
    port map( clk, '1', FMC1_HPC_HA11_P, FMC1_HPC_HA11_N, '1', encoders2(3)(0), encoders2(3)(1), encoders2(3)(2) );
   
encoderTop_comp11: component encoderTop
    port map( clk, '1', FMC1_HPC_LA14_P, FMC1_HPC_LA14_N, '1', encoders2(4)(0), encoders2(4)(1), encoders2(4)(2) );
    
encoderTop_comp12: component encoderTop
    port map( clk, '1', FMC1_HPC_HA13_P, FMC1_HPC_HA13_N, '1', encoders2(5)(0), encoders2(5)(1), encoders2(5)(2) );



prescale_comp: component prescaler
    generic map ( prescale => 4000 )
    port map ( clk, preClk );

IIR_comp: component IIR
    port map ( preClk, clk, reset, ftype, cutoff, Q, filterIn, filterOut );

DAC_comp: component AD5065_DAC
    port map( clk, reset, DACdata, DACstart, DACready, XADC_GPIO_1, XADC_GPIO_3, XADC_GPIO_2, XADC_GPIO_0 );
    
LFOduty_comp: component LFO_duty
    port map( clk, reset, LFOduty_restart,  LFOduty_enable, LFOduty_rate, LFOduty_depth, LFOduty_waveForm, LFOduty_output );

prescale_comp_ASR: component prescaler
    generic map ( prescale => 2 )
    port map ( clk, preClkASR );
        	
ASR_comp: component ASR
    port map( preClkASR, reset, OSC1output, Note_state, ASR_atk_time, ASR_rls_time, ASR_y );
    
btn_comp0: component button
    port map( clk, reset, GPIO_SW_S, btn0_out );

--LCD_comp: component LCD
--	--port map( clk, reset, FMC1_HPC_LA07_P, FMC1_HPC_LA06_N, FMC1_HPC_LA06_P, LCD_DATA, LCD_cmd, LCD_int, LCD_write, LCD_init, LCD_led );
--	port map( clk, reset, LCD_RS, LCD_RW, LCD_E, LCD_DATA, LCD_cmd, LCD_int, LCD_write, LCD_init, LCD_led );

--Uart_comp: component Uart
--	port map(PMOD_0, Reset, Clock_Enable, Uart_send, Uart_Dec);
	
--MIDI_dec_comp: component MIDI_Decoder
--	port map(Uart_Dec, Uart_send, Reset, Clock_Enable, Note_data, Note_ready, Note_state_int);
	
--MIDI_to_osc_comp: component MIDI_to_Osc
--	port map(Note_data, Note_state_int, Note_ready, Reset, Clock_Enable, Note_state, Note_out);
	
--ClockEn_comp: component ClockEnable
--	generic map(DesiredFreq => 312500, ClockFreq => 200000000)
--	port map(Clk, Reset, Clock_Enable);

--------------------------------------------------------------------------------
---- GPIO coupling
--------------------------------------------------------------------------------

    --  LED
    GPIO_LED_0 <= gpioLEDS(0);
    GPIO_LED_1 <= gpioLEDS(1);
    GPIO_LED_2 <= gpioLEDS(2);
    GPIO_LED_3 <= gpioLEDS(3);
    
    --gpioLEDS(0) <= LFOduty_setting;
    
    
    --  ENCODERS 1
    FMC1_HPC_HA10_P <= '1';  --  +
    FMC1_HPC_HA10_N <= '0';  --  -
    --  ENCODERS 2
    FMC1_HPC_LA16_P <= '1';  --  +
    FMC1_HPC_LA16_N <= '0';  --  -

            
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
    
    
    --  Envelope
    --ASR_x        <= OSC1output;
--        ASR_atk_time <= "000011001000";--std_logic_vector(to_unsigned(200,12));
--        ASR_rls_time <= "000011001000";--std_logic_vector(to_unsigned(200,12));
    ASR_atk_time <= std_logic_vector(to_signed(ASR_atk_timeReg,12));
    ASR_rls_time <= std_logic_vector(to_signed(ASR_rls_timeReg,12));
    --btn0_in <= GPIO_SW_S;

    FMC1_HPC_LA02_P <= preDebug;--preClkASR;
    
    
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

--btn_process:
--process(clk)
--begin

--    if rising_edge(clk) then

----        if btn0_out = '1'
----        then gpioLEDS(2) <= not(gpioLEDS(2));
----        end if;
----        gpioLEDS(2) <= btn0_out;

--        if encoders(0)(2) = '1'
--        then gpioLEDS(3) <= not(gpioLEDS(3));
--        end if;
        
--    end if;
    
--end process;

DAC_process:
process(clk)
begin

    if rising_edge(clk) then

        if GPIO_SW_N = '1' then 
        
            reset <= '0';   

        else
        
            reset <= '1';    
        --  DAC               
            if preClk = '1' then
                --if DACready = '1' then
                    --DACdata(3 downto 0) <= (OTHERS => '0');
                    if enablefilter = '1' then
--                        DACdata(15 downto 4) <= std_logic_vector(signed(filterOut) + 2048);
--                        DACdata(15 downto 9) <= LFOduty_output;
--                        DACdata(8 downto 0) <= (OTHERS => '0');
--                    else
                            DACdata(15 downto 4) <= std_logic_vector(signed(OSC1output) + 2048);
                            DACdata(3 downto 0) <= "0000";
                        else
                            DACdata(15 downto 4) <= std_logic_vector(signed(ASR_y) + 2048);
                            DACdata(3 downto 0) <= "0000";
                    end if;
                    DACstart <= '1';
                --else
                    --DACstart <= '0';
                --end if;
            else
                DACstart <= '0';
            end if;
        end if;
    end if;
    
end process;

encoders2_process:
process(clk)
begin

    if GPIO_SW_N = '1' then
    
        gpioLEDS(0) <= '0';
        gpioLEDS(1) <= '0';
        
    elsif rising_edge(clk) then

            if encoders2(0)(0) = '1' then
                if encoders2(0)(1) = '1' then
                    gpioLEDS(0) <= not(gpioLEDS(0));
                else
                    gpioLEDS(1) <= not(gpioLEDS(1));
                end if;
            end if;
    
            if encoders2(1)(0) = '1' then
                if encoders2(1)(1) = '1' then
                    gpioLEDS(0) <= not(gpioLEDS(0));
                else
                    gpioLEDS(1) <= not(gpioLEDS(1));
                end if;
            end if;
            
            if encoders2(2)(0) = '1' then
                if encoders2(2)(1) = '1' then
                    gpioLEDS(0) <= not(gpioLEDS(0));
                else
                    gpioLEDS(1) <= not(gpioLEDS(1));
                end if;
            end if;
            
            if encoders2(3)(0) = '1' then
                if encoders2(3)(1) = '1' then
                    gpioLEDS(0) <= not(gpioLEDS(0));
                else
                    gpioLEDS(1) <= not(gpioLEDS(1));
                end if;
            end if;
            
            if encoders2(4)(0) = '1' then
                if encoders2(4)(1) = '1' then
                    gpioLEDS(0) <= not(gpioLEDS(0));
                else
                    gpioLEDS(1) <= not(gpioLEDS(1));
                end if;
            end if;
    
            if encoders2(5)(0) = '1' then
                if encoders2(5)(1) = '1' then
                    gpioLEDS(0) <= not(gpioLEDS(0));
                else
                    gpioLEDS(1) <= not(gpioLEDS(1));
                end if;
            end if;
                                            
    end if;
end process;

midi_key_process:
process(clk)
begin

    if GPIO_SW_N = '1' then
        
        --gpioLEDS(1) <= '0';
        
    elsif rising_edge(clk) then
    
        if btn0_out = '1' then
        
            if key_state_atk = '0' then
                ASR_attack <= '1';
                key_state_atk <= '1';
                --gpioLEDS(1) <= not(gpioLEDS(1));
            else
                ASR_attack <= '0';
            end if;
            
            key_state_rel <= '1';
            
        else
            
            key_state_atk <= '0';
            
            if key_state_rel = '1' 
            then ASR_release <= '1'; key_state_rel <= '0'; --gpioLEDS(1) <= not(gpioLEDS(1));
            else ASR_release <= '0';
            end if;
            
        end if;        
    end if;
        
end process;
    
env_atk_process:
process(clk)
begin

    if GPIO_SW_N = '1' then
    
        ASR_atk_timeReg <= 1000;
        
    elsif rising_edge(clk) then
    
        --  ENVELOPE ATTACK
        if encoders(0)(0) = '1' then
            if encoders(0)(1) = '1' then
                if ASR_atk_timeReg < 4095 then
                    ASR_atk_timeReg <= ASR_atk_timeReg + 100;
                else
                    ASR_atk_timeReg <= 4095;
                end if;
            else
                if ASR_atk_timeReg > 200 then
                    ASR_atk_timeReg <= ASR_atk_timeReg - 100;
                else
                    ASR_atk_timeReg <= 100;
                end if;
            end if;
        end if;
    end if;
end process;
        
env_rls_process:
process(clk)
begin

    if GPIO_SW_N = '1' then
    
        ASR_rls_timeReg <= 1000;
        
    elsif rising_edge(clk) then
    
        --  ENVELOPE ATTACK
        if encoders(1)(0) = '1' then
            if encoders(1)(1) = '1' then
                if ASR_rls_timeReg < 4095 then
                    ASR_rls_timeReg <= ASR_rls_timeReg + 100;
                else
                    ASR_rls_timeReg <= 4095;
                end if;
            else
                if ASR_rls_timeReg > 200 then
                    ASR_rls_timeReg <= ASR_rls_timeReg - 100;
                else
                    ASR_rls_timeReg <= 100;
                end if;
            end if;
        end if;
    end if;
end process;

--enc_cut_process:
--process(clk)
--begin

--    if GPIO_SW_N = '1' then
    
--        cuttReg <= 1000;
        
--    elsif rising_edge(clk) then
    
--        --  CUTTOFF
--        if encoders(1)(0) = '1' then
--            if encoders(1)(1) = '1' then
--                if cuttReg < 4901 then
--                    cuttReg <= cuttReg + 100;
--                else
--                    cuttReg <= 5000;
--                end if;
--            else
--                if cuttReg > 99 then
--                    cuttReg <= cuttReg - 100;
--                else
--                    cuttReg <= 0;
--                end if;
--            end if;
--        end if;
--    end if;
--end process;

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
        elsif encoders(3)(2) = '1' then
            semiReg <= 0;
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
        
--LFO1_process:
--process(clk)
--begin    --  RESET
--    if GPIO_SW_N = '1' then 
    
--        LFOduty_rateReg  <=  0;     --  Lowest frequency
--        LFOduty_depthReg <= 50;     --  Starts at 6, to make it count to 50 => set to 44
--        LFOduty_waveForm <= '0';
--        LFOduty_setting  <= '0';
        
--    elsif rising_edge(clk) then
    
--        LFOduty_waveForm <= '0';
        
--        --  LFO1: Dutycycle for OSC1
--        if encoders(0)(0) = '1' then
--            if encoders(0)(1) = '1' then            --  Increase
--                if LFOduty_setting = '0' then       --  Rate
--                    if LFOduty_rateReg < 198 then
--                        LFOduty_rateReg <= LFOduty_rateReg + 1;
--                        LFOduty_restart <= '1';
--                    end if;
--                else                                --  Depth
--                    if LFOduty_depthReg < 88 then
--                        LFOduty_depthReg <= LFOduty_depthReg + 1;
--                        LFOduty_restart <= '1';
--                    end if;
--                end if;
--            else                                    --  Decrease
--                if LFOduty_setting = '0' then       --  Rate
--                    if LFOduty_rateReg > 0 then
--                        LFOduty_rateReg <= LFOduty_rateReg - 1;
--                        LFOduty_restart <= '1';
--                    end if;
--                else                                --  Depth
--                    if LFOduty_depthReg > 6 then
--                        LFOduty_depthReg <= LFOduty_depthReg - 1;
--                        LFOduty_restart <= '1';
--                    end if;
--                end if;
--            end if;
--        else
--            LFOduty_restart <= '0';
--        end if;
        
--        if encoders(0)(2) = '1' then
--            LFOduty_setting <= not(LFOduty_setting);
--        end if;
        
--        if LFOduty_enable = '0' then
--            OSC1dutyCycle <= std_logic_vector(to_unsigned(dutyReg,7));
--        else
--            OSC1dutyCycle <= LFOduty_output;
--        end if;
            
--    end if;
--end process;
end arch_top;