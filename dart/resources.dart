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

	/// All sprites get loaded at this point in the program
	///
	/// This means that images wont have to be craeted mroe than once
	void _initSprites() {
		_sprites['logo.roryclaasen'] = new Sprite("${getAssetsDir()}/images/project white.png");
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

	Sprite(this._source) {
		_start();
	}

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
