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

class ResourceManager {

	static EventStreamProvider _esp = new EventStreamProvider<CustomEvent>("resourceSafety");

	static HashMap<String, Sprite> _sprites;

	static HashMap<String, String> _strings;
	static JsonFile _lang;

	static JsonFile sample;

	ResourceManager() {
		_sprites = new HashMap<String, Sprite>();
		_strings = new HashMap<String, String>();

		_lang = _loadJsonFile('lang.json');
		_lang.onLoad.then((data) {
	 		_addStringsInMap(JSON.decode(data.toString()));
			var event = new CustomEvent("resourceSafety", canBubble: false, cancelable: false);
			window.dispatchEvent(event);
		});
		_initSprites();

		sample = _loadJsonFile('problem.sample.json');
	}

	/// All sprites get loaded at this point in the program
	///
	/// This means that images will not have to be created more than once
	void _initSprites() {
		_sprites['logo.roryclaasen.white'] = _loadSprite('project white.png');
		_sprites['logo.roryclaasen.black'] = _loadSprite('project black.png');

		_sprites['ui.button.up.blue'] = _loadSprite('game/ui/kenney/blue_button02.png');
		_sprites['ui.button.down.blue'] = _loadSprite('game/ui/kenney/blue_button03.png');

		_sprites['ui.glass.tr'] = _loadSprite('game/ui/kenney/glassPanel_cornerTL.png');

		_sprites['background.black'] = _loadSprite('game/background/kenney/black.png');
		_sprites['background.blue'] = _loadSprite('game/background/kenney/blue.png');
		_sprites['background.purple'] = _loadSprite('game/background/kenney/purple.png');
		_sprites['background.purple.dark'] = _loadSprite('game/background/kenney/darkPurple.png');

		_sprites['game.enities.station'] = _loadSprite('game/entities/kenney/spaceStation_017.png');
		_sprites['game.enities.station.one'] = _loadSprite('game/entities/kenney/spaceStation_020.png');
		_sprites['game.enities.station.one.shield'] = _loadSprite('game/entities/spaceStation_020_shield.png');
		_sprites['game.enities.station.two'] = _loadSprite('game/entities/kenney/spaceStation_021.png');
		_sprites['game.enities.station.three'] = _loadSprite('game/entities/kenney/spaceStation_024.png');

		_sprites['game.enities.metor.big.1'] = _loadSprite('game/entities/kenney/meteorBrown_big1.png');
		_sprites['game.enities.metor.big.2'] = _loadSprite('game/entities/kenney/meteorBrown_big2.png');
		_sprites['game.enities.metor.big.3'] = _loadSprite('game/entities/kenney/meteorBrown_big3.png');
		_sprites['game.enities.metor.big.4'] = _loadSprite('game/entities/kenney/meteorBrown_big4.png');
		_sprites['game.enities.metor.med.1'] = _loadSprite('game/entities/kenney/meteorBrown_med1.png');
		_sprites['game.enities.metor.med.2'] = _loadSprite('game/entities/kenney/meteorBrown_med3.png');
		_sprites['game.enities.metor.small.1'] = _loadSprite('game/entities/kenney/meteorBrown_small1.png');
		_sprites['game.enities.metor.small.2'] = _loadSprite('game/entities/kenney/meteorBrown_small2.png');
		_sprites['game.enities.metor.tiny.1'] = _loadSprite('game/entities/kenney/meteorBrown_tiny1.png');
		_sprites['game.enities.metor.tiny.2'] = _loadSprite('game/entities/kenney/meteorBrown_tiny2.png');
	}

	/// Recursive function that goes though every level of a json file
	/// When the function finds a `String` the string is put in to a hashmap with a key of all the levels it is from
	void _addStringsInMap(Map map, [String key]) {
		if (key == null) key = "";
		map.forEach((k, v) {
			JsonObject object = new JsonObject.fromJsonString(JSON.encode(v));
			Object test = JSON.decode(object.toString());
			if (test is String) {
				_strings["$key$k"] = v;
			} else {
				_addStringsInMap(test, "$key$k.");
			}
		});
	}

	/// Simple function to create a `Sprite` instance from [name] and [dir]
	Sprite _loadSprite(String name, {String dir}) {
		if (dir == null) return new Sprite("${getAssetsDir()}/images/${name}");
		else return new Sprite("${dir}/${name}");
	}

	/// Simple function to create a `JsonFile` instance from [name] and [dir]
	JsonFile _loadJsonFile(String name, {String dir}) {
			if (dir == null) return new JsonFile("${getAssetsDir()}/json/${name}");
			else return new JsonFile("${dir}/${name}");
	}

	/// Fucntion to get a `String` from the strings array
	/// If key does not exist then the function will return "missing" rather than `null`
	static String getString(String key) {
		if (_strings.containsKey(key)) return _strings[key];
		log.warning("Key [$key] not found in strings array. May still be loading or missing");
		return 'missing';
	}

	/// Gets the sprite from the hash map with the corresponding [key]
	/// If key does not exist then the function will return `null`
	static Sprite getSprite(String key) {
		if (_sprites.containsKey(key)) return _sprites[key];
		log.warning("Key [$key] not found in sprites array. May still be loading or missing");
		return null;
	}

	/// Event funtion allowing for execuation when the strings array has been loaded
	/// If the file has allready been loaded the the function will be called regardless
	static void listenForStringFinsh(Function function) {
		// Try not to call this when  they are loaded as _langLoaded does not seam to work
		// if (_langLoaded) function(_lang);

		_esp.forTarget(window).listen((e) {
			function(e);
		});
	}

	/// Checks that all resources are loaded or have errored
	/// Will return `false` when a resource is still loading or has not started loading
	static bool resourcesLoaded() {
		if (!(_lang.isFailed() || _lang.isComplete())) return false;
		_sprites.values.forEach((s) {
			if (!(s.isComplete() || s.isFailed())) return false;
		});
		return true;
	}

	/// Returns the directory for the assets folder
	static String getAssetsDir() {
		// if (Util.isLive()) return "computing-project/assets";
		return "assets";
	}
}

/// Resource enumerator
/// Helps with loading the file/resource
enum Status {
	initialized, started, failed, complete
}

abstract class BaseResource {
	Status _status = Status.initialized;

	BaseResource() {
		_start();
	}

	/// Abstract function that starts the loading process
	void _start();

	/// Gets the current status of the resource
	Status get status => _status;

	/// Returns `true` if the current status equals complete
	bool isComplete() {
		return _status == Status.complete;
	}

	/// Returns `true` if the current status equals failed
	bool isFailed() {
		return _status == Status.failed;
	}
}


class Sprite extends BaseResource {
	ImageElement _image;
	String  _source;

	Sprite(this._source);

	void _start() {
		_status = Status.started;

		_image = new ImageElement(src: _source);
		_image.onLoad.listen((e) {
			_status = Status.complete;
		});
		_image.onError.listen((e) {
			_status = Status.failed;
		});
	}

	/// Returns the width of the image only if it is loaded
	int get width {
		if (isComplete()) return _image.width;
		return 0;
	}

	/// Returns the height of the image only if it is loaded
	int get height {
		if (isComplete()) return _image.height;
		return 0;
	}

	/// Returns the image element of the source
	ImageElement get texture => _image;

	/// Returns the source that was entered when created
	String get source => _source;
}

class JsonFile extends BaseResource {
	String  _source;
	JsonObject _data;

	JsonFile(this._source);

	void _start() {
		_status = Status.started;
		HttpRequest.getString(_source).then((String dataString) {
			_data = new JsonObject.fromJsonString(dataString);
			_status = Status.complete;

			var detail = {
				"source": _source,
				"data": _data
			};

			window.dispatchEvent(new CustomEvent("jsonLoad", canBubble: false, cancelable: false, detail: detail));
		}).catchError((Error error) {
			_data = new JsonObject();
			_status = Status.failed;
		});
	}

	/// Future function that can be used to help with collecting the contents after being loaded into the program
	Future<JsonObject> get onLoad {
		Completer<JsonObject> completer = new Completer<JsonObject>();
		EventStreamProvider eventStreamProvider = new EventStreamProvider<CustomEvent>("jsonLoad");
		eventStreamProvider.forTarget(window).listen((e) {
			if (e.detail['source'] == _source) {
				completer.complete(e.detail['data']);
			}
		});
		return completer.future;
	}

	/// Returns the source that was entered when created
	String get source => _source;

	/// Returns Json file contents
	JsonObject get data => _data;
}
