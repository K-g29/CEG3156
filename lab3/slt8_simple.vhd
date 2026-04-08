library ieee;
use ieee.std_logic_1164.all;

entity slt8_simple is
  port(
    diff : in  std_logic_vector(7 downto 0); -- a-b
    y    : out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of slt8_simple is
begin
  y(7 downto 1) <= (others => '0');
  y(0) <= diff(7); -- 1 if negative
end architecture;