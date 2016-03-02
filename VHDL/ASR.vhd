----------------------------------------------------------------------------------
-- Code by: Fredrik William Treven
--26 February 2016
--Chalmers University of Technology
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ASR is
  generic(WIDTH:INTEGER:=12);
  Port (clk:in STD_LOGIC;
        reset:in STD_LOGIC;
        x:in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        attack:in STD_LOGIC;
        release:in STD_LOGIC;
        atk_time:in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        rls_time:in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        y:out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
end ASR;

architecture arch_ASR of ASR is

type state_machine is (idle_state, attack_state, sustain_state, release_state);
signal state : state_machine;
signal step : STD_LOGIC_VECTOR(WIDTH-1 downto 0);
signal mult : STD_LOGIC_VECTOR(2*WIDTH-1 downto 0);
--signal new_train : STD_LOGIC;
signal counter : STD_LOGIC_VECTOR(WIDTH-1 downto 0);
--signal divider : STD_LOGIC_VECTOR(WIDTH-1 downto 0);

begin
    
    y <= mult(2*WIDTH-1 downto WIDTH); --Output is 12 MSBs of the internal multiplied value

    multiply:process(clk)
    begin
        if(RISING_EDGE(clk)) then
            mult <= STD_LOGIC_VECTOR(SIGNED(x)*SIGNED(step)); --Get the level of the signal
        end if;
    end process;
    
    env_proc:process(clk,reset)
    variable max_level:STD_LOGIC_VECTOR(WIDTH-1 downto 0) := "000000001000";
    begin
        if(reset = '1') then
            state <= idle_state; --If reset then idle
            step <= (others => '0'); --If reset then reset the level of the output
            counter <= (others => '0');
        elsif(RISING_EDGE(clk)) then --start state machine
            --if(new_train = '1') then --Want to check states upon new wave coming in
                case state is
                    when idle_state =>
                        if(attack = '0') then
                            state <= idle_state; --No attack then remain in this state
                            step <= (others => '0'); 
                        elsif(attack = '1') then
                            state <= attack_state; --Move to attack state if the attack flag is high
                        end if;
                    when attack_state =>
                        counter <= STD_LOGIC_VECTOR(SIGNED(counter) + 1);
                        if(release = '1') then
                            state <= release_state; --If release flag sent then go immediately to release state
                        elsif(step = max_level) then
                            state <= sustain_state; --Go to sustain state if maximum level reached
                            counter <= (others => '0'); --Reset counter
                        elsif(counter = atk_time) then --If we have reached the time set to increase the signal
                            step <= STD_LOGIC_VECTOR(SIGNED(step) + 1); --Increment the step to reach the sustain level
                            counter <= (others => '0'); --Reset counter
                        end if;
                    when sustain_state =>
                        if(release = '1') then
                            state <= release_state; --If release flag detected go to release state
                        end if;
                    when release_state =>
                        counter <= STD_LOGIC_VECTOR(SIGNED(counter) + 1);
                        if(step = "000000000000") then
                            state <= idle_state; --If the signal is completely diminished simply return to idle state
                            counter <= (others => '0'); --Reset counter
                        elsif(attack = '1') then
                            state <= attack_state; --If another key is pressed go to the attack state
                            counter <= (others => '0'); --Reset counter
                        elsif(counter = rls_time) then
                            step <= STD_LOGIC_VECTOR(SIGNED(step) - 1); --If the counter has reached the time set for release diminish the value
                            counter <= (others => '0'); --Reset counter
                        end if;
                end case;
            --end if;
        end if;
    end process;

end arch_ASR;

