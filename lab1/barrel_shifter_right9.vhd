library ieee;
use ieee.std_logic_1164.all;

-- Strictly structural 9-bit right barrel shifter with sticky.
-- Shifts by 1, 2, or 4 based on shamt[0..2]. Sticky ORs all dropped bits.
-- Max effective shift is 7 (1+2+4); if you need 8, add a fourth stage.
entity barrel_shifter_right9 is
  port (
    din     : in  std_logic_vector(8 downto 0);
    shamt   : in  std_logic_vector(2 downto 0); -- 0..7
    dout    : out std_logic_vector(8 downto 0);
    sticky  : out std_logic
  );
end entity;

architecture structural of barrel_shifter_right9 is
  component mux2 is
    generic (N : natural := 8);
    port (
      a, b : in  std_logic_vector(N-1 downto 0);
      s    : in  std_logic;
      y    : out std_logic_vector(N-1 downto 0)
    );
  end component;

  signal stage0, stage1, stage2 : std_logic_vector(8 downto 0);
  signal s0, s1, s2             : std_logic;
  signal st0, st1, st2          : std_logic;
  signal shift1, shift2, shift4 : std_logic_vector(8 downto 0);
begin
  s0 <= shamt(0);
  s1 <= shamt(1);
  s2 <= shamt(2);

  -- Precompute shifted versions
  shift1 <= ('0' & din(8 downto 1));
  shift2 <= ("00" & stage0(8 downto 2));   -- depends on stage0
  shift4 <= ("0000" & stage1(8 downto 4)); -- depends on stage1

  -- Stage 0: shift by 1
  mux0: mux2
    generic map (N => 9)
    port map (a => din, b => shift1, s => s0, y => stage0);
  st0 <= din(0) and s0;

  -- Stage 1: shift by 2
  mux1: mux2
    generic map (N => 9)
    port map (a => stage0, b => shift2, s => s1, y => stage1);
  st1 <= st0 or (s1 and (stage0(1) or stage0(0)));

  -- Stage 2: shift by 4
  mux2i: mux2
    generic map (N => 9)
    port map (a => stage1, b => shift4, s => s2, y => stage2);
  st2 <= st1 or (s2 and (stage1(3) or stage1(2) or stage1(1) or stage1(0)));

  dout   <= stage2;
  sticky <= st2;
end architecture;