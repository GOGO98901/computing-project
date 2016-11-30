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

class GameHost {
	final CanvasElement _canvas;
	final CanvasRenderingContext2D _context;
	static int width, height;
	int _lastTimestamp = 0;
	bool _running = false;

	MasterHandler handler;
	ResourceManager resources;
	UserManagement userManagement;
	StateManager stateManager;

	GameHost(this._canvas, this._context) {
		width = _canvas.width;
		height = _canvas.height;
		_canvas.onResize.listen((event) {
			width = _canvas.width;
			height = _canvas.height;
		});
		resources = new ResourceManager();
		handler = new MasterHandler(_canvas);
		userManagement = new UserManagement();
		stateManager = new StateManager(this, _canvas);
	}

	/// Method to start the gameloop
	///
	/// Stops when `running` is set to `false`
	run() {
		_running = true;
		_canvas.focus();
		window.requestAnimationFrame(_gameLoop);
	}

	/// Main game loop function
	void _gameLoop(double _) {
		_update(_getDelta());
		_render(_context);
		if (_running) window.requestAnimationFrame(_gameLoop);
	}

	/// Get the current delta from the last call to this call
	double _getDelta() {
		final int time = new DateTime.now().millisecondsSinceEpoch;
		double elapsed = 0.0;
		if (_lastTimestamp != 0) elapsed = (time - _lastTimestamp) / 1000.0;
		_lastTimestamp = time;
		return elapsed;
	}

	/// Main render function
	///
	/// [context] is the rendering context of the game canvas
	void _render(CanvasRenderingContext2D context) {
		stateManager.render(context);
	}

	/// Main update method
	///
	/// [delta] is the time between the last updated to this one
	/// e.g. `0.25` is `250` mills
	void _update(final double delta) {
		stateManager.update(delta);
	}
}
