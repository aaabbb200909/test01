#!/usr/bin/perl -w

my $server="localhost";
my $phpfile="tpupp.py";
my $tmpdir="/tmp/tpupp";

###
use strict;
use Getopt::Std;

### Use -d if you want debugglog.
### Use -o if you want to overwirte files there.
my %opts;
$opts{"d"}=0;
$opts{"o"}=0;
getopts ("do" => \%opts);

# Obtain hostname
my $hostname=`hostname`;

sub debuglog ($) {
 my $msg = shift;
 use vars qw(%opts);
 if ($opts{"d"} == 1){
  print $msg;
 }
}
#debuglog ("hello world");


# function to perform http access
use HTTP::Lite;
sub httpget($){
 my $url = shift;
 my $http = new HTTP::Lite;
 $http->request($url) or die "Unable to get document: $!";
 #print "URL:",$url,"\n";
 my $body=$http->body();
 if ($body =~ /TPUPPWARN/) {
  die "Found TPUPPWARN Exiting.\nDetail: $body"
 }
 #print "body:",$body,"\n";
 return $body;
}

sub showdiff($){
 use vars qw(%opts $hostname);
 my $filename=shift;
 print $hostname;

 print "Begin showdiff $filename\n";

 # Create temporary files
 my $tmpfile="$tmpdir/$filename";
 chomp($tmpfile);

 # create temporary dir if it isn't there
 system("tmpdirname=\$(dirname $tmpfile); if [[ ! -d \${tmpdirname} ]]; then mkdir -p \${tmpdirname}; fi");

 # Put Puppet Server files at tempdir:
 open(OUT, ">$tmpfile");
 my $body=httpget("http://$server/$phpfile?filename=$filename&hostname=$hostname");
 print(OUT $body);
 close(OUT);
 #print $tmpfile;
 #print $body; 

 # Obtain diffs:
 if ( -f $filename){
  system("diff $tmpfile $filename");
 }
 else {
  print "$filename isn't there. Skip diffing\n";
 }
 #system("rm -f $tmpfile");

 ## override files
 ## TODO: chmod, chown
 if ($opts{o} == 1){
  print "override $filename";
  open(OUT, ">$filename");
  print(OUT $body);
  close(OUT);
 }
}



#######
# Main
#######


# Get Checksums from Puppet Server:
print "Obtain Checksums from Puppet server:\n";
my $body = httpget("http://$server/$phpfile?hostname=$hostname");
#print $body;

my @l=split("\n", $body);

# Create hash from files on Puppet server
my %filetocksum=();
for my $st (@l) {
 #print $st;
 my @tmp=split(" ", $st);
 my $cksum=$tmp[0];
 my $filename=$tmp[2];
 #print $cksum, $filename;
 $filetocksum{$filename}=$cksum;
}

# Obtain checksums from files on our own server:
print "Obtain our own cksums:\n";
my %localfiletocksum=();
for my $f (keys (%filetocksum)){
 my $tmp;
 if ( -f $f) {
  $tmp=`cksum $f`;
  chomp ($tmp);
 } else {
  $tmp="-1 0 ${f}";
 }
 my @tmp=split(" ", $tmp);
 my $cksum=$tmp[0];
 my $filename=$tmp[2];
 #print $cksum;
 #print $filename;
 $localfiletocksum{$filename}=$cksum;
}


# Start comparing cksums
print "Start comparing cksums:\n";
for my $f (keys (%filetocksum)){
 #print $filetocksum{$f};
 #print $localfiletocksum{$f};
 print "Compare $f 's cksum:\n";
 if ($filetocksum{$f} != $localfiletocksum{$f}) {
  print "  $f is different\n";
  showdiff($f);
 }
 else {
  print "  $f is the same\n";
 }
}

