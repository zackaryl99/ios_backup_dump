#!/usr/bin/perl
use strict;
use warnings;
use File::Find;
use File::Copy;
use File::Basename;
use File::Path qw(make_path);

# Source and destination directories
my $source_dir = shift or die "Usage: $0 SOURCE_DIR DEST_DIR\n";
my $dest_dir   = shift or die "Usage: $0 SOURCE_DIR DEST_DIR\n";

# Ensure the destination directory exists
make_path($dest_dir) unless -d $dest_dir;

# Find and copy all files
find(
    sub {
        return unless -f $_;  # Only files
        my $src_path = $File::Find::name;
        my $base_name = basename($_);

        # Create a unique name if file already exists
        my $dest_path = "$dest_dir/$base_name";
        my $count = 1;
        while (-e $dest_path) {
            $dest_path = "$dest_dir/dup$count.$base_name";
            $count++;
        }

        copy($src_path, $dest_path) or warn "Failed to copy $src_path: $!";
    },
    $source_dir
);
