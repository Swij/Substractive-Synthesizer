library IEEE;
library ieee_proposed;
use ieee_proposed.fixed_float_types.all;
use ieee_proposed.fixed_pkg.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.aids.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity top is
    port ( 
        SYSCLK_P  : in STD_LOGIC;
        SYSCLK_N  : in STD_LOGIC;
        GPIO_SW_N : in STD_LOGIC;
        GPIO_SW_S : in STD_LOGIC;
        GPIO_SW_W : in STD_LOGIC;
        GPIO_SW_E : in STD_LOGIC;
        GPIO_SW_C : in STD_LOGIC;
        GPIO_LED_0 : out STD_LOGIC;
        GPIO_LED_1 : out STD_LOGIC;
        GPIO_LED_2 : out STD_LOGIC;
        GPIO_LED_3 : out STD_LOGIC;
        --FMC1_HPC_HA09_P : in STD_LOGIC;
        --FMC1_HPC_HA09_N : in STD_LOGIC;
        ROTARY_INCA : in STD_LOGIC;
        ROTARY_INCB : in STD_LOGIC;
        ROTARY_PUSH : in STD_LOGIC;
        GPIO_DIP_SW0 : in STD_LOGIC;
        GPIO_DIP_SW1 : in STD_LOGIC;
        GPIO_DIP_SW2 : in STD_LOGIC;
        GPIO_DIP_SW3 : in STD_LOGIC;
        --  DAC
        XADC_GPIO_0 : out STD_LOGIC;  --  LDAC
        XADC_GPIO_1 : out STD_LOGIC;  --  SCLK
        XADC_GPIO_2 : out STD_LOGIC;  --  DIN
        XADC_GPIO_3 : out STD_LOGIC;  --  SYNC
		
		--MIDI IN
		PMOD_0 		: in STD_LOGIC;
        
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
        
        FMC1_HPC_HA10_P : out STD_LOGIC; -- +
        FMC1_HPC_HA10_N : out STD_LOGIC  -- -
    );
end top;

architecture arch_top of top is

    --  Clock signals
    signal clk : STD_LOGIC;
    signal counter : STD_LOGIC_VECTOR(31 downto 0) :=(others => '0');
    signal I : STD_LOGIC;
    signal IB : STD_LOGIC;

    --  Oscillator component and signals
    component oscillator is
    port ( clk       : in STD_LOGIC;
           reset     : in STD_LOGIC;
           enable    : in STD_LOGIC;
           waveForm  : in WAVE;
           note      : in STD_LOGIC_VECTOR (7 downto 0);
           semi      : in STD_LOGIC_VECTOR (4 downto 0);
           dutyCycle : in STD_LOGIC_VECTOR (7 downto 0);
           output    : out STD_LOGIC_VECTOR (11 downto 0));
    end component;

    signal reset     : STD_LOGIC;
    signal enable    : STD_LOGIC;
    signal waveForm  : WAVE;
    signal note      : STD_LOGIC_VECTOR (7 downto 0);
    signal semi      : STD_LOGIC_VECTOR (4 downto 0);
    signal dutyCycle : STD_LOGIC_VECTOR (7 downto 0);
    signal output    : STD_LOGIC_VECTOR (11 downto 0);

    --  Encoder component
    component encoderTop is
    port(
        clk    : in STD_LOGIC;
        reset  : in STD_LOGIC;        
        A      : in STD_LOGIC;        
        B      : in STD_LOGIC;                
        C      : in STD_LOGIC;        
        change : out STD_LOGIC;
        dir    : out STD_LOGIC;
        btn    : out STD_LOGIC);
    end component;

    
--    --signal btnPin   : STD_LOGIC;
    signal change : STD_LOGIC;
    signal dir    : STD_LOGIC;
    signal btn    : STD_LOGIC;
    
    
    type encoderArray is array (0 to 5) of std_logic_vector(2 downto 0);
    signal encoders : encoderArray;

    --  Prescale component
    component prescaler is
        generic (prescale : NATURAL := 4000);
        port ( 
            clk    : IN STD_LOGIC;
            preClk : OUT STD_LOGIC
        );
    end component;
    
    signal preClk : STD_LOGIC;
     
    -- IIR filter component
    component IIR is
        generic ( WIDTH : INTEGER := 12;
                  F_WIDTH : INTEGER := 12);
        port ( clk      : STD_LOGIC;
               fclk     : STD_LOGIC;
               reset    : in STD_LOGIC;
               ftype    : FILTER;
               cutoff   : in integer;
               Q        : in sfixed(16 downto -F_WIDTH);
               x        : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
               y        : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
    end component;

    signal cutoff : integer := 1000;
    signal Q : sfixed(16 downto -12);
    signal ftype : FILTER := LP;
    signal filterOut : STD_LOGIC_VECTOR(11 downto 0);
    signal filterIn  : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    
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

    
    -- MIDI Interface
	
	COMPONENT Uart IS
		PORT ( 
		Data_in		: in STD_LOGIC;
		Reset		: in STD_LOGIC;
		Clock		: in STD_LOGIC;
		Data_send	: out STD_LOGIC;
		Data_out	: out STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
	END COMPONENT;
	
	COMPONENT MIDI_Decoder IS 
	PORT (
		Data_in 	: in STD_LOGIC_VECTOR(7 DOWNTO 0);
		Data_ready	: in STD_LOGIC;
		Reset		: in STD_LOGIC;
		Clock		: in STD_LOGIC;
		
		Data_out		: out STD_LOGIC_VECTOR(15 DOWNTO 0);
		Data_send		: out STD_LOGIC;
		Note_state_out	: out STD_LOGIC
	);
	END COMPONENT;
	
	COMPONENT MIDI_to_Osc IS
	PORT (
		Data_in		: in STD_LOGIC_VECTOR(15 DOWNTO 0);
		Note_on		: in STD_LOGIC;
		Data_ready	: in STD_LOGIC;
		Reset		: in STD_LOGIC;
		Clock		: in STD_LOGIC;
		
		Note		: out STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
	END COMPONENT;
	
	COMPONENT ClockEnable IS
		GENERIC(DesiredFreq : INTEGER;
				ClockFreq : INTEGER);
		PORT(
			ClockIn 	: IN STD_LOGIC;
			Reset		: IN STD_LOGIC;
			ClockOut	: OUT STD_LOGIC
		);
	END COMPONENT;
	
	SIGNAL Clock_Enable : STD_LOGIC;
	SIGNAL Uart_send : STD_LOGIC;
	SIGNAL Uart_Dec : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL Note_data : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL Note_ready : STD_LOGIC;
	SIGNAL Note_state : STD_LOGIC;
	SIGNAL Note_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
    --  Next below here...
    --  ...


    --  Test signals and others...
    signal gpioLEDS   : std_logic_vector(3 downto 0);
    
       
begin    
--------------------------------------------------------------------------------

IBUFDS_inst: IBUFDS
generic map (
    --IBUF_LOW_PWR => TRUE,
    IOSTANDARD => "LVDS_25")
port map (
    O => clk,     -- clock buffer output
    I => I,       -- diff_p clock buffer input
    IB => IB      -- diff_n clock buffer input
);

    I <= SYSCLK_P;
    IB <= SYSCLK_N;

--------------------------------------------------------------------------------

oscillator_comp:component oscillator
    port map( clk, reset, enable, waveForm, Note_out, semi, dutyCycle, output );

encoderTop_comp:component encoderTop
    port map( clk, '1', ROTARY_INCA, ROTARY_INCB, ROTARY_PUSH, change, dir, btn );
    
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

--ASR_comp:component ASR
--    port map( clk, reset, ASR_x, ASR_attack, ASR_release, ASR_atk_time, ASR_rls_time, ASR_y );

--------------------------------------------------------------------------------
--MIDI Instances--
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
----         GPIO     coupling
--------------------------------------------------------------------------------

    --  Just all LEDs
    GPIO_LED_0 <= gpioLEDS(0);
    GPIO_LED_1 <= gpioLEDS(1);
    GPIO_LED_2 <= gpioLEDS(2);
    GPIO_LED_3 <= gpioLEDS(3);
	gpioLEDS <= Uart_Dec(3 DOWNTO 0);
    --  These are driving the encoders
    FMC1_HPC_HA10_P <= '1';
    FMC1_HPC_HA10_N <= '0';

    --filterIn <= std_logic_vector(to_signed(to_integer(signed(oscOutput))+to_integer(signed(oscOutput2)), 13));
    filterIn <= output;
    Q <= to_sfixed(0.7071, Q);

top_process:
process(clk)
variable waveReg : integer range 0 to 7 := 0;
variable semiReg : integer range -11 to 11 := 0;
variable dutyReg : integer range 0 to 100 := 0;
variable cuttReg : integer range 0 to 4000 := 0;
begin

    if rising_edge(clk) then
    
    --  Reset when pushed
        if GPIO_SW_N = '1' then 
        
            reset <= '0';            
            gpioLEDS(0) <= '0';
            gpioLEDS(1) <= '0';
            gpioLEDS(2) <= '0';
            gpioLEDS(3) <= '0';
            waveReg := 0;
            
        else
        
            reset <= '1';

            --  NOTE
            if encoders(5)(0) = '1' then
                if encoders(5)(1) = '1' then
                    if unsigned(note) < 95 then
                        note <= std_logic_vector(unsigned(note) + 1);
                    else
                        note <= std_logic_vector(to_unsigned(95,8));
                    end if;    
                else
                    if unsigned(note) > 0 then
                        note <= std_logic_vector(unsigned(note) - 1);
                    else
                        note <= (OTHERS => '0');
                    end if;    
                end if;
            end if;
            
            --  WAVE
            --  000=Sine, 001=Cosine, 010=Square, 011=Triangle, 100=Saw1, 101=Saw2, 110=Saw1, 111=Saw2
            if encoders(4)(0) = '1' then
                if encoders(4)(1) = '1' then
                    if waveReg < 7 then
                        waveReg := waveReg + 1;
                    else
                        waveReg := 0;
                    end if;    
                else
                    if waveReg > 0 then
                        waveReg := waveReg - 1;
                    else
                        waveReg := 7;
                    end if;    
                end if;
                waveForm <= to_wave(std_logic_vector(to_unsigned(waveReg,3)));
            end if;
                        
            --  SEMI
            if encoders(3)(0) = '1' then
                if encoders(3)(1) = '1' then--increase
                    if semiReg < 11 then
                        semiReg := semiReg + 1;
                    else
                        semiReg := 11;
                        
                    end if;                      
                else
                    if semiReg > -11 then
                        semiReg := semiReg - 1;
                    else
                        semiReg := -11;
                    end if;    
                end if;
                semi <= std_logic_vector(to_signed(semiReg,5));
            end if;
            
            --  DUTY
            if encoders(2)(0) = '1' then
                if encoders(2)(1) = '1' then
                    if dutyReg < 99 then
                        dutyReg := dutyReg + 1;
                    else
                        dutyReg := 99;
                    end if;                      
                else
                    if dutyReg > 1 then
                        dutyReg := dutyReg - 1;
                    else
                        dutyReg := 1;
                    end if;    
                end if;
                dutyCycle <= std_logic_vector(to_signed(dutyReg,8));
            end if;
            
            --  CUTTOFF
            if encoders(1)(0) = '1' then
                if encoders(1)(1) = '1' then
                    if cuttReg < 3901 then
                        cuttReg := cuttReg + 100;
                    else
                        cuttReg := 4000;
                    end if;                      
                else
                    if cuttReg > 99 then
                        cuttReg := cuttReg - 100;
                    else
                        cuttReg := 0;
                    end if;
                end if;    
            end if;
            
        --  DAC               
            if preClk = '1' then
                if DACready = '1' then
                    DACdata(15 downto 12) <= (OTHERS => '0');
                    --DACdata(11 downto 0) <= std_logic_vector(signed(output) + 2048);
                    DACdata(11 downto 0) <= filterOut;
                    DACstart <= '1';
                else
                    DACstart <= '0';
                end if;
            end if;
                            
            --dutyCycle <= "00110010";
            
            enable <= '1';
            
        --  ENCODER PCB
            
            --if encoders(0)(0) = '1' then
              --  if encoders(0)(1) = '1' then
                --    gpioLEDS(0) <= not(gpioLEDS(0));
                  --  gpioLEDS(1) <= not(gpioLEDS(1));
                --else
                 --   gpioLEDS(2) <= not(gpioLEDS(2));
                   -- gpioLEDS(3) <= not(gpioLEDS(3));
                --end if;
            --end if;  
            
--            if encoders(1)(0) = '1' then
--                if encoders(1)(1) = '1' then
--                    gpioLEDS(0) <= not(gpioLEDS(0));
--                    gpioLEDS(1) <= not(gpioLEDS(1));
--                else
--                    gpioLEDS(2) <= not(gpioLEDS(2));
--                    gpioLEDS(3) <= not(gpioLEDS(3));
    
--                end if;
--            end if;  
            
--            if encoders(2)(0) = '1' then
--                if encoders(2)(1) = '1' then
--                    gpioLEDS(0) <= not(gpioLEDS(0));
--                    gpioLEDS(1) <= not(gpioLEDS(1));
--                else
--                    gpioLEDS(2) <= not(gpioLEDS(2));
--                    gpioLEDS(3) <= not(gpioLEDS(3));
--                end if;
--            end if;  
            
--            if encoders(3)(0) = '1' then
--                if encoders(3)(1) = '1' then
--                    gpioLEDS(0) <= not(gpioLEDS(0));
--                    gpioLEDS(1) <= not(gpioLEDS(1));
--                else
--                    gpioLEDS(2) <= not(gpioLEDS(2));
--                    gpioLEDS(3) <= not(gpioLEDS(3));

--                end if;
--            end if;  
            
--            if encoders(4)(0) = '1' then
--                if encoders(4)(1) = '1' then
--                    gpioLEDS(0) <= not(gpioLEDS(0));
--                    gpioLEDS(1) <= not(gpioLEDS(1));
--                else
--                    gpioLEDS(2) <= not(gpioLEDS(2));
--                    gpioLEDS(3) <= not(gpioLEDS(3));
--                end if;
--            end if;  
            
--            if encoders(5)(0) = '1' then
--                if encoders(5)(1) = '1' then
--                    gpioLEDS(0) <= not(gpioLEDS(0));
--                    gpioLEDS(1) <= not(gpioLEDS(1));
--                else
--                    gpioLEDS(2) <= not(gpioLEDS(2));
--                    gpioLEDS(3) <= not(gpioLEDS(3));
--                end if;
--            end if;  
                        
            
        end if;  
         

    end if;
    
end process;    
end arch_top;