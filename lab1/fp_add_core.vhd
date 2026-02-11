library ieee;
use ieee.std_logic_1164.all;

-- Core add/subtract, normalize, round. Mantissas are 9 bits internal, exponent 7 bits.
-- Structural selections use mux2 components; simple boolean ops (and/or/not/xnor) are used directly.
entity fp_add_core is
  port (
    big_sign    : in  std_logic;
    sml_sign    : in  std_logic;
    mant_big    : in  std_logic_vector(8 downto 0); -- aligned, with hidden '1' prepended
    mant_sml    : in  std_logic_vector(8 downto 0); -- aligned, with hidden '1' prepended (shifted if needed)
    exp_common  : in  std_logic_vector(6 downto 0); -- exponent of the larger operand
    sticky_in   : in  std_logic;                    -- sticky from align stage
    sign_out    : out std_logic;
    mant_out    : out std_logic_vector(7 downto 0); -- stored fraction (implicit leading 1)
    exp_out     : out std_logic_vector(6 downto 0);
    overflow    : out std_logic
  );
end entity;

architecture structural of fp_add_core is
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

  component ripple_adder is
    generic (N : natural := 8);
    port (
      a    : in  std_logic_vector(N-1 downto 0);
      b    : in  std_logic_vector(N-1 downto 0);
      cin  : in  std_logic;
      sum  : out std_logic_vector(N-1 downto 0);
      cout : out std_logic
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

  component leading_one_detector9 is
    port (
      din     : in  std_logic_vector(8 downto 0);
      shamt   : out std_logic_vector(3 downto 0);
      zero    : out std_logic
    );
  end component;

  component barrel_shifter_left9 is
    port (
      din     : in  std_logic_vector(8 downto 0);
      shamt   : in  std_logic_vector(3 downto 0);
      dout    : out std_logic_vector(8 downto 0)
    );
  end component;

  component mux2 is
    generic (N : natural := 8);
    port (
      a, b : in  std_logic_vector(N-1 downto 0);
      s    : in  std_logic;
      y    : out std_logic_vector(N-1 downto 0)
    );
  end component;

  -- Sign relation
  signal same_sign                 : std_logic;

  -- Add/sub paths
  signal sum9                      : std_logic_vector(8 downto 0);
  signal cout_sum                  : std_logic;

  signal diff_big                  : std_logic_vector(8 downto 0);
  signal diff_sml                  : std_logic_vector(8 downto 0);
  signal diff_abs                  : std_logic_vector(8 downto 0);

  signal gt_m, lt_m, eq_m          : std_logic;
  signal ge_m                      : std_logic;

  -- Normalization signals
  signal norm_in                   : std_logic_vector(8 downto 0);
  signal shamt_norm                : std_logic_vector(3 downto 0);
  signal norm_out                  : std_logic_vector(8 downto 0);
  signal is_zero                   : std_logic;

  -- Exponent paths
  signal exp_inc, exp_dec, exp_sel : std_logic_vector(6 downto 0);
  signal cout_exp_inc              : std_logic;

  -- Mantissa select and rounding
  signal carry_and                 : std_logic;
  signal mant8_carry_path          : std_logic_vector(7 downto 0);
  signal mant8_sub_path            : std_logic_vector(7 downto 0);
  signal mant8_unrounded           : std_logic_vector(7 downto 0);

  signal guard_carry_vec           : std_logic_vector(0 downto 0);
  signal guard_sub_vec             : std_logic_vector(0 downto 0);
  signal guard_sel_vec             : std_logic_vector(0 downto 0);
  signal round_bit                 : std_logic;
  signal mant8_rounded             : std_logic_vector(7 downto 0);
  signal cout_round                : std_logic;

  -- Sign mux vectors
  signal mag_sign_vec              : std_logic_vector(0 downto 0);
  signal big_sign_vec              : std_logic_vector(0 downto 0);
  signal sml_sign_vec              : std_logic_vector(0 downto 0);
  signal sign_out_vec              : std_logic_vector(0 downto 0);

  -- Final exponent internal and overflow
  signal exp_out_i                 : std_logic_vector(6 downto 0);
  signal ov_lt, ov_eq, ov_gt       : std_logic;
begin
  same_sign <= big_sign xnor sml_sign;

  -- Magnitude comparator for mantissas (used for sign on subtract and for absolute difference)
  cmp_m: comparator
    generic map (N => 9)
    port map (a=>mant_big, b=>mant_sml, lt=>lt_m, eq=>eq_m, gt=>gt_m);

  ge_m <= gt_m or eq_m;

  -- Add mantissas (aligned inputs)
  add9: ripple_adder
    generic map (N => 9)
    port map (a=>mant_big, b=>mant_sml, cin=>'0', sum=>sum9, cout=>cout_sum);

  -- Compute both subtraction directions to form absolute difference
  sub_big_minus_sml: subtractor
    generic map (N => 9)
    port map (a=>mant_big, b=>mant_sml, diff=>diff_big, borrow=>open);

  sub_sml_minus_big: subtractor
    generic map (N => 9)
    port map (a=>mant_sml, b=>mant_big, diff=>diff_sml, borrow=>open);

  -- Select absolute difference: if mant_big ≥ mant_sml use big−sml, else sml−big
  sel_diff_abs: mux2
    generic map (N => 9)
    port map (a=>diff_sml, b=>diff_big, s=>ge_m, y=>diff_abs);

  -- Select add/sub result structurally: norm_in = same_sign ? sum9 : |mant_big - mant_sml|
  sel_norm_in: mux2
    generic map (N => 9)
    port map (a=>diff_abs, b=>sum9, s=>same_sign, y=>norm_in);

  -- Sign selection structurally:
  -- magnitude_sign = ge_m ? big_sign : sml_sign
  big_sign_vec(0) <= big_sign;
  sml_sign_vec(0) <= sml_sign;

  sel_mag_sign: mux2
    generic map (N => 1)
    port map (a=>sml_sign_vec, b=>big_sign_vec, s=>ge_m, y=>mag_sign_vec);

  -- sign_out = same_sign ? big_sign : magnitude_sign
  sel_sign_out: mux2
    generic map (N => 1)
    port map (a=>mag_sign_vec, b=>big_sign_vec, s=>same_sign, y=>sign_out_vec);

  sign_out <= sign_out_vec(0);

  -- Exponent +1 when carry on addition
  add_exp1: ripple_adder
    generic map (N => 7)
    port map (a=>exp_common, b=>(others=>'0'), cin=>'1', sum=>exp_inc, cout=>cout_exp_inc);

  -- Left-normalize (sub/add-result path)
  lod: leading_one_detector9
    port map (din=>norm_in, shamt=>shamt_norm, zero=>is_zero);

  shl: barrel_shifter_left9
    port map (din=>norm_in, shamt=>shamt_norm, dout=>norm_out);

  -- Exponent decrement by normalization shift (zero-extend shamt to 7 bits)
  sub_exp_shamt: subtractor
    generic map (N => 7)
    port map (a=>exp_common, b=>("000" & shamt_norm), diff=>exp_dec, borrow=>open);

  -- Build carry path condition and mantissa selections
  carry_and        <= same_sign and cout_sum;

  -- Carry path (same-sign add with carry): take fraction bits after conceptual right shift
  mant8_carry_path <= norm_in(8 downto 1);

  -- Left-normalize path: store only fraction bits; leading 1 is implicit
  mant8_sub_path   <= norm_out(7 downto 0);

  sel_mant8_unrounded: mux2
    generic map (N => 8)
    port map (a=>mant8_sub_path, b=>mant8_carry_path, s=>carry_and, y=>mant8_unrounded);

  -- Guard bit selection: carry path uses dropped LSB; left-normalize path uses '0' (rely on sticky)
  guard_sub_vec(0)   <= '0';
  guard_carry_vec(0) <= norm_in(0);

  sel_guard: mux2
    generic map (N => 1)
    port map (a=>guard_sub_vec, b=>guard_carry_vec, s=>carry_and, y=>guard_sel_vec);

  round_bit <= guard_sel_vec(0) or sticky_in;

  -- Round to 8 bits (add round_bit)
  rnd: ripple_adder
    generic map (N => 8)
    port map (a=>mant8_unrounded, b=>(others=>'0'), cin=>round_bit,
              sum=>mant8_rounded, cout=>cout_round);

  -- Select exponent path (inc if carry path, else dec), then add rounding carry
  sel_exp_incdec: mux2
    generic map (N => 7)
    port map (a=>exp_dec, b=>exp_inc, s=>carry_and, y=>exp_sel);

  add_exp_round: ripple_adder
    generic map (N => 7)
    port map (a=>exp_sel, b=>(others=>'0'), cin=>cout_round, sum=>exp_out_i, cout=>open);

  -- Drive OUT ports
  exp_out  <= exp_out_i;
  mant_out <= mant8_rounded;

  -- Overflow compare against 127 (all ones)
  cmp_ovf: comparator
    generic map (N => 7)
    port map (a=>exp_out_i, b=>(others=>'1'), lt=>ov_lt, eq=>ov_eq, gt=>ov_gt);

  overflow <= ov_eq; -- or (ov_gt or ov_eq) for >= detection
end architecture;