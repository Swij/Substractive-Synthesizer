library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cstage is
    Generic ( XY_SZ : natural := 16;
              STG : natural := 16;
              i : natural := 0);
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           Xin : in STD_LOGIC_VECTOR (XY_SZ downto 0);
           Yin : in STD_LOGIC_VECTOR (XY_SZ downto 0);
           Zin : in STD_LOGIC_VECTOR (31 downto 0);
           atan : in STD_LOGIC_VECTOR (31 downto 0);
           Xout : out STD_LOGIC_VECTOR (XY_SZ downto 0);
           Yout : out STD_LOGIC_VECTOR (XY_SZ downto 0);
           Zout : out STD_LOGIC_VECTOR (31 downto 0));
end cstage;

architecture Behavioral of cstage is
    signal Z_sign : std_logic;
    signal X_shr, Y_shr : std_logic_vector(XY_SZ downto 0);

begin
    X_shr <= std_logic_vector(shift_right(signed(Xin),i));
    Y_shr <= std_logic_vector(shift_right(signed(Yin),i));
    Z_sign <= Zin(31);

    addorsub:process(clk, reset)
    begin
        if reset = '0' then
            Xout <= (others => '0');
            Yout <= (others => '0');
            Zout <= (others => '0');
        elsif rising_edge(clk) then
            if Z_sign = '0' then
                Xout <= std_logic_vector(signed(Xin) - signed(Y_shr));
                Yout <= std_logic_vector(signed(Yin) + signed(X_shr));
                Zout <= std_logic_vector(signed(Zin) - signed(atan));
            elsif Z_sign = '1' then
                Xout <= std_logic_vector(signed(Xin) + signed(Y_shr));
                Yout <= std_logic_vector(signed(Yin) - signed(X_shr));
                Zout <= std_logic_vector(signed(Zin) + signed(atan));
            end if;
        end if;
    end process;
end Behavioral;
