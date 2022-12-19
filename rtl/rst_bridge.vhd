--------------------------------------------------------------------------------
--! Project  : c-rus.app.jeopardy-buzz
--! Engineer : Chase Ruskin
--! Created  : 2022-12-18
--! Entity   : rst_bridge
--! Details  :
--!     A reset bridge allows a design to apply a reset asynchronously and 
--!     remove the reset synchronously.
--!
--!     The reset de-asserted is delayed until safely after clock edge using
--!     2-stage synchronous flip-flops.
--!
--! Reference:
--!     http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_Resets.pdf
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity rst_bridge is 
    port (
        clk     : in std_logic;
        rst_in  : in std_logic;
        rst_out : out std_logic
    );
end entity rst_bridge;


architecture rtl of rst_bridge is

    -- regsiters to store the reset value
    signal rst_r0 : std_logic := '0';
    signal rst_r1 : std_logic := '0';

begin
    -- create 2-stage synchronous flip-flops
    D_FF: process(clk, rst_in)
    begin
        -- preset logic for FFs (asynchronously apply reset)
        if rst_in = '1' then
            rst_r0 <= '1';
            rst_r1 <= '1';
        -- synchronously remove reset
        elsif rising_edge(clk) then
            rst_r0 <= '0';
            rst_r1 <= rst_r0;
        end if;
    end process;

    rst_out <= rst_r1;
    
end architecture rtl;