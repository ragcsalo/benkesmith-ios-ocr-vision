var exec = require('cordova/exec');

exports.recognizeText = function(base64Image, success, error) {
    exec(success, error, "IOSOCRVision", "recognizeText", [base64Image]);
};
