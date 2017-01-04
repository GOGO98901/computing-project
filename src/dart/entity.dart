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

abstract class Entity  {
	PointSmart _position = new PointSmart(0, 0);
	Sprite _sprite;

	void init();

	void setX(int x) {
		_position.setX(x);
	}

	void setY(int y) {
		_position.setY(y);
	}

	int get x => _position.x;
	int get y => _position.y;

	Vector2 get vector2 => _position.vector2;

	Sprite get sprite => _sprite;
}

class Mob extends Entity {
	int _width, _height;

	Mob(Sprite sprite) {
		this._sprite = sprite;
		init();
	}

	void init() {
		if (_sprite.isComplete()) {
			_width = _sprite.width;
			_height = _sprite.height;
		} else 	_sprite.texture.onLoad.listen((e) {
			_width = _sprite.width;
			_height = _sprite.height;
		});
	}

	int get width => _width;
	int get height => _height;

	Rectangle getBounds() {
		return new Rectangle(x, y, this._width, this._height);
	}

	void render(CanvasRenderingContext2D context) {}
	void update(final double delta) {}

	void setSprite(Sprite sprite) {
		this._sprite = sprite;
		if (_sprite.isComplete()) {
			_width = _sprite.width;
			_height = _sprite.height;
		} else 	_sprite.texture.onLoad.listen((e) {
			_width = _sprite.width;
			_height = _sprite.height;
		});
	}
}

class Asteroid extends Mob {
	double speed = 50.0;
	bool _removed;

	Mob _target;
	double _life = 0.0;

	Asteroid(this._target) : super(ResourceManager.getSprite("game.enities.metor.tiny.1")) {
		Random random = new Random();
		int stage = random.nextInt(4);
		int texture = random.nextInt(2);
		if (stage == 0) texture = random.nextInt(4);
		String type = "";
		switch(stage) {
			case 0: {
				type = "big";
				break;
			}
			case 1: {
				type = "med";
				break;
			}
			case 2: {
				type = "small";
				break;
			}
			case 3: {
				type = "tiny";
				break;
			}
			default: {
				log.warning("Unknown stage size '${stage}'");
				type = "med";
				texture = random.nextInt(2);
				break;
			}
		}
		texture += 1;
		// log.info("using texture game.enities.metor.${type}.${texture}");
		this.setSprite(ResourceManager.getSprite("game.enities.metor.${type}.${texture}"));

		speed += random.nextInt(20) - 5;
	}

	void render(CanvasRenderingContext2D context) {
		if (_sprite != null) {
			if (_sprite.isComplete()) context.drawImage(_sprite.texture, x, y);
		}
	}

	// See http://gamedev.stackexchange.com/a/28337 for refrence
	void update(final double delta) {
		_life += delta;

		double x1 = this.x + 0.0;
		double x2 = _target.x + (_target.width / 2);
		double y1 = this.y + 0.0;
		double y2 = _target.y + (_target.height / 2);

		Vector2 position = new Vector2(x1, y1);
		Vector2 center = new Vector2(width / 2, height / 2);
		position += center;
		Vector2 goal = new Vector2(x2, y2);

		Vector2 norm = goal - position;
		Vector2 direction = (goal - position).normalizeInto(norm);

		position += direction * speed * delta;

		position -= center;
 		if ((direction.dot((goal - position)) + 1).abs() < 1 * max(width, height) || _life >= 60) {
			position = goal;
			remove();
		}
		setX(position.x.round());
		setY(position.y.round());
	}

	void remove() {
		_removed = true;
	}

	bool isRemoved() {
		return _removed;
	}
}

class SpaceStation extends Mob {
	double _shieldTime = -1.0;

	Sprite _shield = ResourceManager.getSprite("game.enities.station.one.shield");

	int _sXOff = 0, _sYOff = 0;

	SpaceStation() : super(ResourceManager.getSprite("game.enities.station.one")) {
		setX(((GameHost.width - _width) / 2).round());
		setY(((GameHost.height - _height) / 4).round());
	}

	void render(CanvasRenderingContext2D context) {
		if (_sprite != null) {
			if (_sprite.isComplete()) context.drawImage(_sprite.texture, x, y);
		}
		if (_shieldTime >= 0 && _shield != null) {
			if (_shield.isComplete()) {
				int xOff = ((_shield.width - _width) / 2).round() - _sXOff;
				int yOFf = ((_shield.height - _height) / 2).round() - _sYOff;
				context.drawImage(_shield.texture, x - xOff, y - yOFf);
			}
		}
	}

	void update(final double delta) {
		if (_shieldTime >= 0) {
			_shieldTime += delta;
			_sXOff = (1.5 * sin(50 * _shieldTime)).round();
			_sYOff = (1.5 * cos(50 * _shieldTime)).round();
			if (_shieldTime > 1.25) _shieldTime = -1.0;
		}
	}

	void shieldsUp() {
		_shieldTime = 0.0;
	}
}
