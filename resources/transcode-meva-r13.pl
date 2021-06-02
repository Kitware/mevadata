#
# Script used to recode DIVA / MEVA videos.
#
#
# SYNOPSIS
#
#    perl -w transcode-meva-r13.pl [options] m n INPUT-PATHS.TXT &> log.txt
#
#
# This script recodes a set of avi files according to the 'r13'
# scheme of crf 25, fast decode, 2s keyframes, yuv420p.
#
# The script supports multithreading by specifying the total number of
# threads ("n" above) and this particular thread instance ("m" above)
# on the command line.
#
# The rough pipeline is:
#
# source.avi -> $PPMDIR/*.ppm -> $OUTDIR/source.r13.avi
#
# The $PPMDIR and $OUTDIR parameters are described below.
#
#
# EXAMPLE
#
#   perl -w transcode-meva-r13.pl -outdir ./r13-dir 1 3 meva.txt &> thread-1.log
#
# ...sets the output directory to r13-dir, declares that this is
# thread #1 of 3 (the others being #0 and #2), allocates the
# files in meva.txt accordingly, and starts processing.
#
#
# CONFIGURATION
#
# Two variables need to be customized to your local situation:
#
# - $FFMPEG should point to an ffmpeg binary
#
# - $PPMDIR is combined with the thread instance parameter to
#   point to a scratch directory with about 60GB of free space.
#   This directory is for the exclusive use of this instance.
#   For example, if $PPMDIR is '/mnt/ram-', and you want to run two
#   instances of the script in parallel, then '/mnt/ram-0' and 'mnt/ram-1'
#   should both exist and both have roughly 60GB of free space.
#
#   (ram drives can be created on e.g. Centos7 via the command
#       sudo mount -t tmpfs -o size=64G tmpfs ram-1
#   ...replace 'ram-1' with your local pathname.)
#
#
# REQUIRED PARAMETERS
#
#  m  - this thread instance, from 0 .. n-1 . (For example, if you are
#       running three instances, set this to 0 for the first instance,
#       1 for the second, and 2 for the third.)
#
#  n  - total number of threads, n >= 1 . (For example, if you have three
#       instances, set this to 3 for all instances.)
#
#  files.txt - a text file with one source avi filepath per line. Filenames
#       must match the original naming schema (or else change the regexps
#       in the extract_clip function.) All instances get the same files.txt.
#
#
# OPTIONAL PARAMETERS
#
#  '-outdir DIR' sets the output directory. Default '.'
#
#  '-restart N' restarts processing at the specified one-based index
#  in the input file, after allocating inputs to threads. For example,
#  if you have 99 files split between three threads, each thread's
#  inputs will be numbered [1..33]. Default 0 (i.e. always start from
#  the beginning.)
#
#  '-ignore' will instruct the script to ignore the output code from
#  the decode-to-frames step. Default: not set; exit with an error if
#  the decode step returns a non-zero error code.
#
#
# LOG FILES
#
# The script generates two per-video logfiles in outdir:
#
# ${clip}-decode.log : this is the combined stdout / stderr from decoding the
# input video into frames.
#
# ${clip}-r13.log : this is the combined stdout / stderr from re-encoding
# the frames into the output video. This log is typically empty.
#
# contact: roddy.collins(at)kitware.com
#


use strict;
use File::Basename;

my $cmdline = join(" ",@ARGV);
dolog("Info: command $cmdline");
my $FFMPEG="/home/collinsr/opt/bin/ffmpeg_static";
my $OUTDIR=".";
my $IGNORE_DECODE_RC=0;
my $RESTART = 0;

while ((scalar(@ARGV)>0) && ($ARGV[0] =~ /^\-/)) {
    my $opt = shift(@ARGV);
    if ($opt eq "-restart") {
	$RESTART = shift(@ARGV);
    } elsif ($opt eq "-outdir") {
	$OUTDIR = shift(@ARGV);
    } elsif ($opt eq "-ignore") {
	$IGNORE_DECODE_RC = 1;
    } else {
	die("Unknown option $opt");
    }
}

die("Usage: $0 [-restart N | -outdir dir | -ignore ] this-thread n-threads files.txt") unless (scalar(@ARGV)==3);
my ($thread, $n_thread, $fn) = @ARGV;
my $PPMDIR="/home/collinsr/work/diva/2020-12-recode/ram-${thread}";

die("No $FFMPEG") unless (-x $FFMPEG);
die("No $PPMDIR") unless (-d $PPMDIR);
die("No $OUTDIR") unless (-d $OUTDIR);



my @files = ();
open(F, $fn) || die("Couldn't read $fn");
my $c = 0;
while (<F>) {
    s/^\s*//;
    s/\s*$//;
    die("No file $_") unless (-s $_);
    if ($c % $n_thread == $thread) {
	push(@files, $_);
    }
    $c++;
}
close F;
my $nf = scalar(@files);
dolog("Info: queued ".scalar(@files)." out of $c files from $fn");
if ($RESTART != 0) {
    dolog("Info: restarting at one-based index $RESTART");
}
my $t0 = time();
my $skip_count = 0;
my $bad_count = 0;
for (my $i=0; $i<$nf;++$i) {
    my $c = $i+1;
    if (($RESTART != 0) && ($c < $RESTART)) {
	dolog("Info: skipping $c / $nf...");
	next;
    }
    my $f = $files[$i];
    my $clip = extract_clip($f);
    die("Couldn't extract clip from $f") unless (defined($clip));
    die("No clip from $f") unless (defined($f));
    dolog($t0, "Info: $c / $nf $clip starting");

    my $t1 = time();
    dolog($t0, $t1, "Info: $c / $nf $clip cleaning $PPMDIR");
    docmd("/bin/rm -f ${PPMDIR}/*.ppm");

    my $okay = 1;
    dolog($t0, $t1, "Info: $c / $nf $clip unpacking");
    {
	my $cmd = "${FFMPEG} -nostdin -v error -i $f -q:v 10 ${PPMDIR}/%05d.ppm > ${OUTDIR}/${clip}-decode.log 2>&1";
	my $rc = system($cmd);
	dolog($t0, $t1, "Info: rc is $rc for unpack $cmd:");
	if ($rc != 0) {
	    ++$bad_count;
	    if ($IGNORE_DECODE_RC == 0) {
		$okay = 0;
		dolog($t0, $t1, "SKIP: $clip");
		++$skip_count;
	    }
	}
	my @g = glob("${PPMDIR}/*.ppm");
	dolog($t0, $t1, "Info: unpacked ".scalar(@g)." ppms");
    }

    if ($okay) {
	dolog($t0, $t1, "Info: $c / $nf $clip r13 recoding");
	docmd("${FFMPEG} -nostdin -y -v error -r 30 -i ${PPMDIR}/%05d.ppm -c:v libx264 -tune fastdecode -g 60 -crf 25 -pix_fmt yuv420p ${OUTDIR}/${clip}.r13.avi > ${OUTDIR}/${clip}-r13.log 2>&1");
    }
}
dolog($t0, "Info: all done; $bad_count had decode errors; $skip_count skipped");
exit 0;

##
##
##

sub dolog
{
    my $lt = time();
    my $prefix = scalar(localtime());
    while (scalar(@_)>1) {
	my $base_t = shift(@_);
	my $dt = $lt - $base_t;
	$prefix .= " $dt";
    }
    my $msg = shift(@_);
    print STDERR $prefix," $msg\n";
}

sub docmd
{
    my ($cmd) = @_;
    system($cmd) == 0 || die("Couldn't $cmd:$!");
}

sub extract_clip
{
  my ($t) = @_;
  my $d = '\d\d\d\d\-\d\d\-\d\d';
  my $r = '\d\d\-\d\d\-\d\d';
  # recoded clip
  if ($t =~ /($d\.$r\.$r\.\w+\.G\w+\.r\d+)/) {
    return $1;
  }
  # source clip
  if ($t =~ /($d\.$r\.$r\.\w+\.G\w+)/) {
    return $1;
  }
  return undef;
}
