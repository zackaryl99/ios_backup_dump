# my $source_path = "/mnt/e/desktop/backup_exports/savvy_2021/AppDomain-com.keepsafe.KeepSafe/Documents/copy/";
my $source_path = "/mnt/c/DCIMs/AppDomain-com.keepsafe.KeepSafe/Documents/com.getkeepsafe.userMedia";
my $destination_path = "/mnt/e/desktop/uniq";
my $file_list = "/mnt/e/desktop/uniq/file_list.txt";

# Read file list into array
open my $fh, '<', $file_list or die "Can't open $file_list: $!";
my @files = <$fh>;
chomp @files;
close $fh;

# Copy
foreach (@files) {
    `cp $source_path/$_ $destination_path/$_`;
}