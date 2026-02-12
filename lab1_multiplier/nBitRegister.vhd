library ieee;
use ieee.std_logic_1164.all;

-- N-bit register built from enARdFF_2 (enable, async reset low).
entity nBitRegister is
  generic ( N : natural := 1 );
  port (
    i_resetBar : in  std_logic;
    i_clock    : in  std_logic;
    i_enable   : in  std_logic;
    d          : in  std_logic_vector(N-1 downto 0);
    q          : out std_logic_vector(N-1 downto 0)
  );
end entity;

architecture structural of nBitRegister is
  component enARdFF_2 is
    port (
      i_resetBar : in  std_logic;
      i_d        : in  std_logic;
      i_enable   : in  std_logic;
      i_clock    : in  std_logic;
      o_q, o_qBar: out std_logic
    );
  end component;

  signal qbar : std_logic_vector(N-1 downto 0);
begin
  gen: for i in 0 to N-1 generate
    dff_i: enARdFF_2
      port map (
        i_resetBar => i_resetBar,
        i_d        => d(i),
        i_enable   => i_enable,
        i_clock    => i_clock,
        o_q        => q(i),
        o_qBar     => qbar(i)
      );
  end generate;
end architecture;