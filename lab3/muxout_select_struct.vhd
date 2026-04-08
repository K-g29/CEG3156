library ieee;
use ieee.std_logic_1164.all;

-- MuxOut selector:
-- 000 PC
-- 001 ALUResult
-- 010 ReadData1
-- 011 ReadData2
-- 100 WriteData
-- other CtrlPack8
entity muxout_select_struct is
  port(
    ValueSelect : in  std_logic_vector(2 downto 0);
    PC          : in  std_logic_vector(7 downto 0);
    ALUResult   : in  std_logic_vector(7 downto 0);
    RD1         : in  std_logic_vector(7 downto 0);
    RD2         : in  std_logic_vector(7 downto 0);
    WD          : in  std_logic_vector(7 downto 0);
    CtrlPack8   : in  std_logic_vector(7 downto 0);
    MuxOut      : out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of muxout_select_struct is
  signal zeros8 : std_logic_vector(7 downto 0);

  -- decode select lines
  signal s0, s1, s2 : std_logic;
  signal ns0, ns1, ns2 : std_logic;

  signal sel000, sel001, sel010, sel011, sel100 : std_logic;
  signal selOther : std_logic;

  -- masked data buses
  signal mPC, mALU, mRD1, mRD2, mWD, mOther : std_logic_vector(7 downto 0);
begin
  zeros8 <= (others => '0');

  s0 <= ValueSelect(0);
  s1 <= ValueSelect(1);
  s2 <= ValueSelect(2);

  ns0 <= not s0;
  ns1 <= not s1;
  ns2 <= not s2;

  -- one-hot for the 5 defined cases
  sel000 <= ns2 and ns1 and ns0;
  sel001 <= ns2 and ns1 and s0;
  sel010 <= ns2 and s1  and ns0;
  sel011 <= ns2 and s1  and s0;
  sel100 <= s2  and ns1 and ns0;

  -- "other" = not(any of above)
  selOther <= not (sel000 or sel001 or sel010 or sel011 or sel100);

  -- mask each bus with its select bit (bitwise AND)
  gen_mask: for i in 0 to 7 generate
    mPC(i)    <= PC(i)        and sel000;
    mALU(i)   <= ALUResult(i) and sel001;
    mRD1(i)   <= RD1(i)       and sel010;
    mRD2(i)   <= RD2(i)       and sel011;
    mWD(i)    <= WD(i)        and sel100;
    mOther(i) <= CtrlPack8(i) and selOther;

    -- OR them together
    MuxOut(i) <= mPC(i) or mALU(i) or mRD1(i) or mRD2(i) or mWD(i) or mOther(i);
  end generate;

end architecture;