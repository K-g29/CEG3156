library ieee;
use ieee.std_logic_1164.all;

entity pc_plus4 is
  port(
    pc      : in  std_logic_vector(7 downto 0);
    pc_plus : out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of pc_plus4 is
  signal b    : std_logic_vector(7 downto 0);
  signal cout : std_logic;
begin
  b <= "00000100";

  add4: entity work.ripple_adder
    generic map(N => 8)
    port map(
      a    => pc,
      b    => b,
      cin  => '0',
      sum  => pc_plus,
      cout => cout
    );
end architecture;