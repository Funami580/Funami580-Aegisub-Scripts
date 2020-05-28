### Merge with move
Merges some lines with the move line. May be useful if you have a move tag
and would like to apply several clips at different time stamps.

#### Steps
1. Put `Funami580.MergeWithMove.lua` in your autoload directory.
   - Linux: `$HOME/.aegisub/automation/autoload/`
   - Windows: `%APPDATA%\Aegisub\automation\autoload\`
   - macOS: `$HOME/Library/Application Support/Aegisub/automation/autoload/`
2. Open Aegisub
3. Select the lines you want to merge
4. Be sure, that the first selected line has a move tag
   - `\move(x1,y1,x2,y2)`
   - `\move(x1,y1,x2,y2,t1,t2)`
5. Automation → Merge with move

#### A working example
```
01.00-05.00 {\move(10,10,100,100,1200,3500)}This is the move line!
01.00-02.00 {#1}{You can put some clip or another tag here}
02.00-02.50 {#2}
03.00-04.50 {#3}
```
These lines result in:
```
01.00-02.00 {#1}{You can put some clip or another tag here}{\pos(10,10)}This is the move line!
02.00-02.50 {#2}{\move(10,10,21.7,21.7,200,500)}This is the move line!
02.50-03.00 {\move(21.7,21.7,41.3,41.3)}This is the move line!
03.00-04.50 {#3}{\move(41.3,41.3,100,100,0,1500)}This is the move line!
04.50-05.00 {\pos(100,100)}This is the move line!
```

#### What doesn't work
When the lines you want to merge into the move line are overlapping in time.
```
01.00-05.00 {\move(10,10,100,100,1200,3500)}This is the move line!
02.00-03.50 {This line overlaps with the line below.}
03.00-04.50 {I start at 03.00, but the line above ends at 03.50...}
```