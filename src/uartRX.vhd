 --Abdullah Furkan Kaya--
--21947396--
--ELE432 PRE#3--
--UART RECEIVER--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity uartRX is
  generic(
    clk_freq: integer := 50_000_000;	  		
    boudrate: integer := 9600  --user defined
  );
  port(
    clk      : in std_logic;
    Rx_i     : in std_logic;
    reset_i  : in std_logic;
    dataout  : out std_logic_vector (7 downto 0);
    Rx_done  : out std_logic
  );
end uartRX;

architecture Behavioral of uartRX is

  constant bittimer_limit   : integer := (clk_freq/boudrate);
  constant bittimer_limit_s : integer := bittimer_limit/2;
  
  type states is (IDLE,START,DATA_RECEIVE,STOP);
  signal rx_state: states;
  
  signal Rx_ii            : std_logic;
  signal Rx_iii           : std_logic;
  signal Rx_iiii          : std_logic;
  signal bittimer 	  : integer range 0 to bittimer_limit;
  signal bitcounter 	  : integer range 0 to 7;
  signal shift_register   : std_logic_vector (7 downto 0);

begin
	
  MAIN: process (clk,reset_i) 
  begin
    if (reset_i = '0') then 
      bittimer       <= 0;
      Rx_done        <= '0';
      rx_state       <= IDLE;
      bitcounter     <= 0;
      shift_register <= "00000000";
      dataout 	     <= "00000000";
      Rx_ii          <= '1';		
      Rx_iii         <= '1';
      rx_iiii        <= '1';
    elsif (rising_edge(clk)) then
      Rx_ii   <= Rx_i;	       --for synchronizer
      Rx_iii  <= Rx_ii;        --for synchronizer
      rx_iiii <= rx_iii;       --for synchronizer
      
      case rx_state is 
		
        when IDLE =>
	  Rx_done      <= '0';
          bittimer     <= 0;
          if (rx_iii = '0' and rx_iiii = '1') then
	    rx_state   <= START;
	  end if;
 				
	when START =>		
	  if (bittimer = bittimer_limit_s) then
	    if(rx_iiii = '1') then
	      rx_state     <= IDLE;				  
	    else
	      rx_state     <= DATA_RECEIVE;
	    end if;	
	    bittimer       <= 0;
	  else
	    bittimer       <= bittimer + 1;
	  end if;
	  bitcounter       <= 0;	
          shift_register   <= (others => '0');	
		
	when DATA_RECEIVE =>
	  if (bittimer = bittimer_limit) then
	    shift_register <= rx_iiii & (shift_register(7 downto 1));
	    if(bitcounter = 7) then
	      rx_state   <= STOP;
	      bitcounter <= 0;
	    else
	      bitcounter <= bitcounter + 1 ;
	    end if;
	    bittimer 	 <= 0;
	  else				
	    bittimer     <= bittimer + 1;					
	  end if;
			
	when STOP =>					
          if (bittimer = bittimer_limit) then
	    rx_state 	  <= IDLE;
	    bittimer 	  <= 0;
	    Rx_done 	  <= '1';
	    dataout       <= shift_register;
	  else
	    bittimer      <= bittimer + 1;
	  end if;
		  
	when others => 
	  bittimer       <= 0;
	  Rx_done        <= '0';
	  rx_state       <= IDLE;
	  bitcounter     <= 0;
	  shift_register <= "00000000";
	  dataout 	 <= "00000000";
	  Rx_ii          <= '1';
          Rx_iii         <= '1';
          rx_iiii        <= '1';
				  
      end case;
    end if;
  end process MAIN;	
end Behavioral;
