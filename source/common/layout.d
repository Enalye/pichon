module common.layout;

import atelier;
import common.config;

private struct AppTheme {
    Color bar, background, base, field, hint, hover, select, lock, text1, text2, text3;
}

private {
    AppTheme[] _themes;
}

void initThemes() {
    AppTheme darkAqua = {
        bar: Color.fromHex(0x0f1112), //
        background: Color.fromHex(0x293030), //
        base: Color.fromHex(0x313f40), //
        field: Color.fromHex(0x434755), //
        hint: Color.fromHex(0x00baaa), //
        hover: Color.fromHex(0x54e5d8), //
        select: Color.fromHex(0xb2f1eb), //
        lock: Color.fromHex(0x434755), //
        text1: Color.fromHex(0xffffff), //
        text2: Color.fromHex(0xb3d9da), //
        text3: Color.fromHex(0x264b47)
    };

    AppTheme darkPurple = {
        bar: Color.fromHex(0x111111), //
        background: Color.fromHex(0x1f232d), //
        base: Color.fromHex(0x2a2e3c), //
        field: Color.fromHex(0x434755), //
        hint: Color.fromHex(0x8900de), //
        hover: Color.fromHex(0xb566e6), //
        select: Color.fromHex(0xddb5f6), //
        lock: Color.fromHex(0x524c52), //
        text1: Color.fromHex(0xffffff), //
        text2: Color.fromHex(0xa6abbb), //
        text3: Color.fromHex(0xffffff)
    };

    AppTheme darkBlue = {
        bar: Color.fromHex(0x0c0c0d), //
        background: Color.fromHex(0x0d0f21), //
        base: Color.fromHex(0x2a2e3c), //
        field: Color.fromHex(0x0d0e1b), //
        hint: Color.fromHex(0x0023d1), //
        hover: Color.fromHex(0x3f59de), //
        select: Color.fromHex(0x9caaeb), //
        lock: Color.fromHex(0x524c52), //
        text1: Color.fromHex(0xffffff), //
        text2: Color.fromHex(0xa6abbb), //
        text3: Color.fromHex(0xffffff)
    };

    AppTheme darkPink = {
        bar: Color.fromHex(0x111111), //
        background: Color.fromHex(0x1f232d), //
        base: Color.fromHex(0x2a2e3c), //
        field: Color.fromHex(0x434755), //
        hint: Color.fromHex(0xee00d4), //
        hover: Color.fromHex(0xe25bd4), //
        select: Color.fromHex(0x9a6995), //
        lock: Color.fromHex(0x524c52), //
        text1: Color.fromHex(0xffffff), //
        text2: Color.fromHex(0xa6abbb), //
        text3: Color.fromHex(0xffffff)
    };

    _themes = [darkAqua, darkPurple, darkBlue, darkPink];
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
    text1,
    text2,
    text3
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
    case text1:
        return currentTheme.text1;
    case text2:
        return currentTheme.text2;
    case text3:
        return currentTheme.text3;
    }
}
