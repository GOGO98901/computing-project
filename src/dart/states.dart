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

class StateManager {

	GameHost _host;
	CanvasElement _canvas;

	/// This Map contains the game states and their corresponding keys
	Map<String, State> _states = new Map<String, State>();

	State _current;

	StateManager(this._host, this._canvas) {
		_states['intro'] = new StateIntro(this);
		_states['login'] = new StateLogin(this);
		_states['game'] = new StateGame(this);

		_current = _states['intro'];
		//_current = _states['login'];
		_current.setVisible(true);
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
		_current.setVisible(false);
		_current = next;
		_current.setVisible(true);
	}

	/// Renders the current state
	void render(CanvasRenderingContext2D context) {
		context..setFillColorRgb(200, 200, 200)..fillRect(0, 0, GameHost.width, GameHost.height);
		_current..renderBackground(context)..render(context)..renderGui(context);
	}

	/// Updates the current state
	void update(final double delta) {
		_current..updateBackground(delta)..update(delta)..updateGui(delta);
	}

	GameHost get host => _host;

	CanvasElement get canvas => _canvas;
}

abstract class State {
	final StateManager _manager;

	HashMap<String, GuiElement> _gui;

	Sprite _background;

	bool _visible = false;

	double _starOffset = 0.0;

	State(this._manager)  {
		_gui = new HashMap<String, GuiElement>();
		init(_manager.canvas);
		if (_background == null) _background = ResourceManager.getSprite("background.blue");
	}

	/// Abstract initializer
	void init(CanvasElement canvas);

	/// Abstrcat render method
	void render(CanvasRenderingContext2D context);

	/// Function that renders the background
	/// Using a small image, the image is rendered next to each other to fill the screen
	void renderBackground(CanvasRenderingContext2D context) {
		if (_background != null) if (_background.isComplete()) {
			ImageElement image = _background.texture;
			for (int y = 0; y < GameHost.height + _background.height; y += _background.height) {
				for (int x = 0; x < GameHost.width; x += _background.width) {
					context.drawImage(image, x, y - _starOffset);
				}
			}
		}
	}

	/// Function to render all the gui elements in the state
	void renderGui(CanvasRenderingContext2D context) {
		_gui.values.forEach((element) => element.render(context));
	}

	/// Abstrcat update method
	void update(final double delta);

	/// Function to update all the gui elements in the state
	void updateGui(final double delta) {
		_gui.values.forEach((element) => element.update(delta));
	}

	void updateBackground(final double delta) {
		if (_background != null) {
			_starOffset += delta * 5;
			if (_starOffset >= _background.height) _starOffset = 0.0;
		}
	}

	bool get visible => _visible;

	/// Notifies all elements in the state of [vis]
	void setVisible(bool vis) {
		this._visible = vis;
		this._gui.values.forEach((element) => element.setParentVisible(vis));
		onVisibilityChange();
	}

	/// Function that can be overwriten
	/// Called when the value of [visible] changes
	void onVisibilityChange() {}
}

class StateIntro extends State {

	StateIntro(StateManager _manager) : super(_manager);

	Sprite _logo;

	double _time = 0.0;

	void init(CanvasElement canvas) {
		_logo = ResourceManager.getSprite('logo.roryclaasen.white');
		_gui['skip'] = new GuiButtonElement(canvas, GameHost.width - GuiButtonElement.width - 20, GameHost.height - GuiButtonElement.height - 20, "skip");
		(_gui['skip'] as GuiButtonElement)..setDisabled(true)..listen(canvas, (e, s) {
			_manager.changeState('login');
		});
	}

	void render(CanvasRenderingContext2D context) {
		context..setFillColorRgb(255, 255, 255)..fillText(document.title, 75, 100);
		if (_logo.isComplete()) {
			int w = (_logo.width * 0.75).toInt();
			int h = (_logo.width * 0.75).toInt();
			context.drawImageScaled(_logo.texture, 75, 100 + ((GameHost.height - 120) - h) / 2, w, h);
		}
	}

	void update(final double delta) {
		if (_time >= 0) _time += delta;
		// TODO At some point add a check for resource loading
		//		Till then the time will suffice
		if (_time > 1.75 && _time < 2) (_gui['skip'] as GuiButtonElement).setDisabled(false);
		if (_time > 5) {
			_time = -1.0;
			_manager.changeState('login');
		}
	}
}

class StateLogin extends State {

	int _xPadding = 75;
	double _hover = 0.0;

	StateLogin(StateManager _manager) : super(_manager);

	Sprite _station = ResourceManager.getSprite("game.enities.station");

	void init(CanvasElement canvas) {
		_gui['play'] = new GuiButtonElement(_manager.canvas, _xPadding, 200, "Play");
		_gui['token'] = new GuiButtonElement(_manager.canvas, _xPadding, 275, "Login");
		// _gui['fullscreen'] = new GuiButtonElement(_manager.canvas(), _xPadding, GameHost.height - 100, "FullScreen", true);
		(_gui['token'] as GuiButtonElement).listen(canvas, (e, s) {
			js.context.callMethod(r'$', ['#modelGameLogin']).callMethod('modal', ['show']);
		});
		(_gui['play'] as GuiButtonElement).listen(canvas, (e, s) {
			_manager.changeState('game');
		});
		//(_gui['fullscreen'] as GuiButtonElement).onClick(canvas, (e, s) {
		//		screenHandler.setFullScreen(!screenHandler.isFullScreen());
		//});

		querySelector('#gameLogin').onClick.listen((event) {
			InputElement input = querySelector('#gameToken') as InputElement;
			String token = input.value;
			if (token != null) if (Util.regex.matches(token, Util.regex.token)) {
				_manager.host.userManagement.login(token).then((connected) {
				if (connected) {
					input.parent.classes.remove('has-error');
					Notify.info("Logged in");
					js.context.callMethod(r'$', ['#modelGameLogin']).callMethod('modal', ['hide']);
					_manager.changeState('game');
				} else {
					input.parent.classes.add('has-error');
					Notify.warn("Unable to login");
				}
			});
			} else {
				input.parent.classes.add('has-error');
				Notify.warn("Unable to login", "Incorrect login token");
			}
		});
	}

	void render(CanvasRenderingContext2D context) {
		context..setFillColorRgb(255, 255, 255)..fillText(document.title, _xPadding, 100);
		if (_station.isComplete()) {
			context..save()
    		..translate((GameHost.width / 1.4) + (2 * sin(_hover)), (GameHost.height / 2) + (10 * sin(_hover * 1.5)))
   			..rotate(45 * PI / 180)
   			..drawImage(_station.texture, -_station.width / 2, -_station.height / 2)
   			..restore();
		}
	}

	void update(final double delta) {
		_hover += delta;
		if (_hover > 360) _hover = 0.0;
	}
}

class StateGame extends State {

	GameLevel _level;

	StateGame(StateManager _manager) : super(_manager);

	void init(CanvasElement canvas) {
		_gui['score'] = new GuiText("0000", 20, 20 + 25);

		ResourceManager.listenForStringFinsh((e) {
			Queue<String> queue = new Queue<String>();
			queue.add(Util.regex.replaceFirst(ResourceManager.getString('game.msg.intro.1'), _manager.host.userManagement.playerName, Util.regex.vars));
			queue.add(ResourceManager.getString('game.msg.intro.2'));
			_gui['temp'] = new GuiTextMessage(null, 50, GameHost.height - 140,queue, canvas);
		});

	}

	void onVisibilityChange() {
		if (visible) {
			if (_manager.host.userManagement.loggedIn) _level = GameLevel.newLevel(_manager.host.userManagement.currentUser);
			else _level = GameLevel.newLevel();
		}
	}

	void render(CanvasRenderingContext2D context) {
		if (_level != null) _level.render(context);
	}

	void update(final double delta) {
		if (_level != null){
			_level.update(delta);
			(_gui['score'] as GuiText).setText(_level.formattedScore);
		}
	}
}
