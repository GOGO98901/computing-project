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
	Map<String, State> _states = new Map<String, State>();

	State _current;

	StateManager() {
		_states['intro'] = new StateIntro(this);
		_states['login'] = new StateLogin(this);
		_states['game'] = new StateGame(this);

		_current = _states['intro'];
	}

	void changeState(String tag) {
		State next = _states[tag];
		if (next == null) {
			log.severe("State '${tag} is null");
			Helper.notify(Helper.error, "StateManager", "${tag} state is null");
			return;
		}
		_current = next;
	}

	void render(CanvasRenderingContext2D context) {
		_current.render(context);
	}

	void update(final double delta) {
		_current.update(delta);
	}
}

abstract class State {
	final StateManager _manager;
	State(this._manager)  {
		init();
	}

	void init();

	void render(CanvasRenderingContext2D context);
	void update(final double delta);
}

class StateIntro extends State {

	StateIntro(StateManager _manager) : super(_manager);

	Sprite _logo;

	double _time = 0.0;

	void init() {
		_logo = ResourceManager.getSprite('logo.roryclaasen');
	}

	void render(CanvasRenderingContext2D context){
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

		void init() {}

		void render(CanvasRenderingContext2D context) {}

		void update(final double delta) {}
}

class StateGame extends State {

		StateGame(StateManager _manager) : super(_manager);

		void init() {}

		void render(CanvasRenderingContext2D context) {}

		void update(final double delta) {}
}
