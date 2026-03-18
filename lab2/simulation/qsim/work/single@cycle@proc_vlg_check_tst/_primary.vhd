library verilog;
use verilog.vl_types.all;
entity singleCycleProc_vlg_check_tst is
    port(
        BranchOut       : in     vl_logic;
        InstructionOut  : in     vl_logic_vector(31 downto 0);
        MemWriteOut     : in     vl_logic;
        MuxOut          : in     vl_logic_vector(7 downto 0);
        RegWriteOut     : in     vl_logic;
        ZeroOut         : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end singleCycleProc_vlg_check_tst;
