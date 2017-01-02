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
	double speed = 30.0;
	bool _removed;

	Mob _target;

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
		log.info("using texture game.enities.metor.${type}.${texture}");
		this.setSprite(ResourceManager.getSprite("game.enities.metor.${type}.${texture}"));

		speed += random.nextInt(15) - (15 / 2);
	}

	void render(CanvasRenderingContext2D context) {
		context.drawImageToRect(_sprite.getTexture(), getBounds());
	}

	void update(final double delta) {
		int x1 = this.getX();
		int x2 = _target.getX() + (_target.getWidth() / 2).round();
		int y1 = this.getY();
		int y2 = _target.getY() + (_target.getHeight() / 2).round();

		if (x1 < x2) x1 += (speed * delta * 0.87).round();
		if (x1 > x2) x1 -= (speed * delta * 0.87).round();
		if (y1 < y2) y1 += (speed * delta * 0.75).round();
		if (y1 > y2) y1 -= (speed * delta * 0.75).round();

		this.setX(x1);
		this.setY(y1);
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
		context.drawImageToRect(_sprite.getTexture(), getBounds());
	}
}
