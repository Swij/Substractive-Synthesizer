library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity voice is
    port(
        clk       : in STD_LOGIC;
        reset     : in STD_LOGIC;
        waveForm  : in WAVE;
        note      : in STD_LOGIC_VECTOR (7 downto 0);
        semi      : in STD_LOGIC_VECTOR (4 downto 0);
        dutyCycle : in STD_LOGIC_VECTOR (7 downto 0);
        output    : out STD_LOGIC_VECTOR (11 downto 0));
end voice;

architecture arch_voice of voice is

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
    
begin

oscillator_comp0:component oscillator
    port map( clk, reset, enable, waveForm, note, semi, dutyCycle, output );
    
oscillator_comp1:component oscillator
    port map( clk, reset, enable, waveForm, note, semi, dutyCycle, output );
    
voice_process:
process(clk)
begin
    if rising_edge(clk) then
        
    end if;
end process;
end arch_voice;
