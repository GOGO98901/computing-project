/*
Copyright 2017 Rory Claasen

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
part of Computer_Science_Project_Utilities;

enum AnimationStage {
	idle, running, stopped
}

abstract class Animation {
	AnimationStage _stage = AnimationStage.idle;
	final Object _source;
	Object _output;

	String _uuid;

	EventStreamProvider _esp = new EventStreamProvider<CustomEvent>("AnimationStageUpdate");

	Animation(this._source) {
		this._uuid = Util.generateUuid();
	}

	/// Changes stage to running and sends an `AnimationStageUpdate`
	void start() {
		_stage = AnimationStage.running;
		sendEvent();
	}

	/// Changes stage to stopped and sends an `AnimationStageUpdate`
	void stop() {
		_stage = AnimationStage.stopped;
		sendEvent();
	}

	/// Sends an `AnimationStageUpdate` on window
	void sendEvent() {
		var detail = { "uuid": uuid, "source": _source, "output": _output };
		var event = new CustomEvent("AnimationStageUpdate", canBubble: false, cancelable: false, detail: detail);
		window.dispatchEvent(event);
	}

	void listen(Function function) {
		_esp.forTarget(window).listen((e) {
			if (e.detail['uuid'] == uuid) function(e, _stage);
		});
	}

	void update(final double delta);

	AnimationStage get stage => _stage;
	Object get source => _source;
	Object get output => _output;

	String get uuid => _uuid;
}

class TextAnimation extends Animation {

	double _time = 0.0;
	double _interval = 0.05;

	int _char = 1;

	TextAnimation(String source, [double interval]) : super(source) {
		if (interval != null) _interval = interval;
		_output = "";
	}

	void update(final double delta) {
		if (stage == AnimationStage.running) {
			_time += delta;
			if (_time > _interval) {
				_char++;
				if (_source != null) {
					if (_char >= (_source as String).length) {
						_char = (_source as String).length;
						stop();
					}
					_output = (_source as String).substring(0, _char);
				}
				_time %= _interval;
			}
		}
	}

	void skip() {
		_output = _source;
		stop();
	}

	String get source => _source;
	String get output => _output;

	// noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
