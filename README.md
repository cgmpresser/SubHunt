# Sub Hunt
 A setup project for the sub hunt game.

## What's New?
- Incorporated Anaya's code organization (subfolders in res:// ) and torpedo.
- Incorporated Dipto's short sonar sound.
- Incorporated Yash's code for movement.
- Ball is now Target.
- Field is bigger and more square.
- Made individual scenes out of Player, Target, and Field. Main has instances of them.
- Added a script to Field which indicates when the player has gone more than 90m from the center.
- Target responds to torpedo.
- Added a bunch of sounds.
- Handles multiple targets (sonar pings from each one)
- Added this list to README.md

## Controls
- Arrow keys: move and turn
- C or `: Toggle camera (on/off)
- S: Sonar ping
- SPACE: fire torpedo
- R: randomly place ball (BUG: you may have to press it twice)

## TODO
### Game Components
- Make a target that is destroyed when the player touches it.
- Make a torpedo (fire by either the player of enemy)
- Make a target which is destroyed by a torpedo
- Make a mechanism for firing the torpedo

### Game Play
- Create a start, end, and next level mechanism
- Create levels (search, survive, destroy)

### Audio
- Sonar: ping and response
- Text to speech game and level instructions
- Find or make good sounds (see below). These should be licensed for free use, preferable allowing us to alter them. Keep track of where they came from for the credits.

### Sounds 
- Ping noise
- Response noise
- Torpedo noise
- Player destroyed noise
- Target destroyed noise
- Collide with something noise
