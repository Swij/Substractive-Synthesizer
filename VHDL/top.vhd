----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/16/2016 06:00:30 PM
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity top is
    
    Port(
        SYSCLK_P  : in STD_LOGIC;
        SYSCLK_N  : in STD_LOGIC;
        GPIO_SW_N : in STD_LOGIC
    );
          
end top;

architecture Behavioral of top is
    
    signal clk : STD_LOGIC;
    signal counter : STD_LOGIC_VECTOR(31 downto 0) :=(others => '0');
    signal I : STD_LOGIC;
    signal IB : STD_LOGIC;
    
    component geometric is
    port( 
        clk         : in STD_LOGIC;
        reset       : in STD_LOGIC;
        enable      : in STD_LOGIC;
        
        waveForm    : in STD_LOGIC_VECTOR (1 downto 0);
        note        : in STD_LOGIC_VECTOR (7 downto 0);
        dutyCycle   : in STD_LOGIC_VECTOR (7 downto 0);
        --semi        : in STD_LOGIC_VECTOR (4 downto 0);
        
        restart     : in STD_LOGIC;
        output      : out STD_LOGIC_VECTOR (11 downto 0)
        );
    end component geometric;
           
    signal reset     : STD_LOGIC;    
    signal enable    : STD_LOGIC;    
    signal waveForm  : STD_LOGIC_VECTOR (1 downto 0);
    signal note      : STD_LOGIC_VECTOR (7 downto 0);
    signal dutyCycle : STD_LOGIC_VECTOR (7 downto 0);           
    signal restart   : STD_LOGIC;
    signal output    : STD_LOGIC_VECTOR (11 downto 0);
    
    type States is (Restart,Idle);
    signal state : States;
    
begin

    I <= SYSCLK_P;
    IB <= SYSCLK_N;

    IBUFDS_inst : IBUFDS
    generic map (
        --IBUF_LOW_PWR => TRUE,
        IOSTANDARD => "LVDS_25")
    port map (
        O => clk, -- clock buffer output
        I => I,       -- diff_p clock buffer input
        IB => IB      -- diff_n clock buffer input
    );
    
    geometric_comp:
    component geometric
        port map(
            clk,
            reset,
            enable,
            waveForm,
            note,
            dutyCycle,
            restart,
            output
        );
        
   
    waveForm <= "01";
    note <= "0100000";
    dutyCycle <= "0010100";
    

    process(clk)
    begin
        if rising_edge(clk) then
        
            if GPIO_SW_N = '1' then
        
                reset <= '0';
                state <= Restart;
                
            else
                
                case state is
                
                when Restart =>
                    
                    enable <= '0';
                    restart <= '1';
                    state <= Idle;
                
                when Idle =>
                
                    enable <= '1';
                    restart <= '0';
                
                end case;
                
                
                
            end if;
        
        
            if GPIO_DIP_SW0 = '1' then
                  GPIO_LED_0 <= '1';
            else
                  GPIO_LED_0 <= '0';
            end if;
            
        end if;
        
    end process;
    
end Behavioral;
