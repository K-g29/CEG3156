library ieee;
use ieee.std_logic_1164.all;

-- 7-bit ripple adder for exponent arithmetic.
entity ripple_adder7 is
  port (
    a    : in  std_logic_vector(6 downto 0);
    b    : in  std_logic_vector(6 downto 0);
    cin  : in  std_logic;
    sum  : out std_logic_vector(6 downto 0);
    cout : out std_logic
  );
end entity;

architecture structural of ripple_adder7 is
  signal p, g : std_logic_vector(6 downto 0);
  signal c    : std_logic_vector(7 downto 0);
begin
  c(0) <= cin;

  gen_pg: for i in 0 to 6 generate
    p(i) <= a(i) xor b(i);
    g(i) <= a(i) and b(i);
  end generate;

  gen_sum: for i in 0 to 6 generate
    sum(i) <= p(i) xor c(i);
    c(i+1) <= g(i) or (p(i) and c(i));
  end generate;

  cout <= c(7);
end architecture;