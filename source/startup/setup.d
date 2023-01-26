module startup.setup;

import std.file : exists, thisExePath;
import std.path : buildNormalizedPath, dirName;

import bindbc.sdl;

import atelier;

import gui, common;
import startup.loader;

void setupApplication(string[] args) {
    //Init
    enableAudio(false);
    createApplication(Vec2i(550, 600), "Pichon", SDL_INIT_VIDEO);
    setWindowResizable(false);
    setWindowBordered(false);
    setWindowHitTest(&hitTestFunc, null);

    const string iconPath = buildNormalizedPath(getBasePath(), "icon.png");
    if (exists(iconPath))
        setWindowIcon(iconPath);

    loadResources();
    loadConfig();
    loadVeraFonts(18);

    //Run
    appendRoot(new Window);
    runApplication();
    destroyApplication();
}

extern (C) SDL_HitTestResult hitTestFunc(SDL_Window*, const SDL_Point* point, void*) nothrow {
    return (point.y <= 50 && point.x < 450) ? SDL_HITTEST_DRAGGABLE : SDL_HITTEST_NORMAL;
}
