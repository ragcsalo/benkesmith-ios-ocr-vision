var exec = require('cordova/exec');

exports.recognizeText = function(base64Image, successCallback, errorCallback) {
    exec(successCallback, errorCallback, "IOSOCRVision", "recognizeText", [base64Image]);
};
