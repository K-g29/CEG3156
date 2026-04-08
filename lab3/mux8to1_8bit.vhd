library ieee;
use ieee.std_logic_1164.all;

entity mux8to1_8bit is
  port(
    d0,d1,d2,d3,d4,d5,d6,d7 : in  std_logic_vector(7 downto 0);
    s                       : in  std_logic_vector(2 downto 0);
    y                       : out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of mux8to1_8bit is
  signal m0,m1,m2,m3 : std_logic_vector(7 downto 0);
  signal n0,n1       : std_logic_vector(7 downto 0);
begin
  -- level 1 (select s(0))
  u0: entity work.mux2 generic map(N=>8) port map(a=>d0, b=>d1, s=>s(0), y=>m0);
  u1: entity work.mux2 generic map(N=>8) port map(a=>d2, b=>d3, s=>s(0), y=>m1);
  u2: entity work.mux2 generic map(N=>8) port map(a=>d4, b=>d5, s=>s(0), y=>m2);
  u3: entity work.mux2 generic map(N=>8) port map(a=>d6, b=>d7, s=>s(0), y=>m3);

  -- level 2 (select s(1))
  u4: entity work.mux2 generic map(N=>8) port map(a=>m0, b=>m1, s=>s(1), y=>n0);
  u5: entity work.mux2 generic map(N=>8) port map(a=>m2, b=>m3, s=>s(1), y=>n1);

  -- level 3 (select s(2))
  u6: entity work.mux2 generic map(N=>8) port map(a=>n0, b=>n1, s=>s(2), y=>y);
end architecture;