library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;
use work.aids.ALL;

entity oscillator is
    Port (  clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            enable : in STD_LOGIC;
            frequency : in STD_LOGIC_VECTOR (12 downto 0);
            wave : in WAVE;
            output : out STD_LOGIC_VECTOR (16 downto 0));
end oscillator;

architecture arch_oscillator of oscillator is
    constant VALUE : integer := 19429; -- 32000 / 1.647;
    signal ang_count : integer range 0 to 359;
    signal sine_out : std_logic_vector(16 downto 0);
    signal cos_out : std_logic_vector(16 downto 0);
    signal angle : std_logic_vector(31 downto 0);
    
    COMPONENT cordic
    PORT( clk : IN  std_logic;
          reset : IN  std_logic;
          angle : IN  std_logic_vector(31 downto 0);
          Xin : IN  std_logic_vector(15 downto 0);
          Yin : IN  std_logic_vector(15 downto 0);
          Xout : OUT  std_logic_vector(16 downto 0);
          Yout : OUT  std_logic_vector(16 downto 0));
    END COMPONENT;
begin
    cordic_comp:cordic
        port map (  clk, 
                    reset,
                    angle, 
                    std_logic_vector(to_signed(VALUE,16)), 
                    (others => '0'), 
                    sine_out, 
                    cos_out );
        
    osc_ctrl:process(reset, clk)
    begin
        if reset = '0' then
            output <= (OTHERS => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
                case wave is
                    when SINE => -- Sine
                        output <= sine_out;
                    when COSINE => -- Cosine
                        output <= cos_out;
                    when SQUARE => -- Square
                         output <= (OTHERS => '1');
                    when TRIANGLE => -- Triangle
                        output <= (OTHERS => '1');
                    when SAW1 => -- Saw 1
                        output <= (OTHERS => '1');
                    when SAW2 => -- Saw 2
                        output <= (OTHERS => '1');
                    when NOISE => -- Noise
                        output <= (OTHERS => '1');
                    when others =>
                        output <= (OTHERS => '0');
                end case;
            end if;
        end if;
	end process;
	
	counter:process(reset, clk)
	begin
        if reset = '0' then
            ang_count <= 0;
            angle <= (others => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
                angle <= angles(ang_count);
                if ang_count < 359 then
                    ang_count <= ang_count+1;
                else
                    ang_count <= 0;
                end if;
            end if;
        end if;
	end process;
end arch_oscillator;
