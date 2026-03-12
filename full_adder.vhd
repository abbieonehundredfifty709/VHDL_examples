library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- The entity defines the "pins" of the full adder HW component:
-- A, B = the two bits to add; Cin = carry in; Sum = result bit; Cout = carry out
entity FULL_ADDER is
    port (
        A    : in  STD_LOGIC;
        B    : in  STD_LOGIC;
        Cin  : in  STD_LOGIC;
        Sum  : out STD_LOGIC;
        Cout : out STD_LOGIC
    );
end FULL_ADDER;

-- The architecture wires together sub-components to implement the full adder.
-- A full adder truth: Sum = A XOR B XOR Cin,  Cout = (A AND B) OR ((A XOR B) AND Cin)
architecture Structural of FULL_ADDER is
    signal s1, s2, s3 : STD_LOGIC;     -- Internal "wires" between gates
begin

    -- s1 = A XOR B
    XOR1 : entity work.XOR_GATE
        port map (A => A, B => B, Y => s1);

    -- Sum = s1 XOR Cin  =  A XOR B XOR Cin
    XOR2 : entity work.XOR_GATE
        port map (A => s1, B => Cin, Y => Sum);

    -- s2 = A AND B
    AND1 : entity work.AND_GATE
        port map (A => A, B => B, Y => s2);

    -- s3 = s1 AND Cin  =  (A XOR B) AND Cin
    AND2 : entity work.AND_GATE
        port map (A => s1, B => Cin, Y => s3);

    -- Cout = s2 OR s3  =  (A AND B) OR ((A XOR B) AND Cin)
    OR1  : entity work.OR_GATE
        port map (A => s2, B => s3, Y => Cout);

end Structural;