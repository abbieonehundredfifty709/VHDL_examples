-- Every VHDL design has two parts: ENTITY (interface) and ARCHITECTURE (behavior)
-- Think of ENTITY as a function signature, ARCHITECTURE as the function body
-- BUT: it's not a function — it's a hardware block that always exists.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity AND_GATE is
    port (
        A : in  STD_LOGIC;
        B : in  STD_LOGIC;
        Y : out STD_LOGIC;
        Z : out STD_LOGIC
    );
end AND_GATE;

architecture Behavioral of AND_GATE is
begin
    -- Hardware unit 1: AND gate
    Y <= A AND B;   -- This is a CONTINUOUS ASSIGNMENT, not a statement. It means that Y is always driven by the result of A AND B.
                    -- Y is ALWAYS equal to A AND B, in hardware it a an AND gate connecting the A and B wires.
                    -- There is no "execution order". In C "y = a && b;" means 
                    --   "evaluate a and b, then assign to y when the statement is reached in the code."
    -- Hardware unit 2: OR gate (on an FPGA or ASIC, this would be a separate physical gate from the AND gate, both present at the same time)
    Z <= A OR B;    -- Z is ALWAYS equal to A OR B, in hardware it a an OR gate connecting the A and B wires.
end Behavioral;
