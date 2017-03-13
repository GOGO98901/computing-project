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

abstract class GuiElement {

	List<StreamSubscription> _listeners = new List<StreamSubscription>();
	EventStreamProvider _esp = new EventStreamProvider<CustomEvent>("GuiEvent");
	Rectangle _bounds;

	bool _parentVisible;

	String _uuid;

	GuiElement(this._bounds, [CanvasElement canvas]) {
		_uuid = Util.generateUuid();
		_init(canvas);
	}

	/// Abstract initializer
	void _init([CanvasElement canvas]);

	/// Abstrcat render method
	void render(CanvasRenderingContext2D context);

	/// Abstrcat update method
	void update(final double delta);

	void setSize(int width, height) {
		bounds = new Rectangle(x, y, width, height);
	}

	void setPosition(int x, int y) {
		bounds = new Rectangle(x, y, _bounds.width, _bounds.height);
	}

	Rectangle get bounds => _bounds;
	void set bounds(Rectangle bounds) {
		_bounds = bounds;
	}

	int get x => _bounds.left;
	int get y => _bounds.top;
	int get width => _bounds.width;
	int get height => _bounds.height;

	bool get visible => _parentVisible;
	void set visible(bool vis) {
		this._parentVisible = vis;
		onVisibilityChange();
	}

	void onVisibilityChange() {}

	void listen(CanvasElement canvas, Function function);

	void removeListeners() => _listeners.forEach((l) => l.cancel());


	String get uuid => _uuid;
}

class GuiButtonElement extends GuiElement {

	static final int fWidth = 190, fHeight =  45, offset = 4;
	int _longWidth = fWidth;

	int _x, _y, _offset;
	String _text;

	bool _long = false, _hover = false, _disabled = false;

	Sprite _up, _down, _current;

	GuiButtonElement(CanvasElement canvas, int x, int y, [String text, bool long]) : super(new Rectangle(x, y, fWidth, fHeight), canvas) {
		this._x = x;
		this._y = y;
		this._offset = 0;
		this._text = text ?? "";
		this._long = long ?? false;
	}

	void _init([CanvasElement canvas]) {
		if (canvas != null) _listeners.add(canvas.onClick.listen((e) {
			if (visible && !_disabled) {
				if (_hover) {
				ResourceManager.playAudio("game.ui.click.3");
					var detail = {
						"type": "button",
						"x": _x,
						"y": _y,
						"text": _text,
						"uuid": uuid
					};
					var event = new CustomEvent("GuiEvent", canBubble: false, cancelable: false, detail: detail);
					canvas.dispatchEvent(event);
				}
			}
		}));

		_up = ResourceManager.getSprite('ui.button.up.blue');
		_down = ResourceManager.getSprite('ui.button.down.blue');

		_current = _up;
	}

	void listen(CanvasElement canvas, Function function, [GuiElement source]) {
		_listeners.add(_esp.forTarget(canvas).listen((e) {
			if (this.visible) {
				if (e.detail['uuid'] == uuid) {
					function(e, source ?? this);
				}
			}
		}));
	}

	void render(CanvasRenderingContext2D context) {
		if (_disabled) context.globalAlpha = 0.5;
		_renderButton(context);
		context.setFillColorRgb(255, 255, 255);
		if (_long) Util.drawCenteredText(_text, _x, _y + _offset, _longWidth, height, context);
		else Util.drawCenteredText(_text, _x, _y + _offset, width, height, context);
		if (_disabled) context.globalAlpha = 1;
	}

	void _renderButton(CanvasRenderingContext2D context) {
		if(!_long) context.drawImage(_current.texture, _x, _y + _offset);
		else {
			_longWidth = Util.getTextMetrics(context, _text).width.round() + 40;
			int step = (width / 3).ceil();
			context.drawImageScaledFromSource(_current.texture, 0, 0, step, height + offset, _x, _y + _offset, step, height + offset);
			for (int xI = step; xI < _longWidth - step; xI += step) {
				if (xI > _longWidth - step) {
					xI = _longWidth - step;
				}
				context.drawImageScaledFromSource(_current.texture, step, 0, step, height + offset, _x + xI, _y + _offset, step, height + offset);
			}
			context.drawImageScaledFromSource(_current.texture, step * 2, 0, step, height + offset, _x + _longWidth - step, _y + _offset, step, height + offset);
		}
	}

	void update(final double delta) {
		if (_long) {
			_bounds = new Rectangle(_x, _y, _longWidth, height);
		}
		if (!_disabled) {
			if (Mouse.inCanvas())  {
				if (_bounds.containsPoint(Mouse.point)) {
					_hover = true;
				} else _hover = false;
			} else _hover = false;

			if (_hover) {
				_current = _down;
				_offset = offset;
			} else {
				_current = _up;
				_offset = 0;
			}
		}
	}

	void setPosition(int x, int y) {
		this._x = x;
		this._y = y;
		this.bounds = new Rectangle(x, y, _bounds.width, _bounds.height);
	}

	String get text => _text;
	void set text(String text) {
		this._text = text;
	}

	bool get disabled => _disabled;
	void set disabled(bool disabled) {
		this._disabled = disabled;
	}
}

class GuiText extends GuiElement {

	String _text;

	GuiText(this._text, int x, int y, [CanvasElement canvas]) : super(new Rectangle(x, y, 0, 0), canvas);

	void _init([CanvasElement canvas]) {}

	void render(CanvasRenderingContext2D context) {
		context.font = Util.resetFont();
		context..setFillColorRgb(255, 255, 255)..fillText(_text, _bounds.left, _bounds.top);
	}

	void update(final double delta) {}

	String get text => _text;
	void set text(String text) {
		this._text = text;
	}

	void listen(CanvasElement canvas, Function function) {}
}

class GuiTextMessage extends GuiText {
	TextAnimation anim;
	Sprite _container;

	int _guiWidth = 0;
	int _imgWidth, _imgHeight, _imgStep;

	bool _hover = false;

	String _exitMsg;

	Queue<String> _queue;

	GuiTextMessage(String text, int x, int y, [Queue<String> queue, CanvasElement canvas]) : super(text, x, y, canvas) {
		if (queue == null) _queue = new Queue<String>();
		else _queue = queue;
		if (text != null) _queue.addFirst(text);
		next();
	}

	void _setUpImage(ImageElement img) {
		_imgWidth = img.width;
		_imgHeight = img.height;
		_imgStep = (_imgWidth / 3).ceil();
		_bounds = new Rectangle(x, y, _guiWidth, _imgHeight);
	}

	void _init([CanvasElement canvas]) {
		_container = ResourceManager.getSprite('ui.glass.tr');
		_guiWidth = (GameHost.width - (x * 2)).toInt();
		if (_container.complete) _setUpImage(_container.texture);
		else _container.texture.onLoad.listen((e) {
			_setUpImage(_container.texture);
		});

		_exitMsg = ResourceManager.getString('game.msg.help.skip');
		if (_queue != null) if (_queue.length == 1) _exitMsg = ResourceManager.getString('game.msg.help.close');

		if (canvas != null) _listeners.add(canvas.onClick.listen((e) {
			if (visible) {
				if (_hover) {
					if (anim.stage == AnimationStage.running) {
						anim.skip();
						if (_queue.length == 0) _exitMsg = ResourceManager.getString('game.msg.help.close');
						else _exitMsg = ResourceManager.getString('game.msg.help.continue');
					} else if (anim.stage == AnimationStage.stopped) {
						var detail = {
							"type": "textMsg",
							"x": y,
							"y": x,
							"text": _text,
							"uuid": uuid
						};
						var event = new CustomEvent("GuiEvent", canBubble: false, cancelable: false, detail: detail);
						canvas.dispatchEvent(event);
						_exitMsg = ResourceManager.getString('game.msg.help.skip');

						if (_queue.length == 0) {
							visible = false;
						} else next();
					}
		            ResourceManager.playAudio("game.ui.click.3");
				}
			}
		}));
	}

	void onVisibilityChange() {
		if (anim != null) {
			if (this.visible) anim.start();
			else anim.stop();
		}
	}

	void next() {
		// ignore: deprecated_member_use
		this.setText(this._queue.removeFirst());
	}

	@deprecated
	void setText(String text) {
		this._text = text;
		anim = new TextAnimation(text);
		anim.listen((e, stage) {
			// if (e.detial['uuid'] == anim.uuid) {
				if (stage == AnimationStage.stopped) {
					 if (_queue.length >= 1) _exitMsg = ResourceManager.getString('game.msg.help.continue');
					 else _exitMsg = ResourceManager.getString('game.msg.help.close');
				}
				if (stage == AnimationStage.running) {
					_exitMsg = ResourceManager.getString('game.msg.help.skip');
				}
			// }
		});
		if (visible) anim.start();
	}

	void render(CanvasRenderingContext2D context) {
		if (visible) {
			if (_container.complete) {
				context.drawImageScaledFromSource(_container.texture, 0, 0, _imgStep, _imgHeight, x, y, _imgStep, _imgHeight);
				for (int xI = _imgStep; xI < _guiWidth - _imgStep; xI += _imgStep) {
					if (xI + _imgStep > _guiWidth - _imgStep) {
						int length = _guiWidth - _imgStep - xI;
						context.drawImageScaledFromSource(_container.texture, _imgStep, 0, length, _imgHeight, x + xI, y, length, _imgHeight);
						continue;
					}
					context.drawImageScaledFromSource(_container.texture, _imgStep, 0, _imgStep, _imgHeight, x + xI, y, _imgStep, _imgHeight);
				}
				context.drawImageScaledFromSource(_container.texture, _imgStep * 2, 0, _imgStep, _imgHeight, x + _guiWidth - _imgStep, y, _imgStep, _imgHeight);
			}

			if (anim != null) {
				context..setFillColorRgb(255, 255, 255)..font = "18pt KenVector Future";

				List<String> words = anim.output.split(" ");
				String output = "";
				String line = null;
				for (String word in words) {
					if (line == null) {
						line = word;
						output = word;
						continue;
					}
					int width = Util.getTextMetrics(context, "$line $word", context.font).width.round();
					if (width >= _guiWidth - 20) {
						output += "\n$word";
						line = word;
					} else {
						line += " $word";
						output += " $word";
					}
				}
				int l = 0;
				for (String outputLine in output.split("\n")) {
					l++;
					context.fillText(outputLine, x + 10, y + (25 * l));
				}
			}
			int width = Util.getTextMetrics(context, _exitMsg, context.font).width.round();
			context.fillText(_exitMsg, x + _guiWidth - width - 10, y + _imgHeight - 20);
		}
	}

	void listen(CanvasElement canvas, Function function) {
		_listeners.add(_esp.forTarget(canvas).listen((e) {
			if (this.visible) {
				if (e.detail['uuid'] == uuid) {
					function(e, this);
				}
			}
		}));
	}

	void update(final double delta) {
		if (visible) {
			if (anim != null) anim.update(delta);

			if (Mouse.inCanvas())  {
				if (_bounds.containsPoint(Mouse.point)) _hover = true;
				else _hover = false;
			} else _hover = false;
		}
	}
}

class GuiQuestionElement extends GuiElement {

	GuiQuestionElement(int x, int y, [CanvasElement canvas]) : super(new Rectangle(x, y, 500, 50), canvas);

	void _init([CanvasElement canvas]) {}

	void render(CanvasRenderingContext2D context) {}

	void update(final double delta) {}

	void listen(CanvasElement canvas, Function function) {}
}

class GuiTypeSelector extends GuiElement {

	List<Sprite> _icons;
	String _question;

	Sprite _container;
	int _slots = 0, _hover = -1, _hoverOffset = 2;

	bool _optionsVisible = true;

	GuiTypeSelector(int x, int y, this._question, List<String> sIons, [CanvasElement canvas]) : super(new Rectangle(x, y, 500, 200), canvas) {
		_icons  = new List<Sprite>();
		for (int i = 0; i < sIons.length; i++) {
			_icons.add(ResourceManager.getSprite(sIons[i]));
		}
		_slots = _icons.length;
	}

	void _init([CanvasElement canvas]) {
		_container = ResourceManager.getSprite('ui.glass.tr');
		if (_container.complete) _setUpImage(_container.texture);
		else _container.texture.onLoad.listen((e) {
			_setUpImage(_container.texture);
		});
		if (canvas != null) _listeners.add(canvas.onClick.listen((e) {
			if (Mouse.inCanvas() && _bounds.containsPoint(Mouse.point)) {
				if (_hover >= 0) {
					var event = new CustomEvent("GuiEvent", canBubble: false, cancelable: false, detail:  {
						"type": "typesSelector",
						"x": y,
						"y": x,
						"selected": _hover,
						"uuid": uuid
					});
					canvas.dispatchEvent(event);
				}
			}
		}));
	}

	void _setUpImage(ImageElement img) {
		this.setSize(GameHost.width - (x * 2), img.height);
	}

	void render(CanvasRenderingContext2D context) {
		if (optionsVisible) for (int i = 0; i < slots; i++) {
			Rectangle bounds = getRectFromIndex(i);
			if (_hover == i) {
				int x = bounds.left + _hoverOffset;
				int y = bounds.top + _hoverOffset;
				int width = bounds.width - (_hoverOffset * 2);
				int height = bounds.height - (_hoverOffset * 2);
				bounds = new Rectangle(x, y, width, height);
			}
			context.drawImageToRect(_container.texture, bounds);
			if (i < _icons.length) if (_icons[i] != null) {
				Sprite icon = _icons[i];
				int xOff = (bounds.width - icon.width) / 2;
				int yOff = (bounds.width - icon.width) / 2;
				if (_hover == i) context.drawImageScaled(icon.texture, bounds.left + xOff - _hoverOffset, bounds.top + yOff - _hoverOffset, icon.width + (_hoverOffset * 2), icon.height + (_hoverOffset * 2));
				else context.drawImage(icon.texture, bounds.left + xOff, bounds.top + yOff);
			}
		}
		context.font = "45pt";
		context..setFillColorRgb(255, 255, 255)..fillText(_question, (GameHost.width - Util.getTextMetrics(context, _question, context.font).width.round()) / 2, GameHost.height / 2);
		Util.resetFont(context);
	}

	void update(final double delta) {
		if (Mouse.inCanvas())  {
			if (_bounds.containsPoint(Mouse.point)) {
				if (optionsVisible) for (int i = 0; i < _slots; i++) {
					_hover = -1;
					if (getRectFromIndex(i).containsPoint(Mouse.point)){
						_hover = i;
						break;
					}
				}
			} else _hover = -1;
		} else _hover = -1;
	}

	void listen(CanvasElement canvas, Function function) {
		_esp.forTarget(canvas).listen((e) {
			if (this.visible) {
				if (e.detail['uuid'] == uuid) {
					function(e, e.detail['selected']);
				}
			}
		});
	}

	bool get optionsVisible => _optionsVisible;
	void set optionsVisible(bool visible) {
		this._optionsVisible = visible;
	}

	Rectangle getRectFromIndex(int index) {
		int x = this.x, y = this.y, width = this.width, height = this.height;
		int iWidth = _container.width;
		double space = width / slots;
		return new Rectangle(x + (space * index) + ((space / 2) - (iWidth / 2)), y, iWidth, height);
	}

	String get text => _question;
	void set text(String text) {
		this._question = text;
	}

	int get slots => _slots;
}
