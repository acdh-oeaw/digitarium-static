# bin/bash
rm -rf tempdir && mkdir tempdir && rm dl.tar.gz
rm -rf ./data/editions && mkdir -p ./data/editions
curl -L https://api.github.com/repos/acdh-oeaw/digitarium-data/tarball > dl.tar.gz
tar -xf dl.tar.gz -C tempdir && rm dl.tar.gz
python copy_files.py
echo "delete invalid files"
python delete_invalid_files.py
find ./data/editions/ -type f -name "*.xml"  -print0 | xargs -0 sed -i 's@^.*<TEI xmlns@<TEI xmlns@g'
find ./data/editions/ -type f -name "*.xml"  -print0 | xargs -0 sed -i 's@notBefore="" notAfter=""@@'
find ./data/editions/ -type f -name "*.xml"  -print0 | xargs -0 sed -i 's@.jpg"@.png"@'
find ./data/editions/ -type f -name "*.xml"  -print0 | xargs -0 sed -i 's@url="anno:.*-17@url="anno:17@'
find ./data/editions/ -type f -name "*.xml"  -print0 | xargs -0 sed -i 's@url="anno:.*_17@url="anno:17@'

echo "add ids"
add-attributes -g "./data/editions/*.xml" -b "https://id.acdh.oeaw.ac.at/digitarium"
add-attributes -g "./data/meta/*.xml" -b "https://id.acdh.oeaw.ac.at/digitarium"
rm -rf tempdir