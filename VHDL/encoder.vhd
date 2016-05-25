library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity encoder is
    port(
        clk    : in STD_LOGIC;
        reset  : in STD_LOGIC;
        A      : in STD_LOGIC;  --  Input from the encoder
        B      : in STD_LOGIC;  --  Input from the encoder
        C      : in STD_LOGIC;  --  Input from the button
        change : out STD_LOGIC; --  Signals when the encoder has changed
        dir    : out STD_LOGIC; --  Signals on what way it has turned
        bt     : out STD_LOGIC  --  Signals a pushed button
    );
end encoder;

architecture arch_encoder of encoder is

    --  Declaration of all the states an encoder has while being turned.
    type stateType is (IDLE,R1,R2,R3,L1,L2,L3,RIGHT,LEFT);
    signal curr_state, next_state : stateType := IDLE;
    
    --  Signals for the button.
    signal press : std_logic;
    signal btn   : std_logic;
    
    --  This is for a debouncer function of the button.
    signal btnCnt : integer range 0 to 20000000;
    
begin

bt <= btn;  --  The button output is always the internal register for it.

--  This process change the encoder states and checks the button.
state_process: 
process(clk, reset)
begin    
    if reset = '0' then
        btn <= '0';
        press <= '0';
        btnCnt <= 0;
    elsif rising_edge(clk) then
        
        --  Change state.
        curr_state <= next_state;
        
        --  This code is for checking the button.
     	if C = '0' and press = '0' then  --  If pressed and hold.
            if btnCnt = 20000000 then    --  Wait
                btnCnt <= 0;
                btn <= '1';              --  Now the button is registered as pushed.
                press <= '1';
            else
                btnCnt <= btnCnt + 1;
            end if;
        else 
            btn <= '0'; 
            press <= '0';
            btnCnt <= 0;
        end if;
    end if;
end process;

--  This code evaluated the encoder inputs and determines the next state.
--  Since the pins counts up to four, there are four states for each way to turn and the IDLE state.
encoder_process:
process(clk, reset, curr_state, A, B)
begin

    if reset = '0' then
        next_state <= curr_state;
        change <= '0';
        dir <= '0';
        
    else
        case curr_state is
            when IDLE =>
                if B = '0' then
                    next_state <= R1;
                elsif A = '0' then
                    next_state <= L1;
                else
                    next_state <= IDLE;
                end if;
                change <= '0';
            
            when R1 =>
                if B = '1' then
                    next_state <= IDLE;
                elsif A = '0' then
                    next_state <=  R2;
                else
                    next_state <= R1;
                end if;
                change <= '0';
            when R2 =>
                if A = '1' then
                    next_state <= R1;
                elsif B = '1' then
                    next_state <= R3;
                else 
                    next_state <= R2;
                end if;
                change <= '0';
            when R3 =>
                if B = '0' then
                    next_state <= R2;
                elsif A = '1' then
                    next_state <= RIGHT;
                else
                    next_state <= R3;
                end if;
                change <= '0';
            when RIGHT =>
                dir <= '1';
                change <= '1';
                next_state <= IDLE;
        
            when L1 =>
                if A = '1' then
                    next_state <= IDLE;
                elsif B ='0' then
                    next_state <= L2;
                else
                    next_state <= L1;
                end if;
                change <= '0';
            when L2 =>
                if B = '1' then
                    next_state <= L1;
                elsif A = '1' then
                    next_state <= L3;
                else 
                    next_state <= L2;
                end if;
                change <= '0';
            when L3 =>
                if A = '0' then
                    next_state <= L2;
                elsif B = '1' then
                    next_state <= LEFT;
                else
                    next_state <= L3;
                end if;
                change <= '0';
            when LEFT =>
                dir <= '0';
                change <= '1';
                next_state <= IDLE;
                
        end case;
    end if;
end process;

end arch_encoder;