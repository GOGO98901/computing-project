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

	int getX() {
		return _position.getX();
	}

	void setY(int y) {
		_position.setY(y);
	}

	int getY() {
		return _position.getY();
	}

	Sprite getSprite() {
		return _sprite;
	}
}

class Mob extends Entity {
	int _width, _height;

	Sprite _sprite;

	Mob(this._sprite) {
		init();
	}

	void init() {
		if (_sprite.isComplete()) {
			_width = _sprite.width();
			_height = _sprite.height();
		} else 	_sprite.getTexture().onLoad.listen((e) {
			_width = _sprite.width();
			_height = _sprite.height();
		});
	}

	int getWidth()  {
		return _width;
	}

	int getHeight() {
		return _height;
	}

	Sprite getSprite() {
		return _sprite;
	}

	Rectangle getBounds() {
		return new Rectangle(this.getX(), this.getY(), this._width, this._height);
	}

	void render(CanvasRenderingContext2D context) {}
	void update(final double delta) {}

	void setSprite(Sprite sprite) {
		this._sprite = sprite;
		if (_sprite.isComplete()) {
			_width = _sprite.width();
			_height = _sprite.height();
		} else 	_sprite.getTexture().onLoad.listen((e) {
			_width = _sprite.width();
			_height = _sprite.height();
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

		speed += random.nextInt(20) - 10;
	}

	void render(CanvasRenderingContext2D context) {
		if (_sprite != null) {
			if (_sprite.isComplete()) context.drawImage(_sprite.getTexture(), getX(), getY());
		}
	}

	// See http://gamedev.stackexchange.com/a/28337 for refrence
	void update(final double delta) {
		_life += delta;

		double x1 = this.getX() + 0.0;
		double x2 = _target.getX() + (_target.getWidth() / 2);
		double y1 = this.getY() + 0.0;
		double y2 = _target.getY() + (_target.getHeight() / 2);

		Vector2 position = new Vector2(x1, y1);
		Vector2 center = new Vector2(_width / 2, _height / 2);
		position += center;
		Vector2 goal = new Vector2(x2, y2);

		Vector2 norm = goal - position;
		Vector2 direction = (goal - position).normalizeInto(norm);

		position += direction * speed * delta;

		position -= center;
 		if ((direction.dot((goal - position)) + 1).abs() < 1 * max(_width, _height) || _life >= 60) {
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
	SpaceStation() : super(ResourceManager.getSprite("game.enities.station.one")) {
		setX(((GameHost.width - _width) / 2).round());
		setY(((GameHost.height - _height) / 2).round());
	}

	void render(CanvasRenderingContext2D context) {
		if (_sprite != null) {
			if (_sprite.isComplete()) context.drawImage(_sprite.getTexture(), getX(), getY());
		}
	}
}
