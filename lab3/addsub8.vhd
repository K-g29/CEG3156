library ieee;
use ieee.std_logic_1164.all;

entity addsub8 is
  port(
    a    : in  std_logic_vector(7 downto 0);
    b    : in  std_logic_vector(7 downto 0);
    sub  : in  std_logic; -- 0 add, 1 subtract
    y    : out std_logic_vector(7 downto 0);
    cout : out std_logic
  );
end entity;

architecture structural of addsub8 is
  signal b_xor : std_logic_vector(7 downto 0);
begin
  -- if sub=1 invert b, else pass b
  b_xor(0) <= b(0) xor sub;
  b_xor(1) <= b(1) xor sub;
  b_xor(2) <= b(2) xor sub;
  b_xor(3) <= b(3) xor sub;
  b_xor(4) <= b(4) xor sub;
  b_xor(5) <= b(5) xor sub;
  b_xor(6) <= b(6) xor sub;
  b_xor(7) <= b(7) xor sub;

  add: entity work.ripple_adder
    generic map(N => 8)
    port map(
      a    => a,
      b    => b_xor,
      cin  => sub,
      sum  => y,
      cout => cout
    );
end architecture;