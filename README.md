# screen-orientation
A small script for rotating the screen and digitiser of convertible notebooks, originally written for my Thinkpad X220 Tablet.

## Current features
* Flip the screen or rotate by 90°
* Disables the Trackpoint in every orientation except "normal", to avoid mouse movement caused by the screen in tablet mode

## Usage
Change the following variables according to your hardware:
* $screen: Name of the output in xrandr (can be found in the output of xrandr)
* $pen: Name of the stylus input in xinput (can be found in the output of xinput)
* $eraser: Name of the eraser (can be found in the output of xinput)
* $trackpoint: Name of the Trackpoint (can be found in xinput)

Call the script with the parameter -f for flipping the screen (rotating the screen by 180°), or with -r for rotating the screen by 90°. Both parameters can also be used at the same time.
