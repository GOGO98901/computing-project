/*
Copyright 2016 Rory Claasen

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
library Computer_Science_Project;

import 'dart:html';
import 'dart:async';
// import 'dart:math';
import 'dart:collection';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';
import 'dart:js' as js;

import 'util/database.dart';

part 'game.dart';
part 'handler.dart';
part 'toolbox.dart';
part 'gui.dart';
part 'resources.dart';
part 'states.dart';
part 'entity.dart';
part 'user.dart';

final Logger log = new Logger('project');

CanvasElement _canvas;

ScreenHandler screenHandler;

int oldWidth, oldHeight;

/// Entry point for the dart code
void main() {
	if (_init()) {
		GameHost _host = new GameHost(_canvas, _canvas.getContext('2d'));
		screenHandler = new ScreenHandler(_host);
		scheduleMicrotask(_host.run);
	} else {
		Notify.error("Failed to initialize");
		log.severe("Failed to initialize");
	}
}

/// Main initialization method
///
/// This function checks to make sure that the canvas iss visible and creates crucial objects
bool _init() {
	Logger.root.level = Level.ALL;
	Logger.root.onRecord.listen((LogRecord rec) {
		print('[DART][${rec.time}] ${rec.level.name}: ${rec.message}');
	});

	log.info("Running from ${Util.getUri()}");

	Util.spec.isLoaded();

	_canvas = document.querySelector('#game-canvas');
	if (_canvas != null) {
		log.info("Found canvas node");
	} else {
		log.severe("DID NOT FIND CANVAS NODE!");
		Notify.warn("Unable to find canvas node");
		return false;
	}
	return true;
}
