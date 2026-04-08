library ieee;
use ieee.std_logic_1164.all;

entity logic8 is
  port(
    a    : in  std_logic_vector(7 downto 0);
    b    : in  std_logic_vector(7 downto 0);
    andy : out std_logic_vector(7 downto 0);
    ory  : out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of logic8 is
begin
  andy <= a and b;
  ory  <= a or b;
end architecture;