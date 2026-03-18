library ieee;
use ieee.std_logic_1164.all;

entity signext16_to_8_signed is
  port(
    imm16 : in  std_logic_vector(15 downto 0);
    imm8  : out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of signext16_to_8_signed is
begin
  -- preserve low 7 bits
  imm8(6 downto 0) <= imm16(6 downto 0);

  -- sign bit for the 8-bit world comes from imm16(15)
  imm8(7) <= imm16(15);
end architecture;