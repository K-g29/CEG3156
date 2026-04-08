library ieee;
use ieee.std_logic_1164.all;

entity shift_left2_8 is
  port(
    x : in  std_logic_vector(7 downto 0);
    y : out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of shift_left2_8 is
begin
  y(7 downto 2) <= x(5 downto 0);
  y(1 downto 0) <= "00";
end architecture;