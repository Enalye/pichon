module gui.buttons;

import atelier;
import common;

import gui.label;

final class ConfirmationButton : Button {
    private {
        CustomLabel _label;
        NinePatch _bg;
    }

    this(string txt) {
        _label = new CustomLabel(txt);
        _label.setAlign(GuiAlignX.center, GuiAlignY.center);
        size = _label.size;
        appendChild(_label);

        _bg = fetch!NinePatch("bg");
        _bg.size = size;
    }

    override void onSize() {
        if (_bg)
            _bg.size = size;
        super.onSize();
    }

    override void update(float deltaTime) {
        super.update(deltaTime);
    }

    override void draw() {
        _label.color = getTheme(ThemeKey.text1);
        if (isLocked) {
            _bg.color = getTheme(ThemeKey.lock);
            _label.color = getTheme(ThemeKey.text2);
        }
        else if (isClicked) {
            _bg.color = getTheme(ThemeKey.select);
        }
        else if (isHovered) {
            _bg.color = getTheme(ThemeKey.hover);
        }
        else {
            _bg.color = getTheme(ThemeKey.hint);
        }
        _bg.draw(center);
    }
}

final class DirButton : Button {
    private {
        CustomLabel _label;
        NinePatch _bg;
    }

    this(string txt, Color color) {
        _label = new CustomLabel(txt);
        _label.color = color;
        _label.setAlign(GuiAlignX.center, GuiAlignY.center);
        size = _label.size;
        appendChild(_label);

        _bg = fetch!NinePatch("bg");
        _bg.size = size;
    }

    override void onSize() {
        if (_bg)
            _bg.size = size;
        super.onSize();
    }

    override void update(float deltaTime) {
        super.update(deltaTime);
    }

    override void draw() {
        if (isClicked) {
            _bg.color = getTheme(ThemeKey.select);
        }
        else if (isHovered) {
            _bg.color = getTheme(ThemeKey.hover);
        }
        else {
            _bg.color = getTheme(ThemeKey.hint);
        }
        _bg.draw(center);
    }
}

final class ExitButton : Button {
    private {
        Sprite _crossSprite;
    }

    this() {
        _crossSprite = fetch!Sprite("exit");
        size = _crossSprite.size + Vec2f(5f, 5f);
    }

    override void update(float deltaTime) {
        super.update(deltaTime);
    }

    override void draw() {
        if (isClicked) {
            _crossSprite.color = getTheme(ThemeKey.select);
        }
        else if (isHovered) {
            _crossSprite.color = getTheme(ThemeKey.hover);
        }
        else {
            _crossSprite.color = getTheme(ThemeKey.hint);
        }
        _crossSprite.draw(center);
    }
}

final class SettingButton : Button {
    private {
        Sprite _optionSprite;
    }

    this() {
        _optionSprite = fetch!Sprite("option");
        size = _optionSprite.size + Vec2f(5f, 5f);
    }

    override void update(float deltaTime) {
        super.update(deltaTime);
    }

    override void draw() {
        if (isClicked) {
            _optionSprite.color = getTheme(ThemeKey.select);
        }
        else if (isHovered) {
            _optionSprite.color = getTheme(ThemeKey.hover);
        }
        else {
            _optionSprite.color = getTheme(ThemeKey.hint);
        }
        _optionSprite.draw(center);
    }
}
