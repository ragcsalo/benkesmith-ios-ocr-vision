# iOS OCR Vision Plugin

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**benkesmith-ios-ocr-vision** is a Cordova plugin that leverages Apple's native Vision framework for on‑device Optical Character Recognition (OCR). This plugin processes a Base64‑encoded image, recognizes any text in the image, and returns the detected text to your Cordova application.

## Overview

The plugin uses the Vision framework (available in iOS 13 and later) to perform OCR entirely offline. This ensures lower latency and enhanced privacy by processing images locally on the device. The plugin is written in Swift and includes a simple JavaScript interface for seamless integration in your Cordova app.

## Features

- **Offline OCR:** Utilizes the native Vision framework for fast, on‑device text recognition.
- **Base64 Image Support:** Accepts images encoded as Base64 strings.
- **Simple API:** A straightforward JavaScript API to trigger OCR and receive recognized text.
- **iOS 13+:** Requires iOS 13 or later due to reliance on the Vision API.

## Requirements

- **iOS:** 13.0 or higher
- **Cordova:** 9.0.0 or later
- **Swift:** 5

## Installation

Install the plugin using the Cordova CLI:

```bash
cordova plugin add https://github.com/ragcsalo/benkesmith-ios-ocr-vision
