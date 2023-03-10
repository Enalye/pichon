/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module gui.open;

import std.file, std.path, std.string;
import atelier;
import gui.editable_path, gui.buttons;
import common;
import gui.label, gui.window;

final class OpenModal : GuiElement {
    final class DirListGui : VList {
        private {
            string[] _subDirs;
        }

        this() {
            super(Vec2f(434f, 334f));
            color = getTheme(ThemeKey.field);
            _container.canvas.clearColor = getTheme(ThemeKey.background);
        }

        override void onCallback(string id) {
            super.onCallback(id);
            if (id == "list") {
                triggerCallback();
            }
        }

        void add(string subDir, Color color) {
            auto btn = new DirButton(subDir, color);
            appendChild(btn);
            _subDirs ~= subDir;
        }

        string getSubDir() {
            if (selected() >= _subDirs.length)
                throw new Exception("Subdirectory index out of range");
            return _subDirs[selected()];
        }

        void reset() {
            removeChildren();
            _subDirs.length = 0;
        }
    }

    /// Search field
    final class SearchField : GuiElement {
        private {
            InputField _inputField;
        }

        @property {
            /// Input text
            string text() const {
                return _inputField.text;
            }
        }

        /// Ctor
        this() {
            _inputField = new InputField(Vec2f(200f, 25f));
            _inputField.font = getFont(FontType.mono);
            _inputField.setCallback(this, "search");
            _inputField.color = getTheme(ThemeKey.text1);
            _inputField.caretColor = getTheme(ThemeKey.hint);
            _inputField.selectionColor = getTheme(ThemeKey.select);
            appendChild(_inputField);
            size = _inputField.size;
        }

        override void onCallback(string id) {
            if (id == "search")
                triggerCallback();
        }

        override void draw() {
            drawFilledRect(origin, size, getTheme(ThemeKey.background));
        }
    }

    private {
        EditablePathGui _pathLabel;
        SearchField _searchField;
        DirListGui _list;
        string _path, _fileName;
        CustomLabel _filePathLabel;
        ScrollLabel _filePathNameLabel;
        GuiElement _applyBtn;
        string[] _extensionList;
        bool _allowDir;
        NinePatch _bg;
    }

    this(string titleKey, string basePath, string[] extensionList, bool allowDir = false) {
        _extensionList = extensionList;
        _allowDir = allowDir;

        if (!basePath.length)
            basePath = getBasePath();

        if (!isDir(basePath)) {
            basePath = dirName(basePath);
        }
        if (basePath.length && exists(basePath) && isDir(basePath)) {
            _path = basePath;
        }
        else {
            _path = getcwd();
        }

        size(Vec2f(500f, 530f));
        setAlign(GuiAlignX.center, GuiAlignY.center);
        isMovable(true);

        _bg = fetch!NinePatch("bg");
        _bg.color = getTheme(ThemeKey.base);
        _bg.size = size;

        { //Title
            auto title = new CustomLabel(getText(titleKey) ~ ":");
            title.color = getTheme(ThemeKey.text2);
            title.setAlign(GuiAlignX.left, GuiAlignY.top);
            title.position = Vec2f(20f, 10f);
            appendChild(title);
        }

        {
            auto hbox = new HContainer;
            hbox.position = Vec2f(0f, 50f);
            hbox.setAlign(GuiAlignX.center, GuiAlignY.top);
            hbox.spacing = Vec2f(10f, 0f);
            appendChild(hbox);

            _pathLabel = new EditablePathGui(_path);
            _pathLabel.setAlign(GuiAlignX.left, GuiAlignY.top);
            _pathLabel.setCallback(this, "path");
            hbox.appendChild(_pathLabel);

            auto parentBtn = new ParentButton;
            parentBtn.setCallback(this, "parent_folder");
            hbox.appendChild(parentBtn);
        }

        {
            _filePathLabel = new CustomLabel(getText(_allowDir ? "path" : "file") ~ ":");
            _filePathLabel.color = getTheme(ThemeKey.text2);
            _filePathLabel.setAlign(GuiAlignX.left, GuiAlignY.bottom);
            _filePathLabel.position = Vec2f(20f, 50f);
            appendChild(_filePathLabel);

            _filePathNameLabel = new ScrollLabel(400f, "---");
            _filePathNameLabel.setAlign(GuiAlignX.right, GuiAlignY.bottom);
            _filePathNameLabel.position = Vec2f(10f, 50f);
            appendChild(_filePathNameLabel);
        }

        { //Validation
            auto box = new HContainer;
            box.setAlign(GuiAlignX.right, GuiAlignY.bottom);
            box.position = Vec2f(10f, 10f);
            box.spacing = Vec2f(8f, 0f);
            appendChild(box);

            auto applyBtn = new ConfirmationButton(getText("open"));
            applyBtn.size = Vec2f(100f, 30f);
            applyBtn.setCallback(this, "apply");
            applyBtn.isLocked = true;
            box.appendChild(applyBtn);
            _applyBtn = applyBtn;

            auto cancelBtn = new ConfirmationButton(getText("cancel"));
            cancelBtn.size = Vec2f(100f, 30f);
            cancelBtn.setCallback(this, "cancel");
            box.appendChild(cancelBtn);
        }

        { //Exit
            auto exitBtn = new ExitButton;
            exitBtn.setAlign(GuiAlignX.right, GuiAlignY.top);
            exitBtn.position = Vec2f(10f, 10f);
            exitBtn.setCallback(this, "cancel");
            appendChild(exitBtn);
        }

        {
            _list = new DirListGui;
            _list.setAlign(GuiAlignX.center, GuiAlignY.center);
            _list.setCallback(this, "file");
            appendChild(_list);
        }

        {
            auto hbox = new HContainer;
            hbox.position = Vec2f(33f, 73f);
            hbox.setAlign(GuiAlignX.right, GuiAlignY.bottom);
            hbox.spacing = Vec2f(10f, 0f);
            appendChild(hbox);

            CustomLabel label = new CustomLabel(getText("search") ~ ":");
            label.color = getTheme(ThemeKey.text2);
            hbox.appendChild(label);

            _searchField = new SearchField;
            _searchField.setCallback(this, "search");
            hbox.appendChild(_searchField);
        }

        reloadList();

        if (_allowDir) {
            _fileName = "";
            _filePathNameLabel.setText(_path);
            _applyBtn.isLocked = false;
        }

        GuiState hiddenState = {scale: Vec2f(1f, 0f), alpha: 0f};
        addState("hidden", hiddenState);

        GuiState defaultState = {
            time: .5f, easing: getEasingFunction(Ease.sineOut)
        };
        addState("default", defaultState);

        setState("hidden");
        doTransitionState("default");

        setCanvas(true);
    }

    string getPath() {
        return buildPath(_path, _fileName);
    }

    override void onCallback(string id) {
        switch (id) {
        case "path":
            if (!exists(_pathLabel.text)) {
                _pathLabel.text = _path;
            }
            else if (isDir(_pathLabel.text)) {
                _path = _pathLabel.text;
                if (_allowDir) {
                    _fileName = "";
                    _filePathNameLabel.setText(_path);
                    _applyBtn.isLocked = false;
                }
                reloadList();
            }
            else {
                _path = dirName(_pathLabel.text);
                _fileName = baseName(_pathLabel.text);
                _filePathNameLabel.setText(_fileName);
                _applyBtn.isLocked = false;
            }
            break;
        case "search":
            reloadList(false);
            break;
        case "file":
            string path = buildPath(_path, _list.getSubDir());
            if (isDir(path)) {
                _path = path;
                if (_allowDir) {
                    _filePathNameLabel.setText(_path);
                    _applyBtn.isLocked = false;
                }
                reloadList();
            }
            else {
                _fileName = _list.getSubDir();
                _filePathNameLabel.setText(_fileName);
                _applyBtn.isLocked = false;
            }
            break;
        case "parent_folder":
            _path = dirName(_path);
            if (_allowDir) {
                _filePathNameLabel.setText(_path);
                _applyBtn.isLocked = false;
            }
            reloadList();
            break;
        case "apply":
            triggerCallback();
            break;
        case "cancel":
            stopModal();
            break;
        default:
            break;
        }
    }

    private enum FileType {
        InvalidType,
        DirectoryType,
        ValidType
    }

    /// Discriminate between file types.
    private FileType getFileType(string filePath) {
        import std.algorithm : canFind;

        try {
            if (isDir(filePath))
                return FileType.DirectoryType;
            const string ext = extension(filePath).toLower();
            if (_extensionList.canFind(ext))
                return FileType.ValidType;
            return FileType.InvalidType;
        }
        catch (Exception e) {
            //Functions like isDir can return an exception
            //when reading a file it can't open.
            //So we don't care about those file.
            return FileType.InvalidType;
        }
    }

    private void reloadList(bool resetSelection = true) {
        import std.typecons : No;
        import std.string : indexOf;

        if (resetSelection && !_allowDir) {
            _fileName = "";
            _filePathNameLabel.setText("---");
            _applyBtn.isLocked = true;
        }
        _pathLabel.text = _path;
        string search = _searchField.text;
        _list.reset();
        auto files = dirEntries(_path, SpanMode.shallow);
        foreach (file; files) {
            if (file.indexOf(search, No.caseSentitive) == -1)
                continue;
            const auto type = getFileType(file);
            final switch (type) with (FileType) {
            case DirectoryType:
                _list.add(baseName(file), getTheme(ThemeKey.text1));
                continue;
            case ValidType:
                _list.add(baseName(file), getTheme(ThemeKey.text3));
                continue;
            case InvalidType:
                continue;
            }
        }
    }

    override void update(float deltaTime) {
        if (getButtonDown(KeyButton.escape))
            onCallback("cancel");
        else if (!_applyBtn.isLocked) {
            if (getButtonDown(KeyButton.enter) || getButtonDown(KeyButton.enter2))
                onCallback("apply");
        }
    }

    override void draw() {
        _bg.draw(center);
    }
}
