### Install fonts
Installs the fonts contained in a mkv file. Linux-only.

#### Prerequisites
* mkvextract
* mkvmerge

You can install the prerequisites on Ubuntu via:
```
sudo apt-get install mkvtoolnix
```

#### Steps
1. Put `Funami580.InstallFonts.lua` and `Funami580.InstallFonts.sh` in your autoload directory.
   - `$HOME/.aegisub/automation/autoload/`
2. Open Aegisub
3. Video → Open video (mkv file with fonts!)
4. Automation → Install fonts
5. Choose between Permanently and Temporarily
   - Permanently: Installed forever
   - Temporarily: Fonts are removed when you choose the Temporarily option again
6. Re-open the video, so Aegisub can recognize the new fonts

#### How can I remove the installed fonts?
Go into your fonts directory: `$HOME/.fonts/`

The temporary fonts are called for example `Aegisub01.ttf`.<br />
The permanent fonts do have their original name e. g. `ClearSans-Bold.ttf`.