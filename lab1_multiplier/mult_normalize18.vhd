library ieee;
use ieee.std_logic_1164.all;

-- Normalize product to [1.0,2.0): if prod18(17)='1' then shift right by 1.
-- Outputs normalized product and norm_shift (0 or 1).
entity mult_normalize18 is
  port (
    prod_in    : in  std_logic_vector(17 downto 0);
    prod_norm  : out std_logic_vector(17 downto 0);
    norm_shift : out std_logic  -- '1' when shifted by 1
  );
end entity;

architecture rtl of mult_normalize18 is
begin
  norm_shift <= '1' when prod_in(17)='1' else '0';
  prod_norm  <= ('0' & prod_in(17 downto 1)) when prod_in(17)='1' else prod_in;
end architecture;