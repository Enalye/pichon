module gui.theme;

import atelier;

import common;

final class ThemeUI : GuiElement {
    private {
        Sprite _bgSprite, _upSprite, _downSprite;
    }

    this() {
        size(Vec2f(22f, 22f));

        _bgSprite = fetch!Sprite("theme.bg");
        _upSprite = fetch!Sprite("theme.1");
        _downSprite = fetch!Sprite("theme.2");

        _upSprite.anchor = Vec2f.zero;
        _downSprite.anchor = Vec2f.one;

        GuiState hiddenState = {
            angle: 45f, time: .2f, easing: getEasingFunction(Ease.sineInOut)
        };
        addState("hover", hiddenState);

        GuiState defaultState = {
            time: .2f, easing: getEasingFunction(Ease.sineInOut)
        };
        addState("default", defaultState);

        setState("default");

        setCanvas(true, true);
    }

    override void onHover() {
        doTransitionState(isHovered ? "hover" : "default");
    }

    override void onEvent(Event event) {
        switch (event.type) with (Event.Type) {
        case custom:
            if (event.custom.id == "theme") {

            }
            break;
        default:
            break;
        }
    }

    override void onSubmit() {
        const int themeId = getThemeId();
        setThemeId(((themeId + 1) < getThemesCount()) ? themeId + 1 : 0);
    }

    override void draw() {
        _bgSprite.color = isHovered ? getTheme(ThemeKey.background) : getTheme(ThemeKey.base);
        _upSprite.color = isHovered ? getTheme(ThemeKey.hover) : getTheme(ThemeKey.hint);
        _downSprite.color = isHovered ? getTheme(ThemeKey.base) : getTheme(ThemeKey.field);

        _bgSprite.draw(center);
        _upSprite.draw(origin + Vec2f.one);
        _downSprite.draw(origin + size - Vec2f.one);
    }
}
