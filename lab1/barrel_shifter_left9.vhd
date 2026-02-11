library ieee;
use ieee.std_logic_1164.all;

-- 9-bit left barrel shifter.
-- Shifts by 1, 2, 4, 8 based on shamt[0..3]. 
entity barrel_shifter_left9 is
  port (
    din    : in  std_logic_vector(8 downto 0);
    shamt  : in  std_logic_vector(3 downto 0); -- 0..8
    dout   : out std_logic_vector(8 downto 0)
  );
end entity;

architecture structural of barrel_shifter_left9 is
  component mux2 is
    generic (N : natural := 8);
    port (a, b: in std_logic_vector(N-1 downto 0);
          s   : in std_logic;
          y   : out std_logic_vector(N-1 downto 0));
  end component;

  signal stage0, stage1, stage2, stage3 : std_logic_vector(8 downto 0);
  signal s0, s1, s2, s3                 : std_logic;
  signal shift1, shift2, shift4, shift8 : std_logic_vector(8 downto 0);
begin
  s0 <= shamt(0);
  s1 <= shamt(1);
  s2 <= shamt(2);
  s3 <= shamt(3);

  -- Precompute shifted versions
  shift1 <= (din(7 downto 0) & '0');
  shift2 <= (stage0(6 downto 0) & "00");      -- depends on stage0
  shift4 <= (stage1(4 downto 0) & "0000");    -- depends on stage1
  shift8 <= (stage2(0) & "00000000");         -- depends on stage2

  -- Stage 0: shift by 1
  mux0: mux2
    generic map (N => 9)
    port map (a => din, b => shift1, s => s0, y => stage0);

  -- Stage 1: shift by 2
  mux1: mux2
    generic map (N => 9)
    port map (a => stage0, b => shift2, s => s1, y => stage1);

  -- Stage 2: shift by 4
  mux2i: mux2
    generic map (N => 9)
    port map (a => stage1, b => shift4, s => s2, y => stage2);

  -- Stage 3: shift by 8
  mux3: mux2
    generic map (N => 9)
    port map (a => stage2, b => shift8, s => s3, y => stage3);

  dout <= stage3;
end architecture;