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

class StateManager {

	CanvasElement _canvas;

	/// This Map contains the game states and their corresponding keys
	Map<String, State> _states = new Map<String, State>();

	State _current;

	StateManager(this._canvas) {
		_states['intro'] = new StateIntro(this);
		_states['login'] = new StateLogin(this);
		_states['game'] = new StateGame(this);

		//_current = _states['intro'];
		_current = _states['login'];
	}

	/// Changes the state to [tag]
	/// If tag is null or there is no state called [tag] the state will not change!
	void changeState(String tag) {
		State next = _states[tag];
		if (next == null) {
			log.severe("State '${tag} is null");
			Notify.error("StateManager", "${tag} state is null");
			return;
		}
		_current = next;
	}

	/// Renders the current state
	void render(CanvasRenderingContext2D context) {
		context..setFillColorRgb(255, 255, 255)..fillRect(0, 0, GameHost.width, GameHost.height);
		_current..render(context)..renderGui(context);
	}

	/// Updates the current state
	void update(final double delta) {
		_current..update(delta)..updateGui(delta);
	}

	CanvasElement canvas() {
		return  _canvas;
	}
}

abstract class State {
	final StateManager _manager;

	HashMap<String, GuiElement> _gui;
	State(this._manager)  {
		_gui = new HashMap<String, GuiElement>();
		init(_manager.canvas());
	}

	/// Abstract initializer
	void init(CanvasElement canvas);

	/// Abstrcat render method
	void render(CanvasRenderingContext2D context);

	void renderGui(CanvasRenderingContext2D context) {
		_gui.values.forEach((element) {
			element.render(context);
		});
	}

	/// Abstrcat update method
	void update(final double delta);

	void updateGui(final double delta) {
		_gui.values.forEach((element) {
			element.update(delta);
		});
	}
}

class StateIntro extends State {

	StateIntro(StateManager _manager) : super(_manager);

	Sprite _logo;

	double _time = 0.0;

	void init(CanvasElement canvas) {
		_logo = ResourceManager.getSprite('logo.roryclaasen.black');
	}

	void render(CanvasRenderingContext2D context) {
		if (_logo.isComplete()) {
			int w = (_logo.width() * 0.75).toInt();
			int h = (_logo.width() * 0.75).toInt();
			context.drawImageScaled(_logo.getTexture(), (GameHost.width / 2) - (w / 2), (GameHost.height / 2) - (h / 2), w, h);
		}
	}

	void update(final double delta) {
		if(_time >= 0)_time += delta;
		if (_time > 2) {
			_time = -1.0;
			_manager.changeState('login');
		}
	}
}

class StateLogin extends State {

	StateLogin(StateManager _manager) : super(_manager);

	void init(CanvasElement canvas) {
		_gui['token'] = new GuiButtonElement(_manager.canvas(), 100, 100, "Login");

		EventStreamProvider eventStreamProvider = new EventStreamProvider<CustomEvent>("GuiEvent");
		eventStreamProvider.forTarget(canvas).listen((e) {
			if (e.detail['type']=='button') {
				if (e.detail['text'] == (_gui['token'] as GuiButtonElement).getText()) {
					js.context.callMethod(r'$', ['#modelGameLogin']).callMethod('modal', ['show']);
				}
			}
		});
	}

	void render(CanvasRenderingContext2D context) {
		// TODO Create login page
	}

	void update(final double delta) {}
}

class StateGame extends State {

	StateGame(StateManager _manager) : super(_manager);

	void init(CanvasElement canvas) {}

	void render(CanvasRenderingContext2D context) {}

	void update(final double delta) {}
}
