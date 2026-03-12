library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM is
    port (
        CLK       : in  STD_LOGIC;
        RESET     : in  STD_LOGIC;
        -- Inputs
        vld       : in  STD_LOGIC;
        bit_end   : in  STD_LOGIC;
        word_end  : in  STD_LOGIC;
        -- Moore outputs (depend only on current state, not inputs)
        rdy        : out STD_LOGIC;
        start      : out STD_LOGIC;
        stop       : out STD_LOGIC;
        count      : out STD_LOGIC;
        data_count : out STD_LOGIC
    );
end FSM;

architecture Behavioral of FSM is

    -- Define the states as an enumeration type.
    -- This is idiomatic VHDL: never use magic numbers like "00","01" for states.
    type state_type is (IDLE, START, DATA, STOP);
    signal current_state : state_type := IDLE;
    signal next_state    : state_type;

begin

    -- =========================================================================
    -- Process 1: State register (clocked)
    -- Only job: advance to next_state on each rising clock edge.
    -- This process creates the flip-flops that store the current state.
    -- =========================================================================
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                current_state <= IDLE;
            else
                current_state <= next_state;
            end if;
        end if;
    end process;


    -- =========================================================================
    -- Process 2: Next-state logic (combinational)
    -- Computes next_state based on current_state and inputs.
    -- Must be combinational: no rising_edge, all inputs in sensitivity list.
    -- =========================================================================
    process(current_state, vld, bit_end, word_end)
    begin
        -- Default: stay in current state (covers all "else" arrows in diagram), uses the last assignment rule (see signals_vs_variables.vhd)
        next_state <= current_state;

        case current_state is

            when IDLE =>
                if vld = '1' then
                    next_state <= START;
                end if;
                -- else: stays IDLE (the "else" self-loop in diagram)

            when START =>
                if bit_end = '1' then
                    next_state <= DATA;
                end if;
                -- else: stays START

            when DATA =>
                if bit_end = '1' and word_end = '1' then
                    next_state <= STOP;
                end if;
                -- else: stays DATA

            when STOP =>
                if bit_end = '1' then
                    next_state <= IDLE;
                end if;
                -- else: stays STOP

        end case;
    end process;


    -- =========================================================================
    -- Process 3: Moore output logic (combinational)
    -- Outputs depend ONLY on current_state — that is the definition of Moore.
    -- Output values are read from the diagram: rdy,start,stop,count,data_count
    --   IDLE  = 1,0,1,0,0
    --   START = 0,1,0,1,0
    --   DATA  = 0,0,0,1,1
    --   STOP  = 0,0,1,1,0
    -- =========================================================================
    process(current_state)
    begin
        case current_state is
            when IDLE  => rdy<='1'; start<='0'; stop<='1'; count<='0'; data_count<='0';
            when START => rdy<='0'; start<='1'; stop<='0'; count<='1'; data_count<='0';
            when DATA  => rdy<='0'; start<='0'; stop<='0'; count<='1'; data_count<='1';
            when STOP  => rdy<='0'; start<='0'; stop<='1'; count<='1'; data_count<='0';
        end case;
    end process;

end Behavioral;
