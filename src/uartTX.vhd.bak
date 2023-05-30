--Abdullah Furkan Kaya--
--21947396--
--ELE432 PRE#3--
--UART TRANSMITTER--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity uartTX is
  generic(
    clk_freq: integer := 50_000_000;	  	
    boudrate: integer := 9600;       --user defined
    stopbit:  integer := 1           --number of stop bit user defined
  );
  port(
    data_i        : in std_logic_vector (7 downto 0);--transmitted data 
    data_en	  : in std_logic;                    --to transmit data
    clk           : in std_logic;
    reset_i       : in std_logic;
    tx_busy	  : out std_logic; 
    Tx_o          : out std_logic
  );
end uartTX;

architecture Behavioral of uartTX is
	
  constant bittimer_limit : integer := (clk_freq/boudrate);
	
  type states is (IDLE,START,DATA_TRANSMISSION,STOP);
  signal tx_state: states := IDLE;
		
  signal bittimer         : integer range 0 to bittimer_limit := 0 ;
  signal bitcounter       : integer range 0 to 7 := 0 ;
  signal shift_register   : std_logic_vector (7 downto 0);
		
  signal bittimer_control : std_logic := '0';  	
  signal bitimer_enable   : std_logic := '0';
	
begin
	
  bittime: process (clk,reset_i)
  begin
    if (reset_i = '0') then
      bittimer         <= 0;
      bittimer_control <= '0';
    elsif (rising_edge(clk)) then
      if (bitimer_enable = '0') then 
	bittimer             <= 0 ;           
      else                        
	case bittimer is
	  when  bittimer_limit-1 => 
	    bittimer         <= 0;
	    bittimer_control <= '0';
	  when  bittimer_limit-2 =>
	    bittimer         <= bittimer + 1;
	    bittimer_control <= '1';
	  when others =>
	    bittimer         <= bittimer + 1;
        end case;			  
      end if;		 		
    end if;
  end process;
		
  MAIN: process (clk,reset_i) 
  begin
    if (reset_i = '0') then
      Tx_o           <= '1';
      bitcounter     <= 0;
      shift_register <= "00000000";
      tx_state       <= IDLE;
      bitimer_enable <= '0'; 
      tx_busy        <= '0';
    else	  
      if (rising_edge(clk)) then 	
        case tx_state is 
	  when IDLE =>	 
	    bitcounter       <= 0;
	    tx_busy 	     <= '0';   
	    if (data_en = '1') then 
	      bitimer_enable <= '1';
	      shift_register <= data_i;
	      tx_state       <= start;                                              
	      Tx_o           <= '0';
	      tx_busy	     <= '1';
	    end if;                                                                  
																							 
	  when START =>                                                                													 
	    if (bittimer_control = '1') then                                         
	      tx_state        <= data_transmission;                                  
	      Tx_o            <= shift_register(0);                                       
	      shift_register  <= shift_register(0) & shift_register(7 downto 1);              
	    end if;                                                                  
																							 
	  when DATA_TRANSMISSION =>                                                    																		 
	    if (bittimer_control = '1') then				                          					  
	      if (bitcounter = 7) then
		bitcounter     <= 0 ;                                                
		tx_state       <= STOP;
		Tx_o           <= '1'; 		
	      else 
	        bitcounter     <= bitcounter + 1 ;
		Tx_o           <= shift_register(0);                                       
		shift_register <= shift_register(0) & shift_register(7 downto 1);     
	      end if;
	    end if;  
					                                         																			        																							 
	  when STOP =>                                                                 
	    if (bittimer_control = '1') then	
              Tx_o             <= '1'; 					
	      if (bitcounter = stopbit-1) then
		tx_state       <= IDLE;
		bitimer_enable <= '0'; 
		bitcounter     <= 0;
	        tx_busy	       <= '0';
	      else
	        bitcounter     <= bitcounter + 1 ;
	      end if; 
	    end if;   
					   	
          when others => 
            Tx_o           <= '1';
	    bitcounter     <= 0;
	    shift_register <= "00000000";
	    tx_state       <= IDLE;
	    bitimer_enable <= '0'; 
	    tx_busy		   <= '0';				
	end case;			
      end if;
    end if;
  end process MAIN;
	
end Behavioral;