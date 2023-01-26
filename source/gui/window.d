module gui.window;

import std.path, std.file;
import atelier;

import common;
import gui.buttons, gui.open, gui.theme, gui.locale, gui.bar;

final class Window : GuiElement {
    private {
        DropDownList _modelSelector;
        FileButton _inputFileBtn, _outputFolderBtn;
        InputField _outputFileField;
        RunButton _runBtn;
        ThemeUI _theme;
        LocaleUI _locale;
        BarUI _bar;
    }

    this() {
        size(getWindowSize());
        setWindowClearColor(BACKGROUND_COLOR);

        auto vbox = new VContainer;
        vbox.spacing(Vec2f(0f, 50f));
        vbox.position(Vec2f(25f, 50f));
        vbox.setChildAlign(GuiAlignX.left);
        appendChild(vbox);

        {
            _bar = new BarUI;
            _bar.setAlign(GuiAlignX.center, GuiAlignY.top);
            appendChild(_bar);
        }

        {
            auto hbox = new HContainer;
            hbox.setAlign(GuiAlignX.right, GuiAlignY.top);
            hbox.position(Vec2f(10f, 60f));
            hbox.spacing = Vec2f(25f, 0f);
            hbox.setChildAlign(GuiAlignY.center);
            appendChild(hbox);

            _theme = new ThemeUI;
            hbox.appendChild(_theme);

            _locale = new LocaleUI;
            hbox.appendChild(_locale);
        }

        {
            auto box = new HContainer;
            box.setAlign(GuiAlignX.left, GuiAlignY.center);
            box.spacing = Vec2f(15f, 0f);
            vbox.appendChild(box);

            box.appendChild(new Label("Model:"));

            _modelSelector = new DropDownList(Vec2f(300f, 25f), 5);
            auto files = dirEntries(buildNormalizedPath(EXE_PATH,
                    EXE_MODELS_FOLDER), "{*.param}", SpanMode.shallow);
            foreach (file; files) {
                string fileName = baseName(stripExtension(file));
                _modelSelector.add(fileName);
            }
            _modelSelector.setSelectedName(getCurrentModel());
            _modelSelector.setCallback(this, "model");
            box.appendChild(_modelSelector);
        }

        {
            vbox.appendChild(new Label("File:"));

            _inputFileBtn = new FileButton(getCurrentFile());
            _inputFileBtn.setCallback(this, "input");
            vbox.appendChild(_inputFileBtn);
        }

        {
            vbox.appendChild(new Label("File:"));

            _outputFolderBtn = new FileButton(getOutputPath());
            _outputFolderBtn.setCallback(this, "output");
            vbox.appendChild(_outputFolderBtn);
        }

        {
            _runBtn = new RunButton;
            _runBtn.setAlign(GuiAlignX.center, GuiAlignY.bottom);
            _runBtn.position(Vec2f(0f, 25f));
            _runBtn.setCallback(this, "run");
            vbox.appendChild(_runBtn);
        }
    }

    override void onCallback(string id) {
        switch (id) {
        case "input":
            stopOverlay();
            isClicked = false;
            isHovered = false;
            auto modal = new OpenModal(getCurrentFile(), [
                    ".jpg", ".jpeg", ".png", ".bmp", ".gif", ".mp4"
                ]);
            modal.setCallback(this, "input.modal");
            pushModal(modal);
            break;
        case "input.modal":
            auto modal = popModal!OpenModal;
            setCurrentFile(modal.getPath());
            _outputFolderBtn.setText(modal.getPath());
            break;
        case "output":
            stopOverlay();
            isClicked = false;
            isHovered = false;
            auto modal = new OpenModal(getOutputPath(), [], true);
            modal.setCallback(this, "output.modal");
            pushModal(modal);
            break;
        case "output.modal":
            auto modal = popModal!OpenModal;
            setCurrentFile(modal.getPath());
            _outputFolderBtn.setText(modal.getPath());
            break;
        case "model":
            setCurrentModel(_modelSelector.getSelectedName());
            break;
        case "run":
            import std.process : escapeShellCommand, spawnProcess;

            //spawnProcess(escapeShellCommand(getExePath(), "-i", getCurrentFile(), "-o", getOutputPath() ~ "output" ));
            break;
        default:
            break;
        }
    }
}

final class FileButton : Button {
    private {
        NinePatch _bg;
        Label _label;
    }

    this(string txt) {
        txt = baseName(txt);
        size = Vec2f(400f, 25f);

        _label = new Label(txt.length ? txt : getText("select_file"));
        _label.setAlign(GuiAlignX.center, GuiAlignY.center);
        appendChild(_label);

        _bg = fetch!NinePatch("bg");
        _bg.size = size;
    }

    void setText(string txt) {
        txt = baseName(txt);
        _label.text = txt.length ? txt : getText("select_file");
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

final class RunButton : Button {
    private {
        NinePatch _bg;
        Label _label;
    }

    this() {
        size = Vec2f(200f, 100f);
        _bg = fetch!NinePatch("bg");
        _bg.size = size;

        _label = new Label(getText("run"), getFont(FontType.bold));
        _label.setAlign(GuiAlignX.center, GuiAlignY.center);
        appendChild(_label);
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
