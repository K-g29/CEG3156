library ieee;
use ieee.std_logic_1164.all;

entity nbitRegister is
  generic (N : natural := 8);
  port (
    i_resetBar : in  std_logic;                        
    i_enable   : in  std_logic;                       
    i_clock    : in  std_logic;
    i_d        : in  std_logic_vector(N-1 downto 0);
    o_q        : out std_logic_vector(N-1 downto 0)
  );
end entity;

architecture structural of nbitRegister is
  component enARdFF_2 is
    port(
      i_resetBar : in  std_logic;
      i_d        : in  std_logic;
      i_enable   : in  std_logic;
      i_clock    : in  std_logic;
      o_q        : out std_logic;
      o_qBar     : out std_logic
    );
  end component;

  signal qbar_dummy : std_logic_vector(N-1 downto 0);
begin
  gen_ff: for i in 0 to N-1 generate
    ff: enARdFF_2
      port map (
        i_resetBar => i_resetBar,
        i_d        => i_d(i),
        i_enable   => i_enable,
        i_clock    => i_clock,
        o_q        => o_q(i),
        o_qBar     => qbar_dummy(i)
      );
  end generate;
end architecture;