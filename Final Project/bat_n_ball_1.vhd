LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY bat_n_ball IS
    PORT (
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        bat_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- current bat x position
        bat_y : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
        bat2_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- current bat x position
        bat2_y : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
        serve : IN STD_LOGIC; -- initiates serve
        red : OUT STD_LOGIC;
        green : OUT STD_LOGIC;
        blue : OUT STD_LOGIC;
        SW : IN STD_LOGIC_VECTOR (4 DOWNTO 0); -- ball speed
        hits: OUT STD_LOGIC_VECTOR (15 DOWNTO 0) -- count the number of successful hits
    );
END bat_n_ball;

ARCHITECTURE Behavioral OF bat_n_ball IS
    CONSTANT bsize : INTEGER := 12; -- ball size in pixels
    SIGNAL bat_h : INTEGER := 24; -- bat width in pixels
    CONSTANT bat_w : INTEGER := 20; -- bat height in pixels
    SIGNAL bat2_h : INTEGER := 24; -- bat width in pixels
    CONSTANT bat2_w : INTEGER := 20; -- bat height in pixels
    -- distance ball moves each frame
    SIGNAL ball_speed : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL ball_on : STD_LOGIC; -- indicates whether ball is at current pixel position
    SIGNAL ball2_on : STD_LOGIC;
    SIGNAL ball3_on : STD_LOGIC;
    SIGNAL ball4_on : STD_LOGIC;
    SIGNAL bat_on : STD_LOGIC; -- indicates whether bat at over current pixel position
    SIGNAL bat2_on : STD_LOGIC; -- indicates whether bat at over current pixel position
    SIGNAL game_on : STD_LOGIC := '0'; -- indicates whether ball is in play
    SIGNAL damage_on : STD_LOGIC := '0';
    -- current ball position - intitialized to center of screen
    SIGNAL ball_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11);
    SIGNAL ball_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
    SIGNAL ball2_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
	SIGNAL ball2_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
	SIGNAL ball3_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
	SIGNAL ball3_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(200, 11);
	SIGNAL ball4_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(200, 11);
	SIGNAL ball4_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(100, 11);
    -- current ball motion - initialized to (+ ball_speed) pixels/frame in both X and Y directions
    SIGNAL ball_x_motion, ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := ball_speed;
    SIGNAL ball2_x_motion, ball2_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := ball_speed;
    SIGNAL ball3_x_motion, ball3_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := ball_speed;
    SIGNAL ball4_x_motion, ball4_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := ball_speed;
    SIGNAL hitcount : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL stop_dbl_hit : STD_LOGIC; -- stops the counter from registering 2 hits at once
BEGIN
    red <= NOT bat_on; -- color setup for red ball and cyan bat on white background
    green <= NOT ball_on AND NOT ball2_on AND NOT ball3_on AND NOT ball4_on AND NOT bat2_on;
    blue <= NOT ball_on OR NOT ball2_on OR NOT ball3_on OR NOT ball4_on OR NOT bat2_on;
    -- process to draw round ball
    -- set ball_on if current pixel address is covered by ball position
    balldraw : PROCESS (ball_x, ball_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF pixel_col <= ball_x THEN -- vx = |ball_x - pixel_col|
            vx := ball_x - pixel_col;
        ELSE
            vx := pixel_col - ball_x;
        END IF;
        IF pixel_row <= ball_y THEN -- vy = |ball_y - pixel_row|
            vy := ball_y - pixel_row;
        ELSE
            vy := pixel_row - ball_y;
        END IF;
        IF ((vx * vx) + (vy * vy)) < (bsize * bsize) THEN -- test if radial distance < bsize
            ball_on <= game_on;
        ELSE
            ball_on <= '0';
        END IF;
    END PROCESS;
    ball2draw : PROCESS (ball2_x, ball2_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF pixel_col <= ball2_x THEN -- vx = |ball_x - pixel_col|
            vx := ball2_x - pixel_col;
        ELSE
            vx := pixel_col - ball2_x;
        END IF;
        IF pixel_row <= ball2_y THEN -- vy = |ball_y - pixel_row|
            vy := ball2_y - pixel_row;
        ELSE
            vy := pixel_row - ball2_y;
        END IF;
        IF ((vx * vx) + (vy * vy)) < (bsize * bsize) THEN -- test if radial distance < bsize
            ball2_on <= game_on;
        ELSE
            ball2_on <= '0';
        END IF;
    END PROCESS;
    ball3draw : PROCESS (ball3_x, ball3_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF pixel_col <= ball3_x THEN -- vx = |ball_x - pixel_col|
            vx := ball3_x - pixel_col;
        ELSE
            vx := pixel_col - ball3_x;
        END IF;
        IF pixel_row <= ball3_y THEN -- vy = |ball_y - pixel_row|
            vy := ball3_y - pixel_row;
        ELSE
            vy := pixel_row - ball3_y;
        END IF;
        IF ((vx * vx) + (vy * vy)) < (bsize * bsize) THEN -- test if radial distance < bsize
            ball3_on <= game_on;
        ELSE
            ball3_on <= '0';
        END IF;
    END PROCESS;
    ball4draw : PROCESS (ball4_x, ball4_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF pixel_col <= ball4_x THEN -- vx = |ball_x - pixel_col|
            vx := ball4_x - pixel_col;
        ELSE
            vx := pixel_col - ball4_x;
        END IF;
        IF pixel_row <= ball4_y THEN -- vy = |ball_y - pixel_row|
            vy := ball4_y - pixel_row;
        ELSE
            vy := pixel_row - ball4_y;
        END IF;
        IF ((vx * vx) + (vy * vy)) < (bsize * bsize) THEN -- test if radial distance < bsize
            ball4_on <= game_on;
        ELSE
            ball4_on <= '0';
        END IF;
    END PROCESS;
    -- process to draw bat
    -- set bat_on if current pixel address is covered by bat position
    batdraw : PROCESS (bat_x, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF ((pixel_col >= bat_x - bat_w) OR (bat_x <= bat_w)) AND
         pixel_col <= bat_x + bat_w AND
             pixel_row >= bat_y - bat_h AND
             pixel_row <= bat_y + bat_h THEN
                bat_on <= '1';
        ELSE
            bat_on <= '0';
        END IF;
    END PROCESS;
    bat2draw : PROCESS (bat2_x, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF ((pixel_col >= bat2_x - bat2_w) OR (bat2_x <= bat2_w)) AND
         pixel_col <= bat2_x + bat2_w AND
             pixel_row >= bat2_y - bat2_h AND
             pixel_row <= bat2_y + bat2_h THEN
                bat2_on <= damage_on;
        ELSE
            bat2_on <= '0';
        END IF;
    END PROCESS;
    -- process to move ball once every frame (i.e., once every vsync pulse)
    mball : PROCESS
        VARIABLE temp : STD_LOGIC_VECTOR (11 DOWNTO 0);
        VARIABLE temp2 : STD_LOGIC_VECTOR (11 DOWNTO 0);
        VARIABLE temp3 : STD_LOGIC_VECTOR (11 DOWNTO 0);
        VARIABLE temp4 : STD_LOGIC_VECTOR (11 DOWNTO 0);
    BEGIN
        ball_speed <= (10 DOWNTO SW'length => '0') & SW;
        WAIT UNTIL rising_edge(v_sync);
        IF serve = '1' THEN -- test for new serve
            game_on <= '1';
            ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
            ball_x_motion <= ball_speed + 1; -- set hspeed to (+ ball_speed) pixels
            ball2_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
            ball2_x_motion <= (NOT ball_speed) + 1; -- set hspeed to (- ball_speed) pixels
            ball3_y_motion <= ball_speed + 1; -- set vspeed to (+ ball_speed) pixels
            ball3_x_motion <= (NOT ball_speed) + 1; -- set hspeed to (- ball_speed) pixels
            ball4_y_motion <= ball_speed + 1; -- set vspeed to (+ ball_speed) pixels
            ball4_x_motion <= ball_speed + 1; -- set hspeed to (+ ball_speed) pixels
            hitcount <= CONV_STD_LOGIC_VECTOR(16, 16);
            stop_dbl_hit <= '0';
        ELSIF ball_y <= bsize THEN -- bounce off top wall
            ball_y_motion <= ball_speed; -- set vspeed to (+ ball_speed) pixels
            stop_dbl_hit <= '0';
            damage_on <= '0';
        ELSIF ball_y + bsize >= 600 THEN -- if ball meets bottom wall
            ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
            damage_on <= '0';
        ELSIF ball2_y <= bsize THEN -- bounce off top wall
            ball2_y_motion <= ball_speed; -- set vspeed to (+ ball_speed) pixels
            stop_dbl_hit <= '0';
            damage_on <= '0';
        ELSIF ball2_y + bsize >= 600 THEN -- if ball meets bottom wall
            ball2_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
            damage_on <= '0';
        ELSIF ball3_y <= bsize THEN -- bounce off top wall
            ball3_y_motion <= ball_speed; -- set vspeed to (+ ball_speed) pixels
            stop_dbl_hit <= '0';
            damage_on <= '0';
        ELSIF ball3_y + bsize >= 600 THEN -- if ball meets bottom wall
            ball3_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
            damage_on <= '0';
        ELSIF ball4_y <= bsize THEN -- bounce off top wall
            ball4_y_motion <= ball_speed; -- set vspeed to (+ ball_speed) pixels
            stop_dbl_hit <= '0';
            damage_on <= '0';
        ELSIF ball4_y + bsize >= 600 THEN -- if ball meets bottom wall
            ball4_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
            damage_on <= '0';
        END IF;
        -- allow for bounce off left or right of screen
        IF ball_x + bsize >= 800 THEN -- bounce off right wall
            ball_x_motion <= (NOT ball_speed) + 1; -- set hspeed to (- ball_speed) pixels
            damage_on <= '0';
        ELSIF ball_x <= bsize THEN -- bounce off left wall
            ball_x_motion <= ball_speed; -- set hspeed to (+ ball_speed) pixels
            damage_on <= '0';
        ELSIF ball2_x + bsize >= 800 THEN -- bounce off right wall
            ball2_x_motion <= (NOT ball_speed) + 1; -- set hspeed to (- ball_speed) pixels
            damage_on <= '0';
        ELSIF ball2_x <= bsize THEN -- bounce off left wall
            ball2_x_motion <= ball_speed; -- set hspeed to (+ ball_speed) pixels
            damage_on <= '0';
        ELSIF ball3_x + bsize >= 800 THEN -- bounce off right wall
            ball3_x_motion <= (NOT ball_speed) + 1; -- set hspeed to (- ball_speed) pixels
            damage_on <= '0';
        ELSIF ball3_x <= bsize THEN -- bounce off left wall
            ball3_x_motion <= ball_speed; -- set hspeed to (+ ball_speed) pixels
            damage_on <= '0';
        ELSIF ball4_x + bsize >= 800 THEN -- bounce off right wall
            ball4_x_motion <= (NOT ball_speed) + 1; -- set hspeed to (- ball_speed) pixels
            damage_on <= '0';
        ELSIF ball4_x <= bsize THEN -- bounce off left wall
            ball4_x_motion <= ball_speed; -- set hspeed to (+ ball_speed) pixels
            damage_on <= '0';
        END IF;
        
        -- allow for bounce off bat
        IF (ball_x + bsize) >= (bat_x - bat_w) AND
         (ball_x - bsize) <= (bat_x + bat_w) AND
             (ball_y + bsize) >= (bat_y - bat_h) AND
             (ball_y - bsize) <= (bat_y + bat_h) AND
             stop_dbl_hit = '0' THEN
                damage_on <= '1';
                hitcount <= hitcount - 1;
                hits <= hitcount;
                stop_dbl_hit <= '1';
        END IF;
        IF (ball2_x + bsize) >= (bat_x - bat_w) AND
         (ball2_x - bsize) <= (bat_x + bat_w) AND
             (ball2_y + bsize) >= (bat_y - bat_h) AND
             (ball2_y - bsize) <= (bat_y + bat_h) AND
                stop_dbl_hit = '0' THEN
                damage_on <= '1';
                hitcount <= hitcount - 1;
                hits <= hitcount;
                stop_dbl_hit <= '1';
        END IF;
        IF (ball3_x + bsize) >= (bat_x - bat_w) AND
         (ball3_x - bsize) <= (bat_x + bat_w) AND
             (ball3_y + bsize) >= (bat_y - bat_h) AND
             (ball3_y - bsize) <= (bat_y + bat_h) AND
                stop_dbl_hit = '0' THEN
                damage_on <= '1';
                hitcount <= hitcount - 1;
                hits <= hitcount;
                stop_dbl_hit <= '1';
        END IF;
        IF (ball4_x + bsize) >= (bat_x - bat_w) AND
         (ball4_x - bsize) <= (bat_x + bat_w) AND
             (ball4_y + bsize) >= (bat_y - bat_h) AND
             (ball4_y - bsize) <= (bat_y + bat_h) AND
                stop_dbl_hit = '0' THEN
                damage_on <= '1';
                hitcount <= hitcount - 1;
                hits <= hitcount;
                stop_dbl_hit <= '1';
        END IF;
        -- compute next ball vertical position
        -- variable temp adds one more bit to calculation to fix unsigned underflow problems
        -- when ball_y is close to zero and ball_y_motion is negative
        temp := ('0' & ball_y) + (ball_y_motion(10) & ball_y_motion);
        IF game_on = '0' THEN
            ball_y <= CONV_STD_LOGIC_VECTOR(600, 11);
        ELSIF temp(11) = '1' THEN
            ball_y <= (OTHERS => '0');
        ELSE ball_y <= temp(10 DOWNTO 0); -- 9 downto 0
        END IF;
        temp2 := ('0' & ball2_y) + (ball2_y_motion(10) & ball2_y_motion);
        IF game_on = '0' THEN
            ball2_y <= CONV_STD_LOGIC_VECTOR(500, 11);
        ELSIF temp2(11) = '1' THEN
            ball2_y <= (OTHERS => '0');
        ELSE ball2_y <= temp2(10 DOWNTO 0); -- 9 downto 0
        END IF;
        temp3 := ('0' & ball3_y) + (ball3_y_motion(10) & ball3_y_motion);
        IF game_on = '0' THEN
            ball3_y <= CONV_STD_LOGIC_VECTOR(300, 11);
        ELSIF temp3(11) = '1' THEN
            ball3_y <= (OTHERS => '0');
        ELSE ball3_y <= temp3(10 DOWNTO 0); -- 9 downto 0
        END IF;
        temp4 := ('0' & ball4_y) + (ball4_y_motion(10) & ball4_y_motion);
        IF game_on = '0' THEN
            ball4_y <= CONV_STD_LOGIC_VECTOR(200, 11);
        ELSIF temp4(11) = '1' THEN
            ball4_y <= (OTHERS => '0');
        ELSE ball4_y <= temp4(10 DOWNTO 0); -- 9 downto 0
        END IF;
        -- compute next ball horizontal position
        -- variable temp adds one more bit to calculation to fix unsigned underflow problems
        -- when ball_x is close to zero and ball_x_motion is negative
        temp := ('0' & ball_x) + (ball_x_motion(10) & ball_x_motion);
        IF temp(11) = '1' THEN
            ball_x <= (OTHERS => '0');
        ELSE ball_x <= temp(10 DOWNTO 0);
        END IF;
        temp2 := ('0' & ball2_x) + (ball2_x_motion(10) & ball2_x_motion);
        IF temp2(11) = '1' THEN
            ball2_x <= (OTHERS => '0');
        ELSE ball2_x <= temp2(10 DOWNTO 0);
        END IF;
        temp3 := ('0' & ball3_x) + (ball3_x_motion(10) & ball3_x_motion);
        IF temp3(11) = '1' THEN
            ball3_x <= (OTHERS => '0');
        ELSE ball3_x <= temp3(10 DOWNTO 0);
        END IF;
        temp4 := ('0' & ball4_x) + (ball4_x_motion(10) & ball4_x_motion);
        IF temp4(11) = '1' THEN
            ball4_x <= (OTHERS => '0');
        ELSE ball4_x <= temp4(10 DOWNTO 0);
        END IF;
   END PROCESS;
END Behavioral;