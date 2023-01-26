module gui.buttons;

import atelier;
import common;

final class ConfirmationButton : Button {
    private {
        Label _label;
        NinePatch _bg;
    }

    this(string txt) {
        _label = new Label(txt);
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
        _label.color = TEXT_TITLE_COLOR;
        if (isLocked) {
            _bg.color = LOCK_COLOR;
        }
        else if (isClicked) {
            _bg.color = SELECT_COLOR;
        }
        else if (isHovered) {
            _bg.color = HOVER_COLOR;
        }
        else {
            _bg.color = HINT_COLOR;
        }
        _bg.draw(center);
    }
}

final class DirButton : Button {
    private {
        Label _label;
        NinePatch _bg;
    }

    this(string txt, Color color) {
        _label = new Label(txt);
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
            _bg.color = SELECT_COLOR;
        }
        else if (isHovered) {
            _bg.color = HOVER_COLOR;
        }
        else {
            _bg.color = HINT_COLOR;
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
            _crossSprite.color = SELECT_COLOR;
        }
        else if (isHovered) {
            _crossSprite.color = HOVER_COLOR;
        }
        else {
            _crossSprite.color = HINT_COLOR;
        }
        _crossSprite.draw(center);
    }
}
