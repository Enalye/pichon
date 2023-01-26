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

    override void draw() {
        _bgSprite.color = isHovered ? BACKGROUND_COLOR : BASE_COLOR;
        _upSprite.color = isHovered ? HOVER_COLOR : HINT_COLOR;
        _downSprite.color = isHovered ? BASE_COLOR : FIELD_COLOR;

        _bgSprite.draw(center);
        _upSprite.draw(origin + Vec2f.one);
        _downSprite.draw(origin + size - Vec2f.one);
    }
}
