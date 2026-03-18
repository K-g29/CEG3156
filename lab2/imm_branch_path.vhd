library ieee;
use ieee.std_logic_1164.all;

entity imm_branch_path is
  port(
    imm16    : in  std_logic_vector(15 downto 0);
    imm8     : out std_logic_vector(7 downto 0);
    imm8_sl2 : out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of imm_branch_path is
begin
  -- Signed truncate 16-bit immediate to 8-bit:
  -- keep low 7 bits, and force bit7 to be the sign (imm16(15))
  imm8(6 downto 0) <= imm16(6 downto 0);
  imm8(7)          <= imm16(15);

  -- shift left by 2 (wiring): imm8_sl2 = imm8 << 2
  imm8_sl2(7 downto 2) <= imm16(6 downto 0);
  imm8_sl2(1 downto 0) <= "00";
end architecture;