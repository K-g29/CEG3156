library ieee;
use ieee.std_logic_1164.all;

entity regfile8x8 is
  port(
    clk      : in  std_logic;
    resetBar  : in  std_logic;

    ra1      : in  std_logic_vector(2 downto 0);
    ra2      : in  std_logic_vector(2 downto 0);
    wa       : in  std_logic_vector(2 downto 0);
    wd       : in  std_logic_vector(7 downto 0);
    we       : in  std_logic;

    rd1      : out std_logic_vector(7 downto 0);
    rd2      : out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of regfile8x8 is
  signal we_dec : std_logic_vector(7 downto 0);

  -- storage: regs(r)(b)
  type reg_array is array (0 to 7) of std_logic_vector(7 downto 0);
  signal regs : reg_array;

  signal qb_dummy : std_logic; -- for o_qBar (unused)
begin
  -- decode write enable
  dec: entity work.decoder3to8
    port map(a => wa, en => we, y => we_dec);

  -- registers implemented with DFFs
  gen_r: for r in 0 to 7 generate
    gen_b: for b in 0 to 7 generate
      ff: entity work.enARdFF_2
        port map(
          i_resetBar => resetBar,
          i_d        => wd(b),
          i_enable   => we_dec(r),
          i_clock    => clk,
          o_q        => regs(r)(b),
          o_qBar     => qb_dummy
        );
    end generate;
  end generate;

  -- read port 1 mux
  rm1: entity work.mux8to1_8bit
    port map(
      d0 => regs(0), d1 => regs(1), d2 => regs(2), d3 => regs(3),
      d4 => regs(4), d5 => regs(5), d6 => regs(6), d7 => regs(7),
      s  => ra1,
      y  => rd1
    );

  -- read port 2 mux
  rm2: entity work.mux8to1_8bit
    port map(
      d0 => regs(0), d1 => regs(1), d2 => regs(2), d3 => regs(3),
      d4 => regs(4), d5 => regs(5), d6 => regs(6), d7 => regs(7),
      s  => ra2,
      y  => rd2
    );
end architecture;