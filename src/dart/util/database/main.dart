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
part of Computer_Science_Project_database;

class DataBaseConnection {
	final String queryPage = "http://database.roryclaasen.me/query.php";
	final Random _random = new Random();

	Regex _regex;

	DataBaseConnection() {
		logDatabase.info('Database connection setting up with url [${queryPage}]');
		_regex = new Regex();
	}

	/// Adds the user with the [name] to the databse
	///
	/// Returns the student details
	Future<JsonObject> addUser(String name) {
		Completer<JsonObject> completer = new Completer();
		_getNextId().then((id) {
			String login = _randomLogin(id);
			logDatabase.info("New login token " + login);
			_getQueryResult("INSERT INTO `cp_students`(`name`, `login`) VALUES ('${name}', '${login}')").then((json) {
				json.isExtendable = true;
				json.name = name;
				json.token = login;
				json.isExtendable = false;
				completer.complete(json);
			});
		});
		return completer.future;
	}

	/// Removes the user with the [id] from the database
	Future<JsonObject> removeUser(int id) {
		Completer<JsonObject> completer = new Completer();
		_getQueryResult("DELETE FROM `cp_students` WHERE `id` = ${id}").then((json) {
			completer.complete(json);
		});
		return completer.future;
	}

	/// Gets the user with the [id] from the database
	Future<JsonObject> getStudent(int id) {
		Completer<JsonObject> completer = new Completer();
		_getQueryResultAsQueryList("SELECT * FROM `cp_students` WHERE `id` = ${id}").then((list) {
			completer.complete(_getUserFromList(list));
		});
		return completer.future;
	}

	/// Gets the user with the [token] from the database
	Future<JsonObject> getStudentFromToken(String token) {
		Completer<JsonObject> completer = new Completer();
		_getQueryResultAsQueryList("SELECT * FROM `cp_students` WHERE login = '${token}'").then((list) {
			completer.complete(_getUserFromList(list));
		});
		return completer.future;
	}

	JsonObject _getUserFromList(JsonList list) {
		if (list != null) {
			if (list.length > 0) {
				return list[0];
			}
		}
		return new JsonObject.fromJsonString('{"error" : "no user found"}');
	}

	/// Gets a list of all the students from the database
	Future<List> getStudentList() {
		Completer<List> completer = new Completer();
		_getQueryResultAsQueryList("SELECT * FROM `cp_students` WHERE 1").then((list) {
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
	Future<int> _getNextId() {
		Completer<int> completer = new Completer();
		_getQueryResultAsQueryList("SHOW TABLE STATUS LIKE 'cp_students'").then((list) {
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

	/// Carries out the query then returns the result as a `JsonList`
	Future<JsonList> _getQueryResultAsQueryList(String query) {
		Completer<JsonList> completer = new Completer();
		_getQueryResult(query).then((json) {
			JsonList list = null;
			try {
				list = new JsonList.fromString(json.output.toString());
			} catch (e) {
				logDatabase.warning("Query failed: ${e} ${json}");
			}
			completer.complete(list);
		});
		return completer.future;
	}

	/// Carries out the query then returns the result as a `JsonObject`
	Future<JsonObject> _getQueryResult(String query) {
		Completer<JsonObject> completer = new Completer();
		_getQueryResultAsString(query).then((json) {
			completer.complete(new JsonObject.fromJsonString(json));
		});
		return completer.future;
	}

	/// Carries out the query then returns the result as a `String` formatted like Json
	Future<String> _getQueryResultAsString(String query) {
		logDatabase.info('Sending query "' + query + '"');
		Completer<String> completer = new Completer();
		HttpRequest req = new HttpRequest();
		req.open("POST", queryPage);
		req.onLoadEnd.first.then((e) {
			if(req.status == 200 || req.status == 0) {
				completer.complete(req.response as String);
			} else {
				completer.complete('{"error": "Can\'t load url ${queryPage}. Response type ${req.status}"}');
			}
		});
		req.send('{"query": "${query}"}');
		return completer.future;
	}
}
