module startup.loader;

import std.file, std.path, std.conv;
import atelier;
import common;

void loadResources() {
    _loadTextures();
}

void _loadTextures() {
    auto textureCache = new ResourceCache!Texture;
    auto spriteCache = new ResourceCache!Sprite;
    auto tilesetCache = new ResourceCache!Tileset;
    auto animationCache = new ResourceCache!Animation;
    auto ninePathCache = new ResourceCache!NinePatch;

    setResourceCache!Texture(textureCache);
    setResourceCache!Sprite(spriteCache);
    setResourceCache!Tileset(tilesetCache);
    setResourceCache!Animation(animationCache);
    setResourceCache!NinePatch(ninePathCache);

    Flip getFlip(JSONValue node) {
        switch (getJsonStr(node, "flip", "none")) {
        case "none":
            return Flip.none;
        case "horizontal":
            return Flip.horizontal;
        case "vertical":
            return Flip.vertical;
        case "both":
            return Flip.both;
        default:
            return Flip.none;
        }
    }

    Vec4i getClip(JSONValue node) {
        auto clipNode = getJson(node, "clip");
        Vec4i clip;
        clip.x = getJsonInt(clipNode, "x", 0);
        clip.y = getJsonInt(clipNode, "y", 0);
        clip.z = getJsonInt(clipNode, "w", 1);
        clip.w = getJsonInt(clipNode, "h", 1);
        return clip;
    }

    Vec2i getMargin(JSONValue node) {
        if (hasJson(node, "margin")) {
            auto marginNode = getJson(node, "margin");
            Vec2i margin;
            margin.x = getJsonInt(marginNode, "x", 0);
            margin.y = getJsonInt(marginNode, "y", 0);
            return margin;
        }
        return Vec2i.zero;
    }

    auto files = dirEntries(buildNormalizedPath(getBasePath(), "img"), "{*.json}", SpanMode.depth);
    foreach (file; files) {
        JSONValue json = parseJSON(readText(file));

        if (getJsonStr(json, "type") != "spritesheet")
            continue;

        auto srcImage = buildNormalizedPath(dirName(file),
            convertPathToImport(getJsonStr(json, "texture")));
        auto texture = new Texture(srcImage);
        textureCache.set(texture, srcImage);

        auto elementsNode = getJsonArray(json, "elements");

        foreach (JSONValue elementNode; elementsNode) {
            string name = getJsonStr(elementNode, "name");
            Vec4i clip = getClip(elementNode);
            Flip flip = getFlip(elementNode);

            const string elementType = getJsonStr(elementNode, "type", "null");
            switch (elementType) {
            case "sprite":
                auto sprite = new Sprite;
                sprite.clip = clip;
                sprite.flip = flip;
                sprite.size = to!Vec2f(clip.zw);
                sprite.drawable = texture;
                spriteCache.set(sprite, name);
                break;
            case "tileset":
                auto tileset = new Tileset;
                tileset.clip = clip;
                tileset.size = to!Vec2f(clip.zw);
                tileset.drawable = texture;
                tileset.flip = flip;
                tileset.margin = getMargin(elementNode);

                tileset.columns = getJsonInt(elementNode, "columns", 1);
                tileset.lines = getJsonInt(elementNode, "lines", 1);
                tileset.maxtiles = getJsonInt(elementNode, "maxtiles", 0);

                tilesetCache.set(tileset, name);
                break;
            case "multiDirAnimation":
            case "animation":
                const int columns = getJsonInt(elementNode, "columns", 1);
                const int lines = getJsonInt(elementNode, "lines", 1);
                const int maxtiles = getJsonInt(elementNode, "maxtiles", 0);

                const Vec2i margin = getMargin(elementNode);

                auto animation = new Animation(texture, clip, columns, lines, maxtiles, margin);

                switch (getJsonStr(elementNode, "mode", "once")) {
                case "once":
                    animation.mode = Animation.Mode.once;
                    break;
                case "reverse":
                    animation.mode = Animation.Mode.reverse;
                    break;
                case "loop":
                    animation.mode = Animation.Mode.loop;
                    break;
                case "loop_reverse":
                    animation.mode = Animation.Mode.loopReverse;
                    break;
                case "bounce":
                    animation.mode = Animation.Mode.bounce;
                    break;
                case "bounce_reverse":
                    animation.mode = Animation.Mode.bounceReverse;
                    break;
                default:
                    break;
                }
                animation.duration = getJsonFloat(elementNode, "duration", 1f);
                animation.flip = flip;

                if (hasJson(json, "frames")) {
                    int[] frames = getJsonArrayInt(json, "frames");
                    if (frames.length)
                        animation.frames = frames;
                }

                if (elementType == "multiDirAnimation") {
                    animation.dirs = getJsonInt(elementNode, "dirs", 1);
                    animation.maxDirs = getJsonInt(elementNode, "maxDirs", 1);
                    animation.dirOffset = Vec2i(getJsonInt(elementNode,
                            "dirXOffset", 0), getJsonInt(elementNode, "dirYOffset", 0));
                }

                animationCache.set(animation, name);
                break;
            case "ninepatch":
                auto ninePath = new NinePatch(texture, clip, getJsonInt(elementNode, "top", 0),
                    getJsonInt(elementNode, "bottom", 0), getJsonInt(elementNode,
                        "left", 0), getJsonInt(elementNode, "right", 0));
                ninePathCache.set(ninePath, name);
                break;
            default:
                break;
            }
        }
    }
}
