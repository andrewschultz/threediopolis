##################################################
# logcheck.pl
# this simply does a logic check on the walkthroughs.
#

use strict;
use warnings;

my $success = 0;

###################options
my $try3d = 1;
my $try4d = 1;
my $showAll = 0;
my $permissible = 0; # how many squares can we walk out?

###################variables
my %loc;
my %valList;
my %tab;
my %friends;
my $count = 0;
my $curTable; ###?? how does this differ from curTab?
my $curTab;
my $lastTab;
my $blammo = 0;
my $thisRound = 0;
my $currentSummary = "";
my $inSummary = "";
my $lastTableStart;
my @locs;
my $q;

while ($count <= $#ARGV)
{
  $a = $ARGV[$count];
  for ($a)
  {
    /3d/ && do { $try3d = 1; $try4d = 0; $count++; next; };
    /4d/ && do { $try3d = 0; $try4d = 1; $count++; next; };
    /^-?a/ && do { $showAll = 1; $count++; next; };
    /^-?p/ && do { $permissible = $ARGV[$count+1]; $count+= 2; next; };
    /opo/ && do { $try3d = 1; $try4d = 1; $count++; next; };
	usage();
  }
}

if ($try3d) { walk3d(); }
if ($try4d) { walk4d(); }

sub walk3d
{
my $inTable = 0;

my $tableName = "";
my $mappedTo;

my @curAry;

open(A, "c:/games/inform/threediopolis.inform/Source/story.ni") || open(A, "story.ni") || die ("No story.ni");

while ($a = <A>)
{
  if ($a =~ /^table of (findies|scenery) \[/)
  {
    $mappedTo = $a; chomp($mappedTo); $mappedTo =~ s/ \[.*//g;
    $inTable = 1; next;
  }
  if (($inTable) && ($a !~ /[a-z]/i))
  {
    $valList{$tableName} = join(",", @curAry);
  }

  if ($inTable)
  {
    if ($a =~ /\(text\)/) { next; }
    if ($a !~ /[a-z]/) { $inTable = 0; next; }
    $b = lc($a); chomp($b); $b =~ s/^\"//g; $b =~ s/\".*//g;
	push(@curAry, $b);
	$tab{$b} = $mappedTo;
	if (($a =~ /\tchums\t/)) { $friends{$b} = 1; }
    $loc{$b} = myloc($b);
	print "$b -> " . myloc($b) . " ($mappedTo)\n";
  }
}

close(A);

open(A, "logic.txt");

while ($a = <A>)
{
  if ($a =~ /^====table of/) { $curTable = $a; chomp($curTable); $curTable =~ s/^=+//g; }
  if ($a =~ /^([desnuw3-8]|friends):/i)
  {
    chomp($a);
	$a =~ s/ *\([^\)]*\) *//g;
	verify(lc($a)); }
}

close(A);

if ($blammo == 0) { print "ALL HEADERS PROCESSED CORRECTLY!\n"; }
else
{
print "# of errors found in logic document headers: $blammo.\n";
}

print "TEST RESULTS:threediopolis-walkthrough,$permissible,$blammo,$success,\n";

if ($showAll)
{
my $q;
my $r;
print "\nHow unsolved headers should look:";
my $cur = "";

for $q (sort keys %loc) { $r = substr($q, 0, 1); if ($r ne $cur) { $cur = $r; print "\n$cur: "; } print "$loc{$q}, "; }
print "\n\nHow solved headers should look:";
$cur = "";
for $q (sort keys %loc) { $r = substr($q, 0, 1); if ($r ne $cur) { $cur = $r; print "\n$cur: "; } print "$q, "; }

print "\n";
}

print "\n======finished 3d check\n\n";
}

sub walk4d
{
$blammo = 0;

open(A, "c:/games/inform/fourdiopolis.inform/source/fourdiopolis-logic.txt") || die ("No 4dop logic file.");

while ($a = <A>)
{
  if ($a =~ /==end explained walkthrough/)
  {
    if ($thisRound) { print "$thisRound errors found in $curTab.\n"; }
	elsif ($lastTab) { print "No errors found in $curTab.\n"; }
	next;
  }
  if ($a =~ /====[a-z]/) { setTable($a); next; }

  if (($a =~ /,/) && ($a !~ /\./))
  {
    $inSummary = 1;
    chomp($a);
	$a =~ s/\([^\)]*\)//g;
	$a =~ s/[ \*]//g;
	if ($currentSummary) { $currentSummary = "$currentSummary,$a"; } else { $currentSummary = $a; $lastTableStart = $.}
	my @check = split(/,/, $a); if ($#check != 4) { print "WARNING need 5 elements per line at line $.: $a\n"; $blammo++; }
	next;
  }
  if ($inSummary)
  {
    #print "$currentSummary\n";
    verify4($currentSummary);
	$currentSummary = "";
	$inSummary = 0;
  }
}

close(A);

print "TEST RESULTS:fourdiopolis-walkthrough,0,$blammo,$success,\n";

if ($blammo == 0) { print "ALL HEADERS PROCESSED CORRECTLY!\n"; }
else
{
print "# of errors found in logic document headers: $blammo.\n";
}

}

############################################
#4dop function setTable

sub setTable
{
  my $tabname = $_[0]; $tabname =~ s/=//g; chomp($tabname);
  my $foundTable = 0;
  my $everFound = 0;
  %loc = ();
  open(B, "c:/games/inform/fourdiopolis.inform/source/story.ni");
  @locs = ();
  while ($b = <B>)
  {
    if (($b =~ /^table of $tabname.*\[/i) && ($b !~ /\t\"/))
	{
	  $everFound = 1;
	  $foundTable = 1;
	  $lastTab = $curTab;
	  $curTab = $b; chomp($curTab); $curTab =~ s/ *\[.*//g;
	  <B>;
	  next;
	}
	if ($foundTable)
	{
	  if ($b !~ /[a-z]/) { $foundTable = 0; if ($thisRound) { print "$thisRound errors found in $lastTab.\n"; } elsif ($lastTab) { print "No errors found in $lastTab.\n"; next; } $thisRound = 0; }
	  my $abr = $b; chomp($abr); $abr =~ s/^\"//g; $abr =~ s/\".*//g;
	  push (@locs, $abr);
	}
  }
  if (!$everFound) { print ("$tabname was not found. Check your logic file and/or source.\n"); } else
  {
    #print "$tabname processed ok: @locs.\n";
  }
  close(B);
}

############################################################
#4dop function verify4

sub verify4
{
  my @cs = split(/,/, $currentSummary);

  my $lineErr = 0;
  for (0..$#cs)
  {
    use integer;
    my $curLine = $lastTableStart + $_ / 5;
	no integer;
    my $temp = lc($cs[$_]);
	my $q = myloc($locs[$_]);
	if (($temp eq $locs[$_]) || (lc($temp) eq lc($q))) { next; } else { print "Mismatch: $temp != $q and $temp != $locs[$_] at line $curLine in $curTab.\n"; $blammo++; $thisRound++; $lineErr = 1; last; }
  }
  if (!$lineErr)
  {
    $success++; #print "$currentSummary ok\n";
  }
  my $index = substr($_[0], 0, 1);
  my $printedYet = 0;

  my $splits = $_[0]; $splits =~ s/.*: *//g;
  my @ents = split(/, */, $splits);

  my $count = 0;

  for $q (sort keys %loc)
  {
    if ($q =~ /^$index/i)
    {
      if ($ents[$count] =~ /\?/) { print "$q/$ents[$count] is partially solved.\n"; next; }
      if (($q ne $ents[$count]) && ($loc{$q} ne $ents[$count]))
      {
          if (!$printedYet) { print "$_[0]:"; $printedYet = 1; }
		  print " Goofed at $ents[$count] in logic vs $q/$loc{$q}.\n"; $blammo++; return;
      }
      $count++;
    }
  }
  #print " SUCCESSFUL!\n";
}

############################################################################
#myloc, for both 4d and 3d
#

sub myloc
{
my @c = split(//, lc($_[0]));

my $up = 0;
my $east = 0;
my $north = 0;

for (@c)
{
  if ($_ eq "u") { $up++; }
  if ($_ eq "d") { $up--; }
  if ($_ eq "e") { $east++; }
  if ($_ eq "w") { $east--; }
  if ($_ eq "n") { $north++; }
  if ($_ eq "s") { $north--; }
  if ($_ eq "h") { $north += 2; $east += 2; $up += 2; }
  if ($_ eq "i") { $north -= 2; $east += 2; $up -= 2; }
  if ($_ eq "j") { $north += 2; $east -= 2; $up -= 2; }
  if ($_ eq "k") { $north -= 2; $east -= 2; $up += 2; }
}

if ($_[0] =~ /[hijk]/)
{
  return ln($up) . ln($north) . ln($east);
}

$up += 4;
$north += 4;
$east += 4;

return 100 * $up + 10 * $north + $east;

}

sub ln
{
  if ($_[0] >= 0) { return $_[0]; }
  return chr(64 - $_[0]);
}

sub verify
{
  my $index = $_[0]; $index =~ s/:.*//g;
  my $printedYet = 0;

  my $splits = $_[0]; $splits =~ s/.*: *//g;
  my @ents = split(/, */, $splits); for (@ents) { $_ =~ s/ //g; }

  my $count = 0;

  print "Verifying $_[0], with $index, for $curTable\n";
  for $q (sort keys %loc)
  {
    #print "$q: $friends{$q}\n";
    if ($tab{$q} ne $curTable) { next; }
    if (($q =~ /^$index/i) || ((lc($index) eq "friends") && ($friends{lc($q)}) || (!$friends{lc($q)} && $index =~ /[0-9]/)))
    {
	  if (($index =~ /[0-9]/) && (length($q) != $index)) { next; }
	  #print "Looking at $q\n";
      if ($ents[$count] =~ /\?/) { print "$q/$ents[$count] is partially solved.\n"; next; }
      if (($q ne $ents[$count]) && ($loc{$q} ne $ents[$count]))
      {
          if (!$printedYet) { print "$_[0]:"; $printedYet = 1; }
		  #print "Q $q ENT COUNT @ents[$count] LOC Q $loc{$q}\n";
		  print " Goofed at line $., $ents[$count] in logic vs $q/$loc{$q}.\n"; $blammo++; return;
      }
	  $success++;
      $count++;
    }
  }
  #print " SUCCESSFUL!\n";
}

sub usage
{
print<<EOT;
USAGE
3d = run 3d
4d = run 4d
opo = run both (default)
EOT
exit;
}