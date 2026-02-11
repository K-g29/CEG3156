LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Structural N-bit comparator 
ENTITY comparator IS
  GENERIC (N : NATURAL := 8);
  PORT (
    a  : IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);
    b  : IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);
    lt : OUT STD_LOGIC;
    eq : OUT STD_LOGIC;
    gt : OUT STD_LOGIC
  );
END comparator;

ARCHITECTURE structural OF comparator IS
  COMPONENT oneBitComparator
    PORT(
      i_GTPrevious : IN  STD_LOGIC;
      i_LTPrevious : IN  STD_LOGIC;
      i_Ai         : IN  STD_LOGIC;
      i_Bi         : IN  STD_LOGIC;
      o_GT         : OUT STD_LOGIC;
      o_LT         : OUT STD_LOGIC
    );
  END COMPONENT;

  SIGNAL int_GT : STD_LOGIC_VECTOR(N-1 DOWNTO 0);
  SIGNAL int_LT : STD_LOGIC_VECTOR(N-1 DOWNTO 0);
  SIGNAL gnd    : STD_LOGIC;
BEGIN
  gnd <= '0';

  -- MSB stage: no previous decision
  msb: oneBitComparator
    PORT MAP (
      i_GTPrevious => gnd,
      i_LTPrevious => gnd,
      i_Ai         => a(N-1),
      i_Bi         => b(N-1),
      o_GT         => int_GT(N-1),
      o_LT         => int_LT(N-1)
    );

  -- Chain remaining stages down to LSB
  gen_chain: FOR i IN N-2 DOWNTO 0 GENERATE
    stage: oneBitComparator
      PORT MAP (
        i_GTPrevious => int_GT(i+1),
        i_LTPrevious => int_LT(i+1),
        i_Ai         => a(i),
        i_Bi         => b(i),
        o_GT         => int_GT(i),
        o_LT         => int_LT(i)
      );
  END GENERATE;

  -- Output drivers
  gt <= int_GT(0);
  lt <= int_LT(0);
  eq <= int_GT(0) NOR int_LT(0);
END structural;