library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cordicStage is

    generic(
        i      : natural := 1;
        XY_SZ  : natural := 16;
        STAGES : natural := 16
    );
    port(
        clk     : in STD_LOGIC;
        reset   : in STD_LOGIC;
        
        Xin     : in STD_LOGIC_VECTOR (XY_SZ downto 0);
        Yin     : in STD_LOGIC_VECTOR (XY_SZ downto 0);
        Zin     : in STD_LOGIC_VECTOR (32-1 downto 0);
        
        atan    : in STD_LOGIC_VECTOR (31 downto 0);
        
        Xout    : out STD_LOGIC_VECTOR (XY_SZ downto 0);
        Yout    : out STD_LOGIC_VECTOR (XY_SZ downto 0);
        Zout    : out STD_LOGIC_VECTOR (32-1 downto 0)
  );
end cordicStage;

architecture arch_cordicStage of cordicStage is

--signal Z_sign : std_logic;
signal X_shr : std_logic_vector(XY_SZ downto 0);
signal Y_shr : std_logic_vector(XY_SZ downto 0);

begin

    X_shr <= std_logic_vector(shift_right(signed(Xin),i));
    Y_shr <= std_logic_vector(shift_right(signed(Yin),i));   
    --Z_sign <= ;
    
    process(reset, clk)
    begin
    
    if reset = '0' then
    
        Xout <= (OTHERS => '0');
        Yout <= (OTHERS => '0');
        Zout <= (OTHERS => '0');
        
--        X_shr <= (OTHERS => '0');
--        Y_shr <= (OTHERS => '0'); 
--        Z_sign <= '0';
    
    elsif rising_edge(clk) then


--        if Z_sign = '1' then

--            Xout <= std_logic_vector(signed(Xin) + signed(shift_right(signed(Yin),i)));            
--            Yout <= std_logic_vector(signed(Yin) - signed(shift_right(signed(Xin),i)));
--            Zout <= std_logic_vector(signed(Zin) + signed(atan));

--        else

--            Xout <= std_logic_vector(signed(Xin) - signed(shift_right(signed(Yin),i)));
--            Yout <= std_logic_vector(signed(Yin) + signed(shift_right(signed(Xin),i)));
--            Zout <= std_logic_vector(signed(Zin) - signed(atan));        

--        end if;

                if Zin(XY_SZ-1) = '1' then
        
                    Xout <= std_logic_vector(signed(Xin) + signed(Y_shr));            
                    Yout <= std_logic_vector(signed(Yin) - signed(X_shr));
                    Zout <= std_logic_vector(signed(Zin) + signed(atan));
        
                else
        
                    Xout <= std_logic_vector(signed(Xin) - signed(Y_shr));
                    Yout <= std_logic_vector(signed(Yin) + signed(X_shr));
                    Zout <= std_logic_vector(signed(Zin) - signed(atan));        
        
                end if;        

    end if;
    
end process;
end arch_cordicStage;