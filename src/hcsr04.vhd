library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity hcsr04 is
    port(
            clk_50     : in  std_logic;
            reset_n    : in  std_logic;
            i_fsm        : in  std_logic_vector(1 downto 0);
            sonar_echo : in  std_logic;
            sonar_trig : out std_logic;
            o_led0       : out std_logic;        -- clear_state
            o_led1       : out std_logic;        -- idle_state
            o_led2       : out std_logic;        -- hcsr_state, end_state
            o_led9       : out std_logic;        -- error_state
            o_seg_cms    : out std_logic_vector(6 downto 0);
			o_seg_ms    : out std_logic_vector(6 downto 0);
            o_seg_dms    : out std_logic_vector(6 downto 0);
			distance_out : out integer range 0 to 255 
            );
end entity  hcsr04;

architecture rtl of hcsr04 is

--- Constants used for 7-segment displays
constant seg_zero        : std_logic_vector(6 downto 0) := "1000000"; -- 0
constant seg_one         : std_logic_vector(6 downto 0) := "1111001"; -- 1
constant seg_two         : std_logic_vector(6 downto 0) := "0100100"; -- 2
constant seg_three       : std_logic_vector(6 downto 0) := "0110000"; -- 3
constant seg_four        : std_logic_vector(6 downto 0) := "0011001"; -- 4
constant seg_five        : std_logic_vector(6 downto 0) := "0010010"; -- 5
constant seg_six         : std_logic_vector(6 downto 0) := "0000011"; -- 6
constant seg_seven       : std_logic_vector(6 downto 0) := "1111000"; -- 7
constant seg_eight       : std_logic_vector(6 downto 0) := "0000000"; -- 8
constant seg_nine        : std_logic_vector(6 downto 0) := "0011000"; -- 9
constant seg_error       : std_logic_vector(6 downto 0) := "0000110"; -- E

--- Signals used for HC-SR04
signal count             : unsigned(16 downto 0) := (others => '0');
signal centimeters       : unsigned(15 downto 0) := (others => '0');
signal centimeters_ones  : unsigned(3 downto 0)  := (others => '0');
signal centimeters_tens  : unsigned(3 downto 0)  := (others => '0');
signal centimeters_hund  : unsigned(3 downto 0)  := (others => '0');
signal output_ones       : unsigned(3 downto 0)  := (others => '0');
signal output_tens       : unsigned(3 downto 0)  := (others => '0');
signal output_hunds       : unsigned(3 downto 0)  := (others => '0');
signal echo_last         : std_logic := '0';
signal echo_synced       : std_logic := '0';
signal echo_unsynced     : std_logic := '0';
signal waiting           : std_logic := '0';

type fsm is (clear_state, idle_state, hcsr_state, end_state, error_state); -- 4 states
signal state : fsm; -- Register to save the current state

begin
distance_out<=to_integer(output_ones) + 10*to_integer(output_tens) + 100*to_integer(output_hunds) ;
    --------------- State process --------------
    process(clk_50, reset_n)
    begin
        if reset_n = '0' then
            state                       <= clear_state;
        elsif (rising_edge(clk_50)) then

            case state is

                -------- CLEAR STATE --------
                when clear_state =>
                    sonar_trig        <= '0';
                    waiting             <= '0';
                    count               <= (others => '0');
                    centimeters_ones    <= (others => '0');
                    centimeters_tens    <= (others => '0');
						  centimeters_hund	 <= (others => '0');
                    output_ones         <= (others => '0');
                    output_tens         <= (others => '0');
                    centimeters         <= (others => '0');
                    state               <= idle_state;

                -------- IDLE STATE --------
                when idle_state =>
                    if i_fsm = "10" then
                        count           <= (others => '0');
                        sonar_trig    <= '0';
                        waiting         <= '0';
                        state           <= hcsr_state;
                    else
                        state           <= idle_state; -- If i_fsm_key is not pressed, wait in idle_state
                    end if;

                -------- HCSR STATE --------
                when hcsr_state =>
                    if i_fsm = "01" then -- Go back to clear_state
                        state <= end_state;
                    else
                        if waiting = '0' then
                            if count = 500 then -- 1000 is for 100MHz -> we use 500 for 50Mhz on DE10-Lite
                                -- After 10us then go into waiting mode
                                sonar_trig <= '0';
                                waiting    <= '1';
                                count       <= (others => '0');
                            else
                                sonar_trig <= '1'; -- keep trig high
                                count <= count+1;  -- count until 10us elapsed
                            end if;
                        elsif echo_last = '0' and echo_synced = '1' then
                            -- Seen rising edge - start count
                            count       <= (others => '0');
                            centimeters <= (others => '0');
                            centimeters_ones <= (others => '0');
                            centimeters_tens <= (others => '0');
									 centimeters_hund	 <= (others => '0');
                        elsif echo_last = '1' and echo_synced = '0' then
                            -- Seen falling edge, so capture count and store the values in output_ones and output_tens
                            output_ones <= centimeters_ones;
                            output_tens <= centimeters_tens;
									 output_hunds <= centimeters_hund;
                        elsif count = 1450*2-1 then
                            -- advance the counter
									 
									if centimeters_tens =9 then 
									   centimeters_hund<=centimeters_hund+1;
									   centimeters_tens<=(others => '0');
                            elsif centimeters_ones = 9  then
                                centimeters_ones <= (others => '0');
                                centimeters_tens <= centimeters_tens + 1;
                            else
                                centimeters_ones <= centimeters_ones + 1;
                            end if;
                            centimeters <= centimeters + 1;
                            count <= (others => '0');
                            if centimeters = 1724 then
                                -- time out - send another pulse
                                waiting <= '0';
                            end if;
                        else
                            count <= count + 1;
                        end if;

                        echo_last        <= echo_synced;
                        echo_synced      <= echo_unsynced;
                        echo_unsynced    <= sonar_echo;

                    end if;

                -------- END STATE --------
                when end_state =>
                    state                <= clear_state;

                -------- ERR STATE --------
                when error_state =>
                    state <= error_state;

                -------- OTHER STATE --------
                when others =>
                    state <= error_state;

            end case;
        end if;
end process;
    ---------------------------------------------

-- Output depends solely on the current state
process (state)
begin
    case state is

    ------- CLEAR STATE --------
        when clear_state =>
            o_led0 <= '1';
            o_led1 <= '0';
            o_led2 <= '0';
            o_led9 <= '0';

    -------- IDLE STATE --------
        when idle_state =>
            o_led0 <= '0';
            o_led1 <= '1';
            o_led2 <= '0';
            o_led9 <= '0';

    -------- HCSR STATE --------
        when hcsr_state =>
            o_led0 <= '0';
            o_led1 <= '0';
            o_led2 <= '1';
            o_led9 <= '0';

    -------- END STATE ---------
        when end_state =>
            o_led0 <= '0';
            o_led1 <= '0';
            o_led2 <= '1';
            o_led9 <= '0';

    -------- ERR STATE ---------
        when error_state =>
            o_led0 <= '0';
            o_led1 <= '0';
            o_led2 <= '0';
            o_led9 <= '1';

    -------- OTHER STATE -------
        when others =>
            o_led0 <= '0';
            o_led1 <= '0';
            o_led2 <= '0';
            o_led9 <= '1';

    end case;
end process;
--------------------------------------------

-- Printing results on 7-seg displays
process(output_ones, output_tens,output_hunds)
begin
    case output_ones is
        when "0000" => o_seg_cms    <= seg_zero;    -- "0000"
        when "0001" => o_seg_cms    <= seg_one;     -- "0001"
        when "0010" => o_seg_cms    <= seg_two;     -- "0010"
        when "0011" => o_seg_cms    <= seg_three;   -- "0011"
        when "0100" => o_seg_cms    <= seg_four;    -- "0100"
        when "0101" => o_seg_cms    <= seg_five;    -- "0101"
        when "0110" => o_seg_cms    <= seg_six;     -- "0110"
        when "0111" => o_seg_cms    <= seg_seven;   -- "0111"
        when "1000" => o_seg_cms    <= seg_eight;   -- "1000"
        when "1001" => o_seg_cms    <= seg_nine;    -- "1001"
        when others => o_seg_cms    <= seg_error;   -- "E"
    end case;

    case output_tens is
        when "0000" => o_seg_dms    <= seg_zero;    -- "0000"
        when "0001" => o_seg_dms    <= seg_one;     -- "0001"
        when "0010" => o_seg_dms    <= seg_two;     -- "0010"
        when "0011" => o_seg_dms    <= seg_three;   -- "0011"
        when "0100" => o_seg_dms    <= seg_four;    -- "0100"
        when "0101" => o_seg_dms    <= seg_five;    -- "0101"
        when "0110" => o_seg_dms    <= seg_six;     -- "0110"
        when "0111" => o_seg_dms    <= seg_seven;   -- "0111"
        when "1000" => o_seg_dms    <= seg_eight;   -- "1000"
        when "1001" => o_seg_dms    <= seg_nine;    -- "1001"
        when others => o_seg_dms    <= seg_error;   -- "E"
    end case;
	 case output_hunds is
        when "0000" => o_seg_ms    <= seg_zero;    -- "0000"
        when "0001" => o_seg_ms    <= seg_one;     -- "0001"
        when "0010" => o_seg_ms    <= seg_two;     -- "0010"
        when "0011" => o_seg_ms    <= seg_three;   -- "0011"
        when "0100" => o_seg_ms    <= seg_four;    -- "0100"
        when "0101" => o_seg_ms    <= seg_five;    -- "0101"
        when "0110" => o_seg_ms    <= seg_six;     -- "0110"
        when "0111" => o_seg_ms    <= seg_seven;   -- "0111"
        when "1000" => o_seg_ms    <= seg_eight;   -- "1000"
        when "1001" => o_seg_ms    <= seg_nine;    -- "1001"
        when others => o_seg_ms    <= seg_error;   -- "E"
    end case;
end process;
--------------------------------------------

end rtl;