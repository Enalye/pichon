module gui.window;

import std.path, std.file, std.conv, std.string, std.datetime;
import std.stdio;
import core.thread;
import atelier;

import common;
import gui.buttons, gui.open, gui.theme, gui.locale, gui.bar;

enum ProgressStatus {
    none,
    success,
    failure
}

private shared {
    float _progressValue;
    ProgressStatus _progressStatus;
    bool _progressRunning;
    string _progressLog;
}

final class Window : GuiElement {
    private {
        DropDownList _modelSelector, _scaleSelector;
        FileButton _inputFileBtn, _outputFolderBtn;
        InputField _outputFileField;
        RunButton _runBtn;
        ThemeUI _theme;
        LocaleUI _locale;
        BarUI _bar;
        QuitButton _clearOutputBtn;
        ProgressBar _progressBar;
        Label _logLabel;

        Label _modelLabel, _scaleLabel, _fileLabel, _outputLabel;
        ScrollLabel _inputFileLabel, _outputFileLabel;

        AppThread _appThread;
        string _generatedFile;
        string _log;
    }

    this() {
        size(getWindowSize());
        setWindowClearColor(getTheme(ThemeKey.background));

        _progressValue = 0f;

        auto vbox = new VContainer;
        vbox.spacing(Vec2f(0f, 25f));
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
            auto box = new GuiElement;
            box.setAlign(GuiAlignX.left, GuiAlignY.center);
            vbox.appendChild(box);

            _modelLabel = new Label(getText("model") ~ ":");
            _modelLabel.setAlign(GuiAlignX.left, GuiAlignY.bottom);
            box.appendChild(_modelLabel);

            _modelSelector = new DropDownList(Vec2f(300f, 25f), 5);
            _modelSelector.setAlign(GuiAlignX.right, GuiAlignY.bottom);

            auto modelsPath = buildNormalizedPath(EXE_PATH, EXE_MODELS_FOLDER);
            if (exists(modelsPath)) {
                auto files = dirEntries(modelsPath, "{*.param}", SpanMode.shallow);
                foreach (file; files) {
                    string fileName = baseName(stripExtension(file));
                    _modelSelector.add(fileName);
                }
            }
            _modelSelector.setSelectedName(getCurrentModel());
            _modelSelector.setCallback(this, "model");
            box.appendChild(_modelSelector);

            box.size(Vec2f(380f, max(_modelLabel.size.y, _modelSelector.size.y)));
        }

        {
            auto box = new GuiElement;
            box.setAlign(GuiAlignX.left, GuiAlignY.center);
            vbox.appendChild(box);

            _scaleLabel = new Label(getText("scale") ~ ":");
            _scaleLabel.setAlign(GuiAlignX.left, GuiAlignY.bottom);
            box.appendChild(_scaleLabel);

            _scaleSelector = new DropDownList(Vec2f(50f, 25f), 3);
            _scaleSelector.setAlign(GuiAlignX.right, GuiAlignY.bottom);
            foreach (value; ["x2", "x3", "x4"]) {
                _scaleSelector.add(value);
            }

            switch (getScale()) {
            case 2:
                _scaleSelector.setSelectedName("x2");
                break;
            case 3:
                _scaleSelector.setSelectedName("x3");
                break;
            case 4:
            default:
                _scaleSelector.setSelectedName("x4");
                break;
            }

            _scaleSelector.setCallback(this, "scale");
            box.appendChild(_scaleSelector);

            box.size(Vec2f(380f, max(_scaleLabel.size.y, _scaleSelector.size.y)));
        }

        {
            auto box = new VContainer;
            box.setAlign(GuiAlignX.left, GuiAlignY.center);
            box.spacing = Vec2f(0f, 10f);
            box.setChildAlign(GuiAlignX.left);
            vbox.appendChild(box);

            auto hbox = new GuiElement;
            box.appendChild(hbox);

            _fileLabel = new Label(getText("file") ~ ": ");
            _fileLabel.setAlign(GuiAlignX.left, GuiAlignY.bottom);
            hbox.appendChild(_fileLabel);

            _inputFileLabel = new ScrollLabel(400f, getCurrentFile());
            _inputFileLabel.setAlign(GuiAlignX.right, GuiAlignY.bottom);
            hbox.appendChild(_inputFileLabel);

            _inputFileBtn = new FileButton("select_file");
            _inputFileBtn.setCallback(this, "input");
            box.appendChild(_inputFileBtn);

            hbox.size(Vec2f(500f, max(_fileLabel.size.y, _inputFileLabel.size.y)));
        }

        {
            auto box = new VContainer;
            box.setAlign(GuiAlignX.left, GuiAlignY.center);
            box.spacing = Vec2f(0f, 10f);
            box.setChildAlign(GuiAlignX.left);
            vbox.appendChild(box);

            auto hbox = new GuiElement;
            box.appendChild(hbox);

            _outputLabel = new Label(getText("output") ~ ": ");
            _outputLabel.setAlign(GuiAlignX.left, GuiAlignY.bottom);
            hbox.appendChild(_outputLabel);

            _outputFileLabel = new ScrollLabel(350f, getOutputPath().length ?
                    getOutputPath() : getText("default_output"));
            _outputFileLabel.setAlign(GuiAlignX.right, GuiAlignY.bottom);
            _outputFileLabel.position(Vec2f(50f, 0f));
            hbox.appendChild(_outputFileLabel);

            _clearOutputBtn = new QuitButton();
            _clearOutputBtn.setAlign(GuiAlignX.right, GuiAlignY.bottom);
            _clearOutputBtn.setCallback(this, "output.clear");
            hbox.appendChild(_clearOutputBtn);

            _outputFolderBtn = new FileButton("select_output");
            _outputFolderBtn.setCallback(this, "output");
            box.appendChild(_outputFolderBtn);

            hbox.size(Vec2f(500f, max(_fileLabel.size.y,
                    _inputFileLabel.size.y, _clearOutputBtn.size.y)));
        }

        {
            auto box = new VContainer;
            box.setAlign(GuiAlignX.center, GuiAlignY.bottom);
            box.setChildAlign(GuiAlignX.center);
            box.position(Vec2f(0f, 35f));
            appendChild(box);

            _runBtn = new RunButton;
            _runBtn.setCallback(this, "run");
            box.appendChild(_runBtn);

            box.appendChild(new SpaceUI(Vec2f(0f, 25f)));

            _progressBar = new ProgressBar;
            box.appendChild(_progressBar);
        }

        {
            _logLabel = new Label("", getFont(FontType.small));
            _logLabel.position(Vec2f(0f, 5f));
            _logLabel.setAlign(GuiAlignX.center, GuiAlignY.bottom);
            appendChild(_logLabel);
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
            _inputFileLabel.setText(modal.getPath());
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
            setOutputPath(modal.getPath());
            _outputFileLabel.setText(modal.getPath());
            break;
        case "output.clear":
            setOutputPath("");
            _outputFileLabel.setText(getText("default_output"));
            break;
        case "model":
            setCurrentModel(_modelSelector.getSelectedName());
            break;
        case "scale":
            switch (_scaleSelector.getSelectedName()) {
            case "x2":
                setScale(2);
                break;
            case "x3":
                setScale(3);
                break;
            case "x4":
            default:
                setScale(4);
                break;
            }
            break;
        case "run":
            _generatedFile = buildNormalizedPath(getOutputPath(),
                setExtension("output", extension(getCurrentFile())));
            _appThread = new AppThread([
                getExePath(), "-i", getCurrentFile(), "-o", _generatedFile,
                "-n", getCurrentModel(), "-s", to!string(getScale())
            ]);
            _appThread.start();
            break;
        default:
            break;
        }
    }

    override void update(float deltaTime) {
        if (_appThread) {
            if (_appThread.isRunning())
                _runBtn.isLocked = true;
            else {
                _runBtn.isLocked = false;
                _appThread = null;

                if (_progressStatus == ProgressStatus.success) {
                    _log = _progressLog;
                    _logLabel.text = getText("done") ~ " " ~ _generatedFile;
                }
            }
        }
        else {
            _runBtn.isLocked = false;
        }

        if (_progressLog != _log) {
            _log = _progressLog;
            _logLabel.text = _log;
        }
    }
}

final class ProgressBar : GuiElement {
    private {
        WritableTexture _barTexture;
        Sprite _barSprite;
        Timer _timer;
        float _barRatio = 1f;
        float _lastBarRatio = 1f;
    }

    this() {
        size(Vec2f(500f, 25f));

        _barTexture = new WritableTexture(500, 25);
        _barSprite = new Sprite(_barTexture);
        _reload();

        _timer.mode = Timer.Mode.bounce;
        _timer.start(.5f);
    }

    private void _reload() {
        struct RasterData {
            float lastBarRatio, barRatio;
            ProgressStatus status;
        }

        RasterData rasterData;
        rasterData.lastBarRatio = _lastBarRatio;
        rasterData.barRatio = _barRatio;
        rasterData.status = _progressStatus;

        _barTexture.write(function(uint* dest, uint* src, uint texWidth,
                uint texHeight, void* data_) {
            RasterData* data = cast(RasterData*) data_;
            int greenArea = cast(int)(texWidth * data.lastBarRatio);
            int whiteArea = cast(int)(texWidth * data.barRatio);

            uint color1 = data.status == ProgressStatus.failure ? 0xd95763ff : 0x99e550ff;
            uint color2 = data.status == ProgressStatus.failure ? 0xac3232ff : 0x6abe30ff;

            for (int iy; iy < texHeight; ++iy) {
                for (int ix; ix < texWidth; ++ix) {
                    if ((ix < iy) || ix >= texWidth - (texHeight - iy)) {
                        dest[iy * texWidth + ix] = 0x00000000;
                    }
                    else if ((ix - iy) <= greenArea) {
                        dest[iy * texWidth + ix] = iy < 5 ? color1 : color2;
                    }
                    else if ((ix - iy) <= whiteArea) {
                        dest[iy * texWidth + ix] = iy < 5 ? 0xffffffff : 0xcbdbfcff;
                    }
                    else {
                        dest[iy * texWidth + ix] = iy < 5 ? 0x696a6aff : 0x595652ff;
                    }
                }
            }
        }, &rasterData);
    }

    override void update(float deltaTime) {
        _timer.update(deltaTime);
        _barRatio = _progressValue;

        if (_progressRunning) {
            _lastBarRatio = lerp(_lastBarRatio, _barRatio, .1f);
        }
        else {
            _lastBarRatio = 1f;
        }
        _reload();
    }

    override void draw() {
        _barSprite.draw(center);
    }
}

final class AppThread : Thread {
    private shared {
        string[] _cmd;
    }

    /// Ctor
    this(string[] cmd) {
        _cmd = cast(shared) cmd;
        super(&run);
    }

    /// thread
    void run() {
        import std.process;
        import std.stdio : writeln;

        ProcessPipes process;
        string[] cmd = cast(string[]) _cmd;
        _progressValue = 0f;
        _progressStatus = ProgressStatus.success;
        _progressRunning = true;

        try {
            process = pipeProcess(cmd, Redirect.stdout | Redirect.stderr);
            scope (exit) {
                _progressValue = 1f;
                _progressRunning = false;
                wait(process.pid);
            }

            long _tickStartFrame;
            _tickStartFrame = Clock.currStdTime();

            for (;;) {
                string txt = process.stderr.readln(); //Pq c’est dans le stderr ?!?

                txt = txt.chomp();

                if (txt.length) {
                    _progressLog = txt.wrap();

                    if (txt[$ - 1] == '%') {
                        txt = txt.chop();
                        txt = txt.replace(',', '.');

                        try {
                            _progressValue = to!float(txt) / 100f;
                        }
                        catch (Exception e) {
                        }
                    }
                }

                auto call = tryWait(process.pid);
                if (call.terminated) {
                    if (call.status == 0) {
                        _progressStatus = ProgressStatus.success;
                    }
                    else
                        _progressStatus = ProgressStatus.failure;
                    _progressValue = 1f;
                    _progressRunning = false;
                    return;
                }

                long deltaTicks = Clock.currStdTime() - _tickStartFrame;
                const long fps = 10;
                if (deltaTicks < (10_000_000 / fps))
                    Thread.sleep(dur!("hnsecs")((10_000_000 / fps) - deltaTicks));
                _tickStartFrame = Clock.currStdTime();
            }
        }
        catch (Exception e) {
            _progressStatus = ProgressStatus.failure;
            _progressValue = 1f;
            _progressRunning = false;
        }
    }
}

final class FileButton : Button {
    private {
        NinePatch _bg;
        Label _label;
    }

    this(string key) {
        size = Vec2f(500f, 35f);

        _label = new Label(getText(key));
        _label.setAlign(GuiAlignX.center, GuiAlignY.center);
        appendChild(_label);

        _bg = fetch!NinePatch("bg");
        _bg.size = size;
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
        if (isLocked) {
            _bg.color = getTheme(ThemeKey.lock);
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

final class SpaceUI : GuiElement {
    this(Vec2f sz) {
        size(sz);
    }
}

final class ScrollLabel : GuiElement {
    private {
        Label _label;
        Timer _timer;
    }

    this(float width_, string txt) {
        _label = new Label(txt);
        _label.color = getTheme(ThemeKey.textTitle);
        size(Vec2f(width_, _label.size.y));
        appendChild(_label);
        setCanvas(true);

        _timer.mode = Timer.Mode.bounce;
        _timer.start(5f);
    }

    void setText(string txt) {
        _label.text = txt;
        size(Vec2f(size.x, _label.size.y));
    }

    override void update(float deltaTime) {
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
