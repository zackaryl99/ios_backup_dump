my $vault_dir = "/mnt/e/desktop/backup_exports/savvy_2021/AppDomain-com.keepsafe.KeepSafe/Documents/copy";
my $dcim_dir = "/mnt/c/DCIMs/DCIM_2021";
my @unique = ();

opendir(my $dh, $vault_dir) or die "Can't open $vault_dir: $!";
my @vault_fs = grep { !/^\.\.?$/ } readdir($dh);  # Skip . and ..
closedir($dh);

opendir(my $dh, $dcim_dir) or die "Can't open $dcim_dir: $!";
my @dcim_fs = grep { !/^\.\.?$/ } readdir($dh);  # Skip . and ..
closedir($dh);

my $match = 0;
my $comp_count = 0;

foreach my $vault_f (@vault_fs) {
    next if $vault_f =~ /^\.\.?$/;  # Skip . and ..
    next if $vault_f =~ /\.pl$/; 

    foreach my $dcim_f (@dcim_fs) {
        next if $dcim_f =~ /^\.\.?$/;  # Skip . and ..
        next if $dcim_f =~ /\.pl$/; 

        $comp_count += 1;

        if (!(`cmp $dcim_dir/$dcim_f $vault_dir/$vault_f`)){ # They're the same
            $match = $dcim_f;
            last;
        }
    }

    if ($match){
        @dcim_fs = grep { $_ ne $match } @dcim_fs;
        print "Match!\t$comp_count\n";
    } else {
        push @unique, "$vault_f";
        print "NO Match!\t$comp_count\t$vault_dir/$vault_f\n";
    }

    $match = 0;
    if ($comp_count > 25000){
        last;
    }
}

foreach(@unique){
    `cp $vault_dir/$_ /mnt/e/Desktop/uniq/$_`;
}