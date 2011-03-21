-------------------------------------------------------------------------------
--
-- TRW Ltd owns the copyright in this source file and all rights are
-- reserved. It must not be used for any purpose other than that for which it
-- is supplied and must not be copied in whole or in part, or disclosed to
-- others without prior written consent of TRW Ltd.
-- Any copy of this source file made by any method must also contain a copy
-- of this legend.
-- -------------------------------------------------------------------------------
-- Copyright (c) 2011 TRW Limited

--
--  $URL::                                                                    $
-- This Revision:
--         $Revision::                                                        $
--   $LastModifiedBy::                                                        $
--             $Date::                                                        $
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------------------------------------------------------------------------

entity tb_ethernet_echo is

end entity tb_ethernet_echo;

----------------------------------------------------------------------------------------------------------------------------------

architecture test of tb_ethernet_echo is

    -- component ports
    signal clk          : std_logic;
    signal resetn_clk   : std_logic;
    signal rx_data      : std_logic_vector(7 downto 0);
    signal rx_sof_n     : std_logic;
    signal rx_eof_n     : std_logic;
    signal rx_src_rdy_n : std_logic;
    signal tx_data      : std_logic_vector(7 downto 0);
    signal tx_sof_n     : std_logic;
    signal tx_eof_n     : std_logic;
    signal tx_src_rdy_n : std_logic;
    signal tx_dst_rdy_n : std_logic;

    -- clock
    signal Clk : std_logic := '1';
    -- finished?
    signal finished : std_logic;

begin  -- architecture test

    -- component instantiation
    DUT: entity work.ethernet_echo
        port map (
            clk          => clk,
            resetn_clk   => resetn_clk,
            rx_data      => rx_data,
            rx_sof_n     => rx_sof_n,
            rx_eof_n     => rx_eof_n,
            rx_src_rdy_n => rx_src_rdy_n,
            tx_data      => tx_data,
            tx_sof_n     => tx_sof_n,
            tx_eof_n     => tx_eof_n,
            tx_src_rdy_n => tx_src_rdy_n,
            tx_dst_rdy_n => tx_dst_rdy_n);

    -- clock generation
    Clk <= not Clk after 10 ns when finished /= '1' else '0';

    -- waveform generation
    WaveGen_Proc: process
    begin
        finished <= '0';
        -- insert signal assignments here
        finished <= '1';
        report (time'image(now) & " Finished");
        wait;
    end process WaveGen_Proc;

    

end architecture test;

----------------------------------------------------------------------------------------------------------------------------------

configuration tb_ethernet_echo_test_cfg of tb_ethernet_echo is
    for test
    end for;
end tb_ethernet_echo_test_cfg;

----------------------------------------------------------------------------------------------------------------------------------
