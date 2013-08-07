#!/usr/bin/env perl
# -*- cperl -*-
=head1 NAME

bib2indivBib.pl

=head1 SYNOPSYS

 RCS:$Id$

=head1 DESCRIPTION

=head1 HISTORY

 ORIGIN: created from templateApp.pl version 3.4 by Min-Yen Kan <kanmy@comp.nus.edu.sg>

 RCS:$Log$

=cut

require 5.0;
use Getopt::Std;
use strict 'vars';
# use diagnostics;

### USER customizable section
my $tmpfile .= $0; $tmpfile =~ s/[\.\/]//g;
$tmpfile .= $$ . time;
if ($tmpfile =~ /^([-\@\w.]+)$/) { $tmpfile = $1; }		      # untaint tmpfile variable
$tmpfile = "/tmp/" . $tmpfile;
$0 =~ /([^\/]+)$/; my $progname = $1;
my $outputVersion = "1.0";
### END user customizable section

### Ctrl-C handler
sub quitHandler {
  print STDERR "\n# $progname fatal\t\tReceived a 'SIGINT'\n# $progname - exiting cleanly\n";
  exit;
}

### HELP Sub-procedure
sub Help {
  print STDERR "usage: $progname -h\t\t\t\t[invokes help]\n";
  print STDERR "       $progname -v\t\t\t\t[invokes version]\n";
  print STDERR "       $progname [-q] filename(s)...\n";
  print STDERR "Options:\n";
  print STDERR "\t-q\tQuiet Mode (don't echo license)\n";
  print STDERR "\n";
  print STDERR "Will accept input on STDIN as a single file.\n";
  print STDERR "\n";
}

### VERSION Sub-procedure
sub Version {
  if (system ("perldoc $0")) {
    die "Need \"perldoc\" in PATH to print version information";
  }
  exit;
}

sub License {
  print STDERR "# Copyright 2005 \251 by Min-Yen Kan\n";
}

###
### MAIN program
###

my $cmdLine = $0 . " " . join (" ", @ARGV);
if ($#ARGV == -1) { 		        # invoked with no arguments, possible error in execution? 
  print STDERR "# $progname info\t\tNo arguments detected, waiting for input on command line.\n";  
  print STDERR "# $progname info\t\tIf you need help, stop this program and reinvoke with \"-h\".\n";
}

$SIG{'INT'} = 'quitHandler';
getopts ('hqv');

our ($opt_q, $opt_v, $opt_h);
# use (!defined $opt_X) for options with arguments
if (!$opt_q) { License(); }		# call License, if asked for
if ($opt_v) { Version(); exit(0); }	# call Version, if asked for
if ($opt_h) { Help(); exit (0); }	# call help, if asked for

## standardize input stream (either STDIN on first arg on command line)
my $fh;
my $filename;
if ($filename = shift) {
 NEWFILE:
  if (!(-e $filename)) { die "# $progname crash\t\tFile \"$filename\" doesn't exist"; }
  open (*IF, $filename) || die "# $progname crash\t\tCan't open \"$filename\"";
  $fh = "IF";
} else {
  $filename = "<STDIN>";
  $fh = "STDIN";
}

my $buf;
my $fileID;
while (<$fh>) {
  if (/^\#/) { next; }			# skip comments
  elsif (/^\s+$/) { next; }		# skip blank lines
  else {
    if (/^\@/) {		# Start bibtex
      if ($buf ne "") { 
	writeEntry($buf, $fileID);
	$buf = "";
      }
    } elsif (/anthology\/([^\}]+)/) {
      $fileID = $1;
      print STDERR "# $progname info\t\tProcessing \"$fileID\"\n";
    }
    $buf .= $_;
  }
}
writeEntry($buf, $fileID);

close ($fh);

if ($filename = shift) {
  goto NEWFILE;
}

sub writeEntry {
  my ($buf,$fileID) = @_;
  print "$fileID\n";
  open (OF,">$fileID\.bib") || die "# $progname fatal\t\tCouldn't open \"$fileID.bib\" for writing.\n";
  print OF $buf;
  close (OF);
}

###
### END of main program
###
