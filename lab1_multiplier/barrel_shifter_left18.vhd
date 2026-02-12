library ieee;
use ieee.std_logic_1164.all;

entity barrel_shifter_left18 is
  port (
    din   : in  std_logic_vector(17 downto 0);
    shamt : in  std_logic_vector(3 downto 0); -- 8,4,2,1
    dout  : out std_logic_vector(17 downto 0)
  );
end entity;

architecture rtl of barrel_shifter_left18 is
  signal s0,s1,s2,s3 : std_logic_vector(17 downto 0);
begin
  s0 <= (din(16 downto 0) & '0')        when shamt(0)='1' else din;
  s1 <= (s0(15 downto 0) & "00")        when shamt(1)='1' else s0;
  s2 <= (s1(13 downto 0) & "0000")      when shamt(2)='1' else s1;
  s3 <= (s2(9  downto 0) & "00000000")  when shamt(3)='1' else s2;
  dout <= s3;
end architecture;