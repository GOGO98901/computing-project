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

class InputboxElement extends GuiElement {

	static final int width = 300, height =  40;

	int _x, _y;
	String _text, _placeholder;

	bool _hover = false, _focus = false;

	InputboxElement(CanvasElement canvas, int x, int y, [String placeholder]) : super(new Rectangle(x, y, width, height)) {
		this._x = x;
		this._y = y;
		this._placeholder = placeholder;

		canvas.onClick.listen((e) {
			if (Mouse.inCanvas()) {
				if (_bounds.containsPoint(Mouse.getPoint())) {
					_focus = true;
				} else _focus = false;
			}
		});
	}

	void _init() {
		_text = '';
	}

	void render(CanvasRenderingContext2D context) {
		if (_hover || _focus) {
			context..setFillColorRgb(0, 0, 0)
			..setStrokeColorRgb(0, 0, 0);
		} else {
			context..setStrokeColorRgb(100, 100, 100)
			..setFillColorRgb(100, 100, 100);
		}
		context.strokeRect(_x, _y, width, height);

		context.font = '19pt Roboto';
		context.fillText(_getText(), _x, _y + (height * 0.75).toInt());
	}

	String _getText() {
		if (_text == null) return  _placeholder;
		if (_text.length > 0) return _text;
		return _placeholder;
	}

	void update(final double delta) {
		_hover = false;
		if (_bounds.containsPoint(Mouse.getPoint())) {
			_hover = true;
		}
	}
}
