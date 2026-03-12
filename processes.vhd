library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PROCESS_EXAMPLE is
    port (
        A : in  STD_LOGIC;
        B : in  STD_LOGIC;
        C : in  STD_LOGIC;
        Y : out STD_LOGIC;   -- driven by Process 1
        Z : out STD_LOGIC;   -- driven by Process 2
        W : out STD_LOGIC    -- driven by concurrent assignment
    );
end PROCESS_EXAMPLE;

architecture Behavioral of PROCESS_EXAMPLE is
begin

    -- Concurrent assignment: always active, runs in parallel with both processes.
    -- These are is just 2 wires connected to an AND gate, they have no "execution order" with respect to the processes.
    W <= A AND B;


    -- Process 1: wakes up when A or B changes.
    process(A, B) -- statements in a process are executed sequentially
    begin
        if A = '1' and B = '1' then
            Y <= '1';
        else
            Y <= '0';
        end if;

        if C = '1' then -- this does not mean that C cannot be used in this process,
            Y <= '0';   -- it just means that changes to C do not trigger this process to run.
        end if;
    end process;


    -- Process 2: wakes up when B or C changes — NOT when A changes.
    -- Even if A changes and triggers Process 1, Process 2 stays asleep.
    -- This is the key point: each process reacts to its OWN sensitivity list.
    process(B, C)
    begin
        if C = '1' then
            Z <= B;
        else
            Z <= '0';
        end if;
    end process;


    -- All three blocks — W, Process 1, Process 2 — run concurrently.
    -- Inside each process, the if/else runs top-to-bottom (sequential).
    -- But the three blocks themselves have no ordering between them.

end Behavioral;
