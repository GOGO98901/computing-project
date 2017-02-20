/*
Copyright 2016-2017 Rory Claasen

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

	Mouse get mouse => _mouse;

	Keyboard get keyboard => _keyboard;
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

	static int get x => _x;
	static int get y => _y;

	static Point get point => new Point(_x, _y);
}

class ScreenHandler {
	GameHost _host;

	int _startWidth, _startHeight;

	bool _fullScreen = false;

	@deprecated
	ScreenHandler(this._host) {
		updateCanvasSize();
		_startWidth = _host.canvas.getBoundingClientRect().width;
		_startHeight = _host.canvas.getBoundingClientRect().height;
		// ignore: deprecated_member_use
		_host.updateSize(_startWidth, _startHeight);
	}

	void setFullScreen(bool state) {
		_fullScreen = state;
		int width, height;
		if (state) {
			js.context.callMethod('goFullScreen');
			width = window.innerWidth;
			height = window.innerHeight;
		} else {
			js.context.callMethod('exitFullScreen');
			width = _startWidth;
			height = _startHeight;
		}
		updateCanvasSize(width, height);
		// ignore: deprecated_member_use
		_host.updateSize(_canvas.width, _canvas.height);
	}

	void updateCanvasSize([int width, int height]) {
		if (width == null) width = _host.canvas.getBoundingClientRect().width;
		if (height == null) height = _host.canvas.getBoundingClientRect().height;
		log.info("Setting game canvas attribute size [${width}px x ${height}px]");
		_canvas.attributes['width'] = "${width}px";
		_canvas.attributes['height'] = "${height}px";
	}

	bool isFullScreen() {
		return _fullScreen;
	}
}
