using KiwiSystem;

class LocalLinkLoopBackTest
{
    static byte[] buffer = new byte[1024];

    class EthernetEcho
    {
        [Kiwi.Hardware()] // This class should be implemented in hardware

        // This class describes a circuit which echos a raw Ethernet frame
        // and is designed to mimic the functionality of the address swap
        // module provided by the Xilinx Core Generator Tri-Mode Ethernet MAX wrapper.

        // DST is this hardware module
        // SRC is the other end (e.g. test bench or the Ethernet MAC interface)
        // RX is the incoming data
        // TX is the outgoing data


        // These are the ports of the circuit (and will appear as ports in the generated Verilog)
        [Kiwi.InputWordPort("rx_data")]
        static byte rx_data;        // Write data to be sent to device
        [Kiwi.InputBitPort("rx_sof_n")]
        static bool rx_sof_n;       // Start of frame indicator
        [Kiwi.InputBitPort("rx_eof_n")]
        static bool rx_eof_n;       // End of frame indicator
        [Kiwi.InputBitPort("rx_src_rdy_n")]
        static bool rx_src_rdy_n;   // Source ready indicator
        //[Kiwi.OutputBitPort("rx_dst_rdy_n")]
        //static bool rx_dst_rdy_n;   // Destination ready indicator

        [Kiwi.OutputWordPort("tx_data")]
        static byte tx_data;        // Write data to be sent to device
        [Kiwi.OutputBitPort("tx_sof_n")]
        static bool tx_sof_n;       // Start of frame indicator
        [Kiwi.OutputBitPort("tx_eof_n")]
        static bool tx_eof_n;       // End of frame indicator
        [Kiwi.OutputBitPort("tx_src_rdy_n")]
        static bool tx_src_rdy_n;   // Source ready indicator
        [Kiwi.InputBitPort("tx_dst_rdy_n")]
        static bool tx_dst_rdy_n;    // Destination ready indicator

        // Thus buffer stores an incoming Ethernet frame
        static byte[] buffer = new byte[1024];

        // This method describes the operations required to echo the Ethernet frame
        static public void echo()
        {

            tx_sof_n = !false; // We are not at the start of a frame
            tx_src_rdy_n = !false;
            tx_eof_n = !false; // We are not at the end of a frame
            bool start = !rx_sof_n && !rx_src_rdy_n; // The start condition
            int i, j;
            bool doneReading;

            while (true) // Process packets indefinately
            {
                // Wait for SOF and SRC_RDY
                while (!start)
                {
                    Kiwi.Pause(); // Wait for a clock tick
                    start = !rx_sof_n && !rx_src_rdy_n; // Check for start of frame
                }

                // Read in the entire frame
                i = 0;
                doneReading = false;

                // Read the remaining bytes
                while (!doneReading)
                {
                    if (!rx_src_rdy_n)
                    {
                        buffer[i] = rx_data;
                        i++;
                    }
                    doneReading = !rx_eof_n;
                    Kiwi.Pause();
                }

                tx_src_rdy_n = !true; // We are not at the start of a frame

                // Now send an Ethernet packet back to where it came from

                // Swap source and destination MAC addresses
                j = 0;
                tx_sof_n = !false;
                for (j = 6; j < 12; j++) // Process a 6 byte MAC address
                {

                    tx_data = buffer[j];
                    tx_sof_n = j != 6;
                    Kiwi.Pause();
                }
                for (j = 0; j < 6; j++) // Process a 6 byte MAC address
                {
                    tx_data = buffer[j];
                    Kiwi.Pause();
                }

                // Transmit the remaining bytes
                j = 12;
                while (j < i)
                {
                    tx_data = buffer[j];
                    if (j == i - 1)
                        tx_eof_n = !true;

                    j++;
                    Kiwi.Pause();
                }
                tx_src_rdy_n = !false; 
                tx_eof_n = !false;
                start = false; // No longer at start of frame
                Kiwi.Pause();
                // End of frame, ready for next frame
            }
        }
    }
