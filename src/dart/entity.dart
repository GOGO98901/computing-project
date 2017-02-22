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

	void init([CanvasElement canvas]);

	void setX(int x) {
		_position.setX(x);
	}

	void setY(int y) {
		_position.setY(y);
	}

	int get x => _position.x;
	int get y => _position.y;

	Vector2 get vector2 => _position.vector2;

	void set vector2(Vector2 pos) {
		_position.set(pos.x.round(), pos.y.round());
	}

	Sprite get sprite => _sprite;
}

enum MobAction {
	remove, click
}

class Mob extends Entity {

	EventStreamProvider _esp = new EventStreamProvider<CustomEvent>("MobAction");

	int _width, _height;
	bool _removed;
	String _uuid;

	Mob(Sprite sprite, {int width, int height, CanvasElement canvas}) {
		this.sprite = sprite;
		init(canvas);
		if (width != null) _width = width;
		if (height != null) _height = height;
	}

	void init([CanvasElement canvas]) {
		_uuid = Util.generateUuid();
		if (canvas != null) {
			canvas.onClick.listen((e) {
				if (!isRemoved() && Mouse.inCanvas()) {
					if (bounds.containsPoint(Mouse.point)) {
						sendEvent(MobAction.click);
					}
				}
			});
		}
	}

	int get width => _width;
	int get height => _height;

	Rectangle get bounds =>	new Rectangle(x, y, width, height);

	void render(CanvasRenderingContext2D context) {}
	void update(final double delta) {}

	void set sprite(Sprite sprite) {
		if (_sprite == null) {
			_width = _height = 0;
			return;
		}
		this._sprite = sprite;
		if (_sprite.complete) {
			_width = _sprite.width;
			_height = _sprite.height;
		} else 	_sprite.texture.onLoad.listen((e) {
			_width = _sprite.width;
			_height = _sprite.height;
		});
	}

	void action(Function actionF) {
		_esp.forTarget(window).listen((e) {
			if (e.detail['uuid'] == _uuid) {
				actionF(e);
			}
		});
	}

	void remove() {
		sendEvent(MobAction.remove);
		_removed = true;
	}

	void sendEvent(MobAction action) {
		var event = new CustomEvent("MobAction", canBubble: false, cancelable: false, detail: {
			"type": this.runtimeType,
			"action": action.index,
			"x": x,
			"y": y,
			"uuid": _uuid
		});
		window.dispatchEvent(event);
	}

	bool isRemoved() {
		return _removed;
	}
}

class Asteroid extends Mob {
	double speed = 50.0;

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
		this.sprite = ResourceManager.getSprite("game.enities.metor.${type}.${texture}");

		speed += random.nextInt(20) - 5;
	}

	void render(CanvasRenderingContext2D context) {
		if (_sprite != null) {
			if (_sprite.complete) context.drawImage(_sprite.texture, x, y);
		}
	}

	// See http://gamedev.stackexchange.com/a/28337 for refrence
	void update(final double delta) {
		super.update(delta);
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
		vector2 = position;
	}
}

class Shape extends Mob {

	double _time = 0.0, speed = 50.0;

	int _dirrection = 0, _rotSpeed;

	Vector2 _target;

	// TODO Create Shape Class
	// - In progress
	Shape(CanvasElement canvas) : super(null, width: 40, height: 40, canvas: canvas) {
		Random rand = new Random();
		_dirrection = rand.nextInt(2) - 1;
		if (_dirrection == 0) _dirrection = -1;
		_rotSpeed = rand.nextInt(80) + 100;
	}

	void render(CanvasRenderingContext2D context) {
		context..setFillColorRgb(0, 255, 0)..fillRect(x, y, width, height)..save()
		..translate(x + (width / 2), y + (height / 2))
		..rotate((_time * _dirrection) * PI / (180 - _rotSpeed))
		..setFillColorRgb(10, 20, 30) // TODO load images
		..fillRect(-(width / 2), -(height / 2), width, height)
		..restore();
	}

	void update(final double delta) {
		super.update(delta);
		_time += delta;

		double x1 = this.x + 0.0;
		double x2 = _target.x;
		double y1 = this.y + 0.0;
		double y2 = _target.y;

		Vector2 position = new Vector2(x1, y1);
		Vector2 center = new Vector2(width / 2, height / 2);
		position += center;
		Vector2 goal = new Vector2(x2, y2);

		Vector2 norm = goal - position;
		Vector2 direction = (goal - position).normalizeInto(norm);

		position += direction * speed * delta;

		position -= center;
		if ((direction.dot((goal - position)) + 1).abs() < 1 * max(width, height) || _time >= 60) {
			position = goal;
			remove();
		}
		vector2 = position;
	}

	Vector2 get target => _target;

	void set target(Vector2 t) {
		_target = t;
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
			if (_sprite.complete) context.drawImage(_sprite.texture, x, y);
		}
		if (_shieldTime >= 0 && _shield != null) {
			if (_shield.complete) {
				int xOff = ((_shield.width - _width) / 2).round() - _sXOff;
				int yOFf = ((_shield.height - _height) / 2).round() - _sYOff;
				context.drawImage(_shield.texture, x - xOff, y - yOFf);
			}
		}
	}

	void update(final double delta) {
		super.update(delta);
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
