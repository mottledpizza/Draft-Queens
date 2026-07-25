Pitching data is taken from the pitcher.
Pitching process is:
- Pitcher picks pitches based on preference
	- 4 types:
- Create strike zone
	- Creates base plate area (17"x17")
	- Height is pulled from height of batter
		- Calculated by: strike zone percentage based on height.
- Finds target within strike zone + 2 inches per dimension (where ball is thrown)
- Calculate gravity's effect on the ball
- Modify target based on gravity and pitch spin (pitching sauce, player-specific value)
	- Pitch type affects the spin
- This results in the PROJECTED TARGET, which is where the pitcher intends to throw the ball
- The actual throw then happens
	- Calculated target is affected by accuracy, and speed is random within a range (player-specific)
- Goes to [[Batting]] (is sometimes ball)