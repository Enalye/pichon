/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module gui.locale;

import std.path, std.file, std.string, std.exception;
import atelier;
import common;
import gui.buttons;

final class LocaleUI : GuiElement {
    private {
        Label _label;

        struct LocaleData {
            string file, id, name;
        }
    }

    this() {
        setAlign(GuiAlignX.center, GuiAlignY.center);
        size(Vec2f(30f, 30f));

        /*auto path = buildNormalizedPath(getBasePath(), "locale");
        enforce(exists(path), "Missing locale folder");
        foreach (file; dirEntries(path, SpanMode.shallow)) {
            const string filePath = absolutePath(buildNormalizedPath(file));
            if (extension(filePath).toLower() != ".json")
                continue;
            JSONValue json = parseJSON(readText(filePath));
            _locales ~= filePath;
            _locales(getJsonStr(json, "locale", baseName(filePath)));
        }*/

        _label = new Label(getText("locale"), getFont(FontType.bold));
        _label.color = TEXT_TITLE_COLOR;
        _label.setAlign(GuiAlignX.center, GuiAlignY.center);
        appendChild(_label);
    }
}
