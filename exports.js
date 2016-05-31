
if (typeof exports !== 'undefined') {
    if (typeof module !== 'undefined' && module.exports) {
        exports = module.exports = jssgf;
    } else {
        exports.jsgf = jssgf;
    }
} else {
    this.jssgf = jssgf;
}
