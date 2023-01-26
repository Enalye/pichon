/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module common.locale;

import std.file, std.path;
import atelier;
import common.config;

private {
    string _localeFilePath, _localeKey;
    string[string] _localizations;
}

string getLocale() {
    return _localeFilePath;
}

string getLocaleKey() {
    return _localeKey;
}

void setLocale(string filePath) {
    if (!exists(filePath))
        return;
    _localeFilePath = filePath;
    _localeKey = baseName(stripExtension(filePath));

    JSONValue json = parseJSON(readText(_localeFilePath));
    foreach (string key, JSONValue value; json) {
        _localizations[key] = value.str;
    }

    sendCustomEvent("locale");

    saveConfig();
}

string getText(string key) {
    auto value = key in _localizations;
    if (value is null)
        return key;
    return *value;
}
