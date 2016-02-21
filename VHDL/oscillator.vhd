library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;
use work.aids.ALL;

entity oscillator is
    port( clk       : in STD_LOGIC;
          reset     : in STD_LOGIC;
          enable    : in STD_LOGIC;
          wave      : in STD_LOGIC_VECTOR (2 downto 0);
          note      : in STD_LOGIC_VECTOR (7 downto 0);
          semi      : in STD_LOGIC_VECTOR (4 downto 0);
          dutyCycle : in STD_LOGIC_VECTOR (7 downto 0);
          output    : out STD_LOGIC_VECTOR (11 downto 0)
    );
end oscillator;

architecture arch_oscillator of oscillator is

    component sineWave
    port( clk    : in STD_LOGIC;
          reset  : in STD_LOGIC;
          enable : in STD_LOGIC;
          note   : in STD_LOGIC_VECTOR (7 downto 0);
          semi   : in STD_LOGIC_VECTOR (4 downto 0);
          sinOut : out STD_LOGIC_VECTOR (16 downto 0);
          cosOut : out STD_LOGIC_VECTOR (16 downto 0) );
    end component;

    component geometric
    generic( accSize  : natural := 18;
             dacWidth : natural := 12 );
    port( clk       : in STD_LOGIC;
          reset     : in STD_LOGIC;
          enable    : in STD_LOGIC;
          waveForm  : in STD_LOGIC_VECTOR (1 downto 0);
          note      : in STD_LOGIC_VECTOR (7 downto 0);
          dutyCycle : in STD_LOGIC_VECTOR (7 downto 0);
          semi      : in STD_LOGIC_VECTOR (4 downto 0);
          restart   : in STD_LOGIC;
          output    : out STD_LOGIC_VECTOR (11 downto 0));
    end component;

    signal out_sin : STD_LOGIC_VECTOR (16 downto 0);
    signal out_cos : STD_LOGIC_VECTOR (16 downto 0);
    signal out_geo : STD_LOGIC_VECTOR (11 downto 0);
    
begin

sineWave_comp: sineWave
    port map( clk, reset, enable, note, semi, out_sin, out_cos );
    
geometry_comp: geometric
    port map( clk, reset, enable, wave(1 to 0), note, dutyCycle, semi, out_geo);

osc_process:
process(reset, clk)
begin

    if reset = '0' then
    
        output <= (OTHERS => '0');
        
    elsif rising_edge(clk) then
    
        if enable = '1' then
        
            case wave is
                    
                when "000" => -- Square
                     output <= out_geo;
                     
                when "001" => -- Triangle
                    output <= out_geo;
                    
                when "010" => -- Saw 1
                    output <= out_geo;
                    
                when "011" => -- Saw 2
                    output <= out_geo;
                            
                when "100" => -- Sine
                    output <= out_sin(16 downto 5);
                    
                when "101" => -- Cosine
                    output <= out_cos(16 downto 5);
                    
                when "110" => -- Noise
                    output <= out_geo;
                    
                when others =>
                    output <= (OTHERS => '0');
                    
            end case;
        
        else
          
            output <= (OTHERS => '0');
            
        end if;
    end if;
end process;

end arch_oscillator;
