library ieee;
use ieee.std_logic_1164.all;

entity branch_take is
  port(
    BranchEQ  : in  std_logic;
    BranchNE  : in  std_logic;
    Zero      : in  std_logic;
    TakeBr    : out std_logic
  );
end entity;

architecture structural of branch_take is
  signal nZero : std_logic;
  signal tEQ   : std_logic;
  signal tNE   : std_logic;
begin
  nZero <= not Zero;
  tEQ   <= BranchEQ and Zero;
  tNE   <= BranchNE and nZero;
  TakeBr <= tEQ or tNE;
end architecture;