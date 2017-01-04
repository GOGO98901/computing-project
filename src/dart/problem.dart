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

class ProblemManager {
  JsonFile _dataFile;

  HashMap<int, List<ProblemItem>> _problems;

  ProblemManager() {
    _problems = new HashMap<int, List<ProblemItem>>();
    _dataFile = ResourceManager.sample;

    _dataFile.onLoad().then((e) {
        JsonList list = new JsonList.fromString(e['problems'].toString());
        for (JsonObject problem in list) {
            int level = problem.level;
            String question = problem.data.question;
            int answer = problem.data.answer;
            List<String> options = problem.data.options;

            if (!_problems.containsKey(level)) _problems[level] = new List<ProblemItem>();
            List<ProblemItem> list = _problems[level];
            list.add(new ProblemItem(question, options, answer));
            _problems[level] = list;
        }
        // log.info(_problems);
    });
  }
}

class ProblemItem {
  String _question;

  List<String> _options;

  int _answer;

  ProblemItem(this._question, this._options, this._answer);

  String get question => _question;

  List<String> get questions => _options;

  int get answer => _answer;

  String toString() {
      return {
          "question": _question,
          "options": _options,
          "anseer": _answer
      }.toString();
  }
}
