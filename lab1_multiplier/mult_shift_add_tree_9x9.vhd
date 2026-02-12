library ieee;
use ieee.std_logic_1164.all;

-- Structural 9x9 shift-and-add multiplier (barrel shifters + AND + ripple adders).
entity mult_shift_add_tree_9x9 is
  port (
    a9     : in  std_logic_vector(8 downto 0);  -- '1' & mantA
    b9     : in  std_logic_vector(8 downto 0);  -- '1' & mantB
    prod18 : out std_logic_vector(17 downto 0)
  );
end entity;

architecture structural of mult_shift_add_tree_9x9 is
  component barrel_shifter_left18 is
    port ( din: in std_logic_vector(17 downto 0);
           shamt: in std_logic_vector(3 downto 0);
           dout: out std_logic_vector(17 downto 0) );
  end component;
  component ripple_adder18 is
    port ( a,b: in std_logic_vector(17 downto 0);
           cin: in std_logic;
           sum: out std_logic_vector(17 downto 0);
           cout: out std_logic );
  end component;

  signal a18_base : std_logic_vector(17 downto 0);
  signal sh0,sh1,sh2,sh3,sh4,sh5,sh6,sh7,sh8 : std_logic_vector(17 downto 0);
  signal bm0,bm1,bm2,bm3,bm4,bm5,bm6,bm7,bm8 : std_logic_vector(17 downto 0);
  signal pp0,pp1,pp2,pp3,pp4,pp5,pp6,pp7,pp8 : std_logic_vector(17 downto 0);
  signal s0,s1,s2,s3,s4,s5,s6,s7,s8           : std_logic_vector(17 downto 0);
begin
  
  a18_base <= "000000000" & a9;  -- 9 zeros concatenated with a9

  -- Barrel-shift a18_base by 0..8
  bs0: barrel_shifter_left18 port map(din=>a18_base, shamt=>"0000", dout=>sh0);
  bs1: barrel_shifter_left18 port map(din=>a18_base, shamt=>"0001", dout=>sh1);
  bs2: barrel_shifter_left18 port map(din=>a18_base, shamt=>"0010", dout=>sh2);
  bs3: barrel_shifter_left18 port map(din=>a18_base, shamt=>"0011", dout=>sh3);
  bs4: barrel_shifter_left18 port map(din=>a18_base, shamt=>"0100", dout=>sh4);
  bs5: barrel_shifter_left18 port map(din=>a18_base, shamt=>"0101", dout=>sh5);
  bs6: barrel_shifter_left18 port map(din=>a18_base, shamt=>"0110", dout=>sh6);
  bs7: barrel_shifter_left18 port map(din=>a18_base, shamt=>"0111", dout=>sh7);
  bs8: barrel_shifter_left18 port map(din=>a18_base, shamt=>"1000", dout=>sh8);

  -- Replicate multiplier bits to 18-bit masks and gate partial products (AND)
  bm0 <= (others => b9(0)); pp0 <= sh0 and bm0;
  bm1 <= (others => b9(1)); pp1 <= sh1 and bm1;
  bm2 <= (others => b9(2)); pp2 <= sh2 and bm2;
  bm3 <= (others => b9(3)); pp3 <= sh3 and bm3;
  bm4 <= (others => b9(4)); pp4 <= sh4 and bm4;
  bm5 <= (others => b9(5)); pp5 <= sh5 and bm5;
  bm6 <= (others => b9(6)); pp6 <= sh6 and bm6;
  bm7 <= (others => b9(7)); pp7 <= sh7 and bm7;
  bm8 <= (others => b9(8)); pp8 <= sh8 and bm8;

  -- Accumulate the 9 partial products with ripple adders (cout is unused => open)
  s0 <= (others => '0');
  a0: ripple_adder18 port map(a=>s0, b=>pp0, cin=>'0', sum=>s1, cout=>open);
  a1: ripple_adder18 port map(a=>s1, b=>pp1, cin=>'0', sum=>s2, cout=>open);
  a2: ripple_adder18 port map(a=>s2, b=>pp2, cin=>'0', sum=>s3, cout=>open);
  a3: ripple_adder18 port map(a=>s3, b=>pp3, cin=>'0', sum=>s4, cout=>open);
  a4: ripple_adder18 port map(a=>s4, b=>pp4, cin=>'0', sum=>s5, cout=>open);
  a5: ripple_adder18 port map(a=>s5, b=>pp5, cin=>'0', sum=>s6, cout=>open);
  a6: ripple_adder18 port map(a=>s6, b=>pp6, cin=>'0', sum=>s7, cout=>open);
  a7: ripple_adder18 port map(a=>s7, b=>pp7, cin=>'0', sum=>s8, cout=>open);
  a8: ripple_adder18 port map(a=>s8, b=>pp8, cin=>'0', sum=>prod18, cout=>open);
end architecture;