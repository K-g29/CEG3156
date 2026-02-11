library ieee;
use ieee.std_logic_1164.all;

-- Datapath: registers + combinational blocks (fp_align, fp_add_core).

entity fp_add_datapath is
  port (
    i_resetBar : in  std_logic;
    i_clock    : in  std_logic;

    -- Operands
    signA      : in  std_logic;
    mantA      : in  std_logic_vector(7 downto 0);
    expA       : in  std_logic_vector(6 downto 0);
    signB      : in  std_logic;
    mantB      : in  std_logic_vector(7 downto 0);
    expB       : in  std_logic_vector(6 downto 0);

    -- Control enables
    en_load    : in  std_logic;
    en_align   : in  std_logic;
    en_core    : in  std_logic;

    -- Results (registered)
    o_sign     : out std_logic;
    o_mant     : out std_logic_vector(7 downto 0);
    o_exp      : out std_logic_vector(6 downto 0);
    o_overflow : out std_logic
  );
end entity;

architecture rtl of fp_add_datapath is
  component nbitRegister is
    generic (N : natural := 8);
    port (
      i_resetBar : in  std_logic;
      i_enable   : in  std_logic;
      i_clock    : in  std_logic;
      i_d        : in  std_logic_vector(N-1 downto 0);
      o_q        : out std_logic_vector(N-1 downto 0)
    );
  end component;

  component fp_align is
    port (
      signA      : in  std_logic;
      mantA      : in  std_logic_vector(7 downto 0);
      expA       : in  std_logic_vector(6 downto 0);
      signB      : in  std_logic;
      mantB      : in  std_logic_vector(7 downto 0);
      expB       : in  std_logic_vector(6 downto 0);
      big_sign   : out std_logic;
      sml_sign   : out std_logic;
      mant_big   : out std_logic_vector(8 downto 0);
      mant_sml   : out std_logic_vector(8 downto 0);
      exp_common : out std_logic_vector(6 downto 0);
      sticky_out : out std_logic
    );
  end component;

  component fp_add_core is
    port (
      big_sign    : in  std_logic;
      sml_sign    : in  std_logic;
      mant_big    : in  std_logic_vector(8 downto 0);
      mant_sml    : in  std_logic_vector(8 downto 0);
      exp_common  : in  std_logic_vector(6 downto 0);
      sticky_in   : in  std_logic;
      sign_out    : out std_logic;
      mant_out    : out std_logic_vector(7 downto 0);
      exp_out     : out std_logic_vector(6 downto 0);
      overflow    : out std_logic
    );
  end component;

  -- Input registers
  signal A_sign_R  : std_logic_vector(0 downto 0);
  signal A_mant_R  : std_logic_vector(7 downto 0);
  signal A_exp_R   : std_logic_vector(6 downto 0);
  signal B_sign_R  : std_logic_vector(0 downto 0);
  signal B_mant_R  : std_logic_vector(7 downto 0);
  signal B_exp_R   : std_logic_vector(6 downto 0);

  -- Align outputs (comb) and align registers
  signal big_sign_w  : std_logic;
  signal sml_sign_w  : std_logic;
  signal mant_big_w  : std_logic_vector(8 downto 0);
  signal mant_sml_w  : std_logic_vector(8 downto 0);
  signal exp_common_w: std_logic_vector(6 downto 0);
  signal sticky_w    : std_logic;

  signal big_sign_R2  : std_logic_vector(0 downto 0);
  signal sml_sign_R2  : std_logic_vector(0 downto 0);
  signal mant_big_R   : std_logic_vector(8 downto 0);
  signal mant_sml_R   : std_logic_vector(8 downto 0);
  signal exp_common_R : std_logic_vector(6 downto 0);
  signal sticky_R     : std_logic_vector(0 downto 0);

  -- Core outputs (comb) and result registers
  signal sign_out_w  : std_logic;
  signal mant_out_w  : std_logic_vector(7 downto 0);
  signal exp_out_w   : std_logic_vector(6 downto 0);
  signal overflow_w  : std_logic;

  signal sign_out_R3 : std_logic_vector(0 downto 0);
  signal mant_out_R3 : std_logic_vector(7 downto 0);
  signal exp_out_R3  : std_logic_vector(6 downto 0);
  signal overflow_R3 : std_logic_vector(0 downto 0);
begin
  -- Stage 1: input regs
  reg_A_sign: nbitRegister
    generic map (N => 1)
    port map (i_resetBar, en_load, i_clock, (0=>signA), A_sign_R);

  reg_A_mant: nbitRegister
    generic map (N => 8)
    port map (i_resetBar, en_load, i_clock, mantA, A_mant_R);

  reg_A_exp: nbitRegister
    generic map (N => 7)
    port map (i_resetBar, en_load, i_clock, expA, A_exp_R);

  reg_B_sign: nbitRegister
    generic map (N => 1)
    port map (i_resetBar, en_load, i_clock, (0=>signB), B_sign_R);

  reg_B_mant: nbitRegister
    generic map (N => 8)
    port map (i_resetBar, en_load, i_clock, mantB, B_mant_R);

  reg_B_exp: nbitRegister
    generic map (N => 7)
    port map (i_resetBar, en_load, i_clock, expB, B_exp_R);

  -- Align
  aligner: fp_align
    port map (
      signA      => A_sign_R(0),
      mantA      => A_mant_R,
      expA       => A_exp_R,
      signB      => B_sign_R(0),
      mantB      => B_mant_R,
      expB       => B_exp_R,
      big_sign   => big_sign_w,
      sml_sign   => sml_sign_w,
      mant_big   => mant_big_w,
      mant_sml   => mant_sml_w,
      exp_common => exp_common_w,
      sticky_out => sticky_w
    );

  -- Stage 2: align regs
  reg_big_sign: nbitRegister
    generic map (N => 1)
    port map (i_resetBar, en_align, i_clock, (0=>big_sign_w), big_sign_R2);

  reg_sml_sign: nbitRegister
    generic map (N => 1)
    port map (i_resetBar, en_align, i_clock, (0=>sml_sign_w), sml_sign_R2);

  reg_mant_big: nbitRegister
    generic map (N => 9)
    port map (i_resetBar, en_align, i_clock, mant_big_w, mant_big_R);

  reg_mant_sml: nbitRegister
    generic map (N => 9)
    port map (i_resetBar, en_align, i_clock, mant_sml_w, mant_sml_R);

  reg_exp_common: nbitRegister
    generic map (N => 7)
    port map (i_resetBar, en_align, i_clock, exp_common_w, exp_common_R);

  reg_sticky: nbitRegister
    generic map (N => 1)
    port map (i_resetBar, en_align, i_clock, (0=>sticky_w), sticky_R);

  -- Core
  core: fp_add_core
    port map (
      big_sign   => big_sign_R2(0),
      sml_sign   => sml_sign_R2(0),
      mant_big   => mant_big_R,
      mant_sml   => mant_sml_R,
      exp_common => exp_common_R,
      sticky_in  => sticky_R(0),
      sign_out   => sign_out_w,
      mant_out   => mant_out_w,
      exp_out    => exp_out_w,
      overflow   => overflow_w
    );

  -- Stage 3: result regs
  reg_sign_out: nbitRegister
    generic map (N => 1)
    port map (i_resetBar, en_core, i_clock, (0=>sign_out_w), sign_out_R3);

  reg_mant_out: nbitRegister
    generic map (N => 8)
    port map (i_resetBar, en_core, i_clock, mant_out_w, mant_out_R3);

  reg_exp_out: nbitRegister
    generic map (N => 7)
    port map (i_resetBar, en_core, i_clock, exp_out_w, exp_out_R3);

  reg_overflow: nbitRegister
    generic map (N => 1)
    port map (i_resetBar, en_core, i_clock, (0=>overflow_w), overflow_R3);

  -- Outputs
  o_sign     <= sign_out_R3(0);
  o_mant     <= mant_out_R3;
  o_exp      <= exp_out_R3;
  o_overflow <= overflow_R3(0);
end architecture;