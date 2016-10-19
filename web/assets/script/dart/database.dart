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
library Computer_Science_Project_database;

import 'dart:html';
import 'dart:math';
import 'package:logging/logging.dart';
import 'dart:async';
import 'package:json_object/json_object.dart';

final Logger log = new Logger('prototype');

void main() {
	Logger.root.level = Level.ALL;
	Logger.root.onRecord.listen((LogRecord rec) {
		print('[DART][${rec.time}] ${rec.level.name}: ${rec.message}');
	});
	DataBaseConnection db = new DataBaseConnection();
	querySelector('#addStudent').onClick.listen((event) {
		db.addUser('testing6').then((json) {
			//TODO Show message
		});
	});
}

class DataBaseConnection {
	final String queryPage = "http://database.roryclaasen.me/query.php";

	DataBaseConnection() {
		log.info('Database connection setting up with url [${queryPage}]');
	}

	Future<JsonObject> addUser(String name) {
		Completer<JsonObject> completer = new Completer();
		_getNextId().then((id) {
			String login = _randomLogin(id, 4);
			log.info("New login token " + login);
			_getQueryResult("INSERT INTO `cp_students`(`name`, `login`) VALUES ('${name}', '${login}')").then((json) {
				log.info(json);
				completer.complete(json);
			});
		});
		return completer.future;
	}

	void removeUser(String login) {
		//TODO Remove user
	}

	Future<int> _getNextId() {
		Completer<int> completer = new Completer();
		_getQueryResult("SELECT id FROM `cp_students` ORDER BY id DESC LIMIT 1").then((json) {
			int id = 0;
			try  {
				List query = json.query;
				log.info(query);
				id = int.parse(query[0].id);
			} catch(error) {
				log.warning(error);
			}
			completer.complete(id);
		});
		return completer.future;
	}

	String _randomLogin(int id, int length) {
		var rand = new Random();
		var codeUnits = new List.generate(
			length,
			(index) {
				return rand.nextInt(26) + 97;
			}
		);
		return new String.fromCharCodes(codeUnits) + id.toString();
	}

	Future<JsonObject> _getQueryResult(String query) {
		log.info('Sending query "' + query + '"');
		String url = queryPage + "?sql=" + query;
		Completer<JsonObject> completer = new Completer();
		HttpRequest req = new HttpRequest();
		req.open("get", url);
		req.onLoadEnd.first.then((e) {
			if(req.status ~/ 100 == 2) {
				completer.complete(new JsonObject.fromJsonString(req.response as String));
			} else {
				completer.complete(new JsonObject.fromJsonString('{"error": "Can\'t load url ${url}. Response type ${req.status}"}'));
			}
		});
		req.send("");
		return completer.future;
	}
}
