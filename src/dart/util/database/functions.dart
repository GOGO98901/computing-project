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

class QueryManager {

    String _site;
    String get querySite => _site;

    QueryManager(this._site) {
    	logDatabase.info('Query Manager set up using [$querySite]');
    }

    /// Carries out the query then returns the result as a `JsonList`
    Future<JsonList> getQueryList(String query) {
        Completer<JsonList> completer = new Completer();
        getQuery(query).then((json) {
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
    Future<JsonObject> getQuery(String query) {
        Completer<JsonObject> completer = new Completer();
        sendQuery(query).then((response) {
            completer.complete(new JsonObject.fromJsonString(response));
        });
        return completer.future;
    }

    /// Carries out the query then returns the result as a `String` formatted like Json
    Future<String> sendQuery(String query) {
        logDatabase.info('Sending query "' + query + '"');
        Completer<String> completer = new Completer();
        HttpRequest req = new HttpRequest();
        req.open("POST", querySite);
        req.onLoadEnd.first.then((e) {
            if(req.status == 200 || req.status == 0) {
                completer.complete(req.response as String);
            } else {
                completer.complete('{"error": "Can\'t load url ${querySite}. Response type ${req.status}"}');
            }
        });
        req.send('{"query": "${query}"}');
        return completer.future;
    }
}
