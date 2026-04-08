library ieee;
use ieee.std_logic_1164.all;

entity mux2 is
  generic (N : natural := 8);
  port (
    a : in  std_logic_vector(N-1 downto 0);
    b : in  std_logic_vector(N-1 downto 0);
    s : in  std_logic; 
    y : out std_logic_vector(N-1 downto 0)
  );
end entity;

architecture structural of mux2 is
  signal ns : std_logic;
begin
  ns <= not s;

  gen: for i in 0 to N-1 generate
   
    y(i) <= (a(i) and ns) or (b(i) and s);
  end generate;
end architecture;