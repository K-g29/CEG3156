library ieee;
use ieee.std_logic_1164.all;

-- Signed truncate 16-bit immediate to 8-bit:
-- imm8[6:0] = imm16[6:0], imm8[7] = imm16[15]
entity imm8_trunc is
  port(
    imm16 : in  std_logic_vector(15 downto 0);
    imm8  : out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of imm8_trunc is
begin
  imm8(6 downto 0) <= imm16(6 downto 0);
  imm8(7)          <= imm16(15);
end architecture;