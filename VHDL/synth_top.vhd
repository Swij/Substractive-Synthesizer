library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
library UNISIM;
    use UNISIM.VComponents.all;

entity synth_top is
    Port (  --  SYSTEM CLOCK
            SYSCLK_P  : in std_logic;
            SYSCLK_N  : in std_logic;

            -- VCC
            FMC1_HPC_HA10_P : out std_logic;

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
    signal clk, I, IB : std_logic;

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

begin
    -- BP LED (broken)
    FMC1_HPC_LA19_P <= '1';

    -- VCC
    FMC1_HPC_HA10_P <= '1';

Encoder_LFO1: component encoderTop
    port map( clk, '1', FMC1_HPC_HA09_N, FMC1_HPC_HA09_P, FMC1_HPC_HA08_N, encoders(0)(0), encoders(0)(1), encoders(0)(2) );

Encoder_LFO2: component encoderTop
    port map( clk, '1', FMC1_HPC_HA19_N, FMC1_HPC_HA19_P, FMC1_HPC_HA18_N, encoders(1)(0), encoders(1)(1), encoders(1)(2) );

Encoder_OSC1_wave: component encoderTop
    port map( clk, '1', FMC1_HPC_LA09_N, FMC1_HPC_LA09_P, FMC1_HPC_LA08_N, encoders(2)(0), encoders(2)(1), encoders(2)(2) );

Encoder_OSC1_duty: component encoderTop
    port map( clk, '1', FMC1_HPC_HA12_N, FMC1_HPC_HA12_P, FMC1_HPC_HA11_N, encoders(3)(0), encoders(3)(1), encoders(3)(2) );

Encoder_OSC2_wave: component encoderTop
    port map( clk, '1', FMC1_HPC_LA09_N, FMC1_HPC_LA09_P, FMC1_HPC_LA08_N, encoders(4)(0), encoders(4)(1), encoders(4)(2) );

Encoder_OSC2_duty: component encoderTop
    port map( clk, '1', FMC1_HPC_HA14_P, FMC1_HPC_HA14_N, FMC1_HPC_HA14_P, encoders(5)(0), encoders(5)(1), encoders(5)(2) );

Encoder_Filter_type: component encoderTop
    port map( clk, '1', FMC1_HPC_HA06_N, FMC1_HPC_HA06_P, FMC1_HPC_HA05_N, encoders(6)(0), encoders(6)(1), encoders(6)(2) );

Encoder_Filter_cut: component encoderTop
    port map( clk, '1', FMC1_HPC_HA16_N, FMC1_HPC_HA16_P, FMC1_HPC_HA15_N, encoders(7)(0), encoders(7)(1), encoders(7)(2) );

Encoder_Echo_length: component encoderTop
    port map( clk, '1', FMC1_HPC_HA08_N, FMC1_HPC_HA07_N, FMC1_HPC_HA07_P, encoders(8)(0), encoders(8)(1), encoders(8)(2) );

Encoder_Envelope_attack: component encoderTop
    port map( clk, '1', FMC1_HPC_HA13_N, FMC1_HPC_HA13_P, FMC1_HPC_HA12_N, encoders(9)(0), encoders(9)(1), encoders(9)(2) );

Encoder_Envelope_release: component encoderTop
    port map( clk, '1', FMC1_HPC_HA03_N, FMC1_HPC_HA03_P, FMC1_HPC_HA02_N, encoders(10)(0), encoders(10)(1), encoders(10)(2) );

IBUFDS_inst: IBUFDS
    generic map( IOSTANDARD => "LVDS_25" )
    port map ( O => clk, I => I, IB => IB );  -- clock buffer output, diff_p clock buffer input, diff_n clock buffer input
    I  <= SYSCLK_P;
    IB <= SYSCLK_N;

-- blinky:process(clk)
--     variable count : integer range 0 to 200_000_000 := 0;
--     variable state : std_logic := '0';
-- begin
--     if rising_edge(clk) then
--         if count >= 200_000_000 then
--             count := 0;
--             state := not state;
--         else
--             count := count+1;
--         end if;
--         FMC1_HPC_LA12_N <= state;
--     end if;
-- end process;

Encoder_LFO1_proc:process(clk)
begin
    if rising_edge(clk) then
        if encoders(0)(0) = '1' then
            if encoders(0)(1) = '1' then
                FMC1_HPC_LA04_N <= '1';
            else
                FMC1_HPC_LA04_N <= '0';
            end if;
        end if;
        if encoders(0)(2) = '1' then
            FMC1_HPC_LA04_N <= '0';
        end if;
    end if;
end process;

Encoder_LFO2_proc:process(clk)
begin
    if rising_edge(clk) then
        if encoders(1)(0) = '1' then
            if encoders(1)(1) = '1' then
                FMC1_HPC_LA08_P <= '1';
            else
                FMC1_HPC_LA08_P <= '0';
            end if;
        end if;
        if encoders(1)(2) = '1' then
            FMC1_HPC_LA08_P <= '0';
        end if;
    end if;
end process;

Encoder_OSC1_wave_proc:process(clk)
begin
    if rising_edge(clk) then
        if encoders(2)(0) = '1' then
            if encoders(2)(1) = '1' then
              FMC1_HPC_LA04_P <= '1';
            else
              FMC1_HPC_LA04_P <= '0';
            end if;
        end if;
        -- if encoders(2)(2) = '1' then
        --   FMC1_HPC_LA04_P <= '0';
        -- end if;
    end if;
end process;

Encoder_OSC1_duty_proc:process(clk)
begin
    if rising_edge(clk) then
        if encoders(3)(0) = '1' then
            if encoders(3)(1) = '1' then
              FMC1_HPC_LA03_N <= '1';
            else
              FMC1_HPC_LA03_N <= '0';
            end if;
        end if;
        -- if encoders(3)(2) = '1' then
        --   FMC1_HPC_LA03_N <= '0';
        -- end if;
    end if;
end process;

Encoder_OSC2_wave_proc:process(clk)
begin
    if rising_edge(clk) then
        if encoders(4)(0) = '1' then
            if encoders(4)(1) = '1' then
              FMC1_HPC_LA07_N <= '1';
            else
              FMC1_HPC_LA07_N <= '0';
            end if;
        end if;
        -- if encoders(4)(2) = '1' then
        --   FMC1_HPC_LA07_N <= '0';
        -- end if;
    end if;
end process;

Encoder_OSC2_duty_proc:process(clk)
begin
    if rising_edge(clk) then
        if encoders(5)(0) = '1' then
            if encoders(5)(1) = '1' then
              FMC1_HPC_LA07_P <= '1';
            else
              FMC1_HPC_LA07_P <= '0';
            end if;
        end if;
        -- if encoders(5)(2) = '1' then
        --   FMC1_HPC_LA07_P <= '0';
        -- end if;
    end if;
end process;

Encoder_Filter_type_proc:process(clk)
begin
    if rising_edge(clk) then
        if encoders(6)(0) = '1' then
            if encoders(6)(1) = '1' then
              FMC1_HPC_LA12_N <= '1';
            else
              FMC1_HPC_LA12_N <= '0';
            end if;
        end if;
        -- if encoders(6)(2) = '1' then
        --   FMC1_HPC_LA12_N <= '0';
        -- end if;
    end if;
end process;

Encoder_Filter_cut_proc:process(clk)
begin
    if rising_edge(clk) then
        if encoders(7)(0) = '1' then
            if encoders(7)(1) = '1' then
              FMC1_HPC_LA19_N <= '1';
            else
              FMC1_HPC_LA19_N <= '0';
            end if;
        end if;
        -- if encoders(7)(2) = '1' then
        --   FMC1_HPC_LA19_N <= '0';
        -- end if;
    end if;
end process;

Encoder_Echo_length_proc:process(clk)
begin
    if rising_edge(clk) then
        if encoders(8)(0) = '1' then
            if encoders(8)(1) = '1' then
              FMC1_HPC_LA05_P <= '1';
            else
              FMC1_HPC_LA05_P <= '0';
            end if;
        end if;
        -- if encoders(8)(2) = '1' then
        --   FMC1_HPC_LA05_P <= '0';
        -- end if;
    end if;
end process;

Encoder_Envelope_attack_proc:process(clk)
begin
    if rising_edge(clk) then
        if encoders(9)(0) = '1' then
            if encoders(9)(1) = '1' then
              FMC1_HPC_LA03_P <= '1';
            else
              FMC1_HPC_LA03_P <= '0';
            end if;
        end if;
        -- if encoders(9)(2) = '1' then
        --   FMC1_HPC_LA03_P <= '0';
        -- end if;
    end if;
end process;

Encoder_Envelope_release_proc:process(clk)
begin
    if rising_edge(clk) then
        if encoders(10)(0) = '1' then
            if encoders(10)(1) = '1' then
              FMC1_HPC_LA05_N <= '1';
            else
              FMC1_HPC_LA05_N <= '0';
            end if;
        end if;
        -- if encoders(10)(2) = '1' then
        --   FMC1_HPC_LA05_N <= '0';
        -- end if;
    end if;
end process;

end Behavioral;
