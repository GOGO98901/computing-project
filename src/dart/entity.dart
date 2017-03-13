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

enum Direction {
	NORTH, SOUTH, EAST, WEST
}

abstract class Entity  {
	PointSmart _position = new PointSmart(0, 0);
	Sprite _sprite;

	void init([CanvasElement canvas]);

	int get x => _position.x;
	void set x(int x) {
		_position.setX(x);
	}

	int get y => _position.y;
	void set y(int y) {
		_position.setY(y);
	}

	Vector2 get vector2 => _position.vector2;

	void set vector2(Vector2 pos) {
		_position.set(pos.x.round(), pos.y.round());
	}

	double distanceTo(Entity start, [Vector2 offset]) {
		if (offset == null) offset = new Vector2(0.0, 0.0);
        return vector2.distanceTo(start.vector2 + offset);
    }

	Sprite get sprite => _sprite;
}

enum MobAction {
	remove, click
}

class Mob extends Entity {

	List<StreamSubscription> _listeners = new List<StreamSubscription>();
	EventStreamProvider _esp = new EventStreamProvider<CustomEvent>("MobAction");

	int _width, _height;
	bool _removed;
	String _uuid;

	Mob(Sprite texture, {int width, int height, CanvasElement canvas}) {
		sprite = texture;
		init(canvas);
		if (width != null) _width = width;
		if (height != null) _height = height;
	}

	void init([CanvasElement canvas]) {
		_uuid = Util.generateUuid();
		if (canvas != null) {
			_listeners.add(canvas.onClick.listen((e) {
				if (!isRemoved() && Mouse.inCanvas()) {
					if (bounds.containsPoint(Mouse.point)) {
						sendEvent(MobAction.click);
					}
				}
			}));
		}
	}

	int get width => _width;
	int get height => _height;

	Rectangle get bounds =>	new Rectangle(x, y, width, height);

	void render(CanvasRenderingContext2D context) {}
	void update(final double delta) {}

	void set sprite(Sprite sprite) {
		if (sprite == null) {
			_width = _height = 0;
			_sprite = null;
			return;
		}
		this._sprite = sprite;
		if (_sprite.complete) {
			_width = _sprite.width;
			_height = _sprite.height;
		} else _listeners.add(_sprite.texture.onLoad.listen((e) {
			_width = _sprite.width;
			_height = _sprite.height;
		}));
	}

	void action(Function actionF) {
		_listeners.add(_esp.forTarget(window).listen((e) {
			if (e.detail['uuid'] == _uuid) {
				actionF(e);
			}
		}));
	}

	void removeListeners() => _listeners.forEach((l) => l.cancel());

	void remove() {
		// This event may not be recived due to the fact that all the listeners are being removed
		sendEvent(MobAction.remove);
		removeListeners();
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

class SpaceTrash extends Mob {

	SpaceStation _station;

	double _time = 0.0, _speed = 50.0, _rotSpeed = 0.0;

	int _dirrection = 0;

	Vector2 _target;

	SpaceTrash(CanvasElement canvas, Sprite sprite, this._station) : super(sprite, width: 40, height: 40, canvas: canvas) {
		Random rand = new Random();
		_dirrection = rand.nextInt(2);
		if (_dirrection == 0) _dirrection = -1;
		_rotSpeed = 1.5 + rand.nextDouble() * 10;
	}

	void render(CanvasRenderingContext2D context) {
		if (distanceTo(_station, new Vector2(_station.width / 2, _station.height / 4)) <= 150) {
			context.globalAlpha = (distanceTo(_station).toDouble() / 2.75) / 150.0;
		}
		context..save()
		..translate(x + (width / 2), y + (height / 2))
		..rotate((_time * _rotSpeed * _dirrection) * PI / 180)
		..drawImageScaled(sprite.texture, -(width / 2), -(height / 2), width, height)
		..restore()..globalAlpha = 1;
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

		position += direction * _speed * delta;

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

	SpaceStation() : super(ResourceManager.getSprite("game.enities.station.one")) {
		x = ((GameHost.width - _width) / 2).round();
		y = (GameHost.height - (_height / 2)).round();
	}

	void render(CanvasRenderingContext2D context) {
		if (_sprite != null) {
			if (_sprite.complete) context.drawImage(_sprite.texture, x, y);
		}
	}

	void update(final double delta) {
		super.update(delta);
	}
}
