library ieee;
use ieee.std_logic_1164.all;

-- Exponent is 7 bits (excess-63), mantissa is 8 bits with implied leading '1'
entity fp_align is
  port (
    signA      : in  std_logic;
    mantA      : in  std_logic_vector(7 downto 0);
    expA       : in  std_logic_vector(6 downto 0);
    signB      : in  std_logic;
    mantB      : in  std_logic_vector(7 downto 0);
    expB       : in  std_logic_vector(6 downto 0);
    big_sign   : out std_logic;
    sml_sign   : out std_logic;
    mant_big   : out std_logic_vector(8 downto 0);  -- 9 bits (hidden '1' + 8)
    mant_sml   : out std_logic_vector(8 downto 0);  -- aligned smaller mantissa
    exp_common : out std_logic_vector(6 downto 0);
    sticky_out : out std_logic
  );
end entity;

architecture structural of fp_align is
  component comparator is
    generic (N : natural := 8);
    port (
      a  : in  std_logic_vector(N-1 downto 0);
      b  : in  std_logic_vector(N-1 downto 0);
      lt : out std_logic;
      eq : out std_logic;
      gt : out std_logic
    );
  end component;

  component subtractor is
    generic (N : natural := 8);
    port (
      a      : in  std_logic_vector(N-1 downto 0);
      b      : in  std_logic_vector(N-1 downto 0);
      diff   : out std_logic_vector(N-1 downto 0);
      borrow : out std_logic
    );
  end component;

  component barrel_shifter_right9 is
    port (
      din     : in  std_logic_vector(8 downto 0);
      shamt   : in  std_logic_vector(2 downto 0);
      dout    : out std_logic_vector(8 downto 0);
      sticky  : out std_logic
    );
  end component;

  component mux2 is
    generic (N : natural := 8);
    port (a, b : in std_logic_vector(N-1 downto 0);
         s     : in std_logic;
         y     : out std_logic_vector(N-1 downto 0));
  end component;

  signal gt, lt, eq                 : std_logic;
  signal exp_big7, exp_sml7         : std_logic_vector(6 downto 0);
  signal diff7                      : std_logic_vector(6 downto 0);
  signal high_bits                  : std_logic_vector(3 downto 0);  -- diff7(6..3)
  signal shamt3                     : std_logic_vector(2 downto 0);

  signal mant_big8                  : std_logic_vector(7 downto 0);
  signal mant_sml8_pre              : std_logic_vector(7 downto 0);

  -- 9-bit full significands (hidden '1' prepended BEFORE shifting)
  signal mant_big9_pre              : std_logic_vector(8 downto 0);
  signal mant_sml9_pre              : std_logic_vector(8 downto 0);
  signal mant_sml9_aligned          : std_logic_vector(8 downto 0);
  signal sticky_align               : std_logic;

  signal signA_v, signB_v, big_sign_v, sml_sign_v : std_logic_vector(0 downto 0);
begin
  -- Compare exponents (unsigned excess-63)
  cmp_exp: comparator
    generic map (N => 7)
    port map (a=>expA, b=>expB, lt=>lt, eq=>eq, gt=>gt);

  -- Select common exponent and big/small exponents structurally
  exp_big_sel: mux2
    generic map (N => 7)
    port map (a=>expB, b=>expA, s=>gt, y=>exp_big7);

  exp_sml_sel: mux2
    generic map (N => 7)
    port map (a=>expA, b=>expB, s=>gt, y=>exp_sml7);

  exp_common <= exp_big7;

  -- Select mantissas structurally (8-bit fractions)
  big_mant_sel: mux2
    generic map (N => 8)
    port map (a=>mantB, b=>mantA, s=>gt, y=>mant_big8);

  sml_mant_sel: mux2
    generic map (N => 8)
    port map (a=>mantA, b=>mantB, s=>gt, y=>mant_sml8_pre);

  -- Select signs structurally
  signA_v(0) <= signA; signB_v(0) <= signB;

  big_sign_sel: mux2
    generic map (N => 1)
    port map (a=>signB_v, b=>signA_v, s=>gt, y=>big_sign_v);

  sml_sign_sel: mux2
    generic map (N => 1)
    port map (a=>signA_v, b=>signB_v, s=>gt, y=>sml_sign_v);

  big_sign <= big_sign_v(0);
  sml_sign <= sml_sign_v(0);

  -- Difference of exponents (non-negative by construction)
  diff_sub: subtractor
    generic map (N => 7)
    port map (a=>exp_big7, b=>exp_sml7, diff=>diff7, borrow=>open);

  -- Saturate shift amount to 7 if exponent difference > 7
  high_bits <= diff7(6 downto 3);
  shamt3    <= "111" when high_bits /= "0000" else diff7(2 downto 0);

  -- Prepend hidden '1' BEFORE alignment
  mant_big9_pre <= '1' & mant_big8;
  mant_sml9_pre <= '1' & mant_sml8_pre;

  -- ALIGN: right-shift the FULL 9-bit smaller mantissa; capture sticky of shifted-out bits
  align_shift: barrel_shifter_right9
    port map (din=>mant_sml9_pre, shamt=>shamt3, dout=>mant_sml9_aligned, sticky=>sticky_align);

  -- Drive outputs to core
  mant_big   <= mant_big9_pre;
  mant_sml   <= mant_sml9_aligned;
  sticky_out <= sticky_align;
end architecture;