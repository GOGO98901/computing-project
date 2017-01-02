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

	static HashMap<String, Sprite> _sprites;

	static JsonFile sample;

	ResourceManager() {
		_sprites = new HashMap<String, Sprite>();
		_initSprites();

		sample = _loadJsonFile('problems/sample.json');
	}

	/// All sprites get loaded at this point in the program
	///
	/// This means that images wont have to be craeted mroe than once
	void _initSprites() {
		_sprites['logo.roryclaasen.white'] = _loadSprite('project white.png');
		_sprites['logo.roryclaasen.black'] = _loadSprite('project black.png');

		_sprites['ui.button.up.blue'] = _loadSprite('game/ui/kenney/blue_button02.png');
		_sprites['ui.button.down.blue'] = _loadSprite('game/ui/kenney/blue_button03.png');

		_sprites['background.black'] = _loadSprite('game/background/kenney/black.png');
		_sprites['background.blue'] = _loadSprite('game/background/kenney/blue.png');
		_sprites['background.purple'] = _loadSprite('game/background/kenney/purple.png');
		_sprites['background.purple.dark'] = _loadSprite('game/background/kenney/darkPurple.png');


		_sprites['game.enities.station.one'] = _loadSprite('game/entities/kenney/spaceStation_017.png');
		_sprites['game.enities.station.two'] = _loadSprite('game/entities/kenney/spaceStation_020.png');
		_sprites['game.enities.station.three'] = _loadSprite('game/entities/kenney/spaceStation_026.png');
	}

	Sprite _loadSprite(String name, {String dir}) {
		if (dir == null) return new Sprite("${getAssetsDir()}/images/${name}");
		else return new Sprite("${dir}/${name}");
	}

	JsonFile _loadJsonFile(String name, {String dir}) {
			if (dir == null) return new JsonFile("${getAssetsDir()}/${name}");
			else return new JsonFile("${dir}/${name}");
	}

	/// Gets the sprite from the hash map with the corresponding [key]
	static Sprite getSprite(String key) {
		return _sprites[key];
	}

	static String getAssetsDir() {
		// if (Util.isLive()) return "computing-project/assets";
		return "assets";
	}
}

enum Status {
	initialized, started, failed, complete
}

abstract class BaseResource {
	Status _status = Status.initialized;

	BaseResource() {
		_start();
	}

	void _start();

	/// Gets the current status of the resource
	Status getStatus() {
		return _status;
	}

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
	int width() {
		if (isComplete()) return _image.width;
		return 0;
	}

	/// Returns the height of the image only if it is loaded
	int height() {
		if (isComplete()) return _image.height;
		return 0;
	}

	/// Returns the image element of the source
	ImageElement getTexture() {
		return _image;
	}

	/// Returns the source that was entered when created
	String getSource() {
		return _source;
	}
}

class JsonFile extends BaseResource {
	String  _source;
	JsonObject _data;

	JsonFile(this._source);

	void _start() {
		_status = Status.started;

		HttpRequest req = new HttpRequest();
		req.open("GET", _source);
		req.onLoadEnd.first.then((e) {
			if(req.status == 200 || req.status == 0) {
				String data = req.response as String;
				_data = new JsonObject.fromJsonString(data);
				_status = Status.complete;

				var detail = {
					"source": _source,
					"data": _data
				};

		    	window.dispatchEvent(new CustomEvent("jsonLoad", canBubble: false, cancelable: false, detail: detail));
			} else {
				_data = new JsonObject();
				_status = Status.failed;
			}
		});
		_status = Status.started;
		req.send();
	}

	Future<JsonObject> onLoad() {
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
	String getSource() {
		return _source;
	}

	/// Returns Json file contents
	JsonObject getData() {
		return _data;
	}
}
