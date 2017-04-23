#!/usr/bin/env perl

use warnings;
use strict;
use 5.010;
use Getopt::Std;
no warnings 'experimental::smartmatch';

my $screen ="LVDS1";
my $eraser = "Wacom ISDv4 90 Pen eraser";
my $pen = "Wacom ISDv4 90 Pen stylus";
my $trackpoint = "TPPS/2 IBM TrackPoint";

our($opt_f, $opt_r);
getopts('fr');                                                                  # Acquire cmd parameters -f and -r.

unless ($opt_f || $opt_r) {                                                     # Check for parameters. At least one is required.
    say "Please supply an option (-f for flip, -r for rotate)";
    exit 1;
}

# Calls xrandr to find out the current orientation
sub GetOrientation {
    my $scr = shift;
    my $regex = qr/\s*$scr[\s+\w+]+\s+[x+\d]+\s+(|left|right|inverted)\s*\(/; # Regex parsing the output of xrandr to find the current orientation
    if (`xrandr` =~ /$regex/) {
        return "normal" unless ($1);                                            # $1 contains orientation or empty string if normal
        return $1;
    } else {
        say "help!";
        return undef;
    }
}

# Returns supplied orientation flipped.
sub Flip {
    return undef unless (scalar @_ == 1);                                       # Subroutine needs one parameter (orientation)
    
    given ($_[0]) {                                                             # Apply flip. Returns undef if unknown orientation was given.
        when ('normal')   { return 'inverted'; }
        when ('left')     { return 'right'; }
        when ('inverted') { return 'normal'; }
        when ('right')    { return 'left'; }
        default           { return undef; }
    }
}

# Returns supplied orientation rotated. Similar to Flip.
sub Rotate {
    return undef unless (scalar @_ == 1);
    
    given ($_[0]) {
        when ('normal')   { return 'left'; }
        when ('left')     { return 'inverted'; }
        when ('inverted') { return 'right'; }
        when ('right')    { return 'normal'; }
        default           { return undef; }
    }
}

# Returns the transformation matrix required for xinput for a given orientation.
sub Matrix {
    unless (scalar @_ == 1) {
        return undef;
    }
    given ($_[0]) {
        when ('normal')   { return ' 1  0  0  0  1  0  0  0  1'; }
        when ('left')     { return ' 0 -1  1  1  0  0  0  0  1'; }
        when ('inverted') { return '-1  0  1  0 -1  1  0  0  1'; }
        when ('right')    { return ' 0  1  0 -1  0  1  0  0  1'; }
        default           { return undef; }
    }
}

# Beginning of actual script
my $orientation = GetOrientation($screen);                                      # Acquire the current orientation

exit -1 unless (defined $orientation);

$orientation = Rotate($orientation) if ($opt_r);                                # Apply the desired changes in orientation (flip or rotate) based on parameters)
$orientation = Flip($orientation) if ($opt_f);

my $matrix = Matrix($orientation);                                              # Find out the transformation matrix for the desired orientation.
my $screenstatus = `xrandr --output $screen --rotate $orientation`;             # Rotate the screen
my $penstatus = `xinput set-prop \'$pen\' --type=float \'Coordinate Transformation Matrix\'  $matrix `;                 # Apply matrix to stylus
my $eraserstatus = `xinput set-prop \'$eraser\' --type=float \'Coordinate Transformation Matrix\' $matrix`;             # Apply matrix to eraser
my $tpstatus;

# Disable or enable Trackpoint
if ($orientation eq 'normal') {                                                                                         
    $tpstatus = `xinput --enable \'$trackpoint\'`;
} else {
    $tpstatus = `xinput --disable \'$trackpoint\'`;
}

unless ($screenstatus eq "" && $penstatus eq "" && $eraserstatus eq "" && $tpstatus eq "") {                            # Exit with nonzero status if anything failed
    die("Failed. Output of failed command:\n$screenstatus\n$penstatus\n$eraserstatus\n$tpstatus");
}

exit 0;
