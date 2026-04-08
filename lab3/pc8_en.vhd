library ieee;
use ieee.std_logic_1164.all;

entity pc8_en is
  port(
    clk      : in  std_logic;
    resetBar  : in  std_logic;
    en       : in  std_logic; -- PCWrite
    d        : in  std_logic_vector(7 downto 0);
    q        : out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of pc8_en is
begin
  r: entity work.nbitRegister
    generic map(N => 8)
    port map(
      i_resetBar => resetBar,
      i_enable   => en,
      i_clock    => clk,
      i_d        => d,
      o_q        => q
    );
end architecture;