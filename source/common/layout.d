module common.layout;

import atelier;
import common.config;

private struct AppTheme {
    Color bar, background, base, field, hint, hover, select, lock, textBase, textTitle;
}

private {
    AppTheme[] _themes;
}

void initThemes() {
    AppTheme darkAqua = {
        bar: Color.fromHex(0x111111), //
        background: Color.fromHex(0x1f232d), //
        base: Color.fromHex(0x2a2e3c), //
        field: Color.fromHex(0x434755), //
        hint: Color.fromHex(0x00baaa), //
        hover: Color.fromHex(0x54e5d8), //
        select: Color.fromHex(0xb2f1eb), //
        lock: Color.fromHex(0x434755), //
        textBase: Color.fromHex(0xffffff), //
        textTitle: Color.fromHex(0xa6abbb)
    };

    AppTheme lightPink = {
        bar: Color.fromHex(0x111111), //
        background: Color.fromHex(0x1f232d), //
        base: Color.fromHex(0x2a2e3c), //
        field: Color.fromHex(0x434755), //
        hint: Color.fromHex(0xee00d4), //
        hover: Color.fromHex(0xe25bd4), //
        select: Color.fromHex(0x9a6995), //
        lock: Color.fromHex(0x524c52), //
        textBase: Color.fromHex(0xffffff), //
        textTitle: Color.fromHex(0xa6abbb)
    };

    _themes = [darkAqua, lightPink];
}

enum ThemeKey {
    bar,
    background,
    base,
    field,
    hint,
    hover,
    select,
    lock,
    textBase,
    textTitle
}

int getThemesCount() {
    return cast(int) _themes.length;
}

Color getTheme(ThemeKey type) {
    int themeId = getThemeId();
    if (themeId >= _themes.length)
        themeId = 0;

    if (!_themes.length)
        return Color.white;

    AppTheme currentTheme = _themes[themeId];

    final switch (type) with (ThemeKey) {
    case bar:
        return currentTheme.bar;
    case background:
        return currentTheme.background;
    case base:
        return currentTheme.base;
    case field:
        return currentTheme.field;
    case hint:
        return currentTheme.hint;
    case hover:
        return currentTheme.hover;
    case select:
        return currentTheme.select;
    case lock:
        return currentTheme.lock;
    case textBase:
        return currentTheme.textBase;
    case textTitle:
        return currentTheme.textTitle;
    }
}
