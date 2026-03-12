library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SIG_VS_VAR is
    port (
        TRIGGER : in  STD_LOGIC;   -- external input to make the entity synthesizable
        RESULT  : out STD_LOGIC    -- observe final signal value from outside
    );
end SIG_VS_VAR;

architecture Behavioral of SIG_VS_VAR is
    signal   S : STD_LOGIC := '0';  -- Signal: updated AFTER the process ends (delta delay)
begin

    process(TRIGGER)
        variable V : STD_LOGIC := '0';
    begin
        -- VARIABLE: updated immediately, next line sees the new value
        V := '1';
        V := not V;         -- V is now '0'

        -- SIGNAL: scheduled, S still reads its OLD value throughout this process
        S <= '1';
        S <= not S;         -- last assignment wins: S will become NOT(0) after process
    end process;

    RESULT <= S;            -- Result will be '1' after the process, because S's last assignment is NOT(0) = '1'.
end Behavioral;
