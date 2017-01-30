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

	void setPosition(int x, int y) {
		setBounds(new Rectangle(x, y, _bounds.width, _bounds.height));
	}

	void setBounds(Rectangle bounds) {
		_bounds = bounds;
	}

	Rectangle get bounds => _bounds;
	int get x => _bounds.left;
	int get y => _bounds.top;

	void setParentVisible(bool vis) {
		this._parentVisible = vis;
		onVisibilityChange();
	}

	void onVisibilityChange() {}

	void listen(CanvasElement canvas, Function function);

	bool get visible => _parentVisible;

	String get uuid => _uuid;
}

class GuiButtonElement extends GuiElement {

	static final int width = 190, height =  45, offset = 4;
	int _longWidth = width;

	int _x, _y, _offset;
	String _text;

	bool _long = false, _hover = false, _disabled = false;

	Sprite _up, _down, _current;

	GuiButtonElement(CanvasElement canvas, int x, int y, [String text, bool long]) : super(new Rectangle(x, y, width, height), canvas) {
		this._x = x;
		this._y = y;
		this._offset = 0;
		this._text = text ?? "";
		this._long = long ?? false;
	}

	void _init([CanvasElement canvas]) {
		if (canvas != null) canvas.onClick.listen((e) {
			if (visible && !_disabled) {
				if (_hover) {
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
		});

		_up = ResourceManager.getSprite('ui.button.up.blue');
		_down = ResourceManager.getSprite('ui.button.down.blue');

		_current = _up;
	}

	void listen(CanvasElement canvas, Function function, [GuiElement source]) {
		_esp.forTarget(canvas).listen((e) {
			if (this.visible) {
				if (e.detail['uuid'] == uuid) {
					function(e, source ?? this);
				}
			}
		});
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
				if (_bounds.containsPoint(Mouse.getPoint())) {
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
		this.setBounds(new Rectangle(x, y, _bounds.width, _bounds.height));
	}

	void setText(String text) {
		this._text = text;
	}

	void setDisabled(bool disabled) {
		this._disabled = disabled;
	}

	bool get disabled => _disabled;

	String getText() {
		return _text;
	}
}

class GuiText extends GuiElement {

	String _text;

	GuiText(this._text, int x, int y, [CanvasElement canvas]) : super(new Rectangle(x, y, 0, 0), canvas);

	void _init([CanvasElement canvas]) {}

	void render(CanvasRenderingContext2D context) {
		context.fillText(_text, _bounds.left, _bounds.top);
	}

	void update(final double delta) {}

	void setText(String text) {
		this._text = text;
	}

	void listen(CanvasElement canvas, Function function) {}

	String getText() {
		return _text;
	}
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

	void _init([CanvasElement canvas]) {
		_container = ResourceManager.getSprite('ui.glass.tr');
		_guiWidth = (GameHost.width - (x * 2)).toInt();
		_container.texture.onLoad.listen((e) {
			_imgWidth = _container.width;
			_imgHeight = _container.height;
			_imgStep = (_imgWidth / 3).ceil();
			_bounds = new Rectangle(x, y, _guiWidth, _imgHeight);
		});

		_exitMsg = ResourceManager.getString('game.msg.help.skip');
		if (_queue != null) if (_queue.length == 1) _exitMsg = ResourceManager.getString('game.msg.help.close');

		if (canvas != null) canvas.onClick.listen((e) {
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
							setParentVisible(false);
						} else next();
					}
				}
			}
		});
	}

	void onVisibilityChange() {
		// _close.setParentVisible(visible);
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
					log.info(_queue.length);
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


			if (anim != null) {
				context.font = "18pt KenVector Future";

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
			//_close.render(context);
			int width = Util.getTextMetrics(context, _exitMsg, context.font).width.round();
			context.fillText(_exitMsg, x + _guiWidth - width - 10, y + _imgHeight - 20);
		}
	}

	void listen(CanvasElement canvas, Function function) {
		_esp.forTarget(canvas).listen((e) {
			if (this.visible) {
				if (e.detail['uuid'] == uuid) {
					function(e, this);
				}
			}
		});
	}

	void update(final double delta) {
		if (visible) {
			if (anim != null) {
				anim.update(delta);
			}
			//_close.update(delta);
			if (Mouse.inCanvas())  {
				if (_bounds.containsPoint(Mouse.getPoint())) _hover = true;
				else _hover = false;
			} else _hover = false;
		}
	}
}

class GuiQuestionElement extends GuiElement {
	static final int width = 200, height = 500;

	GuiQuestionElement(int x, int y, [CanvasElement canvas]) :super(new Rectangle(x, y, width, height), canvas) {

	}

	void _init([CanvasElement canvas]) {}

	void render(CanvasRenderingContext2D context) {}

	void update(final double delta) {}

	void listen(CanvasElement canvas, Function function) {}
}

class GuiTypeSelector extends GuiElement {
	static final int width = 500, height = 200;

	GuiTypeSelector(int x, int y, [CanvasElement canvas]) :super(new Rectangle(x, y, width, height), canvas);

	void _init([CanvasElement canvas]) {}

	void render(CanvasRenderingContext2D context) {}

	void update(final double delta) {}

	void listen(CanvasElement canvas, Function function) {}
}
