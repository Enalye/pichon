/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module gui.locale;

import std.path, std.file, std.string, std.exception;
import atelier;
import common;
import gui.buttons, gui.label;

final class LocaleUI : GuiElement {
    private {
        CustomLabel _label;
        string[] _locales;
    }

    this() {
        setAlign(GuiAlignX.center, GuiAlignY.center);
        size(Vec2f(30f, 30f));

        auto path = buildNormalizedPath(getBasePath(), "locale");
        enforce(exists(path), "Missing locale folder");
        foreach (file; dirEntries(path, SpanMode.shallow)) {
            const string filePath = absolutePath(buildNormalizedPath(file));
            if (extension(filePath).toLower() != ".json")
                continue;
            _locales ~= filePath;
        }

        _label = new CustomLabel(getText("locale"), getFont(FontType.bold));
        _label.color = getTheme(ThemeKey.text2);
        _label.setAlign(GuiAlignX.left, GuiAlignY.center);
        appendChild(_label);
    }

    override void update(float deltaTime) {
        _label.color = isSelected || isHovered ? getTheme(ThemeKey.text1) : getTheme(ThemeKey.text2);
    }

    override void onEvent(Event event) {
        switch (event.type) with (Event.Type) {
        case custom:
            if (event.custom.id == "locale") {
                _label.text = getText("locale");
            }
            break;
        default:
            break;
        }
    }

    override void onSubmit() {
        const string currentLocale = stripExtension(baseName(getLocale()));

        for (size_t i; i < _locales.length; ++i) {
            const string locale = stripExtension(baseName(_locales[i]));
            if (locale == currentLocale) {
                if (i + 1 == _locales.length)
                    setLocale(_locales[0]);
                else
                    setLocale(_locales[i + 1]);
                return;
            }
        }

        if (_locales.length) {
            setLocale(_locales[0]);
        }
    }
}
