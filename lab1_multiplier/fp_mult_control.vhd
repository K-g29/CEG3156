library ieee;
use ieee.std_logic_1164.all;

-- Structural one-hot controller: LOAD -> MULT -> NORM -> VALID.
entity fp_mult_control is
  port (
    i_resetBar : in  std_logic;
    i_clock    : in  std_logic;
    en_load    : out std_logic;
    en_mult    : out std_logic;
    en_norm    : out std_logic;
    o_valid    : out std_logic
  );
end entity;

architecture structural of fp_mult_control is
  component enARdFF_2 is
    port (
      i_resetBar : in  std_logic;
      i_d        : in  std_logic;
      i_enable   : in  std_logic;
      i_clock    : in  std_logic;
      o_q        : out STD_LOGIC;
      o_qBar     : out STD_LOGIC
    );
  end component;

  signal S1_q, S2_q, S3_q, S4_q : std_logic;
  signal S1_d, S2_d, S3_d, S4_d : std_logic;

  
  signal init_q : std_logic;
begin
 
  init_ff: enARdFF_2
    port map (
      i_resetBar => i_resetBar,
      i_d        => '1',
      i_enable   => '1',
      i_clock    => i_clock,
      o_q        => init_q,
      o_qBar     => open
    );

  
  S1_d <= S4_q or (not init_q);
  S2_d <= S1_q;
  S3_d <= S2_q;
  S4_d <= S3_q;

  -- State registers (one-hot)
  s1: enARdFF_2 port map(i_resetBar=>i_resetBar, i_d=>S1_d, i_enable=>'1', i_clock=>i_clock, o_q=>S1_q, o_qBar=>open);
  s2: enARdFF_2 port map(i_resetBar=>i_resetBar, i_d=>S2_d, i_enable=>'1', i_clock=>i_clock, o_q=>S2_q, o_qBar=>open);
  s3: enARdFF_2 port map(i_resetBar=>i_resetBar, i_d=>S3_d, i_enable=>'1', i_clock=>i_clock, o_q=>S3_q, o_qBar=>open);
  s4: enARdFF_2 port map(i_resetBar=>i_resetBar, i_d=>S4_d, i_enable=>'1', i_clock=>i_clock, o_q=>S4_q, o_qBar=>open);

  -- outputs
  en_load <= S1_q;
  en_mult <= S2_q;
  en_norm <= S3_q;
  o_valid <= S4_q;
end architecture;