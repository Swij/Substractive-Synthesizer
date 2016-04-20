library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity encoder is
    port(
        clk    : in STD_LOGIC;
        reset  : in STD_LOGIC;
        A      : in STD_LOGIC;
        B      : in STD_LOGIC;
        C      : in STD_LOGIC;
        change    : out STD_LOGIC;
        dir    : out STD_LOGIC;
        bt    : out STD_LOGIC
    );
end encoder;

architecture arch_encoder of encoder is

    type stateType is (IDLE,R1,R2,R3,L1,L2,L3,RIGHT,LEFT);
    signal curr_state, next_state : stateType := IDLE;
    
    signal press : std_logic;    
    --signal change : std_logic;    
    --signal dir : std_logic;    
    signal btn : std_logic;
    signal btnCnt : integer range 0 to 20000000;
    
begin

state_process: 
process(clk)
begin

    
    bt <= btn;
    
    if reset = '0' then
        btn <= '0';
        press <= '0';
        btnCnt <= 0;
        
    elsif rising_edge(clk) then
        
        curr_state <= next_state;
        
     	if C = '0' and press = '0' then
            if btnCnt = 20000000 then
                btnCnt <= 0;
                btn <= '1'; 
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

encoder_process:
process(clk, reset, curr_state, A, B)
begin

    if reset = '0' then

        next_state <= curr_state;
        --press <= '0';
        change <= '0';
        dir <= '0';
        --btn <= '0';
        
    --elsif rising_edge(clk) then
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