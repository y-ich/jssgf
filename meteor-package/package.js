Package.describe({
    summary: "jssgf - SGF parser"
});

Package.onUse(function (api) {
    api.addFiles('jssgf.js');
    api.export('jssgf');
});
