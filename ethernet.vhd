--// This class describes a circuit which echos a raw Ethernet frame
--// and is designed to mimic the functionality of the address swap
--// module provided by the Xilinx Core Generator Tri-Mode Ethernet MAX wrapper.

--// DST is this hardware module
--// SRC is the other end (e.g. test bench or the Ethernet MAC interface)
--// RX is the incoming data
--// TX is the outgoing data

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ethernet_echo is
    
    port (
        clk          : in  std_logic;
        resetn_clk   : in  std_logic;
        rx_data      : in  std_logic_vector(7 downto 0);
        rx_sof_n     : in  std_logic;
        rx_eof_n     : in  std_logic;
        rx_src_rdy_n : in  std_logic;
        tx_data      : out std_logic_vector(7 downto 0);
        tx_sof_n     : out std_logic;
        tx_eof_n     : out std_logic;
        tx_src_rdy_n : out std_logic;
        tx_dst_rdy_n : in  std_logic);

end entity;
architecture inferred_sm_simple of ethernet_echo is
begin  -- architecture inferred_sm
    echoer : process is
        type t_buffer is array (natural range <>) of std_logic_vector(7 downto 0);
        variable buff        : t_buffer(0 to 1023);  -- buffer is a reserved word in VHDL
        variable start       : boolean;
        variable i, j        : integer;
        variable doneReading : boolean;
    begin  -- process echoer
        main : loop                                          -- Process packets indefinately
            wait until rising_edge(clk); exit main when resetn_clk = '0';
            tx_sof_n     <= '1';                                 -- We are not at the start of a frame
            tx_src_rdy_n <= '1';
            tx_eof_n     <= '1';                                 --  We are not at the end of a frame
            -- Wait for SOF and SRC_RDY
            while not start loop
                wait until rising_edge(clk); exit main when resetn_clk = '0';
                start := rx_sof_n = '0' and rx_src_rdy_n = '0';  -- Check for start of frame
            end loop;
            -- Read in the entire frame
            i           := 0;
            doneReading := false;

            -- Read the remaining bytes
            while not doneReading loop
                if rx_src_rdy_n = '0' then
                    buff(i) := rx_data;
                    i       := i+1;
                end if; 
                doneReading := rx_eof_n = '0';
                wait until rising_edge(clk); exit main when resetn_clk = '0';
            end loop;

            tx_src_rdy_n <= '0';   -- We are not at the start of a frame
            -- Now send an Ethernet packet back to where it came from
            -- Swap source and destination MAC addresses
            tx_sof_n     <= '1';
            for j in 6 to 11 loop  -- Process a 6 byte MAC address
                tx_data  <= buff(j);
                tx_sof_n <= '0';
                if j /= 6 then
                    tx_sof_n <= '1';
                end if;
                wait until rising_edge(clk); exit main when resetn_clk = '0';
            end loop;
            for j in 0 to 5 loop   -- Process a 6 byte MAC address
                tx_data <= buff(j);
                wait until rising_edge(clk); exit main when resetn_clk = '0';
            end loop;

                                    -- Transmit the remaining bytes
            j := 12;
            while j < i loop
                tx_data <= buff(j);
                if j = i - 1 then
                    tx_eof_n <= '0';
                end if;
                j := j + 1;
                wait until rising_edge(clk); exit main when resetn_clk = '0';
            end loop;
            tx_src_rdy_n <= '1';
            tx_eof_n     <= '1';
            start        := false;  -- No longer at start of frame
            wait until rising_edge(clk); exit main when resetn_clk = '0';
          -- End of frame, ready for next frame
        end loop;
    end process echoer;
    

end architecture inferred_sm_simple;
