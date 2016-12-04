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

class MasterHandler {
	CanvasElement _canvas;

	Keyboard _keyboard;
	Mouse _mouse;

	MasterHandler(this._canvas) {
		_keyboard = new Keyboard();
		_mouse = new Mouse(_canvas);
	}

	Mouse getMouse()  {
		return _mouse;
	}

	Keyboard getKeyboard() {
		return _keyboard;
	}
}

class Keyboard {
	static final HashSet<int> _keys = new HashSet<int>();

	Keyboard() {
		window.onKeyDown.listen((final KeyboardEvent e) {
			_keys.add(e.keyCode);
		});

		window.onKeyUp.listen((final KeyboardEvent e) {
			_keys.remove(e.keyCode);
		});
	}

	static isPressed(int keyCode) => _keys.contains(keyCode);
}

class Mouse {
	static int _x = 0, _y = 0;
	static bool _inside;
	CanvasElement _canvas;
	Mouse(this._canvas) {
		_canvas.onMouseMove.listen((e) {
			_inside = false;
			if (_canvas.getBoundingClientRect().containsPoint(e.client)) {
				_inside = true;
				_x = e.offset.x;
				_y = e.offset.y;
			}
		});
	}

	static bool inCanvas() {
		return _inside;
	}

	static int getX() {
		return _x;
	}

	static int getY() {
		return _y;
	}

	static Point getPoint() {
		return new Point(_x, _y);
	}
}

class ScreenHandler {
	GameHost _host;

	int _startWidth, _startHeight;

	bool _fullScreen = false;

	ScreenHandler(this._host) {
		updateCanvasSize();
		_startWidth = _host.getCanvas().getBoundingClientRect().width;
		_startHeight = _host.getCanvas().getBoundingClientRect().height;
		_host.updateSize(_startWidth, _startHeight);
	}

	void setFullScreen(bool state) {
		_fullScreen = state;
		if (state) {
			js.context.callMethod('goFullScreen');
			updateCanvasSize(window.innerWidth, window.innerHeight);
			_host.updateSize(window.innerWidth, window.innerHeight);
		} else {
			js.context.callMethod('exitFullScreen');
			updateCanvasSize(_startWidth, _startHeight);
			_host.updateSize(_canvas.width, _canvas.height);
		}
	}

	void updateCanvasSize([int width, int height]) {
		log.info("Setting game canvas attribute size");
		if (width == null) width = _host.getCanvas().getBoundingClientRect().width;
		if (height == null) height = _host.getCanvas().getBoundingClientRect().height;
		_canvas.attributes['width'] = "${width}px";
		_canvas.attributes['height'] = "${height}px";
	}

	bool isFullScreen() {
		return _fullScreen;
	}
}
