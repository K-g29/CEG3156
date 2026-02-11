library ieee;
use ieee.std_logic_1164.all;

-- Leading-one detector for 9-bit input.
-- Outputs:
--   shamt: number of left shifts (0..8) needed to bring the first '1' to bit 8.
--   zero : '1' when din is all zeros, else '0'.
entity leading_one_detector9 is
  port (
    din   : in  std_logic_vector(8 downto 0);
    shamt : out std_logic_vector(3 downto 0);
    zero  : out std_logic
  );
end entity;

architecture rtl of leading_one_detector9 is
begin
  -- Zero detect (avoid OTHERS; use explicit 9-bit constant)
  zero <= '1' when din = "000000000" else '0';

  -- Priority encode first '1' from MSB to LSB; map to left-shift amount.
  shamt <= "0000" when din(8) = '1' else
           "0001" when din(7) = '1' else
           "0010" when din(6) = '1' else
           "0011" when din(5) = '1' else
           "0100" when din(4) = '1' else
           "0101" when din(3) = '1' else
           "0110" when din(2) = '1' else
           "0111" when din(1) = '1' else
           "1000" when din(0) = '1' else
           "0000";  -- if din=0, shamt defaults to 0 (zero='1' flags the special case)
end architecture;