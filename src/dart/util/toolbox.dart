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
library Computer_Science_Project_Utilities;

import 'dart:html';
import 'dart:math';
import 'dart:async';

import 'package:logging/logging.dart';
import 'package:json_object/json_object.dart';
import 'package:vector_math/vector_math.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';

import 'dart:js' as js;

part 'toolbox/animation.dart';
part 'toolbox/math.dart';

final Logger logUtil = Util.createdLogger('utilities');

class Notify {
	static final String keyInfo = "info";
	static final String keySuccess = "success";
	static final String keyWarn = "warning";
	static final String keyError = "error";

	static void info(String title, [String message]) {
		notify(keyInfo, title, message);
	}

	static void success(String title, [String message]) {
		notify(keySuccess, title, message);
	}

	static void warn(String title, [String message]) {
		notify(keyWarn, title, message);
	}

	static void error(String title, [String message]) {
		notify(keyError, title, message);
	}

	static void notify(String type, String title, [String message]) {
		if (message == null) message = '';
		js.context.callMethod('notif', [type, title, message]);
	}
}

class Util {
	static final Uuid uuid = new Uuid();
	static final Spec spec = new Spec();
	static final Regex regex = new Regex();

	/// Gets the Uri that the system is connected from
	static Uri getUri() {
		return Uri.base;
	}

	/// Returns `true` when not connected to from the local host `127.0.0.1`
	static bool isLive()  {
		String address = getUri().toString().toLowerCase().replaceFirst("http://", "");
		// Helper.notify(Helper.info, address);
		if (address.startsWith('127.0.0.1')) return false;
		return true;
	}

	static void drawCenteredText(String text, int x, int y, int width, int height, CanvasRenderingContext2D context, [String font]) {
		if (text == null) text = "";
		int textWidth = getTextMetrics(context, text, font).width.round();
		context.fillText(text, x + (width / 2) - (textWidth / 2), y + (height * 0.775));
	}

	static TextMetrics getTextMetrics(CanvasRenderingContext2D context, String text, [String font]) {
		if (text == null) text = "";
		if (font == null) font = "30pt KenVector Future";
		context.font = font;
		return context.measureText(text);
	}

	static String generateUuid() {
		return uuid.v1();
	}

	static Logger createdLogger(String name) {
		Logger logger = new Logger(name);
		Logger.root.level = Level.ALL;
		Logger.root.onRecord.listen((LogRecord rec) {
			print('[DART][${rec.time}] ${rec.level.name}: ${rec.message}');
		});
		return logger;
	}
}

class Regex {
	RegExp get vars => new RegExp(r'\$[1-9]\d*');
	RegExp get token => new RegExp(r'admin\d*|(\b\w{3,4}[1-9]\d*)');

	// Have not tested
	String replace(String str, List<String> array, RegExp exp) {
		if (matches(str, exp)) {
			Iterable<Match> matches = allMatches(str, exp);
			int iteration = 0;
			matches.forEach((match) {
				if (iteration < array.length) {
					str = replaceFirst(str, array[iteration], exp);
					iteration++;
				} // Can't break out of forEach loop
			});
		}
		return str;
	}

	String replaceFirst(String str, String replace, RegExp exp) {
		return str.replaceFirstMapped(exp, (match) {
			return replace;
		});
	}

	Match firstMatch(String str, RegExp exp) {
		Iterable<Match> matches = allMatches(str, exp);
		if (matches.length == 0) {
			logUtil.warning("String did not match regex expression");
    		// String didn't match regex; throw error.
			return null;
		} else {
    		return matches.first;
		}
	}

	Iterable<Match> allMatches(String str, RegExp exp) {
		return exp.allMatches(str);
	}

	bool matches(String str, RegExp exp) {
		return firstMatch(str, exp) != null;
	}
}

class Spec {

	bool _loaded = false;

	YamlMap _map;

	Spec() {
		if (Util.isLive()) {
			_load().then((map) {
				if (map != null) {
					_loaded = true;
					_map = map;

					logUtil.info("[${name}] ${version}#${build}");
				}
			});
		} else logUtil.warning("skiped loading pubspec due to runnign local host");
	}

	String get name => _get('name');

	String get description => _get('description');

	String get homepage => _get('homepage');

	String get version => _get('version');

	String get build => _get('build');

	String _get(String key){
		if (_loaded) return _map[key];
		return "";
	}

	@deprecated
	YamlMap map() {
		return _map;
	}

	bool get loaded => _loaded;

	Future<YamlMap> _load() {
		Completer<YamlMap> completer = new Completer();
		HttpRequest.getString('pubspec.yaml').then((String yaml) {
			logUtil.info("loaded pubspec");
			completer.complete(loadYaml(yaml));
		}).catchError((Error error) {
			logUtil.warning("failed to load pubspec");
			completer.complete(null);
		});
		return completer.future;
	}
}

class JsonList extends JsonObject implements List {
	JsonList();

	factory JsonList.fromString(String jsonString) {
		return new JsonObject.fromJsonString(jsonString, new JsonList());
	}
}
