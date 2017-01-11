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

class Util {
	static final Spec spec = new Spec();
	static final Regex regex = new Regex();

	/// Gets the Uri that the system is connected from
	static Uri getUri() {
		return Uri.base;
	}

	/// Returns `true` when not connected to from the local host `127.0.0.1`
	static bool isLive()  {
		String address = getUri().toString().toLowerCase().replaceFirst("http://", "");
		// Helper.notify(Helper.info, address);
		if (address.startsWith('127.0.0.1')) return false;
		return true;
	}

	static void drawCenteredText(String text, int x, int y, int width, int height, CanvasRenderingContext2D context, [String font]) {
		if (text == null) text = "";
		int textWidth = getTextMetrics(context, text, font).width.round();
		context.fillText(text, x + (width / 2) - (textWidth / 2), y + (height * 0.775));
	}

	static TextMetrics getTextMetrics(CanvasRenderingContext2D context, String text, [String font]) {
		if (text == null) text = "";
		if (font == null) font = "30pt KenVector Future";
		context.font = font;
		return context.measureText(text);
	}
}

class PointSmart {
	int _x, _y;

	PointSmart(this._x, this._y);

	void setX(int x) {
		this._x = x;
	}

	void setY(int y) {
		this._y = y;
	}

	int get x => _x;
	int get y => _y;

	void set(int x, int y) {
		this._x = x;
		this._y = y;
	}

	Vector2 get vector2 => new Vector2(0.0 + _x, 0.0 + _y);

	Point toPoint() {
		return new Point(_x, _y);
	}

	operator +(PointSmart other) => new PointSmart(_x + other._x, _y + other._y);
	operator -(PointSmart other) => new PointSmart(_x - other._x, _y - other._y);
	operator *(int factor) => new PointSmart(_x * factor, _y * factor);
	operator /(int factor) => new PointSmart(_x ~/ factor, _y ~/ factor);
}

class Spec {

	bool _loaded = false;

	YamlMap _map;

	Spec() {
		if (Util.isLive()) {
			_load().then((map) {
				if (map != null) {
					_loaded = true;
					_map = map;

					log.info("[${name()}] ${version()}#${build()}");
				}
			});
		} else log.warning("skiped loading pubspec due to runnign local host");
	}

	String name() {
		return _get('name');
	}

	String description() {
		return _get('description');
	}

	String homepage() {
		return _get('homepage');
	}

	String version() {
		return _get('version');
	}

	String build() {
		return _get('build');
	}

	String _get(String key){
		if (_loaded) return _map[key];
		return "";
	}

	@deprecated
	YamlMap map() {
		return _map;
	}

	bool isLoaded() {
		return _loaded;
	}

	Future<YamlMap> _load() {
		Completer<YamlMap> completer = new Completer();
		HttpRequest.getString('pubspec.yaml').then((String yaml) {
			log.info("loaded pubspec");
			completer.complete(loadYaml(yaml));
		}).catchError((Error error) {
			log.warning("failed to load pubspec");
			completer.complete(null);
		});
		return completer.future;
	}
}

enum AnimationStage {
	idle, running, stopped
}

abstract class Animation {
	AnimationStage _stage = AnimationStage.idle;
	final Object _source;
	Object _output;

	Animation(this._source);

	void start() {
		_stage = AnimationStage.running;
	}

	void stop() {
		_stage = AnimationStage.stopped;
	}

	void update(final double delta);

	AnimationStage get stage => _stage;
	Object get source => _source;
	Object get output => _output;
}

class TextAnimation extends Animation {

	double _time = 0.0;
	double _interval = 0.05;

	int _char = 1;

	TextAnimation(String source, [double interval]) : super(source) {
		if (interval != null) _interval = interval;
		_output = "";
	}

	void update(final double delta) {
		if (stage == AnimationStage.running) {

			_time += delta;
			if (_time > _interval) {
				_char++;
				if (_source != null) {
					if (_char >= (_source as String).length) {
						_char = (_source as String).length;
						stage == AnimationStage.stopped;
					}
					_output = (_source as String).substring(0, _char);
				}
				_time %= _interval;
			}
		}
	}

	String get source => _source;
	String get output => _output;

	// noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class Regex {
	RegExp get vars => new RegExp(r'\$[^0]\d+|\$[1-9]');
}
