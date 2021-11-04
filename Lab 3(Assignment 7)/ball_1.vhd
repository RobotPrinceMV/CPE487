LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY ball IS
	PORT (
		v_sync    : IN STD_LOGIC;
		pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		red       : OUT STD_LOGIC;
		green     : OUT STD_LOGIC;
		blue      : OUT STD_LOGIC
		
	);
END ball;

ARCHITECTURE Behavioral OF ball IS
	CONSTANT size  : INTEGER := 16; -- modify ball size from 8
	SIGNAL ball_on : STD_LOGIC; -- indicates whether ball is over current pixel position
	
	SIGNAL ball2_on : STD_LOGIC;
	-- current ball position - intitialized to center of screen
	SIGNAL ball_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
	SIGNAL ball_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
	
	SIGNAL ball2_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
	SIGNAL ball2_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(200, 11);
	-- current ball motion - initialized to +4 pixels/frame
	SIGNAL ball_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000001000";
	SIGNAL ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000001000";
	
	SIGNAL ball2_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000001000";
	SIGNAL ball2_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000001000";
BEGIN
	red <= NOT ball_on; -- color setup for red ball on white background
	green <= NOT ball2_on;
	--green <= NOT ball_on; 
	blue  <= '1'; -- modify ball color from red to magenta
	-- process to draw ball current pixel address is covered by ball position
	bdraw : PROCESS (ball_x, ball_y, pixel_row, pixel_col) IS
	BEGIN
	IF ((((CONV_INTEGER(pixel_col)-CONV_INTEGER(ball_x))*
		(CONV_INTEGER(pixel_col)-CONV_INTEGER(ball_x)))+
		((CONV_INTEGER(pixel_row)-CONV_INTEGER(ball_y))*
		(CONV_INTEGER(pixel_row)-CONV_INTEGER(ball_y)))) <= (size*size)) THEN
--		IF (pixel_col >= ball_x - size) AND
--		 (pixel_col <= ball_x + size) AND
--			 (pixel_row >= ball_y - size) AND
--			 (pixel_row <= ball_y + size) THEN
				ball_on <= '1';
		ELSE
			ball_on <= '0';
		END IF;
		END PROCESS;
		
--------------------------------	
	-- process to draw ball current pixel address is covered by ball position
	bdraw2 : PROCESS (ball2_x, ball2_y, pixel_row, pixel_col) IS
	BEGIN
	IF ((((CONV_INTEGER(pixel_col)-CONV_INTEGER(ball2_x))*
		(CONV_INTEGER(pixel_col)-CONV_INTEGER(ball2_x)))+
		((CONV_INTEGER(pixel_row)-CONV_INTEGER(ball2_y))*
		(CONV_INTEGER(pixel_row)-CONV_INTEGER(ball2_y)))) <= (size*size)) THEN
--		IF (pixel_col >= ball2_x - size) AND
--		 (pixel_col <= ball2_x + size) AND
--			 (pixel_row >= ball2_y - size) AND
--			 (pixel_row <= ball2_y + size) THEN
				ball2_on <= '1';
		ELSE
			ball2_on <= '0';
		END IF;
		END PROCESS;
		
		-- process to move ball once every frame (i.e. once every vsync pulse)
		mball : PROCESS
		BEGIN
			WAIT UNTIL rising_edge(v_sync);
			IF ball_x + size >= 800 THEN
				ball_x_motion <= "11111111100"; -- -4 pixels
			ELSIF ball_x <= size THEN
				ball_x_motion <= "00000000100"; -- +4 pixels
			END IF;
			IF ball2_x + size >= 800 THEN
				ball2_x_motion <= "11111111101";
			ELSIF ball2_x <= size THEN
				ball2_x_motion <= "00000000101";
			END IF;
			-- allow for bounce off top or bottom of screen
			IF ball_y + size >= 600 THEN
				ball_y_motion <= "11111111100"; -- -4 pixels
			ELSIF ball_y <= size THEN
				ball_y_motion <= "00000000100"; -- +4 pixels
			END IF;
			IF ball2_y + size >= 600 THEN
				ball2_y_motion <= "11111111101";
			ELSIF ball2_y <= size THEN
				ball2_y_motion <= "00000000101";
			END IF;
			ball_x <= ball_x + ball_x_motion;
			ball_y <= ball_y + ball_y_motion; -- compute next ball position
			ball2_x <= ball2_x + ball2_x_motion;
			ball2_y <= ball2_y + ball2_y_motion; -- compute next ball position
		
		END PROCESS;
END Behavioral;
