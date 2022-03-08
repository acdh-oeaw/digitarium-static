var path = require("path");
var fs = require("fs");
var lunr = require("lunr");
var cheerio = require("cheerio");


// Change these constants to suit your needs
const HTML_FOLDER = "html";  // folder with your HTML files
// Valid search fields: "title", "description", "keywords", "body"
const SEARCH_FIELDS = ["title", "body"];
const EXCLUDE_FILES = [
    "search.html",
    "lunr-search.html",
    "imprint.html",
    "index.html",
    "toc.html",
    "about.html"
];
const MAX_PREVIEW_CHARS = 275;  // Number of characters to show for a given search result
const OUTPUT_INDEX = "./html/js/lunr_index.js";  // Index file


function isHtml(filename) {
    lower = filename.toLowerCase();
    return (lower.endsWith(".htm") || lower.endsWith(".html"));
}


function findHtml(folder) {
    if (!fs.existsSync(folder)) {
        console.log("Could not find folder: ", folder);
        return;
    }

    var files = fs.readdirSync(folder);
    var htmls = [];
    for (var i = 0; i < files.length; i++) {
        var filename = path.join(folder, files[i]);
        var stat = fs.lstatSync(filename);
        if (stat.isDirectory()) {
            var recursed = findHtml(filename);
            for (var j = 0; j < recursed.length; j++) {
                recursed[j] = path.join(files[i], recursed[j]).replace(/\\/g, "/");
            }
            htmls.push.apply(htmls, recursed);
        }
        else if (isHtml(filename) && !EXCLUDE_FILES.includes(files[i])) {
            htmls.push(files[i]);
        };
    };
    return htmls;
};


function readHtml(root, file, fileId) {
    var filename = path.join(root, file);
    var txt = fs.readFileSync(filename).toString();
    var $ = cheerio.load(txt);
    var title = $("title").text();
    if (typeof title == 'undefined') title = file;
    var description = $("meta[name=description]").attr("content");
    if (typeof description == 'undefined') description = "";
    var keywords = $("meta[name=keywords]").attr("content");
    if (typeof keywords == 'undefined') keywords = "";
    var body = $("#indexme").text()
    if (typeof body == 'undefined') body = "";
    var data = {
        "id": fileId,
        "link": file,
        "t": title,
        "b": body
    }
    return data;
}


function buildIndex(docs) {
    var idx = lunr(function () {
        this.ref('id');
        for (var i = 0; i < SEARCH_FIELDS.length; i++) { 
            this.field(SEARCH_FIELDS[i].slice(0, 1));
        } 
        docs.forEach(function (doc) {
                this.add(doc);
            }, this);
        });
    return idx;
}


function buildPreviews(docs) {
    var result = {};
    for (var i = 0; i < docs.length; i++) {
        var doc = docs[i];
        var preview = doc["t"];
        if (preview == "") preview = doc["b"];
        if (preview.length > MAX_PREVIEW_CHARS)
            preview = preview.slice(0, MAX_PREVIEW_CHARS) + " ...";
        result[doc["id"]] = {
            "t": doc["t"],
            "p": preview,
            "l": doc["link"]
        }
    }
    return result;
}


function main() {
    files = findHtml(HTML_FOLDER);
    var docs = [];
    var startDate = new Date();
    console.log("Building index for these files:");
    console.log(`Starting at ${startDate.toTimeString()}`);
    for (var i = 0; i < files.length; i++) {
        console.log("    " + files[i]);
        docs.push(readHtml(HTML_FOLDER, files[i], i));
    }
    var idx = buildIndex(docs);
    var previews = buildPreviews(docs);
    var js = "const LUNR_DATA = " + JSON.stringify(idx) + ";\n" + 
             "const PREVIEW_LOOKUP = " + JSON.stringify(previews) + ";";
    fs.writeFile(OUTPUT_INDEX, js, function(err) {
        if(err) {
            return console.log(err);
        }
        console.log("Index saved as " + OUTPUT_INDEX);
    });
    var endDate = new Date()
    console.log(`Started at ${startDate.toTimeString()}`);
    console.log(`Finished at ${endDate.toTimeString()}`); 
}

main();