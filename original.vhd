architecture original of ethernet_echo is

begin  -- architecture original

    control_fsm_sync_p : process(rx_ll_clock)
   begin
      if rising_edge(rx_ll_clock) then
         if rx_ll_reset = '1' then
            control_fsm_state <= wait_sf;
         else
           if rx_enable = '1' then
             case control_fsm_state is
                when wait_sf =>
                   if sof_sr_content(4) = '1' then
                      control_fsm_state <= bypass_sa1;
                   else
                      control_fsm_state <= wait_sf;
                   end if;

                when bypass_sa1 =>
                   if not(sof_sr_content(4) = '0' and eof_sr_content(4) = '1') then
                      control_fsm_state <= bypass_sa2;
                   else
                      control_fsm_state <= wait_sf;
                   end if;

                when bypass_sa2 =>
                   if not(sof_sr_content(4) = '0' and eof_sr_content(4) = '1') then
                      control_fsm_state <= bypass_sa3;
                   else
                      control_fsm_state <= wait_sf;
                   end if;

                when bypass_sa3 =>
                   if not(sof_sr_content(4) = '0' and eof_sr_content(4) = '1') then
                      control_fsm_state <= bypass_sa4;
                   else
                      control_fsm_state <= wait_sf;
                   end if;

                when bypass_sa4 =>
                   if not(sof_sr_content(4) = '0' and eof_sr_content(4) = '1') then
                      control_fsm_state <= bypass_sa5;
                   else
                      control_fsm_state <= wait_sf;
                   end if;

                when bypass_sa5 =>
                   if not(sof_sr_content(4) = '0' and eof_sr_content(4) = '1') then
                      control_fsm_state <= bypass_sa6;
                   else
                      control_fsm_state <= wait_sf;
                   end if;

                when bypass_sa6 =>
                   if not(sof_sr_content(4) = '0' and eof_sr_content(4) = '1') then
                      control_fsm_state <= pass_rof;
                   else
                      control_fsm_state <= wait_sf;
                   end if;

                when pass_rof =>
                   if not(sof_sr_content(4) = '0' and eof_sr_content(4) = '1') then
                      control_fsm_state <= pass_rof;
                   else
                      control_fsm_state <= wait_sf;
                   end if;

                when others =>
                   control_fsm_state <= wait_sf;

                end case;
             end if;
           end if;
      end if;
   end process;  -- control_fsm_sync_p

   ----------------------------------------------------------------------------
   --Process control_fsm_comb_p
   --Determines control signals from control_fsm state
   ----------------------------------------------------------------------------
   control_fsm_comb_p : process(control_fsm_state)
   begin
      case control_fsm_state is
         when wait_sf    =>
            sel_delay_path <= '0';  -- output data from data shift register
            enable_data_sr <= '1';  -- enable data to be loaded into shift register

         when bypass_sa1 =>
            sel_delay_path <= '1';  -- output data directly from input
            enable_data_sr <= '0';  -- hold current data in shift register

         when bypass_sa2 =>
            sel_delay_path <= '1';  -- output data directly from input
            enable_data_sr <= '0';  -- hold current data in shift register

         when bypass_sa3 =>
            sel_delay_path <= '1';  -- output data directly from input
            enable_data_sr <= '0';  -- hold current data in shift register

         when bypass_sa4 =>
            sel_delay_path <= '1';  -- output data directly from input
            enable_data_sr <= '0';  -- hold current data in shift register

         when bypass_sa5 =>
            sel_delay_path <= '1';  -- output data directly from input
            enable_data_sr <= '0';  -- hold current data in shift register

         when bypass_sa6 =>
            sel_delay_path <= '1';  -- output data directly from input
            enable_data_sr <= '0';  -- hold current data in shift register

         when pass_rof   =>
            sel_delay_path <= '0';  -- output data from data shift register
            enable_data_sr <= '1';  -- enable data to be loaded into shift register

         when others     =>
            sel_delay_path <= '0';
            enable_data_sr <= '1';

      end case;
   end process;  -- control_fsm_comb_p

end architecture original;
