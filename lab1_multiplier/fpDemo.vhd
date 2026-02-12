LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY fpDemo IS
    PORT (
        GClock      : IN  STD_LOGIC;
        GReset      : IN  STD_LOGIC;
        SignOut     : OUT STD_LOGIC;
        ExponentOut : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        MantissaOut : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        Overflow    : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE s_fpDemo OF fpDemo IS
    -- Signals for the inputs
    SIGNAL int_SignA    : STD_LOGIC;
    SIGNAL int_ExpA     : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL int_ManA     : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL int_SignB    : STD_LOGIC;
    SIGNAL int_ExpB     : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL int_ManB     : STD_LOGIC_VECTOR(7 DOWNTO 0);

   

    -- Replace placeholder with the multiplier top-level component
    COMPONENT fp_mult_top
        PORT (
            i_resetBar : IN  STD_LOGIC;
            i_clock    : IN  STD_LOGIC;
            -- Operands
            signA      : IN  STD_LOGIC;
            mantA      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            expA       : IN  STD_LOGIC_VECTOR(6 DOWNTO 0);
            signB      : IN  STD_LOGIC;
            mantB      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            expB       : IN  STD_LOGIC_VECTOR(6 DOWNTO 0);
            -- Result
            o_sign     : OUT STD_LOGIC;
            o_mant     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            o_exp      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
            o_overflow : OUT STD_LOGIC;
            o_valid    : OUT STD_LOGIC
        );
    END COMPONENT;
BEGIN
   

    -- INSTRUCTIONS:
    -- Uncomment ONE of the test cases below to simulate. 
    -- Ensure all other test cases are commented out.

    ------------------------------------------------------------------
    -- TEST CASE 1: A + B = 3.75 (adder example shown for reference)
    -- A   =  +1.25 = 0 0111111 01000000
    -- B   =  +2.5  = 0 1000000 01000000
    -- Out =  +3.75 = 0 1000000 11100000
    ------------------------------------------------------------------
    -- int_SignA <= '0'; int_ExpA <= "0111111"; int_ManA <= "01000000";
    -- int_SignB <= '0'; int_ExpB <= "1000000"; int_ManB <= "01000000";

    ------------------------------------------------------------------
    -- TEST CASE 3: A * B = 3.125
    -- A   =  +1.25  = 0 0111111 01000000
    -- B   =  +2.5   = 0 1000000 01000000
    -- Out =  +3.125 = 0 1000000 10010000
    ------------------------------------------------------------------
    int_SignA <= '0'; int_ExpA <= "0111111"; int_ManA <= "01000000";
    int_SignB <= '0'; int_ExpB <= "1000000"; int_ManB <= "01000000";

    ------------------------------------------------------------------
    -- TEST CASE 4: A * (-B) = -3.125
    -- A   =  +1.25  = 0 0111111 01000000
    -- B   =  -2.5   = 1 1000000 01000000
    -- Out =  -3.125 = 1 1000000 10010000
    ------------------------------------------------------------------
    -- int_SignA <= '0'; int_ExpA <= "0111111"; int_ManA <= "01000000";
    -- int_SignB <= '1'; int_ExpB <= "1000000"; int_ManB <= "01000000";

    -- Instantiate fp_mult_top (multiplier)
    FP : fp_mult_top
    PORT MAP(
        i_resetBar => GReset,
        i_clock    => GClock,
        signA      => int_SignA,
        expA       => int_ExpA,
        mantA      => int_ManA,
        signB      => int_SignB,
        expB       => int_ExpB,
        mantB      => int_ManB,
        o_sign     => SignOut,
        o_exp      => ExponentOut,
        o_mant     => MantissaOut,
        o_overflow => Overflow,
        o_valid    => OPEN
    );
END s_fpDemo;