-- In C: variables hold state naturally.
-- In VHDL: you need CLOCKED PROCESSES to create memory (flip-flops).

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity D_FLIPFLOP is
    port (
        CLK : in  STD_LOGIC;
        D   : in  STD_LOGIC;
        Q   : out STD_LOGIC
    );
end D_FLIPFLOP;

architecture Behavioral of D_FLIPFLOP is
begin
    process(CLK)
    begin
        if rising_edge(CLK) then    -- Only act on the clock edge
            Q <= D;                 -- This synthesizes to an actual flip-flop
        end if;
    end process;

    -- KEY INSIGHT: Without rising_edge(), you get combinational logic (no memory).
    -- With rising_edge(), you get a register (has memory).
end Behavioral;
