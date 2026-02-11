library ieee;
use ieee.std_logic_1164.all;

entity mux2 is
  generic (N : natural := 8);
  port (
    a : in  std_logic_vector(N-1 downto 0);
    b : in  std_logic_vector(N-1 downto 0);
    s : in  std_logic;  -- 0->a, 1->b
    y : out std_logic_vector(N-1 downto 0)
  );
end entity;

architecture rtl of mux2 is
begin
  y <= a when s='0' else b;
end architecture;