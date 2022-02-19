# bin/bash
rm -rf tempdir && mkdir tempdir && rm dl.tar.gz
rm -rf ./data/editions && mkdir -p ./data/editions
curl -H "Authorization: token ${GITLAB_TOKEN}" -L https://api.github.com/repos/dariok/wienerdiarium/tarball > dl.tar.gz
tar -xf dl.tar.gz -C tempdir && rm dl.tar.gz
python copy_files.py
echo "delete invalid files"
python delete_invalid_files.py
find ./data/editions/ -type f -name "*.xml"  -print0 | xargs -0 sed -i 's@^.*<TEI xmlns@<TEI xmlns@g'
find ./data/editions/ -type f -name "*.xml"  -print0 | xargs -0 sed -i 's@notBefore="" notAfter=""@@'

