library ieee;
use ieee.std_logic_1164.all;

entity pc8 is
  port(
    clk        : in  std_logic;
    resetBar   : in  std_logic;
    d          : in  std_logic_vector(7 downto 0);
    q          : out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of pc8 is
  signal qBar_unused : std_logic_vector(7 downto 0);
begin
  gen: for i in 0 to 7 generate
    FF: entity work.enARdFF_2
      port map(
        i_resetBar => resetBar,
        i_d        => d(i),
        i_enable   => '1',
        i_clock    => clk,
        o_q        => q(i),
        o_qBar     => qBar_unused(i)
      );
  end generate;
end architecture;