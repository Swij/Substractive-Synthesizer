-- Dependencies
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
library UNISIM;
    use UNISIM.VComponents.ALL;
--library IEEE_proposed;
--    use IEEE_proposed.fixed_float_types.all;
--    use IEEE_proposed.fixed_pkg.all;

-- IEEE_proposed
use work.fixed_float_types.all;
use work.fixed_pkg.all;

-- Own libraries
use work.ascii.ALL;
use work.aids.ALL;

entity synth_top is
  Port (
    --  SYSTEM CLOCK
    SYSCLK_P  : in std_logic;
    SYSCLK_N  : in std_logic;

    -- I2S
    FMC1_HPC_LA22_N : out std_logic; -- SCK
    FMC1_HPC_LA23_P : out std_logic; -- WS
    FMC1_HPC_LA23_N : out std_logic; -- SD

    -- VCC
    FMC1_HPC_HA10_P : out std_logic := '1';

    -- GPIO switches
    GPIO_SW_N : in std_logic; -- reset
    GPIO_SW_S : in std_logic; -- reset

    -- MIDI in
    FMC1_HPC_LA22_P : in std_logic;

    -- LEDs
    GPIO_LED_0 : out std_logic;
    GPIO_LED_1 : out std_logic;
    GPIO_LED_2 : out std_logic;
    GPIO_LED_3 : out std_logic;

    -- PMOD
    PMOD_2 : inout std_logic; -- LCD-SDA
    PMOD_3 : inout std_logic; -- LCD-SCL

    -- XADC
    XADC_GPIO_0 : out std_logic;  --  LDAC
    XADC_GPIO_1 : out std_logic;  --  SCLK
    XADC_GPIO_2 : out std_logic;  --  DIN
    XADC_GPIO_3 : out std_logic;  --  SYNC

    -- MCP3202_ADC
    FMC1_HPC_LA20_P : out std_logic; -- CS
    FMC1_HPC_LA20_N : out std_logic; -- CLK
    FMC1_HPC_LA21_P : in std_logic;  -- OUT
    FMC1_HPC_LA21_N : out std_logic; -- IN

    -- Toggle switches
    FMC1_HPC_LA13_P : in std_logic; -- Echo
    FMC1_HPC_LA14_N : in std_logic; -- MIDI/USB
    FMC1_HPC_LA15_P : in std_logic; -- LFO 1
    FMC1_HPC_LA15_N : in std_logic; -- LFO 2
    FMC1_HPC_LA16_P : in std_logic; -- Oscillator 2
    FMC1_HPC_LA16_N : in std_logic; -- Filter

    ---- Encoders
    -- LFO1 dutycycle
    FMC1_HPC_HA08_N : in std_logic; -- Button
    FMC1_HPC_HA09_P : in std_logic; -- A
    FMC1_HPC_HA09_N : in std_logic; -- B
    -- LFO2 Offset
    FMC1_HPC_HA18_N : in std_logic; -- Button
    FMC1_HPC_HA19_P : in std_logic; -- A
    FMC1_HPC_HA19_N : in std_logic; -- B
    -- Oscillator 1  wavetype
    FMC1_HPC_LA08_N : in std_logic; -- Button
    FMC1_HPC_LA09_P : in std_logic; -- A
    FMC1_HPC_LA09_N : in std_logic; -- B
    -- Oscillator 1 dutycycle
    FMC1_HPC_HA11_P : in std_logic; -- Button
    FMC1_HPC_HA11_N : in std_logic; -- A
    FMC1_HPC_HA12_P : in std_logic; -- B
    -- Oscillator 2 wavetype
    FMC1_HPC_HA04_P : in std_logic; -- Button
    FMC1_HPC_HA04_N : in std_logic; -- A
    FMC1_HPC_HA05_P : in std_logic; -- B
    -- Oscillator 2 dutycycle
    FMC1_HPC_HA14_P : in std_logic; -- Button
    FMC1_HPC_HA14_N : in std_logic; -- A
    FMC1_HPC_HA15_P : in std_logic; -- B
    -- Filter type/resonance
    FMC1_HPC_HA05_N : in std_logic; -- Button
    FMC1_HPC_HA06_P : in std_logic; -- A
    FMC1_HPC_HA06_N : in std_logic; -- B
    -- Filter cutoff
    FMC1_HPC_HA15_N : in std_logic; -- Button
    FMC1_HPC_HA16_P : in std_logic; -- A
    FMC1_HPC_HA16_N : in std_logic; -- B
    -- Echo length
    FMC1_HPC_HA07_P : in std_logic; -- Button
    FMC1_HPC_HA07_N : in std_logic; -- A
    FMC1_HPC_HA08_P : in std_logic; -- B
    -- Envelope attack
    FMC1_HPC_HA12_N : in std_logic; -- Button
    FMC1_HPC_HA13_P : in std_logic; -- A
    FMC1_HPC_HA13_N : in std_logic; -- B
    -- Envelope release
    FMC1_HPC_HA02_N : in std_logic; -- Button
    FMC1_HPC_HA03_P : in std_logic; -- A
    FMC1_HPC_HA03_N : in std_logic; -- B

    -- LEDs
    FMC1_HPC_LA02_N : out std_logic; -- Oscillator 1 Saw 2
    FMC1_HPC_LA03_P : out std_logic; -- Oscillator 1 Saw 1
    FMC1_HPC_LA03_N : out std_logic; -- Oscillator 1 Triangle
    FMC1_HPC_LA04_P : out std_logic; -- Oscillator 1 Square
    FMC1_HPC_LA04_N : out std_logic; -- Oscillator 1 Sine
    FMC1_HPC_LA05_P : out std_logic; -- Oscillator 2 Saw 2
    FMC1_HPC_LA05_N : out std_logic; -- Oscillator 2 Saw 1
    FMC1_HPC_LA07_P : out std_logic; -- Oscillator 2 Triangle
    FMC1_HPC_LA07_N : out std_logic; -- Oscillator 2 Square
    FMC1_HPC_LA08_P : out std_logic; -- Oscillator 2 Sine
    FMC1_HPC_LA12_N : out std_logic; -- Filter LP
    FMC1_HPC_LA19_P : out std_logic; -- Filter BP
    FMC1_HPC_LA19_N : out std_logic  -- Filter HP
  );
end synth_top;

architecture Behavioral of synth_top is
  signal clk, reset, I, IB : std_logic;

  -- NOT FIXED ENCODER VALUES
  signal ENC_LFO2_offset_rate, ENC_LFO2_offset_depth, ENC_OSC2_offset, ENC_Filter_Q : integer range 0 to 100 := 50;

  -- Values changed by encoders
  signal multi : integer range 1 to 1000 := 1;
  signal ENC_Echo_length : integer range 0 to 1999 := 1000;
  signal ENC_LFO1_duty_rate : integer range 0 to 255 := 198;
  signal ENC_LFO1_duty_depth : integer range 0 to 127 := 50;
  signal ENC_Envelope_attack, ENC_Envelope_release : integer range 0 to 65535 := 32767;
  signal ENC_OSC1_dutycycle, ENC_OSC2_dutycycle : integer range 0 to 100 := 50;
  signal ENC_OSC1_wavetype, ENC_OSC2_wavetype : std_logic_vector(2 downto 0) := (others => '0');
  signal ENC_Echo_gain : integer range 0 to 4095 := 1;
  signal ENC_Filter_cutoff : natural range 0 to 16383 := 4000;
  signal Filter_type : FILTER := LP;

  -- Encoder states
  signal LFO1_ES, LFO2_ES, OSC2_ES, Filter_ES, Echo_ES : std_logic := '0';

  -- Test LED vector
  signal OSC1_leds, OSC2_leds : std_logic_vector(4 downto 0) := (others => '0');
  signal Filter_leds : std_logic_vector(2 downto 0) := (others => '0');
  signal leds : std_logic_vector(3 downto 0);

  --  Encoder signals
  type encoderArray is array (0 to 10) of std_logic_vector(2 downto 0);
  signal encoders : encoderArray;

  -- Prescaler signals
  signal preClk40k : std_logic := '0';
  signal preClkASR : std_logic := '0';
  signal preClkADC : std_logic := '0';

  -- LCD signals
  signal value : std_logic_vector(15 downto 0) := (others => '0');
  signal value_type : integer range 0 to 15 := 0;

  -- Oscillator 1 signals
  signal OSC1note   : std_logic_vector (7 downto 0) := (others => '0');
  signal OSC1semi   : std_logic_vector (4 downto 0) := (others => '0');
  signal OSC1output : std_logic_vector (11 downto 0) := (others => '0');
  signal OSC1dutycycle  : std_logic_vector (6 downto 0) := "0110010";
  signal OSC1wavetype : WAVE := SINE;

  -- Oscillator 2 signals
  signal OSC2note   : std_logic_vector (7 downto 0) := (others => '0');
  signal OSC2semi   : std_logic_vector (4 downto 0) := (others => '0');
  signal OSC2output : std_logic_vector (11 downto 0) := (others => '0');
  signal OSC2dutycycle  : std_logic_vector (6 downto 0) := "0110010";
  signal OSC2wavetype : WAVE := SINE;

  -- ASR Envelope signals
  signal ASR_atk_time, ASR_rls_time : std_logic_vector(15 downto 0) := (others => '0');
  signal ASR_in, ASR_out : std_logic_vector(11 downto 0) := (others => '0');
  signal ASR_noteState   : std_logic := '0';

  -- IIR signals
  signal Filter_Q  : sfixed(16 downto -12);
  signal Filter_cutoff : integer range 0 to 16383 := 4000;
  signal Filter_out : std_logic_vector(11 downto 0) := (others => '0');
  signal Filter_in  : std_logic_vector(11 downto 0) := (others => '0');

  -- I2S Transmitter signals
  signal I2S_data : std_logic_vector(11 downto 0);
  signal I2S_sck  : std_logic;
  signal I2S_ws   : std_logic;
  signal I2S_sd   : std_logic;

  -- ADC signals
  constant ADC_settings : std_logic_vector(3 downto 0) := "1101";
  signal ADC_conversion : std_logic_vector(11 downto 0);
  signal ADC_cs    : std_logic;
  signal ADC_sck   : std_logic;
  signal ADC_si    : std_logic;
  signal ADC_so    : std_logic;
  signal ADC_get   : std_logic;
  signal ADC_rdy   : std_logic;
  signal ADC_start : std_logic;

  -- DAC signals
  signal DACdata  : std_logic_vector(15 DOWNTO 0);
  signal DACstart : std_logic;
  signal DACready : std_logic;

  -- MIDI signals
  TYPE States IS (Idle, Recieved);
  SIGNAL MIDI_note_state 	: States;
  signal Clock_Enable : std_logic;
  signal Uart_send    : std_logic;
  signal Uart_Dec     : std_logic_vector(7 downto 0);
  signal Note_data    : std_logic_vector(15 downto 0);
  signal Note_ready   : std_logic;
  signal Note_state   : std_logic;
  signal uartLED      : std_logic;
  signal Note_out     : std_logic_vector(7 downto 0);
  signal Note_rec     : std_logic_vector(7 downto 0);
  signal MIDI_ASR_noteState   : std_logic := '0';

  -- LFO duty signals
  signal LFOduty_restart  : std_logic;
  signal LFOduty_enable   : std_logic;
  signal LFOduty_rate     : std_logic_vector (7 downto 0);
  signal LFOduty_depth    : std_logic_vector (6 downto 0);
  signal LFOduty_waveForm : std_logic;
  signal LFOduty_output   : std_logic_vector (6 downto 0);
  signal LFOduty_setting  : std_logic;

  -- Toggle switch signals
  signal EN_Echo      : std_logic;
  signal EN_MIDI_USB  : std_logic;
  signal EN_LFO1      : std_logic;
  signal EN_LFO2      : std_logic;
  signal EN_OSC2      : std_logic;
  signal EN_Filter    : std_logic;

  -- Echo output signal
  signal Echo_output : std_logic_vector(11 downto 0);
  signal Echo_gain : std_logic_vector(11 downto 0) := "000000000001";

begin
  -- Reset signal
  reset <= not GPIO_SW_N;

  -- Toggle switches
  EN_Echo      <= FMC1_HPC_LA13_P;
  EN_MIDI_USB  <= FMC1_HPC_LA14_N;
  EN_LFO1      <= FMC1_HPC_LA15_P;
  EN_LFO2      <= FMC1_HPC_LA15_N;
  EN_OSC2      <= FMC1_HPC_LA16_P;
  EN_Filter    <= FMC1_HPC_LA16_N;

  -- -- Note number leds
  GPIO_LED_0 <= leds(0);
  GPIO_LED_1 <= leds(1);
  GPIO_LED_2 <= leds(2);
  GPIO_LED_3 <= leds(3);
  with GPIO_SW_S select
    leds <= note_out(3 downto 0) when '0',
            note_out(7 downto 4) when '1';

  -- LED
  FMC1_HPC_LA04_N <= OSC1_leds(0); -- Oscillator 1 Sine
  FMC1_HPC_LA04_P <= OSC1_leds(1); -- Oscillator 1 Square
  FMC1_HPC_LA03_N <= OSC1_leds(2); -- Oscillator 1 Triangle
  FMC1_HPC_LA03_P <= OSC1_leds(3); -- Oscillator 1 Saw 1
  FMC1_HPC_LA02_N <= OSC1_leds(4); -- Oscillator 1 Saw 2
  FMC1_HPC_LA08_P <= OSC2_leds(0); -- Oscillator 2 Sine
  FMC1_HPC_LA07_N <= OSC2_leds(1); -- Oscillator 2 Square
  FMC1_HPC_LA07_P <= OSC2_leds(2); -- Oscillator 2 Triangle
  FMC1_HPC_LA05_N <= OSC2_leds(3); -- Oscillator 2 Saw 1
  FMC1_HPC_LA05_P <= OSC2_leds(4); -- Oscillator 2 Saw 2
  FMC1_HPC_LA12_N <= Filter_leds(0); -- Filter LP
  FMC1_HPC_LA19_P <= Filter_leds(1); -- Filter BP
  FMC1_HPC_LA19_N <= Filter_leds(2); -- Filter HP

  -- Oscillator 1 wavetype LED changer
  with OSC1wavetype select
    OSC1_leds <=  "00001" when SINE,
                  "00010" when SQUARE,
                  "00100" when TRIANGLE,
                  "01000" when SAW1,
                  "10000" when SAW2,
                  "11111" when others;

  -- Oscillator 2 wavetype LED changer
  with OSC2wavetype select
    OSC2_leds <=  "00001" when SINE,
                  "00010" when SQUARE,
                  "00100" when TRIANGLE,
                  "01000" when SAW1,
                  "10000" when SAW2,
                  "11111" when others;

  -- Filter type LED changer
  with Filter_type select
    Filter_leds <=  "001" when LP,
                    "010" when BP,
                    "100" when HP;

-- Clock scaler for IIR filter
prescale_comp: entity work.prescaler
  generic map ( prescale => 4000 )
  port map ( clk, preClk40k );

-- Clock scaler for ASR Envelope
prescale_comp_ASR: entity work.prescaler
  generic map ( prescale => 2 )
  port map ( clk, preClkASR );

-- UART clock sclaer
ClockEn_comp: entity work.ClockEnable
 	generic map(DesiredFreq => 312500, ClockFreq => 200_000_000)
 	port map(clk, reset, Clock_Enable);

-- Clock scaler for ADC
ADC_enable_comp: entity work.prescaler
  generic map ( prescale => 8 )
  port map ( clk, preClkADC );

-- UART midi reciever
Uart_comp: entity work.Uart
 	port map( FMC1_HPC_LA22_P, reset, Clock_Enable, Uart_send, Uart_Dec );

-- MIDI decoder
MIDI_dec_comp: entity work.MIDI_Decoder
 	port map( Uart_Dec, Uart_send, reset, Clock_Enable, Note_data, Note_ready, Note_state );

-- MIDI to oscillator translator
MIDI_to_osc_comp: entity work.MIDI_to_Osc
 	port map( Note_data, Note_state, Note_ready, reset, Clock_Enable, MIDI_ASR_noteState, Note_out );

-- Oscillator 1 component
Oscillator1_comp: entity work.oscillator
  port map( clk, reset, '1', OSC1wavetype, OSC1note, OSC1semi, OSC1dutycycle, OSC1output );
  OSC1dutycycle <= std_logic_vector(to_unsigned(ENC_OSC1_dutycycle, 7));
  OSC1wavetype <= to_wave(ENC_OSC1_wavetype);
  OSC1note <= Note_out;

-- Oscillator 2 component
Oscillator2_comp: entity work.oscillator
  port map( clk, reset, '0', OSC2wavetype, OSC2note, OSC2semi, OSC2dutycycle, OSC2output );
  OSC2dutycycle <= std_logic_vector(to_unsigned(ENC_OSC2_dutycycle, 7));
  OSC2wavetype <= to_wave(ENC_OSC2_wavetype);
  OSC2note <= Note_out;

-- ASR Envelope component
ASR_comp: entity work.ASR
  port map( clk, reset, ASR_in, ASR_noteState, ASR_atk_time, ASR_rls_time, ASR_out );
  ASR_in <= OSC1output;
  ASR_atk_time <= std_logic_vector(to_signed(ENC_Envelope_attack, 16));
  ASR_rls_time <= std_logic_vector(to_signed(ENC_Envelope_release, 16));
  ASR_noteState <= MIDI_ASR_noteState;

-- IIR filter component
IIR_comp: entity work.IIR
  generic map ( WIDTH => 12, F_WIDTH => 12)
  port map ( preClk40k, clk, reset, Filter_type, Filter_cutoff, Filter_Q, Filter_in, Filter_out );
  Filter_cutoff <= ENC_Filter_cutoff;
  Filter_in <= ASR_out;
  Filter_Q <= to_sfixed(0.7071, Filter_Q);

-- I2S Transmitter
I2S_comp: entity work.I2S_transmitter
	generic map ( WIDTH => 12 )
	port map( preClk40k, I2S_data, I2S_sck, I2S_ws, I2S_sd );
  FMC1_HPC_LA22_N <= I2S_sck;
  FMC1_HPC_LA23_P <= I2S_ws;
  FMC1_HPC_LA23_N <= I2S_sd;
  I2S_data <= Filter_out;

-- LFO 1 duty rate and depth
LFOduty_comp: entity work.LFO_duty
  port map( clk, reset, LFOduty_restart, LFOduty_enable, LFOduty_rate, LFOduty_depth, LFOduty_waveForm, LFOduty_output );
  LFOduty_rate  <= std_logic_vector(to_unsigned(ENC_LFO1_duty_rate,8));
  LFOduty_depth <= std_logic_vector(to_unsigned(ENC_LFO1_duty_depth,7));

-- Echo module
Echo_comp: entity work.Delay
  port map(	clk, reset, Filter_out, ENC_Echo_length, Echo_gain, Echo_output );
  Echo_gain <= std_logic_vector(to_unsigned(ENC_Echo_gain, 12));

-- DAC component
DAC_comp: entity work.AD5065_DAC
    port map( clk, reset, DACdata, DACstart, DACready, XADC_GPIO_1, XADC_GPIO_3, XADC_GPIO_2, XADC_GPIO_0 );

-- ADC component
ADC_comp: entity work.MCP3202_ADC
  generic map( WIDTH => 12 )
  port map( preClkADC, ADC_cs, ADC_sck, ADC_si, ADC_so, ADC_conversion, ADC_settings, ADC_get, ADC_rdy );
  FMC1_HPC_LA20_P <= ADC_cs;
  FMC1_HPC_LA20_N <= ADC_sck;
  ADC_si <= FMC1_HPC_LA21_P;
  FMC1_HPC_LA21_N <= ADC_so;

-- LCD driver component
LCD_main_comp: entity work.LCD_main
  generic map ( 200_000_000, 100_000 )
  port map ( clk, reset, '1', value, value_type, "0100111", PMOD_2, PMOD_3 );

-- Encoder components
Encoder_LFO_duty: entity work.encoderTop
  port map( clk, '1', FMC1_HPC_HA09_P, FMC1_HPC_HA09_N, FMC1_HPC_HA08_N, encoders(0)(0), encoders(0)(1), encoders(0)(2) );
Encoder_LFO_offset: entity work.encoderTop
  port map( clk, '1', FMC1_HPC_HA19_P, FMC1_HPC_HA19_N, FMC1_HPC_HA18_N, encoders(1)(0), encoders(1)(1), encoders(1)(2) );
Encoder_OSC1_wave: entity work.encoderTop
  port map( clk, '1', FMC1_HPC_LA09_P, FMC1_HPC_LA09_N, FMC1_HPC_LA08_N, encoders(2)(0), encoders(2)(1), encoders(2)(2) );
Encoder_OSC1_duty: entity work.encoderTop
  port map( clk, '1', FMC1_HPC_HA11_N, FMC1_HPC_HA12_P, FMC1_HPC_HA11_P, encoders(3)(0), encoders(3)(1), encoders(3)(2) );
Encoder_OSC2_wave: entity work.encoderTop
  port map( clk, '1', FMC1_HPC_HA04_N, FMC1_HPC_HA05_P, FMC1_HPC_HA04_P, encoders(4)(0), encoders(4)(1), encoders(4)(2) );
Encoder_OSC2_duty_offset: entity work.encoderTop
  port map( clk, '1', FMC1_HPC_HA14_N, FMC1_HPC_HA15_P, FMC1_HPC_HA14_P, encoders(5)(0), encoders(5)(1), encoders(5)(2) );
Encoder_Filter_type: entity work.encoderTop
  port map( clk, '1', FMC1_HPC_HA06_P, FMC1_HPC_HA06_N, FMC1_HPC_HA05_N, encoders(6)(0), encoders(6)(1), encoders(6)(2) );
Encoder_Filter_cut: entity work.encoderTop
  port map( clk, '1', FMC1_HPC_HA16_P, FMC1_HPC_HA16_N, FMC1_HPC_HA15_N, encoders(7)(0), encoders(7)(1), encoders(7)(2) );
Encoder_Echo_length: entity work.encoderTop
  port map( clk, '1', FMC1_HPC_HA07_N, FMC1_HPC_HA08_P, FMC1_HPC_HA07_P, encoders(8)(0), encoders(8)(1), encoders(8)(2) );
Encoder_Envelope_attack: entity work.encoderTop
  port map( clk, '1', FMC1_HPC_HA13_P, FMC1_HPC_HA13_N, FMC1_HPC_HA12_N, encoders(9)(0), encoders(9)(1), encoders(9)(2) );
Encoder_Envelope_release: entity work.encoderTop
  port map( clk, '1', FMC1_HPC_HA03_P, FMC1_HPC_HA03_N, FMC1_HPC_HA02_N, encoders(10)(0), encoders(10)(1), encoders(10)(2) );

-- Clock driver
IBUFDS_inst: IBUFDS
  generic map( IOSTANDARD => "LVDS_25" )
  port map ( O => clk, I => I, IB => IB );  -- clock buffer output, diff_p clock buffer input, diff_n clock buffer input
  I  <= SYSCLK_P;
  IB <= SYSCLK_N;

-- ADC process
ADC_process:process(clk)
begin
  if rising_edge(clk) then
    if preClk40k = '1' then
      ADC_start <= '1';
      ADC_get <= '1';
    end if;
    if ADC_start = '1' and ADC_rdy = '0' then
      ADC_start <= '0';
      ADC_get <= '0';
    end if;
  end if;
end process;

-- DAC process
DAC_process:process(clk)
begin
  if rising_edge(clk) then
    if preClk40k = '1' then
      DACstart <= '1';
      if EN_Echo = '1' then
        DACdata(15 downto 4) <= std_logic_vector(signed(Echo_output) + 2048);
        DACdata(3 downto 0) <= (OTHERS => '0');
      elsif EN_Filter = '1' then
        DACdata(15 downto 4) <= std_logic_vector(signed(Filter_out) + 2048);
        DACdata(3 downto 0) <= (OTHERS => '0');
      else
        DACdata(15 downto 4) <= std_logic_vector(signed(ASR_out) + 2048);
        DACdata(3 downto 0) <= (OTHERS => '0');
      end if;
    else
      DACstart <= '0';
    end if;
  end if;
end process;

-- Encoder process for changing LFO duty rate and depth
Encoder_LFO_duty_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(0)(0) = '1' then
      if encoders(0)(1) = '1' then
        if LFO1_ES = '1' then  -- LFO duty dept
          if ENC_LFO1_duty_depth < 100-multi then
            ENC_LFO1_duty_depth <= ENC_LFO1_duty_depth + multi;
          else
            ENC_LFO1_duty_depth <= 100;
          end if;
        else                   -- LFO duty rate
          if ENC_LFO1_duty_rate < 255-multi then
            ENC_LFO1_duty_rate <= ENC_LFO1_duty_rate + multi;
          else
            ENC_LFO1_duty_rate <= 255;
          end if;
        end if;
      else
        if LFO1_ES = '1' then -- LFO duty dept
          if ENC_LFO1_duty_depth > multi then
            ENC_LFO1_duty_depth <= ENC_LFO1_duty_depth - multi;
          else
            ENC_LFO1_duty_depth <= multi;
          end if;
        else                  -- LFO duty rate
          if ENC_LFO1_duty_rate > multi then
            ENC_LFO1_duty_rate <= ENC_LFO1_duty_rate - multi;
          else
            ENC_LFO1_duty_rate <= multi;
          end if;
        end if;
      end if;
    end if;
    if encoders(0)(2) = '1' then
      LFO1_ES <= not LFO1_ES;
    end if;
  end if;
end process;

-- Encoder process for changing LFO offset rate and depth
Encoder_LFO_offset_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(1)(0) = '1' then
      if encoders(1)(1) = '1' then
        if LFO2_ES = '1' then  -- LFO offset dept
          if ENC_LFO2_offset_depth < 100-multi then
            ENC_LFO2_offset_depth <= ENC_LFO2_offset_depth + multi;
          else
            ENC_LFO2_offset_depth <= 100;
          end if;
        else                   -- LFO offset rate
          if ENC_LFO2_offset_rate < 100-multi then
            ENC_LFO2_offset_rate <= ENC_LFO2_offset_rate + multi;
          else
            ENC_LFO2_offset_rate <= 100;
          end if;
        end if;
      else
        if LFO2_ES = '1' then -- LFO offset dept
          if ENC_LFO2_offset_depth > multi then
            ENC_LFO2_offset_depth <= ENC_LFO2_offset_depth - multi;
          else
            ENC_LFO2_offset_depth <= multi;
          end if;
        else                  -- LFO offset rate
          if ENC_LFO2_offset_rate > multi then
            ENC_LFO2_offset_rate <= ENC_LFO2_offset_rate - multi;
          else
            ENC_LFO2_offset_rate <= multi;
          end if;
        end if;
      end if;
    end if;
    if encoders(1)(2) = '1' then
      LFO2_ES <= not LFO2_ES;
    end if;
  end if;
end process;

-- Encoder process for changing Oscillator 1 wavetype
Encoder_OSC1_wave_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(2)(0) = '1' then
      if encoders(2)(1) = '1' then
        ENC_OSC1_wavetype <= std_logic_vector(unsigned(ENC_OSC1_wavetype)+1);
      else
        ENC_OSC1_wavetype <= std_logic_vector(unsigned(ENC_OSC1_wavetype)-1);
      end if;
    end if;
  end if;
end process;

-- Encoder process for changing Oscillator 1 dutycycle
Encoder_OSC1_duty_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(3)(0) = '1' then
      if encoders(3)(1) = '1' then
        if ENC_OSC1_dutycycle < 100-multi then
          ENC_OSC1_dutycycle <= ENC_OSC1_dutycycle + multi;
        else
          ENC_OSC1_dutycycle <= 100;
        end if;
      else
        if ENC_OSC1_dutycycle > multi then
          ENC_OSC1_dutycycle <= ENC_OSC1_dutycycle - multi;
        else
          ENC_OSC1_dutycycle <= multi;
        end if;
      end if;
    end if;
  end if;
end process;

-- Encoder process for changing Oscillator 2 wavetype
Encoder_OSC2_wave_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(4)(0) = '1' then
      if encoders(4)(1) = '1' then
        ENC_OSC2_wavetype <= std_logic_vector(unsigned(ENC_OSC2_wavetype)+1);
      else
        ENC_OSC2_wavetype <= std_logic_vector(unsigned(ENC_OSC2_wavetype)-1);
      end if;
    end if;
  end if;
end process;

-- Encoder process for changing Oscillator 2 dutycycle and offset
Encoder_OSC2_duty_offset_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(5)(0) = '1' then
      if encoders(5)(1) = '1' then
        if OSC2_ES = '1' then -- duty
          if ENC_OSC2_dutycycle < 100-multi then
            ENC_OSC2_dutycycle <= ENC_OSC2_dutycycle + multi;
          else
            ENC_OSC2_dutycycle <= 100;
          end if;
        else -- offset
          if ENC_OSC2_offset < 100-multi then
            ENC_OSC2_offset <= ENC_OSC2_offset + multi;
          else
            ENC_OSC2_offset <= 100;
          end if;
        end if;
      else
        if OSC2_ES = '1' then -- duty
          if ENC_OSC2_dutycycle > multi then
            ENC_OSC2_dutycycle <= ENC_OSC2_dutycycle - multi;
          else
            ENC_OSC2_dutycycle <= multi;
          end if;
        else  -- offset
          if ENC_OSC2_offset > multi then
            ENC_OSC2_offset <= ENC_OSC2_offset - multi;
          else
            ENC_OSC2_offset <= multi;
          end if;
        end if;
      end if;
    end if;
    if encoders(5)(2) = '1' then
      OSC2_ES <= not OSC2_ES;
    end if;
  end if;
end process;

-- Encoder process for changing Filter type and Q
Encoder_Filter_type_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(6)(0) = '1' then
      if encoders(6)(1) = '1' then
        if Filter_ES = '1' then -- Q

        else -- Filter type
          if Filter_type = LP then
            Filter_type <= BP;
          elsif Filter_type = BP then
            Filter_type <= HP;
          else
            Filter_type <= LP;
          end if;
        end if;
      else
        if Filter_ES = '1' then -- Q

        else -- Filter type
          if Filter_type = LP then
            Filter_type <= HP;
          elsif Filter_type = BP then
            Filter_type <= LP;
          else
            Filter_type <= BP;
          end if;
        end if;
      end if;
    end if;
    if encoders(6)(2) = '1' then
      Filter_ES <= not Filter_ES;
    end if;
  end if;
end process;

-- Encoder process for changing Filter cutoff
Encoder_Filter_cut_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(7)(0) = '1' then
      if encoders(7)(1) = '1' then
        if ENC_Filter_cutoff < (15000-multi) then
          ENC_Filter_cutoff <= ENC_Filter_cutoff + multi;
        else
          ENC_Filter_cutoff <= 15000;
        end if;
      else
        if ENC_Filter_cutoff > multi then
          ENC_Filter_cutoff <= ENC_Filter_cutoff - multi;
        else
          ENC_Filter_cutoff <= multi;
        end if;
      end if;
    end if;
  end if;
end process;

-- Encoder process for changing Echo length and gain
Encoder_Echo_length_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(8)(0) = '1' then
      if encoders(8)(1) = '1' then
        if Echo_ES = '1' then
          if ENC_Echo_length < 100-multi then
            ENC_Echo_length <= ENC_Echo_length + multi;
          else
            ENC_Echo_length <= 100;
          end if;
        else
          if ENC_Echo_gain < 100-multi then
            ENC_Echo_gain <= ENC_Echo_gain + multi;
          else
            ENC_Echo_gain <= 100;
          end if;
        end if;
      else
        if Echo_ES = '1' then
          if ENC_Echo_length > multi then
            ENC_Echo_length <= ENC_Echo_length - multi;
          else
            ENC_Echo_length <= multi;
          end if;
        else
          if ENC_Echo_gain > multi then
            ENC_Echo_gain <= ENC_Echo_gain - multi;
          else
            ENC_Echo_gain <= multi;
          end if;
        end if;
      end if;
    end if;
    if encoders(8)(2) = '1' then
      Echo_ES <= not Echo_ES;
    end if;
  end if;
end process;

-- Encoder process for changing Envelope attack
Encoder_Envelope_attack_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(9)(0) = '1' then
      if encoders(9)(1) = '1' then
        if ENC_Envelope_attack < 65535-multi then
          ENC_Envelope_attack <= ENC_Envelope_attack + multi;
        else
          ENC_Envelope_attack <= 65535;
        end if;
      else
        if ENC_Envelope_attack > multi then
          ENC_Envelope_attack <= ENC_Envelope_attack - multi;
        else
          ENC_Envelope_attack <= multi;
        end if;
      end if;
    end if;
  end if;
end process;

-- Encoder process for changing Envelope release
Encoder_Envelope_release_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(10)(0) = '1' then
      if encoders(10)(1) = '1' then
        if ENC_Envelope_release < 65535-multi then
          ENC_Envelope_release <= ENC_Envelope_release + multi;
        else
          ENC_Envelope_release <= 65535;
        end if;
      else
        if ENC_Envelope_release > multi then
          ENC_Envelope_release <= ENC_Envelope_release - multi;
        else
          ENC_Envelope_release <= multi;
        end if;
      end if;
    end if;
  end if;
end process;

-- Process for changing value multiplier for encoders without any other button function
Multiplier:process(clk)
begin
  if rising_edge(clk) then
    if encoders(10)(2) = '1' OR encoders(9)(2) = '1' OR encoders(7)(2) = '1' OR encoders(3)(2) = '1' then
      if multi = 1 then
        multi <= 10;
      elsif multi = 10 then
        multi <= 100;
      elsif multi = 100 then
        multi <= 1000;
      else
        multi <= 1;
      end if;
    end if;
  end if;
end process;

-- Process for changing the content of the LCD to the must recently changed one
LCD_value_type:process(clk)
begin
  if rising_edge(clk) then
    if encoders(0)(0) = '1' then
      if LFO1_ES = '1' then
        value_type <= 11;   -- LFO duty dept
        value <= std_logic_vector(to_unsigned(ENC_LFO1_duty_depth, 16));
      else
        value_type <= 12; -- LFO duty rate
        value <= std_logic_vector(to_unsigned(ENC_LFO1_duty_rate, 16));
      end if;
    elsif encoders(1)(0) = '1' then
      if LFO2_ES = '1' then
        value_type <= 13;   -- LFO offset depth
        value <= std_logic_vector(to_unsigned(ENC_LFO2_offset_depth, 16));
      else
        value_type <= 14; -- LFO offset rate
        value <= std_logic_vector(to_unsigned(ENC_LFO2_offset_rate, 16));
      end if;
    elsif encoders(3)(0) = '1' then -- OSC1 duty
      value_type <= 2;
      value <= std_logic_vector(to_unsigned(ENC_OSC1_dutycycle, 16));
    elsif encoders(5)(0) = '1' then
      if OSC2_ES = '1' then
        value_type <= 3;   -- if duty
        value <= std_logic_vector(to_unsigned(ENC_OSC2_dutycycle, 16));
      else
        value_type <= 4; -- if offset
        value <= std_logic_vector(to_unsigned(ENC_OSC2_offset, 16));
      end if;
    elsif encoders(6)(0) = '1' then
      if Filter_ES = '1' then
        value_type <= 5; -- only if Q mode
        --value <= ENC_Filter_Q;
      end if;
    elsif encoders(7)(0) = '1' then
      value_type <= 6;
      value <= std_logic_vector(to_unsigned(ENC_Filter_cutoff, 16));
    elsif encoders(8)(0) = '1' then
      if Echo_ES = '1' then
        value_type <= 7;   -- if echo length
        value <= std_logic_vector(to_unsigned(ENC_Echo_length, 16));
      else
        value_type <= 8; -- if echo gain
        value <= std_logic_vector(to_unsigned(ENC_Echo_gain, 16));
      end if;
    elsif encoders(9)(0) = '1' then
      value_type <= 9;
      value <= std_logic_vector(to_unsigned(ENC_Envelope_attack, 16));
    elsif encoders(10)(0) = '1' then
      value_type <= 10;
      value <= std_logic_vector(to_unsigned(ENC_Envelope_release, 16));
    end if;
  end if;
end process;
end Behavioral;
