library verilog;
use verilog.vl_types.all;
entity singleCycleProc is
    port(
        GClock          : in     vl_logic;
        GResetBar       : in     vl_logic;
        ValueSelect     : in     vl_logic_vector(2 downto 0);
        MuxOut          : out    vl_logic_vector(7 downto 0);
        InstructionOut  : out    vl_logic_vector(31 downto 0);
        BranchOut       : out    vl_logic;
        ZeroOut         : out    vl_logic;
        MemWriteOut     : out    vl_logic;
        RegWriteOut     : out    vl_logic
    );
end singleCycleProc;
