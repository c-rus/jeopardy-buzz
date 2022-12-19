--------------------------------------------------------------------------------
--! Project   : c-rus.app.jeopardy-buzz
--! Engineer  : Chase Ruskin
--! Created   : 2022-12-18
--! Testbench : rst_bridge_tb
--! Details   :
--!     Tests the expected behavior for a reset bridge module.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library work;
-- @note: uncomment the next 3 lines to use the toolbox package.
library util;
use util.toolbox_pkg.all;
use std.textio.all;

entity rst_bridge_tb is 
end entity rst_bridge_tb;


architecture sim of rst_bridge_tb is
    --! unit-under-test (UUT) interface wires
    signal rst_out : std_logic;

    --! internal testbench signals
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    -- the simulation will stop when `halt` becomes '1'
    signal halt : std_logic := '0';

    constant PERIOD : time := 10 ns;
begin
    --! UUT instantiation
    UUT : entity work.rst_bridge
    port map (
        clk     => clk,
        rst_in  => rst,
        rst_out => rst_out
    );

    --! generate clock with 50% duty cycle
    clk <= not clk after PERIOD/2 when halt = '0';

    --! test the circuit's behavior
    bench: process
    begin
        wait for PERIOD*2;
        -- verify the reset is initially removed
        assert rst_out = '0' report error_sl("rst_out", rst_out, '0') severity failure;
        wait for 1 ns;
        -- apply the reset asynchronously
        rst <= '1';
        -- 1. check for asynchronous behavior
        wait for 1 ns;
        assert rst_out = '1' report error_sl("rst_out", rst_out, '1') severity failure;
        rst <= '0';
        -- 2. check for reset being removed synchronously
        wait until rising_edge(clk);
        assert rst_out = '1' report error_sl("rst_out", rst_out, '1') severity failure;
        wait until rising_edge(clk);
        assert rst_out = '1' report error_sl("rst_out", rst_out, '1') severity failure;
        -- reset is synchronously de-asserted on the next clock cycle
        wait until rising_edge(clk);
        assert rst_out = '0' report error_sl("rst_out", rst_out, '0') severity failure;
        -- check the reset removal is continued to be upheld
        wait until rising_edge(clk);
        assert rst_out = '0' report error_sl("rst_out", rst_out, '0') severity failure;

        wait for PERIOD*4;

        assert rst_out = '0' report error_sl("rst_out", rst_out, '0') severity failure;
        wait for 1 ns;
        -- apply the reset asynchronously
        rst <= '1';
        -- 1. check for asynchronous behavior
        wait for 1 ns;
        assert rst_out = '1' report error_sl("rst_out", rst_out, '1') severity failure;
        rst <= '0';
        -- wait for synchronous removal
        wait until rising_edge(clk);
        assert rst_out = '1' report error_sl("rst_out", rst_out, '1') severity failure;
        -- apply reset again before removal
        wait for 1 ns;
        rst <= '1';
        wait for 1 ns;
        rst <= '0';
        -- 2. check for reset being removed synchronously
        wait until rising_edge(clk);
        assert rst_out = '1' report error_sl("rst_out", rst_out, '1') severity failure;
        wait until rising_edge(clk);
        assert rst_out = '1' report error_sl("rst_out", rst_out, '1') severity failure;
        -- reset is synchronously de-asserted on the next clock cycle
        wait until rising_edge(clk);
        assert rst_out = '0' report error_sl("rst_out", rst_out, '0') severity failure;
        -- check the reset removal is continued to be upheld
        wait until rising_edge(clk);
        assert rst_out = '0' report error_sl("rst_out", rst_out, '0') severity failure;

        -- stop the simulation
        halt <= '1';
        report "Simulation complete.";
        wait;
    end process;

end architecture sim;