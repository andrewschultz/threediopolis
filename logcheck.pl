open(A, "c:/games/inform/threediopolis.inform/Source/story.ni") || open(A, "story.ni") || die ("No story.ni");

$blammo = 0;

while ($a = <A>)
{
  if ($a =~ /^table of scenery \[/)
  {
    $inTable = 1; next;
  }

  if ($inTable)
  {
    if ($a =~ /\(text\)/) { next; }
    if ($a !~ /[a-z]/) { $inTable = 0; next; }
    $b = $a; chomp($b); $b =~ s/^\"//g; $b =~ s/\".*//g;
    $loc{$b} = myloc($b);
  }
}


close(A);

open(A, "logic.txt");

while ($a = <A>)
{
  if ($a =~ /^[desnuw]:/i)
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
$go{"s"} = -10;
$go{"n"} = 10;
$go{"e"} = 1;
$go{"w"} = -1;
$go{"u"} = 100;
$go{"d"} = -100;

my $temp = 444;

@c = split(//, $_[0]);

for (@c)
{
  $temp += $go{$_};
}

return $temp;
}

sub verify
{
  my $index = substr($_[0], 0, 1);
  my $printedYet = 0;

  my $splits = $_[0]; $splits =~ s/.*: *//g;
  my @ents = split(/, */, $splits);

  my $count = 0;

  for $q (sort keys %loc)
  {
    if ($q =~ /^$index/i)
    {
      if (@ents[$count] =~ /\?/) { print "$q/@ents[$count] is partially solved.\n"; next; }
      if (($q ne @ents[$count]) && ($loc{$q} ne @ents[$count]))
      {
          if (!$printedYet) { print "$_[0]:"; $printedYet = 1; }
		  print " Goofed at @ents[$count] in logic vs $q/$loc{$q}.\n"; $blammo++; return;
      }
	  $success++;
      $count++;
    }
  }
  #print " SUCCESSFUL!\n";
}