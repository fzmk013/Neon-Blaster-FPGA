library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
entity VGA_Square is
  port ( CLK_24MHz		: in std_logic;
			RESET				: in std_logic;
			Btn            : in std_logic_vector(3 downto 0);  --use Key(0) to BtnLeft , key(3) to BtnRight
			end_game       : in bit;
			score          : out integer;
			lose           : out bit;
			ColorOut			: out std_logic_vector(5 downto 0); -- RED & GREEN & BLUE
			SQUAREWIDTH		: in std_logic_vector(7 downto 0);
			ScanlineX		: in std_logic_vector(10 downto 0);
			ScanlineY		: in std_logic_vector(10 downto 0)
  );
end VGA_Square;

architecture Behavioral of VGA_Square is
signal x  : integer := 300;
signal y  : integer := 440;
signal x_player  : integer := 300;
signal y_player  : integer := 440;
signal x_bullet  : integer := 200;
signal y_bullet : integer  := 250;
signal x_enemy  : integer := 320;
signal y_enemy : integer  := 0;

signal NumX, NumY : integer;
--random
signal pseudo_rand : std_logic_vector(31 downto 0) := (others => '0');
--enemy's stuff
signal freq_enemy : integer := 0;
signal flag_enemy : std_logic := '0';
signal flag_dir_enemy : std_logic_vector(1 downto 0) := "00";
signal enemy_speed : integer := 2;


signal counter_player : integer := 0;
signal player_score : integer := 0;

signal freq_bullet   : integer := 0;
signal timer_bullet : integer :=0; 


signal game_over : std_logic := '0';
signal enemy_life_counter : integer range 1 to 7;
signal flag_start : std_logic := '0';  


begin
	 
  process (CLK_24MHz , RESET)
		-- maximal length 32-bit xnor LFSR
		function lfsr32(x : std_logic_vector(31 downto 0)) return std_logic_vector is
		begin
			return x(30 downto 0) & (x(0) xnor x(1) xnor x(21) xnor x(31));
		end function;
  begin
  if RESET = '1' then
		--pseudo_rand <= (others => '0');
		flag_enemy <= '0';
		flag_dir_enemy <= "00";
		game_over <= '0';
		flag_start <= '0';
		enemy_speed <= 2;
		player_score <= 0;
		lose <= '0';
		
  elsif(rising_edge(CLK_24MHz)) then 
		pseudo_rand <= lfsr32(pseudo_rand);
		
		if flag_start = '1' and end_game = '0' then
			counter_player <= counter_player +1;
			freq_bullet <= freq_bullet + 1;
			freq_enemy <= freq_enemy + 1;
			timer_bullet <= timer_bullet+1;
		end if;
		
		ColorOut <= "000000";
		
	  --size of enemy
	  if (ScanlineX > x_enemy AND ScanlineX <= x_enemy+60) AND (ScanlineY > y_enemy AND ScanlineY <= y_enemy+60)then
			ColorOut <= "001100";
	  end if;
	  
	  
		-- size of player (40*40)
		if (ScanlineX > x_player  AND ScanlineX <= x_player +40) AND (ScanlineY > y_player  AND ScanlineY <= y_player +40)then
			ColorOut <= "110000";
		end if;
		
		 --size of bullet
		if (ScanlineX > x_bullet AND ScanlineX <= x_bullet+5) AND (ScanlineY > y_bullet AND ScanlineY <= y_bullet+5)then
			ColorOut <= "000011";
		end if;
	  
		
		--Start game
		if (Btn(0) = '0' or Btn(3) = '0') and end_game = '0' then
		  flag_start <= '1';
		end if;
		

	  --Generate Enemy (Random Entrance)
	  if (flag_enemy = '0') then
			x_enemy <= to_integer(unsigned(pseudo_rand(8 downto 0)));
			y_enemy <= 0;
			flag_dir_enemy <= pseudo_rand(1 downto 0);
			flag_enemy <=  '1';
			enemy_life_counter <= to_integer(unsigned(pseudo_rand(1 downto 0))) + 4;
		end if;
		
			--enemy movement
			if (freq_enemy = 350000) then
			
				if(flag_dir_enemy(0) = '1') then
					x_enemy <= x_enemy + enemy_speed;
				else
					x_enemy <= x_enemy - enemy_speed;
				end if;
				
				if(flag_dir_enemy(1) = '1') then
					y_enemy <= y_enemy - enemy_speed;
				else
					y_enemy <= y_enemy + enemy_speed;
				end if;
				
				if ( x_enemy >= 580) then
					flag_dir_enemy(0) <= '0';
				end if;
				
				if ( x_enemy <= 0) then
					flag_dir_enemy(0) <= '1';
				end if;
				
				if ( y_enemy >= 420) then
					flag_dir_enemy(1) <= '1';
				end if;
				
				if ( y_enemy <= 0) then
					flag_dir_enemy(1) <= '0';
				end if;
				
				 freq_enemy <= 0;
			end if;
						
		
			--Movement player
		if (counter_player = 100001 ) then --Player's speed
			if(Btn(0) = '0' AND x_player <= 600) then
				x_player  <= x_player +2; 
			elsif(Btn(3) ='0' AND x_player  >=0) then
				x_player  <= x_player -2;
			 end if;
			--reset counter
			counter_player <= 0;
	  end if;
	  
		  --bullet's movement
			if(timer_bullet = 24000042) then --speed of bullet apearance
				y_bullet <= y_player -5;
				x_bullet <= x_player  + 18;
				timer_bullet <= 0;
			end if;
			
			
			if (freq_bullet = 200001) then --bullet's speed
				y_bullet  <= y_bullet -4;
				--reset timer
				freq_bullet <= 0;
			end if;



	  
	  --enemy hits player
	   if (y_enemy +60 >= y_player AND x_enemy +60 >= x_player AND x_player +40 >= x_enemy ) then
			 game_over <= '1';
			 lose <= '1';
			--if (	Btn(2) <= '0' ) then
				flag_enemy <= '1'; --reset enemy position	
			--end if;
		end if;
		
		--bullets hits the enemy
		
			if (y_bullet +5 >= y_enemy  AND
					y_enemy +60 >= y_bullet AND 
					x_bullet +5 >= x_enemy  AND
					x_enemy +60 >= x_bullet) then
					
				 player_score <= player_score + 1;
				 x_bullet <= 700;
				 y_bullet <= 700;
				 enemy_life_counter <= enemy_life_counter -1; --decrease the life time
				 
			 end if;
			 
			if (enemy_life_counter = 0 ) then
				 --game_over <= '1';
				 flag_enemy <= '0'; --reset enemy position	
				 enemy_speed <= enemy_speed + 1;
			end if;	  
	
	
	
			--Number Movement
			NumX <= x_enemy + 21;
			NumY <= y_enemy + 15;



	--writing and reducing the enemy's life time 
	if(flag_enemy = '1') then
			case enemy_life_counter is
			
			when 1 =>
				if(ScanlineX <= NumX + 17 and ScanlineX >= NumX + 12  and ScanlineY <= NumY + 29 and ScanlineY >= NumY) then -- Right Vertical Line
					ColorOut <= "111111";
				end if;

			when 2 =>
				if((ScanlineX >= NumX and ScanlineX <= NumX + 17) and ((ScanlineY >= NumY and ScanlineY <= NumY + 5) or (ScanlineY >= NumY + 12 and ScanlineY <= NumY + 17) or (ScanlineY >= NumY + 24 and ScanlineY <= NumY + 29))) then -- Three Horizontal lines
					ColorOut <= "111111";
				end if;
				if((ScanlineX >= NumX + 12 and ScanlineX <= NumX + 17 and ScanlineY >= NumY and ScanlineY <= NumY + 12) or (ScanlineX >= NumX and ScanlineX <= NumX + 5 and ScanlineY >= NumY + 17 and ScanlineY <= NumY + 24)) then -- Vertical Lines
					ColorOut <= "111111";
				end if;
			
			when 3 =>
				if((ScanlineX >= NumX and ScanlineX <= NumX + 17) and ((ScanlineY >= NumY and ScanlineY <= NumY + 5) or (ScanlineY >= NumY + 12 and ScanlineY <= NumY + 17) or (ScanlineY >= NumY + 24 and ScanlineY <= NumY + 29))) then -- Three Horizontal lines
					ColorOut <= "111111";
				end if;
				if(ScanlineX >= NumX + 12 and ScanlineX <= NumX + 17 and ScanlineY >= NumY and ScanlineY <= NumY + 29) then -- Vertical Lines
					ColorOut <= "111111";
				end if;
				
			when 4 =>
				-- Number four
				if(ScanlineX >= NumX + 12 and ScanlineX <= NumX + 17 and ScanlineY >= NumY and ScanlineY <= NumY + 29) then -- RightV line
					ColorOut <= "111111";
				end if;
				if(ScanlineX >= NumX and ScanlineX <= NumX + 5 and ScanlineY >= NumY and ScanlineY <= NumY + 12) then -- LeftV line
					ColorOut <= "111111";
				end if;
				if(ScanlineX >= NumX and ScanlineX <= NumX + 17 and ScanlineY >= NumY + 12 and ScanlineY <= NumY + 17) then -- MiddleH Line
					ColorOut <= "111111";
				end if;

			when 5 =>
				-- Number five
				if((ScanlineX >= NumX and ScanlineX <= NumX + 17) and ((ScanlineY >= NumY and ScanlineY <= NumY + 5) or (ScanlineY >= NumY + 12 and ScanlineY <= NumY + 17) or (ScanlineY >= NumY + 24 and ScanlineY <= NumY + 29))) then -- Three Horizontal lines
					ColorOut <= "111111";
				end if;
				if((ScanlineX >= NumX and ScanlineX <= NumX + 5 and ScanlineY >= NumY and ScanlineY <= NumY + 12) or (ScanlineX >= NumX + 12 and ScanlineX <= NumX + 17 and ScanlineY >= NumY + 17 and ScanlineY <= NumY + 29)) then -- Vertical Lines
					ColorOut <= "111111";
				end if;
			
			when 6 =>
				-- Number six
				if((ScanlineX >= NumX and ScanlineX <= NumX + 17) and ((ScanlineY >= NumY and ScanlineY <= NumY + 5) or (ScanlineY >= NumY + 12 and ScanlineY <= NumY + 17) or (ScanlineY >= NumY + 24 and ScanlineY <= NumY + 29))) then -- Three Horizontal lines
					ColorOut <= "111111";
				end if;
				if((ScanlineX >= NumX and ScanlineX <= NumX + 5 and ScanlineY >= NumY and ScanlineY <= NumY + 29) or (ScanlineX >= NumX + 12 and ScanlineX <= NumX + 17 and ScanlineY >= NumY + 17 and ScanlineY <= NumY + 29)) then -- Vertical Lines
					ColorOut <= "111111";
				end if;
			
			when 7 =>
				-- Number seven
				if((ScanlineX >= NumX and ScanlineX <= NumX + 17) and (ScanlineY >= NumY and ScanlineY <= NumY + 5)) then -- Horizontal line
					ColorOut <= "111111";
				end if;
				if(ScanlineX >= NumX + 12 and ScanlineX <= NumX + 17 and ScanlineY >= NumY and ScanlineY <= NumY + 29) then -- Vertical Line
					ColorOut <= "111111";
				end if;
			end case;
		end if;
		
	   --Game Over and Lose
		if (game_over = '1' ) then
			ColorOut <= "110000";
		end if;
	
	  --Game Over and Win
	  if (end_game = '1' AND game_over = '0') then
		ColorOut <= "001100";
		flag_start <= '0';
     end if;
  
	end if;
  end process;
  
  
  
  score <= player_score;
  
  
end Behavioral;
