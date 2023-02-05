/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module gui.label;

import std.algorithm.comparison : min;
import std.string, std.conv;

import atelier;

import common;

/// A single line of text.
final class CustomLabel : GuiElement {
    private {
        dstring _text;
        Font _font;
        int _charSpacing, _charScale = 1;
    }

    @property {
        /// Text
        string text() const {
            return to!string(_text);
        }
        /// Ditto
        string text(string text_) {
            _text = to!dstring(text_);
            reload();
            return text_;
        }

        /// Font
        Font font() const {
            return cast(Font) _font;
        }
        /// Ditto
        Font font(Font font_) {
            _font = font_;
            reload();
            return _font;
        }

        /// Additionnal spacing between each character
        int charSpacing() const {
            return _charSpacing;
        }
        /// Ditto
        int charSpacing(int charSpacing_) {
            return _charSpacing = charSpacing_;
        }

        /// Characters scaling
        int charScale() const {
            return _charScale;
        }
        /// Ditto
        int charScale(int charScale_) {
            return _charScale = charScale_;
        }
    }

    /// Build label
    this(string text_ = "", Font font = getDefaultFont()) {
        setInitFlags(Init.notInteractable);
        _font = font;
        _text = to!dstring(text_);
        reload();
    }

    private void reload() {
        Vec2f totalSize_ = Vec2f(0f, _font.ascent - _font.descent) * _charScale;
        float lineWidth = 0f;
        dchar prevChar;
        foreach (dchar ch; _text) {
            if (getLocaleKey() == "eo") {
                if (ch == 'x') {
                    switch (prevChar) {
                    case 'c':
                    case 'C':
                    case 's':
                    case 'S':
                    case 'g':
                    case 'G':
                    case 'j':
                    case 'J':
                    case 'h':
                    case 'H':
                    case 'u':
                    case 'U':
                        continue;
                    default:
                        break;
                    }
                }
            }
            if (ch == '\n') {
                lineWidth = 0f;
                totalSize_.y += _font.lineSkip * _charScale;
            }
            else {
                const Glyph metrics = _font.getMetrics(ch);
                lineWidth += _font.getKerning(prevChar, ch) * _charScale;
                lineWidth += metrics.advance * _charScale;
                if (lineWidth > totalSize_.x)
                    totalSize_.x = lineWidth;
                prevChar = ch;
            }
        }
        size = totalSize_;
    }

    override void draw() {
        Vec2f pos = origin;
        dchar prevChar;
        float prevPos = 0f;
        foreach (dchar ch; _text) {
            if (ch == '\n') {
                pos.x = origin.x;
                pos.y += _font.lineSkip * _charScale;
                prevChar = 0;
            }
            else if (getLocaleKey() == "eo" && ch == 'x') {
                // Du bidouillage complet car bitstream gère pas ces accents là ces shlags.
                dchar diacritic = (prevChar == 'u' || prevChar == 'U') ? '˘' : '^';
                Vec2i diaOffset = Vec2i.zero;
                switch (prevChar) {
                case 'u':
                    diaOffset = Vec2i(1, 0);
                    break;
                case 'U':
                    diaOffset = Vec2i(2, 2);
                    break;
                case 'c':
                    diaOffset = Vec2i(-2, 3);
                    break;
                case 'C':
                    diaOffset = Vec2i(0, 6);
                    break;
                case 's':
                    diaOffset = Vec2i(-3, 3);
                    break;
                case 'S':
                    diaOffset = Vec2i(-2, 6);
                    break;
                case 'g':
                    diaOffset = Vec2i(-2, 3);
                    break;
                case 'G':
                    diaOffset = Vec2i(0, 6);
                    break;
                case 'j':
                    diaOffset = Vec2i(-4, 1);
                    break;
                case 'J':
                    diaOffset = Vec2i(-4, 6);
                    break;
                case 'h':
                    diaOffset = Vec2i(-2, 6);
                    break;
                case 'H':
                    diaOffset = Vec2i(-1, 6);
                    break;
                default:
                    Glyph metrics = _font.getMetrics(ch);
                    if (!metrics.exists)
                        continue;
                    pos.x += _font.getKerning(prevChar, ch) * _charScale;
                    Vec2f drawPos = Vec2f(pos.x + metrics.offsetX * _charScale,
                        pos.y - metrics.offsetY * _charScale);
                    metrics.draw(drawPos, _charScale, color, alpha);
                    prevPos = pos.x;
                    pos.x += (metrics.advance + _charSpacing) * _charScale;
                    prevChar = ch;
                    continue;
                }

                Glyph metrics = _font.getMetrics(diacritic);
                if (!metrics.exists)
                    continue;
                Vec2f drawPos = Vec2f(prevPos + (metrics.offsetX + diaOffset.x) * _charScale,
                    pos.y - (metrics.offsetY + diaOffset.y) * _charScale);
                metrics.draw(drawPos, _charScale, color, alpha);
            }
            else {
                Glyph metrics = _font.getMetrics(ch);
                if (!metrics.exists)
                    continue;
                pos.x += _font.getKerning(prevChar, ch) * _charScale;
                Vec2f drawPos = Vec2f(pos.x + metrics.offsetX * _charScale,
                    pos.y - metrics.offsetY * _charScale);
                metrics.draw(drawPos, _charScale, color, alpha);
                prevPos = pos.x;
                pos.x += (metrics.advance + _charSpacing) * _charScale;
                prevChar = ch;
            }
        }
    }
}
