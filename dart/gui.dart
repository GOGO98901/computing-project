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

	static final int width = 300, height =  40;

	int _x, _y;

	GuiButtonElement(CanvasElement canvas, int x, int y, [String text]) : super(new Rectangle(x, y, width, height)) {
		this._x = x;
		this._y = y;
	}

	void _init() {

	}

	void render(CanvasRenderingContext2D context) {
	}

	void update(final double delta) {

	}
}
