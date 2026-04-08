library ieee;
use ieee.std_logic_1164.all;

entity alu_control_unit is
  port(
    ALUOp1    : in  std_logic;
    ALUOp0    : in  std_logic;
    funct     : in  std_logic_vector(5 downto 0);
    Operation : out std_logic_vector(2 downto 0)
  );
end entity;

architecture structural of alu_control_unit is
  signal F0,F1,F2,F3 : std_logic;
begin
  F0 <= funct(0);
  F1 <= funct(1);
  F2 <= funct(2);
  F3 <= funct(3);

  -- Operation2 = ALUOp0 OR (ALUOp1 AND F1)
  Operation(2) <= ALUOp0 or (ALUOp1 and F1);

  -- Operation1 = (NOT ALUOp1) OR (NOT F2)
  Operation(1) <= (not ALUOp1) or (not F2);

  -- Operation0 = ALUOp1 AND (F3 OR F0)
  Operation(0) <= ALUOp1 and (F3 or F0);
end architecture;