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
	PointSmart _position;
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
		_width = _sprite.width();
		_height = _sprite.height();
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

	void setSprite(Sprite sprite){
		this._sprite = sprite;
		_width = _sprite.width();
		_height = _sprite.height();
	}
}

class SpaceShip extends Mob {
	bool _removed;

	SpaceShip() : super (ResourceManager.getSprite("game.eneity.ship.one")) {

	}

	void remove() {
		_removed = true;
	}

	bool isRemoved() {
		return _removed;
	}
}

class SpaceStation extends Mob {
	SpaceStation() : super (ResourceManager.getSprite("game.eneity.station.one")) {
		setX(((GameHost.width / 2) - (_width / 2)).round());
		setY(((GameHost.height / 2) - (_height / 2)).round());
	}

	void render(CanvasRenderingContext2D context) {
		context.drawImageToRect(_sprite.getTexture(), getBounds());
	}
}
