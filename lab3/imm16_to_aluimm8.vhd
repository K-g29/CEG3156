library ieee;
use ieee.std_logic_1164.all;

entity imm16_to_aluimm8 is
  port (
    imm16   : in  std_logic_vector(15 downto 0);
    ALUImm8 : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of imm16_to_aluimm8 is
begin
  ALUImm8(6 downto 0) <= imm16(6 downto 0);
  ALUImm8(7)          <= imm16(15);
end architecture;