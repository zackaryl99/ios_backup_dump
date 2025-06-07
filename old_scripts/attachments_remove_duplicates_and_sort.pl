# Zackary Savoie 2025
# About: 
#   This script will:
#       -Remove .plist and .plugginPayloadAttachment files
#       -Convert .heif files to .jpg
#       -Sort data into photos, video (and live photos), contacts, documents and other
# Notes:
#   Run "attachment_extract.pl" first to get all data into one directory
# Bugs:
#   Files with quotes (' or ") in their names cause some bugs, but not failure

my $data_dir = "/mnt/e/Desktop/extracted_attachments2023";
chdir($data_dir) or die "chdir failed: $!";


# Store lists of files which are in this category
my @photos = ();
my @videos = ();
my @documents = ();
my @contacts = ();
my @others = ();


# Used for tracking duplicates and live photo isolation
my %counts = {};


# Pre-process (and count deletions)
my $old_count = 0;

# Remove .pluginPayloadAttachment
$old_count = `find . -maxdepth 1 -type f | wc -l`;
`rm *.pluginPayloadAttachment`;
$old_count -= `find . -maxdepth 1 -type f | wc -l`;
print "Deleted $old_count .pluginPayloadAttachment files\n";

# Remove .plist
$old_count = `find . -maxdepth 1 -type f | wc -l`;
`rm *.plist`;
$old_count -= `find . -maxdepth 1 -type f | wc -l`;
print "Deleted $old_count .plist files\n";

# Convert .heic and .HEIC to .jpg and delete original
$old_count = (split("\n'", `count=0; for f in *.heic *.HEIC; do [ -e "\$f" ] && heif-convert --quiet "\$f" "converted_\${f%.*}.jpg" && rm "\$f" && count=\$((count+1)); done; echo "\$count"`))[-1];
chomp($old_count);
print "Converted $old_count images\n";


# Build file path lists of different kinds 
opendir(my $dh, $data_dir) or die "Can't open $data_dir: $!";
my $name = "";
foreach my $file (readdir($dh)) {
    next if $file =~ /^\.\.?$/;  # Skip . and ..
    next if $file =~ /\.pl$/; 

    # Store counts of file names
    $name = $file;
    $name =~ s/\.[^.]+$//; # Strip off extension
    $name =~ s/^converted_//; # Strip off added "converted_" flag

    # Keep track of files with same names (will be used to isolate live photos later)
    if (exists($counts{$name})){
        $counts{$name}{"count"} += 1;
        push @{$counts{$name}{"paths"}}, $file;
    } else {
        $counts{$name} = {count => 1, paths => [$file]};
        # print scalar(@{$counts{$name}{"paths"}});
        # print "\n";
    }

    # Video
    if ($file =~ /\.mov$/i || $file =~ /\.mp4$/i) {
        push @videos, "$file";
        next;
    }

    # Photo
    if ($file =~ /\.heic$/i || $file =~ /\.jpeg$/i || $file =~ /\.jpg$/i || $file =~ /\.png$/i || $file =~ /\.gif$/i) {
        push @photos, "$file";
        next;
    }

    # Documents
    if ($file =~ /\.docx$/i || $file =~ /\.pdf$/i || $file =~ /\.xlsx$/i) {
        push @documents, "$file";
        next;
    }

    # Contacts
    if ($file =~ /\.vcf$/i) {
        push @contacts, "$file";
        next;
    }
    
    # Others
    push @others, "$file";

}

closedir($dh);


# Print stats
print "Videos: ";
print scalar(@videos);
print "\tPhotos: ";
print scalar(@photos);
print "\tDocuments: ";
print scalar(@documents);
print "\tContacts: ";
print scalar(@contacts);
print "\tOthers: ";
print scalar(@others);
print "\n";


# Debug
# foreach my $filename (keys %counts){
#     if ($counts{$filename}{"count"} == 2){
#         print $counts{$filename}{"count"}.":\n";
#         foreach(@{$counts{$filename}{"paths"}}){
#             print $_." ";
#         }
#         print "\n\n";
#     }
# }
# exit;


# Move into folders
`mkdir videos; mkdir photos; mkdir documents; mkdir contacts; mkdir others; mkdir videos/live_photos;`;

foreach(@videos){
    `mv '$_' videos/'$_'`;
}

foreach(@photos){
    `mv '$_' photos/'$_'`;
}

foreach(@documents){
    `mv '$_' documents/'$_'`;
}

foreach(@contacts){
    `mv '$_' contacts/'$_'`;
}

foreach(@others){
    `mv '$_' others/'$_'`;
}


# Move live photos
# Criteria to be a live photo: At least one .MOV and one IMAGE with same name, AND video is less than 7 seconds
my $count = 0;
foreach my $filename (keys %counts){
    if ($counts{$filename}{"count"} > 1){ # At least two with same name
        foreach my $path (@{$counts{$filename}{"paths"}}){
            if ((grep { $_ eq ($path) } @videos)){ # Found the one which is a video
                if (`ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "videos/$path"` < 5.1) { # It's less than 5.1 seconds (arbitrary)
                    # print "Move: videos/$path to videos/live_photos/$path\n\n";
                    `mv videos/'$path' videos/live_photos/'$path'`;
                    $count += 1;
                    last;
                }
            }
            # print "Left: $path\n"
        }
    }
}

print "Identified $count videos as live photots\n";
print "Done!\n\n";