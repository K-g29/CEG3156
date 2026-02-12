library ieee;
use ieee.std_logic_1164.all;

-- Structural datapath for FP multiplier (no rounding).
entity fp_mult_datapath is
  port (
    i_resetBar : in  std_logic;
    i_clock    : in  std_logic;
    -- Inputs
    signA      : in  std_logic;
    mantA      : in  std_logic_vector(7 downto 0);
    expA       : in  std_logic_vector(6 downto 0);
    signB      : in  std_logic;
    mantB      : in  std_logic_vector(7 downto 0);
    expB       : in  std_logic_vector(6 downto 0);
    -- Control
    en_load    : in  std_logic;
    en_mult    : in  std_logic;
    en_norm    : in  std_logic;
    -- Outputs
    o_sign     : out std_logic;
    o_mant     : out std_logic_vector(7 downto 0);
    o_exp      : out std_logic_vector(6 downto 0);
    o_overflow : out std_logic
  );
end entity;

architecture structural of fp_mult_datapath is
  component nBitRegister is
    generic ( N : natural := 1 );
    port (
      i_resetBar : in  std_logic;
      i_clock    : in  std_logic;
      i_enable   : in  std_logic;
      d          : in  std_logic_vector(N-1 downto 0);
      q          : out std_logic_vector(N-1 downto 0)
    );
  end component;

  component mult_shift_add_tree_9x9 is
    port ( a9: in std_logic_vector(8 downto 0);
           b9: in std_logic_vector(8 downto 0);
           prod18: out std_logic_vector(17 downto 0) );
  end component;

  component mult_normalize18 is
    port ( prod_in: in std_logic_vector(17 downto 0);
           prod_norm: out std_logic_vector(17 downto 0);
           norm_shift: out std_logic );
  end component;

  component ripple_adder7 is
    port ( a,b: in std_logic_vector(6 downto 0);
           cin: in std_logic;
           sum: out std_logic_vector(6 downto 0);
           cout: out std_logic );
  end component;

  component subtractor7 is
    port ( a,b: in std_logic_vector(6 downto 0);
           diff: out std_logic_vector(6 downto 0) );
  end component;

  -- LOAD registers
  signal r_signA, r_signB : std_logic_vector(0 downto 0);
  signal r_expA, r_expB   : std_logic_vector(6 downto 0);
  signal r_mantA, r_mantB : std_logic_vector(7 downto 0);

  -- MULT stage regs
  signal r_a9, r_b9       : std_logic_vector(8 downto 0);
  signal prod18_s         : std_logic_vector(17 downto 0);
  signal r_prod18         : std_logic_vector(17 downto 0);
  signal exp_sum_s        : std_logic_vector(6 downto 0);
  signal exp_base_s       : std_logic_vector(6 downto 0);
  signal r_exp_base       : std_logic_vector(6 downto 0);
  constant bias63_s       : std_logic_vector(6 downto 0) := "0111111";

  -- NORM stage regs
  signal prod18_norm_s    : std_logic_vector(17 downto 0);
  signal norm_shift_s     : std_logic;
  signal r_prod18_norm    : std_logic_vector(17 downto 0);
  signal r_norm_shift     : std_logic_vector(0 downto 0);
  signal exp_out_s        : std_logic_vector(6 downto 0);
  signal r_exp_out        : std_logic_vector(6 downto 0);
  signal r_sign_out       : std_logic_vector(0 downto 0);
  signal r_mant_out       : std_logic_vector(7 downto 0);
  signal r_overflow       : std_logic_vector(0 downto 0);

  -- FIX for port map expressions: prepare signals for conditional inputs
  signal exp_norm_inc_s   : std_logic_vector(6 downto 0); -- "0000001" or "0000000"
  signal overflow_comb_s  : std_logic;                    -- '1' when r_exp_out=127 else '0'
begin
  -- LOAD
  reg_signA: nBitRegister generic map(N=>1)
    port map(i_resetBar=>i_resetBar, i_clock=>i_clock, i_enable=>en_load,
             d=>(others=>signA), q=>r_signA);

  reg_signB: nBitRegister generic map(N=>1)
    port map(i_resetBar=>i_resetBar, i_clock=>i_clock, i_enable=>en_load,
             d=>(others=>signB), q=>r_signB);

  reg_expA : nBitRegister generic map(N=>7)
    port map(i_resetBar=>i_resetBar, i_clock=>i_clock, i_enable=>en_load,
             d=>expA, q=>r_expA);

  reg_expB : nBitRegister generic map(N=>7)
    port map(i_resetBar=>i_resetBar, i_clock=>i_clock, i_enable=>en_load,
             d=>expB, q=>r_expB);

  reg_mantA: nBitRegister generic map(N=>8)
    port map(i_resetBar=>i_resetBar, i_clock=>i_clock, i_enable=>en_load,
             d=>mantA, q=>r_mantA);

  reg_mantB: nBitRegister generic map(N=>8)
    port map(i_resetBar=>i_resetBar, i_clock=>i_clock, i_enable=>en_load,
             d=>mantB, q=>r_mantB);

  -- Prepare 9-bit significands
  r_a9 <= '1' & r_mantA;
  r_b9 <= '1' & r_mantB;

  -- MULT (combinational components)
  mult_u  : mult_shift_add_tree_9x9 port map(a9=>r_a9, b9=>r_b9, prod18=>prod18_s);
  add_exp : ripple_adder7          port map(a=>r_expA, b=>r_expB, cin=>'0', sum=>exp_sum_s, cout=>open);
  sub_bias: subtractor7            port map(a=>exp_sum_s, b=>bias63_s, diff=>exp_base_s);

  -- MULT registers
  reg_prod18 : nBitRegister generic map(N=>18)
    port map(i_resetBar=>i_resetBar, i_clock=>i_clock, i_enable=>en_mult,
             d=>prod18_s, q=>r_prod18);

  reg_expbase: nBitRegister generic map(N=>7)
    port map(i_resetBar=>i_resetBar, i_clock=>i_clock, i_enable=>en_mult,
             d=>exp_base_s, q=>r_exp_base);

  -- NORM: build conditional inputs as signals (tool doesn't allow 'when' in port map)
  exp_norm_inc_s <= "0000001" when norm_shift_s='1' else "0000000";

  norm_u   : mult_normalize18 port map(prod_in=>r_prod18, prod_norm=>prod18_norm_s, norm_shift=>norm_shift_s);
  add_norm : ripple_adder7    port map(a=>r_exp_base,
                                       b=>exp_norm_inc_s,
                                       cin=>'0',
                                       sum=>exp_out_s,
                                       cout=>open);

  -- NORM registers
  reg_prod18n : nBitRegister generic map(N=>18)
    port map(i_resetBar=>i_resetBar, i_clock=>i_clock, i_enable=>en_norm,
             d=>prod18_norm_s, q=>r_prod18_norm);

  reg_normsh  : nBitRegister generic map(N=>1)
    port map(i_resetBar=>i_resetBar, i_clock=>i_clock, i_enable=>en_norm,
             d=>(others=>norm_shift_s), q=>r_norm_shift);

  reg_expout  : nBitRegister generic map(N=>7)
    port map(i_resetBar=>i_resetBar, i_clock=>i_clock, i_enable=>en_norm,
             d=>exp_out_s, q=>r_exp_out);

  reg_signout : nBitRegister generic map(N=>1)
    port map(i_resetBar=>i_resetBar, i_clock=>i_clock, i_enable=>en_norm,
             d=>(others=>(r_signA(0) xor r_signB(0))), q=>r_sign_out);

  reg_mantout : nBitRegister generic map(N=>8)
    port map(i_resetBar=>i_resetBar, i_clock=>i_clock, i_enable=>en_norm,
             d=>r_prod18_norm(15 downto 8), q=>r_mant_out);

  -- Overflow combinational signal and register
  overflow_comb_s <= '1' when r_exp_out="1111111" else '0';

  reg_ovf     : nBitRegister generic map(N=>1)
    port map(i_resetBar=>i_resetBar, i_clock=>i_clock, i_enable=>en_norm,
             d=>(others=>overflow_comb_s),
             q=>r_overflow);

  -- Outputs
  o_sign     <= r_sign_out(0);
  o_mant     <= r_mant_out;
  o_exp      <= r_exp_out;
  o_overflow <= r_overflow(0);
end architecture;