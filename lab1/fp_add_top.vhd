library ieee;
use ieee.std_logic_1164.all;

-- Top-level
entity fp_add_top is
  port (
    i_resetBar : in  std_logic;
    i_clock    : in  std_logic;

    -- Operand A
    signA      : in  std_logic;
    mantA      : in  std_logic_vector(7 downto 0);
    expA       : in  std_logic_vector(6 downto 0);

    -- Operand B
    signB      : in  std_logic;
    mantB      : in  std_logic_vector(7 downto 0);
    expB       : in  std_logic_vector(6 downto 0);

    -- Result
    o_sign     : out std_logic;
    o_mant     : out std_logic_vector(7 downto 0);
    o_exp      : out std_logic_vector(6 downto 0);
    o_overflow : out std_logic;
    o_valid    : out std_logic
  );
end entity;

architecture structural of fp_add_top is
  component fp_add_control is
    port (
      i_resetBar : in  std_logic;
      i_clock    : in  std_logic;
      en_load    : out std_logic;
      en_align   : out std_logic;
      en_core    : out std_logic;
      o_valid    : out std_logic
    );
  end component;

  component fp_add_datapath is
    port (
      i_resetBar : in  std_logic;
      i_clock    : in  std_logic;
      signA      : in  std_logic;
      mantA      : in  std_logic_vector(7 downto 0);
      expA       : in  std_logic_vector(6 downto 0);
      signB      : in  std_logic;
      mantB      : in  std_logic_vector(7 downto 0);
      expB       : in  std_logic_vector(6 downto 0);
      en_load    : in  std_logic;
      en_align   : in  std_logic;
      en_core    : in  std_logic;
      o_sign     : out std_logic;
      o_mant     : out std_logic_vector(7 downto 0);
      o_exp      : out std_logic_vector(6 downto 0);
      o_overflow : out std_logic
    );
  end component;

  signal en_load_s, en_align_s, en_core_s : std_logic;
begin
  ctrl: fp_add_control
    port map (
      i_resetBar => i_resetBar,
      i_clock    => i_clock,
      en_load    => en_load_s,
      en_align   => en_align_s,
      en_core    => en_core_s,
      o_valid    => o_valid
    );

  data: fp_add_datapath
    port map (
      i_resetBar => i_resetBar,
      i_clock    => i_clock,
      signA      => signA,
      mantA      => mantA,
      expA       => expA,
      signB      => signB,
      mantB      => mantB,
      expB       => expB,
      en_load    => en_load_s,
      en_align   => en_align_s,
      en_core    => en_core_s,
      o_sign     => o_sign,
      o_mant     => o_mant,
      o_exp      => o_exp,
      o_overflow => o_overflow
    );
end architecture;