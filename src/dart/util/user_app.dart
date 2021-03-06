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
library Computer_Science_Project_user;

import 'dart:html';
import 'package:logging/logging.dart';
import 'dart:js' as js;
import 'package:json_object/json_object.dart';

import 'toolbox.dart';
import 'database/database.dart';

final Logger log = Util.createdLogger('user');

void main() {
	DataBaseConnection db = new DataBaseConnection();

	// ADD USER
	querySelector('#addStudent').onClick.listen((event) {
		String name = (querySelector('#userAddName') as InputElement).value;
		if (name.length > 0)	{
			db.addUser(name).then((json) {
				querySelector('#userAddName').attributes['disabled'] = "";
				querySelector('#stage-start').style.display = "none";
				querySelector('#stage-end').style.display = "inline";
				querySelector('#userAddReturnCode').text = json.token;

				Notify.success('Added Student', name);
			});
		} else {
			querySelector('#userAddForm').classes.add('has-error');
		}
	});
	querySelector('#userAddName').onInput.listen((event) {
		querySelector('#userAddForm').classes.remove('has-error');
	});
	querySelector('#addStudentClose').onClick.listen((event) {
		querySelector('#userAddName').attributes.remove('disabled');
		querySelector('#stage-start').style.display = "inline";
		querySelector('#stage-end').style.display = "none";
		querySelector('#userAddReturnCode').text = "";
		(querySelector('#userAddName') as InputElement).value = "";
	});

	// REMOVE USER
	querySelector('#modelUserRemoveBtn').onClick.listen((event) {
		db.getStudentList().then((list) {
			SelectElement element = querySelector('#userRemoveSelect') as SelectElement;
			element.attributes.remove('disabled');
			element.children.clear();
			OptionElement option = new OptionElement();
			option.text = "Select a Student";
			option.attributes['id'] = "-1";
			element.children.add(option);
			for (JsonObject json in list) {
				OptionElement option = new OptionElement();
				option.text = json.name + " (" + json.token + ")";
				option.attributes['id'] = json.id;
				option.attributes['name'] = json.name;
				option.attributes['token'] = json.token;
				element.children.add(option);
			}
		});
	});

	SelectElement rmSelector = querySelector('#userRemoveSelect') as SelectElement;
	querySelector('#removeStudentWarning').onClick.listen((event) {
		if (rmSelector.selectedIndex > 0) {
			db.getStudent(int.parse(rmSelector.item(rmSelector.selectedIndex).attributes['id'])).then((json) {
				querySelector('#userRemoveConfirmName').text = json.name;
				querySelector('#userRemoveConfirmToken').text = json.token;
			});
			js.context.callMethod(r'$', ['#modelUserRemoveConfirm']).callMethod('modal', ['show']);
		}
	});
	querySelector('#removeStudentConfirm').onClick.listen((event) {
		var name = rmSelector.item(rmSelector.selectedIndex).attributes['name'];
		db.removeUser(int.parse(rmSelector.item(rmSelector.selectedIndex).attributes['id'])).then((json) {
			log.info(json);
			js.context.callMethod(r'$', ['#modelUserRemove']).callMethod('modal', ['hide']);
			js.context.callMethod(r'$', ['#modelUserRemoveConfirm']).callMethod('modal', ['hide']);

			Notify.warn('Removed Student', name);
		});
	});
}
