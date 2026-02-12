library ieee;
use ieee.std_logic_1164.all;

-- 18-bit ripple adde used to accumulate partial products.
entity ripple_adder18 is
  port (
    a    : in  std_logic_vector(17 downto 0);
    b    : in  std_logic_vector(17 downto 0);
    cin  : in  std_logic;
    sum  : out std_logic_vector(17 downto 0);
    cout : out std_logic
  );
end entity;

architecture structural of ripple_adder18 is
  signal p, g : std_logic_vector(17 downto 0);
  signal c    : std_logic_vector(18 downto 0);
begin
  c(0) <= cin;

  gen_pg: for i in 0 to 17 generate
    p(i) <= a(i) xor b(i);
    g(i) <= a(i) and b(i);
  end generate;

  gen_sum: for i in 0 to 17 generate
    sum(i) <= p(i) xor c(i);
    c(i+1) <= g(i) or (p(i) and c(i));
  end generate;

  cout <= c(18);
end architecture;