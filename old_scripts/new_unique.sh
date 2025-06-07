# dirA="/mnt/e/desktop/backup_exports/savvy_2021/AppDomain-com.keepsafe.KeepSafe/Documents/copy"
dirA="/mnt/c/DCIMs/AppDomain-com.keepsafe.KeepSafe/Documents/com.getkeepsafe.userMedia"
dirB="/mnt/c/DCIMs/DCIM_2021"

echo "Generate dirA's hashes"
# Get SHA256 hashes for all files in dirA
cd "$dirA"
find . -type f | parallel -j24 sha256sum {} | sort > /tmp/hashesA.txt

echo "Generate dirB's hashes"
# Get SHA256 hashes for all files in dirB
cd "$dirB"
find . -type f | parallel -j24 sha256sum {} | sort > /tmp/hashesB.txt

echo "Extract the hashes"
# Extract just the hashes (ignore file names)
cut -d ' ' -f1 /tmp/hashesA.txt > /tmp/hashesA_only.txt
cut -d ' ' -f1 /tmp/hashesB.txt > /tmp/hashesB_only.txt

echo "Find hashes unique to A"
# Find hashes unique to A
comm -23 /tmp/hashesA_only.txt /tmp/hashesB_only.txt > /tmp/unique_hashesA.txt

echo "Find hashes unique to B"
# Find hashes unique to B
comm -13 /tmp/hashesA_only.txt /tmp/hashesB_only.txt > /tmp/unique_hashesB.txt

echo "Files unique by content in dirA:"
grep -Ff /tmp/unique_hashesA.txt /tmp/hashesA.txt

echo "Files unique by content in dirB:"
grep -Ff /tmp/unique_hashesB.txt /tmp/hashesB.txt

# Run this, then manually copy DirA hash from output txt into separate, then use WSL to cut to get only filenames, then copy, then convert