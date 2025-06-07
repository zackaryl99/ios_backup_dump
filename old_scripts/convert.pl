my $data_dir = "/mnt/e/Desktop/uniq";

my @pngs = ();
my @videos = ();
my @heic = ();
my @gifs = ();
my @neither = ();

my $just_name = "";

opendir(my $dh, $data_dir) or die "Can't open $data_dir: $!";
foreach my $file (readdir($dh)) {
    next if $file =~ /^\.\.?$/;  # Skip . and ..
    next if $file =~ /\.pl$/; 

    # Reset playground
    if ($ARGV[0]){
        $_ = $file;
        s/\..*$//g;
        `mv $file $_`;
        next;
    }

    open(my $fh, '<', "$data_dir/$file") or die "Can't open $file: $!";
    
    while (my $line = <$fh>) {

        # Video
        if ($file =~ "video") {
            push @videos, "$data_dir/$file";
            last;
        }

        # GIF
        if ($file =~ "gif") {
            push @gifs, "$data_dir/$file";
            last;
        }

        # PNG
        if ($line =~ "PNG") {
            push @pngs, "$data_dir/$file";
            last;
        }

        # HEIC
        if ($line =~ "ftypheic") {
            push @heic, "$data_dir/$file";
            last;
        }
        
        # Neither
        push @neither, "$data_dir/$file";
        last;
    }

    close($fh);
}
closedir($dh);

# Reset playground
if ($ARGV[0]){
    exit;
}

print "Video: ";
print scalar(@videos);
print "\tPNGs: ";
print scalar(@pngs);
print "\tGIFs: ";
print scalar(@gifs);
print "\tHEIC: ";
print scalar(@heic);
print "\tNone of the above (jpg): ";
print scalar(@neither);
print "\n";

foreach(@videos){
    `mv $_ $_.mov`;
}

foreach(@pngs){
    `mv $_ $_.png`;
}

foreach(@gifs){
    `mv $_ $_.gif`;
}

foreach(@heic){
    `mv $_ $_.heic`;
    # `heif-convert $_ $_.png`;
}

foreach(@neither){
    `mv $_ $_.jpg`;
}

`ls *.heic | parallel -j 12 'heif-convert {} {.}.png'`;