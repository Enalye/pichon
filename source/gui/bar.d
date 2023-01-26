module gui.bar;

import atelier;

import common;

final class BarUI : GuiElement {
    private {
        QuitButton _quitBtn;
        MinimizeButton _minimizeBtn;
    }

    this() {
        size(Vec2f(getWindowWidth(), 50f));

        auto title = new Label("PICHON", getFont(FontType.boldItalic));
        title.color = TEXT_TITLE_COLOR;
        title.setAlign(GuiAlignX.center, GuiAlignY.center);
        appendChild(title);

        auto box = new HContainer;
        box.spacing(Vec2f(10f, 0f));
        box.setAlign(GuiAlignX.right, GuiAlignY.center);
        appendChild(box);

        _minimizeBtn = new MinimizeButton;
        _minimizeBtn.setCallback(this, "minimize");
        box.appendChild(_minimizeBtn);

        _quitBtn = new QuitButton;
        _quitBtn.setCallback(this, "quit");
        box.appendChild(_quitBtn);
    }

    override void onCallback(string id) {
        switch(id) {
        case "quit":
            stopApplication();
            break;
        case "minimize":
            minimizeWindow();
            break;
        default:
            break;
        }
    }

    override void draw() {
        drawFilledRect(origin, size, BAR_COLOR);
    }
}

final class QuitButton : Button {
    private {
        Sprite _crossSprite;
        NinePatch _bg;
    }

    this() {
        size(Vec2f(40f, 40f));

        _crossSprite = fetch!Sprite("exit");

        _bg = fetch!NinePatch("bg");
        _bg.size = size;
    }

    override void update(float deltaTime) {
        super.update(deltaTime);
    }

    override void draw() {
        if (isClicked) {
            _bg.color = SELECT_COLOR;
            _crossSprite.color = TEXT_BASE_COLOR;
        }
        else if (isHovered) {
            _bg.color = HOVER_COLOR;
            _crossSprite.color = TEXT_BASE_COLOR;
        }
        else {
            _bg.color = BACKGROUND_COLOR;
            _crossSprite.color = TEXT_TITLE_COLOR;
        }
        _bg.draw(center);
        _crossSprite.draw(center);
    }
}


final class MinimizeButton : Button {
    private {
        Sprite _minimizeSprite;
        NinePatch _bg;
    }

    this() {
        size(Vec2f(40f, 40f));

        _minimizeSprite = fetch!Sprite("minimize");

        _bg = fetch!NinePatch("bg");
        _bg.size = size;
    }

    override void update(float deltaTime) {
        super.update(deltaTime);
    }

    override void draw() {
        if (isClicked) {
            _bg.color = SELECT_COLOR;
            _minimizeSprite.color = TEXT_BASE_COLOR;
        }
        else if (isHovered) {
            _bg.color = HOVER_COLOR;
            _minimizeSprite.color = TEXT_BASE_COLOR;
        }
        else {
            _bg.color = BACKGROUND_COLOR;
            _minimizeSprite.color = TEXT_TITLE_COLOR;
        }
        _bg.draw(center);
        _minimizeSprite.draw(center);
    }
}
