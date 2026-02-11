library ieee;
use ieee.std_logic_1164.all;


-- Always enables all pipeline stages; o_valid asserts after 3 clocks.
entity fp_add_control is
  port (
    i_resetBar : in  std_logic;  -- active-low async reset
    i_clock    : in  std_logic;

    en_load    : out std_logic;
    en_align   : out std_logic;
    en_core    : out std_logic;
    o_valid    : out std_logic
  );
end entity;

architecture structural of fp_add_control is
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

  signal valid_reg  : std_logic_vector(2 downto 0);
  signal valid_next : std_logic_vector(2 downto 0);
begin
  en_load  <= '1';
  en_align <= '1';
  en_core  <= '1';

  valid_next(0) <= '1';
  valid_next(1) <= valid_reg(0);
  valid_next(2) <= valid_reg(1);

  valid_sr: nbitRegister
    generic map (N => 3)
    port map (
      i_resetBar => i_resetBar,
      i_enable   => '1',
      i_clock    => i_clock,
      i_d        => valid_next,
      o_q        => valid_reg
    );

  o_valid <= valid_reg(2);
end architecture;