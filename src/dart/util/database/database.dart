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
library Computer_Science_Project_database;

import 'dart:html';
import 'dart:math';
import 'package:logging/logging.dart';
import 'dart:async';
import 'package:json_object/json_object.dart';

import '../toolbox.dart';

part 'functions.dart';

final Logger logDatabase = Util.createdLogger('database');

class DataBaseConnection {
	final Random _random = new Random();

	Regex _regex = new Regex();

	QueryManager _query;
	QueryManager get query => _query;

	DataBaseConnection() {
		_query = new QueryManager("http://database.roryclaasen.me/query.php");
	}

	/// Adds the user with the [name] to the databse
	///
	/// Returns the student details
	Future<JsonObject> addUser(String name) {
		Completer<JsonObject> completer = new Completer();
		getNextId(table: 'cs_students').then((id) {
			String token = _randomLogin(id);
			logDatabase.info("New login token " + token);
			query.getQuery("INSERT INTO `cs_students`(`token`, `name`) VALUES ('$token', '$name')").then((json) {
				json.isExtendable = true;
				json.name = name;
				json.token = token;
				json.isExtendable = false;
				completer.complete(json);
			});
		});
		return completer.future;
	}

	/// Removes the user with the [id] from the database
	Future<JsonObject> removeUser(int id) {
		Completer<JsonObject> completer = new Completer();
		query.getQuery("DELETE FROM `cs_students` WHERE `id` = ${id}").then((json) =>	completer.complete(json));
		return completer.future;
	}

	/// Gets the user with the [id] from the database
	Future<JsonObject> getStudent(int id) {
		Completer<JsonObject> completer = new Completer();
		query.getQueryList("SELECT * FROM `cs_students` WHERE `id` = ${id}").then((list) => completer.complete(_getUserFromList(list)));
		return completer.future;
	}

	/// Gets the user with the [token] from the database
	Future<JsonObject> getStudentFromToken(String token) {
		Completer<JsonObject> completer = new Completer();
		query.getQueryList("SELECT * FROM `cp_students` WHERE login = '${token}'").then((list) => completer.complete(_getUserFromList(list)));
		return completer.future;
	}

	JsonObject _getUserFromList(JsonList list) {
		if (list != null) {
			if (list.length > 0) return list[0];
		}
		return new JsonObject.fromJsonString('{"error" : "no user found"}');
	}

	/// Gets a list of all the students from the database
	Future<List> getStudentList() {
		Completer<List> completer = new Completer();
		query.getQueryList("SELECT * FROM `cs_students` WHERE 1").then((list) {
			List<JsonObject> userList = new List<JsonObject>();
			for(var iter = list.iterator; iter.moveNext();) {
				JsonObject current = iter.current;
				userList.add(current);
			}
			completer.complete(userList);
		});
		return completer.future;
	}

	/// Gets the next id from the table [cp_students] from the database
	Future<int> getNextId({String table}) {
		if (table == null) table = 'cs_students';
		Completer<int> completer = new Completer();
		query.getQueryList("SHOW TABLE STATUS LIKE '$table'").then((list) {
			int id = 0;
			try  {
				id = int.parse(list[0].Auto_increment);
			} catch(error) {
				logDatabase.warning(error);
			}
			completer.complete(id);
		});
		return completer.future;
	}

	/// Returns a random prefix word with the [id] appended on to the end
	String _randomLogin(int id) {
		List prefixes = ['car', 'lion', 'cat', 'cube', 'gem'];
		String test = prefixes[_random.nextInt(prefixes.length)] + id.toString();
		if (_regex.matches(test, _regex.token)) return test;
		// Try till it does match. This may restult in a infine loop if all prefixes don't match the regex expression
		return _randomLogin(id);
	}
}
