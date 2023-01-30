/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module common.config;

import std.file, std.path, std.json;
import atelier;
import common.locale;

enum EXE_PATH = "bin\\realesrgan-ncnn-vulkan-20220424-windows";

enum EXE_FILENAME = "realesrgan-ncnn-vulkan.exe";

enum EXE_MODELS_FOLDER = "models";

private {
    bool _isConfigFilePathConfigured;
    string _configFilePath = "config.json";
    bool _isDevMode = true;
    string _exeFileName, _exePath, _modelsFolder, _inputPath, _outputPath,
        _currentFile, _currentModel;
    int _themeId = 0, _scale = 4;
}

string getExePath() {
    return buildNormalizedPath(_exePath, _exeFileName);
}

string getBasePath() {
    if (_isDevMode) {
        return getcwd();
    }
    else {
        return dirName(thisExePath());
    }
}

int getThemeId() {
    return _themeId;
}

void setThemeId(int themeId) {
    _themeId = themeId;
    sendCustomEvent("theme");
    saveConfig();
}

string getCurrentModel() {
    return _currentModel;
}

void setCurrentModel(string model) {
    _currentModel = model;
    saveConfig();
}

string getCurrentFile() {
    return _currentFile;
}

void setCurrentFile(string path) {
    _currentFile = path;
    saveConfig();
}

string getOutputPath() {
    if (_outputPath.length)
        return _outputPath;

    auto path = dirName(_currentFile);

    if (path.length)
        return path;

    return _exePath;
}

bool hasOutputPath() {
    return _outputPath.length > 0;
}

void setOutputPath(string path) {
    _outputPath = path;
    saveConfig();
}

int getScale() {
    return _scale;
}

void setScale(int scale) {
    _scale = scale;
    saveConfig();
}

/// Load config file
void loadConfig() {
    if (!_isConfigFilePathConfigured) {
        _isConfigFilePathConfigured = true;
        _configFilePath = buildNormalizedPath(getBasePath(), _configFilePath);
    }
    if (!exists(_configFilePath)) {
        if (!_exePath.length) {
            _exePath = buildNormalizedPath(getBasePath(), EXE_FILENAME);
        }
        if (!_modelsFolder.length) {
            _modelsFolder = EXE_MODELS_FOLDER;
        }
        saveConfig();
        if (!exists(_configFilePath))
            return;
    }
    JSONValue json = parseJSON(readText(_configFilePath));
    _exeFileName = getJsonStr(json, "app", EXE_FILENAME);
    _exePath = buildNormalizedPath(getJsonStr(json, "path", _isDevMode ? EXE_PATH : ""));
    _modelsFolder = getJsonStr(json, "models", EXE_MODELS_FOLDER);
    _inputPath = getJsonStr(json, "input", "");
    _outputPath = getJsonStr(json, "output", "");
    _currentFile = getJsonStr(json, "currentFile", "");
    _currentModel = getJsonStr(json, "currentModel", "");
    _scale = clamp(getJsonInt(json, "scale", 4), 2, 4);
    _themeId = getJsonInt(json, "themeId", 0);

    string localePath = buildNormalizedPath(absolutePath(getJsonStr(json,
            "locale", ""), getBasePath()));

    setLocale(localePath);
}
/*
private bool loadPlugin(string pluginPath) {
    JSONValue json = parseJSON(readText(pluginPath));
    string scriptPath = buildNormalizedPath(absolutePath(getJsonStr(json,
            "script", ""), dirName(pluginPath)));
    if (!exists(scriptPath))
        return false;
    _exePath = pluginPath;
    loadScript(scriptPath);
    return true;
}*/

/// Save config file
void saveConfig() {
    JSONValue json;
    json["app"] = _exeFileName;
    json["path"] = _exePath;
    json["models"] = _modelsFolder;
    json["scale"] = _scale;
    json["input"] = _inputPath;
    json["output"] = _outputPath;
    json["currentFile"] = _currentFile;
    json["currentModel"] = _currentModel;
    json["locale"] = (getLocale().length && exists(getLocale())) ? relativePath(
        buildNormalizedPath(getLocale()), getBasePath()) : buildNormalizedPath("locale",
        "en_US.json");
    json["themeId"] = _themeId;

    std.file.write(_configFilePath, toJSON(json, true));
}
