library ieee;
use ieee.std_logic_1164.all;

entity decoder3to8 is
  port(
    a  : in  std_logic_vector(2 downto 0);
    en : in  std_logic;
    y  : out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of decoder3to8 is
  signal na0, na1, na2 : std_logic;
begin
  na0 <= not a(0);
  na1 <= not a(1);
  na2 <= not a(2);

  y(0) <= en and na2 and na1 and na0;
  y(1) <= en and na2 and na1 and a(0);
  y(2) <= en and na2 and a(1) and na0;
  y(3) <= en and na2 and a(1) and a(0);
  y(4) <= en and a(2) and na1 and na0;
  y(5) <= en and a(2) and na1 and a(0);
  y(6) <= en and a(2) and a(1) and na0;
  y(7) <= en and a(2) and a(1) and a(0);
end architecture;