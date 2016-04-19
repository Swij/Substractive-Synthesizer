library ieee;
library ieee_proposed;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.fixed_float_types.all;
use ieee_proposed.fixed_pkg.all;
use work.aids.all;

entity IIR is
   generic ( WIDTH : INTEGER := 12;
             F_WIDTH : INTEGER := 12);
   port ( clk      : in STD_LOGIC;
          fclk     : in STD_LOGIC;
          reset    : in STD_LOGIC;
          ftype    : FILTER;
          cutoff   : in integer;
          Q        : in sfixed(16 downto -F_WIDTH);
          x        : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
          y        : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
end IIR;

architecture arch_IIR of IIR is
    signal Fs, cutoff_fp, alpha : sfixed(31 downto -F_WIDTH);
    signal sin_fp, cos_fp : sfixed(16 downto -F_WIDTH);
    signal a0, a1, a2, b0, b1, b2, yf, xf : sfixed(WIDTH-1 downto -F_WIDTH);
    signal b0_LP, b1_LP, b0_HP, b1_HP, b0_BP, b1_BP : sfixed(WIDTH-1 downto -F_WIDTH);
    signal sinOut, cosOut : STD_LOGIC_VECTOR(16 downto 0);
    signal angle : STD_LOGIC_VECTOR(31 downto 0);

    type SFParray is array(2 downto 0) of sfixed(WIDTH-1 downto -F_WIDTH);
    signal xs, ys : SFParray;

    component cordic is
        Generic ( XY_SZ : natural := 16;   -- width of input and output data
                  STG : natural := 16); -- same as bit width of X and Y
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               angle : in STD_LOGIC_VECTOR (31 downto 0); -- angle is a signed value in the range of -PI to +PI that must be represented as a 32 bit signed number
               Xin : in STD_LOGIC_VECTOR (XY_SZ-1 downto 0);
               Yin : in STD_LOGIC_VECTOR (XY_SZ-1 downto 0);
               Xout : out STD_LOGIC_VECTOR (XY_SZ downto 0);
               Yout : out STD_LOGIC_VECTOR (XY_SZ downto 0));
    end component;
begin
    -- Samplefreq & cutoff
    Fs <= to_sfixed(40000, Fs);
    cutoff_fp <= to_sfixed(cutoff, cutoff_fp);

    -- w0 = f/Fs * 2^32
    angle <= std_logic_vector(resize(shift_left(cutoff_fp/Fs, 32), angle'LENGTH-1, 0));

    -- sin(w0) & cos(w0)
    sin_fp <= shift_right(to_sfixed(signed(sinOut), sin_fp), 15);
    cos_fp <= shift_right(to_sfixed(signed(cosOut), cos_fp), 15);

    -- alpha = sin(w0)/(2*Q)
    alpha <= resize(sin_fp/shift_left(Q,1), alpha);

    -- Filter coefficients
    -- a0, a1, a2
    a0 <= resize(alpha+1, a0);
    a1 <= resize(-shift_left(cos_fp, 1)/a0, a1);
    a2 <= resize((1-alpha)/a0, a2);
    -- b0
    b0_LP <= resize((1-cos_fp)/shift_left(a0, 1), b0);
    b0_HP <= resize((1+cos_fp)/shift_left(a0, 1), b0);
    b0_BP <= resize(Q*alpha, b0);
    -- b1
    b1_LP <= resize((1-cos_fp)/a0, b1);
    b1_HP <= resize(-(1+cos_fp)/a0, b1);
    b1_BP <= (others => '0');
    -- b2
    b2 <= b0;

    with ftype select
        b0 <= b0_LP when LP,
              b0_HP when HP,
              b0_BP when others;

    with ftype select
        b1 <= b1_LP when LP,
              b1_HP when HP,
              b1_BP when others;

    -- Fixed point of input
    xf <= resize(to_sfixed(x, 11, 0),xf);

    -- Direct implementation
    yf <= resize(b0*xs(0) + b1*xs(1) + b2*xs(2) - a1*ys(1) - a2*ys(2), yf);

    -- Output
    y <= std_logic_vector(resize(ys(0), y'LENGTH-1, 0));

    -- Values for 1kHz LP cutoff
    --sin_fp <= to_sfixed(0.156434, sin_fp);
    --cos_fp <= to_sfixed(0.987688, cos_fp);
    --alpha <= to_sfixed(0.110617, alpha);
    --a0 <= to_sfixed(1.110617, a0);
    --a1 <= to_sfixed(-1.778630, a1);
    --a2 <= to_sfixed(0.800801, a2);
    --b0_LP <= to_sfixed(0.005543, b0_LP);
    --b1_LP <= to_sfixed(0.011085, b1_LP);

filter_proc:
process(clk, reset)
begin
    if reset = '0' then
        xs <= (others => (others => '0'));
        ys <= (others => (others => '0'));
    elsif rising_edge(clk) then
        xs(0) <= xf;
        xs(1) <= xs(0);
        xs(2) <= xs(1);

        ys(0) <= yf;
        ys(1) <= yf;
        ys(2) <= ys(1);
    end if;
end process;

cordic_comp:component cordic
    port map(fclk, reset, angle, std_logic_vector(to_signed(19429,16)), (others => '0'), cosOut, sinOut);
end arch_IIR;
