/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module gui.editable_path;

import std.path;
import atelier;
import common;

/// Chemin de fichier éditable
final class EditablePathGui : GuiElement {
    private {
        Label _label;
        InputField _inputField;
        bool _isEditing;
        Timer _timer;
    }

    @property {
        string text() const {
            return _label.text;
        }

        string text(string t) {
            _label.text = t;
            size = Vec2f(400f, _label.size.y + 2f);
            return _label.text;
        }
    }

    /// Ctor
    this(string path = "") {
        size = Vec2f(400f, 25f);

        _label = new Label(path);
        _label.color = getTheme(ThemeKey.textTitle);
        _label.setAlign(GuiAlignX.left, GuiAlignY.center);
        appendChild(_label);

        setCanvas(true);

        _timer.mode = Timer.Mode.bounce;
        _timer.start(5f);
    }

    override void update(float deltaTime) {
        if (_isEditing) {
            if (getButtonDown(KeyButton.enter))
                applyEditedName();
            else if (_inputField && !_inputField.hasFocus)
                cancelEditedName();
        }
        else {
            _timer.update(deltaTime);
            if (_label.size.x > size.x) {
                float delta = size.x - _label.size.x;
                _label.position = Vec2f(lerp(10f, delta - 10f, easeInOutSine(_timer.value01)), 0f);
            }
            else {
                _label.position = Vec2f.zero;
            }
        }
    }

    void cancelEditedName() {
        if (!_isEditing)
            throw new Exception("The element is not in an editing state");
        _isEditing = false;
        _inputField = null;

        removeChildren();
        appendChild(_label);
        triggerCallback();

        _timer.start(5f);
    }

    void applyEditedName() {
        if (!_isEditing)
            throw new Exception("The element is not in an editing state");
        _isEditing = false;

        auto path = _inputField.text;
        path = buildNormalizedPath(path);
        _label.text = path;
        _inputField = null;

        removeChildren();
        appendChild(_label);
        triggerCallback();

        _timer.start(5f);
    }

    override void onSubmit() {
        if (!_isEditing) {
            _isEditing = true;
            removeChildren();
            _inputField = new InputField(size, _label.text);
            _inputField.font = getFont(FontType.mono);
            _inputField.color = getTheme(ThemeKey.textTitle);
            _inputField.caretColor = getTheme(ThemeKey.hint);
            _inputField.selectionColor = getTheme(ThemeKey.select);
            _inputField.setAlign(GuiAlignX.center, GuiAlignY.center);
            _inputField.size = Vec2f(400f, _label.size.y);
            _inputField.hasFocus = true;
            appendChild(_inputField);
        }
        triggerCallback();
    }

    override void draw() {
        drawFilledRect(origin, size, getTheme(ThemeKey.field));
    }
}

final class ParentButton : Button {
    private {
        Sprite _parentSprite;
    }

    this() {
        _parentSprite = fetch!Sprite("parent");
        size = Vec2f(24f, 24f);
    }

    override void draw() {
        if (isClicked) {
            _parentSprite.color = getTheme(ThemeKey.select);
        }
        else if (isHovered) {
            _parentSprite.color = getTheme(ThemeKey.hover);
        }
        else {
            _parentSprite.color = getTheme(ThemeKey.hint);
        }
        _parentSprite.draw(center);
    }
}
