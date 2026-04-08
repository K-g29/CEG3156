library ieee;
use ieee.std_logic_1164.all;

entity eq3 is
  port(
    a  : in  std_logic_vector(2 downto 0);
    b  : in  std_logic_vector(2 downto 0);
    eq : out std_logic
  );
end entity;

architecture structural of eq3 is
  signal x2, x1, x0 : std_logic;
begin
  x2 <= a(2) xnor b(2);
  x1 <= a(1) xnor b(1);
  x0 <= a(0) xnor b(0);
  eq <= x2 and x1 and x0;
end architecture;