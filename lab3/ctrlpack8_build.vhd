library ieee;
use ieee.std_logic_1164.all;

-- Builds CtrlPack8 = [ '0', RegDst, Jump, MemRead, MemtoReg, ALUOp1, ALUOp0, ALUSrc ]
entity ctrlpack8_build is
  port(
    RegDst   : in  std_logic;
    Jump     : in  std_logic;
    MemRead  : in  std_logic;
    MemtoReg : in  std_logic;
    ALUOp1   : in  std_logic;
    ALUOp0   : in  std_logic;
    ALUSrc   : in  std_logic;
    CtrlPack8: out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of ctrlpack8_build is
begin
  CtrlPack8(7) <= '0';
  CtrlPack8(6) <= RegDst;
  CtrlPack8(5) <= Jump;
  CtrlPack8(4) <= MemRead;
  CtrlPack8(3) <= MemtoReg;
  CtrlPack8(2) <= ALUOp1;
  CtrlPack8(1) <= ALUOp0;
  CtrlPack8(0) <= ALUSrc;
end architecture;