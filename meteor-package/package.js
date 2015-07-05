Package.describe({
    name: "new3rs:jssgf",
    summary: "jssgf - SGF parser"
});

Package.onUse(function (api) {
    api.addFiles('jssgf.js');
    api.export('jssgf');
});
