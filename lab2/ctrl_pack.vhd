library ieee;
use ieee.std_logic_1164.all;

entity ctrl_pack is
  port (
    RegDst   : in  std_logic;
    Jump     : in  std_logic;
    MemRead  : in  std_logic;
    MemtoReg : in  std_logic;
    ALUOp1   : in  std_logic;
    ALUOp0   : in  std_logic;
    ALUSrc   : in  std_logic;
    CtrlPack : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of ctrl_pack is
begin
  CtrlPack <= '0' & RegDst & Jump & MemRead & MemtoReg & ALUOp1 & ALUOp0 & ALUSrc;
end architecture;