##################################################
# logcheck.pl
# this simply does a logic check on the walkthroughs.
#

open(A, "c:/games/inform/threediopolis.inform/Source/story.ni") || open(A, "story.ni") || die ("No story.ni");

$blammo = 0;

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

my $logicLine = 0;

while ($a = <A>)
{
  $logicLine++;
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

print "TEST RESULTS:threediopolis-walkthrough,0,$blammo,$success,\n";

print "\nHow unsolved headers should look:";
$cur = ""; for $q (sort keys %loc) { $r = substr($q, 0, 1); if ($r ne $cur) { $cur = $r; print "\n$cur: "; } print "$loc{$q}, "; }
print "\n\nHow solved headers should look:";
$cur = ""; for $q (sort keys %loc) { $r = substr($q, 0, 1); if ($r ne $cur) { $cur = $r; print "\n$cur: "; } print "$q, "; }

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
      if (@ents[$count] =~ /\?/) { print "$q/@ents[$count] is partially solved.\n"; next; }
      if (($q ne @ents[$count]) && ($loc{$q} ne @ents[$count]))
      {
          if (!$printedYet) { print "$_[0]:"; $printedYet = 1; }
		  #print "Q $q ENT COUNT @ents[$count] LOC Q $loc{$q}\n";
		  print " Goofed at line $logicLine, @ents[$count] in logic vs $q/$loc{$q}.\n"; $blammo++; return;
      }
	  $success++;
      $count++;
    }
  }
  #print " SUCCESSFUL!\n";
}