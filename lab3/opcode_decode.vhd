library ieee;
use ieee.std_logic_1164.all;

entity opcode_decode is
  port(
    op      : in  std_logic_vector(5 downto 0);
    isRtype : out std_logic;
    isLW    : out std_logic;
    isSW    : out std_logic;
    isBEQ   : out std_logic;
    isBNE   : out std_logic;
    isJ     : out std_logic
  );
end entity;

architecture structural of opcode_decode is
  signal n : std_logic_vector(5 downto 0);
begin
  -- invert opcode bits
  n(0) <= not op(0);
  n(1) <= not op(1);
  n(2) <= not op(2);
  n(3) <= not op(3);
  n(4) <= not op(4);
  n(5) <= not op(5);

  -- opcodes:
  -- Rtype: 000000
  isRtype <= n(5) and n(4) and n(3) and n(2) and n(1) and n(0);

  -- lw:    100011 (35)
  isLW <= op(5) and n(4) and n(3) and n(2) and op(1) and op(0);

  -- sw:    101011 (43)
  isSW <= op(5) and n(4) and op(3) and n(2) and op(1) and op(0);

  -- beq:   000100 (4)
  isBEQ <= n(5) and n(4) and n(3) and op(2) and n(1) and n(0);

  -- bne:   000101 (5)
  isBNE <= n(5) and n(4) and n(3) and op(2) and n(1) and op(0);

  -- j:     000010 (2)
  isJ <= n(5) and n(4) and n(3) and n(2) and op(1) and n(0);
end architecture;