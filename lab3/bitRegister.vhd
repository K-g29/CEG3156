library ieee;
use ieee.std_logic_1164.all;

entity bitRegister is
  port(
    clk      : in  std_logic;
    resetBar : in  std_logic;
    en       : in  std_logic;
    d        : in  std_logic;
    q        : out std_logic
  );
end entity;

architecture structural of bitRegister is
  signal qbar : std_logic;
begin
  ff: entity work.enARdFF_2
    port map(
      i_resetBar => resetBar,
      i_d        => d,
      i_enable   => en,
      i_clock    => clk,
      o_q        => q,
      o_qBar     => qbar
    );
end architecture;