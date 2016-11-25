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

class ResourceManager {

	static HashMap<String, Sprite> _sprites;

	ResourceManager() {
		_sprites = new HashMap<String, Sprite>();
		_initSprites();
	}

	void _initSprites() {
		_sprites['logo.roryclaasen'] = new Sprite("${getAssetsDir()}/images/project white.png");
	}

	static Sprite getSprite(String key) {
		return _sprites[key];
	}

	static String getAssetsDir() {
		if (Util.isLive()) return "computing-project/assets";
		return "assets";
	}
}

enum Status {
	initialized, started, failed, complete
}

abstract class BaseResource {
	Status _stage = Status.initialized;

	void _start();

	Status getStatus() {
		return _stage;
	}

	bool isComplete() {
		return _stage == Status.complete;
	}

	bool isFailed() {
		return _stage == Status.failed;
	}
}


class Sprite extends BaseResource {
	ImageElement _image;
	String  _source;

	Sprite(this._source) {
		_start();
	}

	void _start() {
		_stage = Status.started;

		_image = new ImageElement(src: _source);
		_image.onLoad.listen((e) {
			_stage = Status.complete;
		});
		_image.onError.listen((e) {
			_stage = Status.failed;
		});
	}

	int width() {
		if (isComplete()) return _image.width;
		return 0;
	}

	int height() {
		if (isComplete()) return _image.height;
		return 0;
	}

	ImageElement getTexture() {
		return _image;
	}

	String getSource() {
		return _source;
	}
}
