use work.ascii.ALL;
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
library UNISIM;
    use UNISIM.VComponents.ALL;

entity synth_top is
  Port (  --  SYSTEM CLOCK
          SYSCLK_P  : in std_logic;
          SYSCLK_N  : in std_logic;

          -- LCD
          FMC1_HPC_LA13_N : inout std_logic; -- SDA
          FMC1_HPC_LA14_P : inout std_logic; -- SCL

          -- VCC
          FMC1_HPC_HA10_P : out std_logic := '1';

          -- GPIO switches
          GPIO_SW_N : in std_logic;

          -- PMOD
          PMOD_2 : inout std_logic; -- SDA
          PMOD_3 : inout std_logic; -- SCL

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

  -- Values changed by encoders
  signal multi : integer range 1 to 1000 := 1;
  signal LFO1_duty_rate, LFO1_duty_depth, LFO2_offset_rate, LFO2_offset_depth, OSC2_offset, Echo_length, Echo_gain : integer range 0 to 100 := 50;
  signal OSC1_wavetype, OSC2_wavetype : std_logic_vector(2 downto 0);
  signal OSC1_dutycycle, OSC2_dutycycle : integer range 0 to 100 := 50;
  signal Filter_type : integer range 0 to 2 := 0;
  signal Filter_Q : real range 0.0 to 10.0 := 0.7;
  signal Filter_cutoff : integer range 0 to 20000 := 4000;
  signal Envelope_attack, Envelope_release : integer range 0 to 65535 := 10000;

  -- Encoder states
  signal LFO1_ES, LFO2_ES, OSC2_ES, Filter_ES, Echo_ES : std_logic := '0';

  -- Test LED vector
  signal OSC1_leds, OSC2_leds : std_logic_vector(4 downto 0) := (others => '0');
  signal Filter_leds : std_logic_vector(2 downto 0) := (others => '0');

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

  type encoderArray is array (0 to 10) of std_logic_vector(2 downto 0);
  signal encoders : encoderArray;

  -- LCD component
  component LCD_main is
    Generic ( input_clk : integer;
              i2c_bus_clk : integer); -- Delay to wait between commands
    Port (  clk : in  std_logic;
            reset : in  std_logic;
            lcd_bl : in std_logic;
            value : in std_logic_vector(15 downto 0);
            value_type : in integer range 0 to 15;
            lcd_addr : in std_logic_vector(6 downto 0);
            i2c_sda : inout std_logic;
            i2c_scl : inout std_logic);
  end component;

  signal value : std_logic_vector(15 downto 0) := (others => '0');
  signal value_type : integer range 0 to 15 := 0;


begin
  -- Reset signal
  reset <= not GPIO_SW_N;

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

LCD_main_inst: LCD_main
  generic map (200_000_000, 30_000)
  port map (clk, reset, '1', value, value_type, "0100111", PMOD_2, PMOD_3);

Encoder_LFO_duty: encoderTop
  port map( clk, '1', FMC1_HPC_HA09_P, FMC1_HPC_HA09_N, FMC1_HPC_HA08_N, encoders(0)(0), encoders(0)(1), encoders(0)(2) );

Encoder_LFO_offset: encoderTop
  port map( clk, '1', FMC1_HPC_HA19_P, FMC1_HPC_HA19_N, FMC1_HPC_HA18_N, encoders(1)(0), encoders(1)(1), encoders(1)(2) );

Encoder_OSC1_wave: encoderTop
  port map( clk, '1', FMC1_HPC_LA09_P, FMC1_HPC_LA09_N, FMC1_HPC_LA08_N, encoders(2)(0), encoders(2)(1), encoders(2)(2) );

Encoder_OSC1_duty: encoderTop
  port map( clk, '1', FMC1_HPC_HA11_N, FMC1_HPC_HA12_P, FMC1_HPC_HA11_P, encoders(3)(0), encoders(3)(1), encoders(3)(2) );

Encoder_OSC2_wave: encoderTop
  port map( clk, '1', FMC1_HPC_HA04_N, FMC1_HPC_HA05_P, FMC1_HPC_HA05_P, encoders(4)(0), encoders(4)(1), encoders(4)(2) );

Encoder_OSC2_duty_offset: encoderTop
  port map( clk, '1', FMC1_HPC_HA14_N, FMC1_HPC_HA15_P, FMC1_HPC_HA14_P, encoders(5)(0), encoders(5)(1), encoders(5)(2) );

Encoder_Filter_type: encoderTop
  port map( clk, '1', FMC1_HPC_HA06_P, FMC1_HPC_HA06_N, FMC1_HPC_HA05_N, encoders(6)(0), encoders(6)(1), encoders(6)(2) );

Encoder_Filter_cut: encoderTop
  port map( clk, '1', FMC1_HPC_HA16_P, FMC1_HPC_HA16_N, FMC1_HPC_HA15_N, encoders(7)(0), encoders(7)(1), encoders(7)(2) );

Encoder_Echo_length: encoderTop
  port map( clk, '1', FMC1_HPC_HA07_N, FMC1_HPC_HA08_P, FMC1_HPC_HA07_P, encoders(8)(0), encoders(8)(1), encoders(8)(2) );

Encoder_Envelope_attack: encoderTop
  port map( clk, '1', FMC1_HPC_HA13_P, FMC1_HPC_HA13_N, FMC1_HPC_HA12_N, encoders(9)(0), encoders(9)(1), encoders(9)(2) );

Encoder_Envelope_release: encoderTop
  port map( clk, '1', FMC1_HPC_HA03_P, FMC1_HPC_HA03_N, FMC1_HPC_HA02_N, encoders(10)(0), encoders(10)(1), encoders(10)(2) );

IBUFDS_inst: IBUFDS
  generic map( IOSTANDARD => "LVDS_25" )
  port map ( O => clk, I => I, IB => IB );  -- clock buffer output, diff_p clock buffer input, diff_n clock buffer input
  I  <= SYSCLK_P;
  IB <= SYSCLK_N;

Encoder_LFO_duty_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(0)(0) = '1' then
      if encoders(0)(1) = '1' then
        if LFO1_ES = '1' then  -- LFO duty dept
          if LFO1_duty_depth < 100-multi then
            LFO1_duty_depth <= LFO1_duty_depth + multi;
          else
            LFO1_duty_depth <= 100;
          end if;
        else                   -- LFO duty rate
          if LFO1_duty_rate < 100-multi then
            LFO1_duty_rate <= LFO1_duty_rate + multi;
          else
            LFO1_duty_rate <= 100;
          end if;
        end if;
      else
        if LFO1_ES = '1' then -- LFO duty dept
          if LFO1_duty_depth > multi then
            LFO1_duty_depth <= LFO1_duty_depth - multi;
          else
            LFO1_duty_depth <= multi;
          end if;
        else                  -- LFO duty rate
          if LFO1_duty_rate > multi then
            LFO1_duty_rate <= LFO1_duty_rate - multi;
          else
            LFO1_duty_rate <= multi;
          end if;
        end if;
      end if;
    end if;
    if encoders(0)(2) = '1' then
      LFO1_ES <= not LFO1_ES;
    end if;
  end if;
end process;

Encoder_LFO_offset_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(1)(0) = '1' then
      if encoders(1)(1) = '1' then
        if LFO2_ES = '1' then  -- LFO offset dept
          if LFO2_offset_depth < 100-multi then
            LFO2_offset_depth <= LFO2_offset_depth + multi;
          else
            LFO2_offset_depth <= 100;
          end if;
        else                   -- LFO offset rate
          if LFO2_offset_rate < 100-multi then
            LFO2_offset_rate <= LFO2_offset_rate + multi;
          else
            LFO2_offset_rate <= 100;
          end if;
        end if;
      else
        if LFO2_ES = '1' then -- LFO offset dept
          if LFO2_offset_depth > multi then
            LFO2_offset_depth <= LFO2_offset_depth - multi;
          else
            LFO2_offset_depth <= multi;
          end if;
        else                  -- LFO offset rate
          if LFO2_offset_rate > multi then
            LFO2_offset_rate <= LFO2_offset_rate - multi;
          else
            LFO2_offset_rate <= multi;
          end if;
        end if;
      end if;
    end if;
    if encoders(1)(2) = '1' then
      LFO2_ES <= not LFO2_ES;
    end if;
  end if;
end process;

Encoder_OSC1_wave_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(2)(0) = '1' then
      if encoders(2)(1) = '1' then
        OSC1_wavetype <= std_logic_vector(unsigned(OSC1_wavetype)+1);
      else
        OSC1_wavetype <= std_logic_vector(unsigned(OSC1_wavetype)-1);
      end if;
    end if;
  end if;
end process;

Encoder_OSC1_duty_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(3)(0) = '1' then
      if encoders(3)(1) = '1' then
        if OSC1_dutycycle < 100-multi then
          OSC1_dutycycle <= OSC1_dutycycle + multi;
        else
          OSC1_dutycycle <= 100;
        end if;
      else
        if OSC1_dutycycle > multi then
          OSC1_dutycycle <= OSC1_dutycycle - multi;
        else
          OSC1_dutycycle <= multi;
        end if;
      end if;
    end if;
  end if;
end process;

Encoder_OSC2_wave_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(4)(0) = '1' then
      if encoders(4)(1) = '1' then
        OSC2_wavetype <= std_logic_vector(unsigned(OSC2_wavetype)+1);
      else
        OSC2_wavetype <= std_logic_vector(unsigned(OSC2_wavetype)-1);
      end if;
    end if;
  end if;
end process;

Encoder_OSC2_duty_offset_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(5)(0) = '1' then
      if encoders(5)(1) = '1' then
        if OSC2_ES = '1' then -- duty
          if OSC2_dutycycle < 100-multi then
            OSC2_dutycycle <= OSC2_dutycycle + multi;
          else
            OSC2_dutycycle <= 100;
          end if;
        else -- offset
          if OSC2_offset < 100-multi then
            OSC2_offset <= OSC2_offset + multi;
          else
            OSC2_offset <= 100;
          end if;
        end if;
      else
        if OSC2_ES = '1' then -- duty
          if OSC2_dutycycle > multi then
            OSC2_dutycycle <= OSC2_dutycycle - multi;
          else
            OSC2_dutycycle <= multi;
          end if;
        else  -- offset
          if OSC2_offset > multi then
            OSC2_offset <= OSC2_offset - multi;
          else
            OSC2_offset <= multi;
          end if;
        end if;
      end if;
    end if;
    if encoders(5)(2) = '1' then
      OSC2_ES <= not OSC2_ES;
    end if;
  end if;
end process;

Encoder_Filter_type_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(6)(0) = '1' then
      if encoders(6)(1) = '1' then
        if Filter_ES = '1' then -- Q

        else -- Filter type
          Filter_type <= Filter_type+1;
        end if;
      else
        if Filter_ES = '1' then -- Q

        else -- Filter type
          Filter_type <= Filter_type-1;
        end if;
      end if;
    end if;
    if encoders(6)(2) = '1' then
      Filter_ES <= not Filter_ES;
    end if;
  end if;
end process;

Encoder_Filter_cut_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(7)(0) = '1' then
      if encoders(7)(1) = '1' then
        if Filter_cutoff < 20000-multi then
          Filter_cutoff <= Filter_cutoff + multi;
        else
          Filter_cutoff <= 20000;
        end if;
      else
        if Filter_cutoff > multi then
          Filter_cutoff <= Filter_cutoff - multi;
        else
          Filter_cutoff <= multi;
        end if;
      end if;
    end if;
  end if;
end process;

Encoder_Echo_length_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(8)(0) = '1' then
      if encoders(8)(1) = '1' then
        if Echo_ES = '1' then
          if Echo_length < 100-multi then
            Echo_length <= Echo_length + multi;
          else
            Echo_length <= 100;
          end if;
        else
          if Echo_gain < 100-multi then
            Echo_gain <= Echo_gain + multi;
          else
            Echo_gain <= 100;
          end if;
        end if;
      else
        if Echo_ES = '1' then
          if Echo_length > multi then
            Echo_length <= Echo_length - multi;
          else
            Echo_length <= multi;
          end if;
        else
          if Echo_gain > multi then
            Echo_gain <= Echo_gain - multi;
          else
            Echo_gain <= multi;
          end if;
        end if;
      end if;
    end if;
    if encoders(8)(2) = '1' then
      Echo_ES <= not Echo_ES;
    end if;
  end if;
end process;

Encoder_Envelope_attack_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(9)(0) = '1' then
      if encoders(9)(1) = '1' then
        if Envelope_attack < 65535-multi then
          Envelope_attack <= Envelope_attack + multi;
        else
          Envelope_attack <= 65535;
        end if;
      else
        if Envelope_attack > multi then
          Envelope_attack <= Envelope_attack - multi;
        else
          Envelope_attack <= multi;
        end if;
      end if;
    end if;
  end if;
end process;

Encoder_Envelope_release_proc:process(clk)
begin
  if rising_edge(clk) then
    if encoders(10)(0) = '1' then
      if encoders(10)(1) = '1' then
        if Envelope_release < 65535-multi then
          Envelope_release <= Envelope_release + multi;
        else
          Envelope_release <= 65535;
        end if;
      else
        if Envelope_release > multi then
          Envelope_release <= Envelope_release - multi;
        else
          Envelope_release <= multi;
        end if;
      end if;
    end if;
  end if;
end process;

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

LCD_value_type:process(clk)
begin
  if rising_edge(clk) then
    if encoders(0)(0) = '1' then
      if LFO1_ES = '1' then
        value_type <= 11;   -- LFO duty dept
        value <= std_logic_vector(to_unsigned(LFO1_duty_depth, 16));
      else
        value_type <= 12; -- LFO duty rate
        value <= std_logic_vector(to_unsigned(LFO1_duty_rate, 16));
      end if;
    elsif encoders(1)(0) = '1' then
      if LFO2_ES = '1' then
        value_type <= 13;   -- LFO offset depth
        value <= std_logic_vector(to_unsigned(LFO2_offset_depth, 16));
      else
        value_type <= 14; -- LFO offset rate
        value <= std_logic_vector(to_unsigned(LFO2_offset_rate, 16));
      end if;
    elsif encoders(3)(0) = '1' then -- OSC1 duty
      value_type <= 2;
      value <= std_logic_vector(to_unsigned(OSC1_dutycycle, 16));
    elsif encoders(5)(0) = '1' then
      if OSC2_ES = '1' then
        value_type <= 3;   -- if duty
        value <= std_logic_vector(to_unsigned(OSC2_dutycycle, 16));
      else
        value_type <= 4; -- if offset
        value <= std_logic_vector(to_unsigned(OSC2_offset, 16));
      end if;
    elsif encoders(6)(0) = '1' then
      if Filter_ES = '1' then
        value_type <= 5; -- only if Q mode
        --value <= Filter_Q;
      end if;
    elsif encoders(7)(0) = '1' then
      value_type <= 6;
      value <= std_logic_vector(to_unsigned(Filter_cutoff, 16));
    elsif encoders(8)(0) = '1' then
      if Echo_ES = '1' then
        value_type <= 7;   -- if echo length
        value <= std_logic_vector(to_unsigned(Echo_length, 16));
      else
        value_type <= 8; -- if echo gain
        value <= std_logic_vector(to_unsigned(Echo_gain, 16));
      end if;
    elsif encoders(9)(0) = '1' then
      value_type <= 9;
      value <= std_logic_vector(to_unsigned(Envelope_attack, 16));
    elsif encoders(10)(0) = '1' then
      value_type <= 10;
      value <= std_logic_vector(to_unsigned(Envelope_release, 16));
    end if;
  end if;
end process;
end Behavioral;
