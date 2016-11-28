/*
Copyright 2016 Rory Claasen

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
part of Computer_Science_Project;

abstract class GuiElement {
	Rectangle _bounds;

	GuiElement(this._bounds)  {
		_init();
	}

	/// Abstract initializer
	void _init();

	/// Abstrcat render method
	void render(CanvasRenderingContext2D context);

	/// Abstrcat update method
	void update(final double delta);

	void setBounds(Rectangle bounds) {
		_bounds = bounds;
	}

	Rectangle getBounds() {
		return _bounds;
	}
}

class GuiButtonElement extends GuiElement {

	static final int width = 190, height =  45, offset = 4;

	int _x, _y, _offset;
	String _text;

	bool _hover = false;

	Sprite _up, _down, _current;

	GuiButtonElement(CanvasElement canvas, int x, int y, [String text]) : super(new Rectangle(x, y, width, height)) {
		this._x = x;
		this._y = y;
		this._offset = 0;
		this._text = text;

		canvas.onClick.listen((e) {
			if (_hover) {
				var detail = {
					"type": "button",
					"x": _x,
					"y": _y,
					"text": _text
				};
				var event = new CustomEvent("GuiEvent", canBubble: false, cancelable: false, detail: detail);
				canvas.dispatchEvent(event);
			}
		});
	}

	void _init() {
		_up = ResourceManager.getSprite('ui.button.up.blue');
		_down = ResourceManager.getSprite('ui.button.down.blue');

		_current = _up;
	}

	void render(CanvasRenderingContext2D context) {
		context.drawImage(_current.getTexture(), _x, _y + _offset);
		context.setFillColorRgb(255, 255, 255);
		context.font = "30pt KenVector Future";
		Util.drawCenteredText(_text, _x, _y + _offset, width, height, context);
	}

	void update(final double delta) {
		if (Mouse.inCanvas())  {
			if (_bounds.containsPoint(Mouse.getPoint())) {
				_hover = true;
			} else _hover = false;
		} else _hover = false;

		if (_hover) {
			_current = _down;
			_offset = offset;
		} else {
			_current = _up;
			_offset = 0;
		}
	}

	String getText() {
		return _text;
	}
}
