echo "build index"
ant -f ./static-search/build.xml -DssConfigFile=${PWD}/ss_config.xml
rm ./html/static-search/staticSearch_report.html