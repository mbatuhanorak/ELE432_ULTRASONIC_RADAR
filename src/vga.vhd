
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.math_real.all;


entity VGA is
    Port ( CLK25              : IN  STD_LOGIC;																			
           rez_160x120        : IN  STD_LOGIC;
           rez_320x240        : IN  STD_LOGIC;
           Hsync,Vsync        : OUT STD_LOGIC;						
			  Nblank             : OUT STD_LOGIC;								
           activecam_o        : OUT STD_LOGIC;
		     cam_data_i         : IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
		     activecam_i        : IN	STD_LOGIC;
		     R,G,B 	            : OUT	STD_LOGIC_VECTOR (7 DOWNTO 0);
		     distance_in        : IN  INTEGER range 0 to 255 ;  
		     motor_location_in : IN  INTEGER range 0 to 360 ; 
			  Nsync              : OUT STD_LOGIC);	
end VGA;

architecture Behavioral of VGA is
signal Hcnt:STD_LOGIC_VECTOR(9 downto 0):="0000000000";		
signal Vcnt:STD_LOGIC_VECTOR(9 downto 0):="1000001000";		
signal video:STD_LOGIC;
constant HM: integer :=799;	
constant HD: integer :=640;	
constant HF: integer :=16;		
constant HB: integer :=48;		
constant HR: integer :=96;		
constant VM: integer :=524;	
constant VD: integer :=480;	
constant VF: integer :=10;		
constant VB: integer :=33;		
constant VR: integer :=2;		
signal counter :integer  range 0 to 200_000_000 :=0;
signal co :integer:=0;
signal ball_row: integer := 240; -- 480/2
signal ball_col: integer := 320; -- 640/2
signal ball_size : integer := 5;
type sinlut is array (0 to 359) of integer;--
signal sinrom : sinlut;
signal cosrom : sinlut;


signal pixel_row     : std_logic_vector(9 downto 0);
signal pixel_column : std_logic_vector(9 downto 0);

begin

genrom_sin: for i in 0 to 359 generate
constant x : real := sin ( real(i) * math_pi / real(179));
constant xn : integer := (integer (x * real(100)));
begin
	sinrom(i) <= xn;
end generate;
	
genrom_cos: for i in 0 to 359 generate
constant x : real := cos ( real(i) * math_pi / real(179));
constant xn : integer := (integer (x * real(100)));
begin
	cosrom(i) <= xn;
end generate;

pixel_column <= Hcnt;
pixel_row    <= Vcnt;

	process(CLK25)
		begin
			if (CLK25'event and CLK25='1') then
				if (Hcnt = HM) then
					Hcnt <= "0000000000";
               if (Vcnt= VM) then
                  Vcnt <= "0000000000";
                  activecam_o <= '1';
               else
                  if rez_160x120 = '1' then
                     if vCnt < 120-1 then
                        activecam_o <= '1';
                     end if;
                  elsif rez_320x240 = '1' then
                     if vCnt < 240-1 then
                        activecam_o <= '1';
                     end if;
                  else
                     if vCnt < 480-1 then
                        activecam_o <= '1';
                     end if;
                  end if;
                  Vcnt <= Vcnt+1;
               end if;
				else
               if rez_160x120 = '1' then
                  if hcnt = 160-1 then
                     activecam_o <= '0';
                  end if;
               elsif rez_320x240 = '1' then
                  if hcnt = 320-1 then
                     activecam_o <= '0';
                  end if;
               else
                  if hcnt = 640-1 then
                     activecam_o <= '0';
                  end if;
               end if;
					Hcnt <= Hcnt + 1;
				end if;
			end if;
		end process;
--process(CLK25)
--begin
--  if (rising_edge(CLK25)) then
--    if counter = 25_000_000 then
--      co <= 0;
--    elsif counter = 50_000_000 then
--      co <= 50;
--    elsif counter = 75_000_000 then
--      co <= 120;
--    elsif counter = 100_000_000 then
--      co <= 160;
--    elsif counter = 125_000_000 then
--      co <= 210;
--	 elsif counter = 150_000_000 then
--      co <= 260;
--	 elsif counter = 175_000_000 then
--      co <= 310;	
--	elsif counter = 200_000_000 then
--      co <= 350;	
--      counter <= 0; 	
--    end if;
--      counter <= counter + 1;
--  end if;
--end process;
		
   process(video)
   begin

     if (distance_in > 0) then
	   if distance_in > 100 then -- if distance is higher than 200cm, show black point at 10x10 pixel
		 ball_row <= 10;
		 ball_col <= 10;
		 R <= (others => '0');
		 G <= (others => '0');
		 B <= (others => '0');
	   else
		 ball_col <= (distance_in*(cosrom (motor_location_in))/100)*2+320;---en son çembere göre 175 oldu için değelere maplamek istenilen sayıya bolunuğ çarpılıyor. 
		 ball_row <= (distance_in*(sinrom (motor_location_in))/100)*2+240;-- ornek 175 en son cember normalde 175  150 istiyoruz =>>>>175/150 çarp  	
	   end if;
     end if;

     -----DRAW BACKGROUND BLACK----
     if (pixel_row > 0 and pixel_row < 480 and pixel_column > 0 and pixel_column < 640) then 
		 R <= (others => '0');
		 G <= (others => '0');
		 B <= (others => '0');
	

    
	
	--------------- burdan sonras� benim kendi �izimlerim merkezi ortadan sa�a 50 pixel kayd�rd�m
	-----DRAW POINT MAGENTA----
	if (activecam_i = '1') then 
      R <= cam_data_i(11 downto 8) & cam_data_i(11 downto 8);		   
      G <= cam_data_i(7 downto 4)  & cam_data_i(7 downto 4) ;
      B <= cam_data_i(3 downto 0)  & cam_data_i(3 downto 0) ;	  
	end if;
	
	if ( (pixel_column-50) > (ball_col - ball_size) and (pixel_column-50) < (ball_col + ball_size) and pixel_row > (ball_row - ball_size) and pixel_row < (ball_row + ball_size) ) then
	   R <= (others => '1');
	   G <= (others => '1');
	   B <= (others => '1');
	end if;
--	
    if ( ( ((conv_integer(pixel_column)-370)*(conv_integer(pixel_column)-370)) + ((conv_integer(pixel_row)-240)*(conv_integer(pixel_row)-240)) ) <= 2500
	  and ( ((conv_integer(pixel_column)-370)*(conv_integer(pixel_column)-370)) + ((conv_integer(pixel_row)-240)*(conv_integer(pixel_row)-240)) ) >= 2401) then 
	   R <= (others => '1');
	   G <= (others => '0');
	   B <= (others => '0');
	end if;
	
	if ( ( ((conv_integer(pixel_column)-370)*(conv_integer(pixel_column)-370)) + ((conv_integer(pixel_row)-240)*(conv_integer(pixel_row)-240)) ) <= 4900
	  and ( ((conv_integer(pixel_column)-370)*(conv_integer(pixel_column)-370)) + ((conv_integer(pixel_row)-240)*(conv_integer(pixel_row)-240)) ) >= 4761) then
	   R <= (others => '1');
	   G <= (others => '0');
	   B <= (others => '0');
	end if;
	
	if ( ( ((conv_integer(pixel_column)-370)*(conv_integer(pixel_column)-370)) + ((conv_integer(pixel_row)-240)*(conv_integer(pixel_row)-240)) ) <= 8100
	  and ( ((conv_integer(pixel_column)-370)*(conv_integer(pixel_column)-370)) + ((conv_integer(pixel_row)-240)*(conv_integer(pixel_row)-240)) ) >= 7921) then
	   R <= (others => '1');
	   G <= (others => '0');
	   B <= (others => '0');
	end if;
	
	if ( ( ((conv_integer(pixel_column)-370)*(conv_integer(pixel_column)-370)) + ((conv_integer(pixel_row)-240)*(conv_integer(pixel_row)-240)) ) <= 12100
	  and ( ((conv_integer(pixel_column)-370)*(conv_integer(pixel_column)-370)) + ((conv_integer(pixel_row)-240)*(conv_integer(pixel_row)-240)) ) >= 11881) then
	   R <= (others => '1');
	   G <= (others => '0');
	   B <= (others => '0');
	end if;
	
	if ( ( ((conv_integer(pixel_column)-370)*(conv_integer(pixel_column)-370)) + ((conv_integer(pixel_row)-240)*(conv_integer(pixel_row)-240)) ) <= 16900
	  and ( ((conv_integer(pixel_column)-370)*(conv_integer(pixel_column)-370)) + ((conv_integer(pixel_row)-240)*(conv_integer(pixel_row)-240)) ) >= 16641) then
	   R <= (others => '1');
	   G <= (others => '0');
	   B <= (others => '0');
	end if;
	
	if ( ( ((conv_integer(pixel_column)-370)*(conv_integer(pixel_column)-370)) + ((conv_integer(pixel_row)-240)*(conv_integer(pixel_row)-240)) ) <= 22500
	  and ( ((conv_integer(pixel_column)-370)*(conv_integer(pixel_column)-370)) + ((conv_integer(pixel_row)-240)*(conv_integer(pixel_row)-240)) ) >= 22201) then
	   R <= (others => '1');
	   G <= (others => '0');
	   B <= (others => '0');
	end if;
	
	if ( ( ((conv_integer(pixel_column)-370)*(conv_integer(pixel_column)-370)) + ((conv_integer(pixel_row)-240)*(conv_integer(pixel_row)-240)) ) <= 28900
	  and ( ((conv_integer(pixel_column)-370)*(conv_integer(pixel_column)-370)) + ((conv_integer(pixel_row)-240)*(conv_integer(pixel_row)-240)) ) >= 28561) then
	   R <= (others => '1');
	   G <= (others => '0');
	   B <= (others => '0');
	end if;		
	--------------------------------------------------------------------------------------

	
	--------------------------------------------------------------------------------------------
	
	
	
end if;  
end process;
   
	process(CLK25)
		begin
			if (CLK25'event and CLK25='1') then
				if (Hcnt >= (HD+HF) and Hcnt <= (HD+HF+HR-1)) then   --- Hcnt >= 656 and Hcnt <= 751
					Hsync <= '0';
				else
					Hsync <= '1';
				end if;
			end if;
		end process;

	process(CLK25)
		begin
			if (CLK25'event and CLK25='1') then
				if (Vcnt >= (VD+VF) and Vcnt <= (VD+VF+VR-1)) then  ---Vcnt >= 490 and vcnt<= 491
					Vsync <= '0';
				else
					Vsync <= '1';
				end if;
			end if;
		end process;


		

Nsync <= '1';
video <= '1' when (Hcnt < HD) and (Vcnt < VD) else '0';
Nblank <= video;

		
end Behavioral;

