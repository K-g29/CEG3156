library ieee;
use ieee.std_logic_1164.all;

-- Signed comparator for two's-complement 7-bit numbers.
-- Structural approach: decide by sign bits first; if equal, compare lower 6 bits unsigned.
entity signed_exp_compare is
  port (
    a  : in  std_logic_vector(6 downto 0); -- signed two's complement
    b  : in  std_logic_vector(6 downto 0);
    lt : out std_logic;  -- a < b (signed)
    eq : out std_logic;  -- a = b
    gt : out std_logic   -- a > b (signed)
  );
end entity;

architecture structural of signed_exp_compare is
  component comparator is
    generic (N : natural := 8);
    port (
      a  : in  std_logic_vector(N-1 downto 0);
      b  : in  std_logic_vector(N-1 downto 0);
      lt : out std_logic;
      eq : out std_logic;
      gt : out std_logic
    );
  end component;

  signal sa, sb     : std_logic;                         -- sign bits
  signal a_lo, b_lo : std_logic_vector(5 downto 0);      -- lower 6 bits
  signal lt_lo, eq_lo, gt_lo : std_logic;
  signal sign_diff  : std_logic;
begin
  sa    <= a(6);
  sb    <= b(6);
  a_lo  <= a(5 downto 0);
  b_lo  <= b(5 downto 0);
  sign_diff <= sa xor sb;

  -- When signs equal, compare magnitudes of the lower 6 bits (unsigned)
  cmp_lo: comparator
    generic map (N => 6)
    port map (a=>a_lo, b=>b_lo, lt=>lt_lo, eq=>eq_lo, gt=>gt_lo);

  -- Signed decision:
  -- If signs differ: negative < positive
  -- If signs equal: use lower-bits comparator result
  lt <= (sign_diff and sa) or ((not sign_diff) and lt_lo);
  gt <= (sign_diff and (not sa)) or ((not sign_diff) and gt_lo);
  eq <= (not sign_diff) and eq_lo;
end architecture;