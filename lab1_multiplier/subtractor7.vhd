library ieee;
use ieee.std_logic_1164.all;

-- Unsigned subtractor: diff = a - b (two's complement add of NOT b + 1).
entity subtractor7 is
  port (
    a    : in  std_logic_vector(6 downto 0);
    b    : in  std_logic_vector(6 downto 0);
    diff : out std_logic_vector(6 downto 0)
  );
end entity;

architecture rtl of subtractor7 is
  signal nb : std_logic_vector(6 downto 0);
  signal c  : std_logic_vector(7 downto 0);
  signal p  : std_logic_vector(6 downto 0);
begin
  nb    <= not b;
  c(0)  <= '1'; -- +1
  gen: for i in 0 to 6 generate
    p(i)    <= a(i) xor nb(i);
    diff(i) <= p(i) xor c(i);
    c(i+1)  <= (a(i) and nb(i)) or (p(i) and c(i));
  end generate;
end architecture;