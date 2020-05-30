### Lines by frames
Quick way to create lines for the specified frames. For example if you have
a typeset that starts at frame 500 and ends at frame 600, you would just specify:
* Start frame: 500
* End frame: 600
* Step: 1

#### Steps
1. Put `Funami580.LinesByFrames.lua` in your autoload directory.
   - Linux: `$HOME/.aegisub/automation/autoload/`
   - Windows: `%APPDATA%\Aegisub\automation\autoload\`
   - macOS: `$HOME/Library/Application Support/Aegisub/automation/autoload/`
2. Open Aegisub
3. Automation → Lines by frames
4. A dialog pops up. You can specify:
   - Start frame: The first frame the generated lines shall contain (inclusive)
   - End frame: The last frame the generated lines shall contain (inclusive)
   - Step: A step size of 2 would mean that the lines are 2 frames long
5. Press OK

#### Tricks
The dialog auto-fills the start frame and the end frame. It gets
the values from the current selected line. Therefore you could
just create a new line, select it, go to the frame the typesetting starts with
and do `Set start of selected subtitles to current video frame`.
Then you can go to the last frame of the typesetting and click
`Set end of selected subtitles to current video frame`. If you
now open the dialog you can skip entering the frames.

Here's an image showing the buttons:

![Buttons in Aegisub](../img/set_to_current_frame.png?raw=true)