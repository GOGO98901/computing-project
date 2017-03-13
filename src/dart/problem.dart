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
    Random _random = new Random();

    JsonFile _dataFile;

    HashMap<int, List<ProblemItem>> _problems;
    List<ProblemTypeItem> _typeProblems;

    ProblemManager() {
        _problems = new HashMap<int, List<ProblemItem>>();
        _typeProblems = new List<ProblemTypeItem>();
        _dataFile = ResourceManager.sample;

        _dataFile.onLoad.then((e) {
            loadProblems(new JsonList.fromString(e['problems'].toString()));
            loadTypeProblems(new JsonList.fromString(e['typeProblems'].toString()));
        });
    }

    void loadProblems(JsonList list) {
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
    }

    void loadTypeProblems(JsonList list) {
        for (JsonObject problem in list) {
            String question = problem.question;
            List<int> answers = problem.answer;
            List<String> options = problem.options;

            _typeProblems.add(new ProblemTypeItem(question, options, answers));
        }
    }

    ProblemTypeItem get randomProblemType {
        ProblemTypeItem item = null;
        int index = -1;
        for (int i = 0; i < 3; i++) {
            index = _random.nextInt(typeProblmes.length);
            item = typeProblmes[index];
            if (!item.used) break;
        }
        item.used = true;
        typeProblmes[index] = item;
        return item;
    }

    HashMap<int, List<ProblemItem>> get problems => _problems;
    List<ProblemTypeItem> get typeProblmes => _typeProblems;
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
            "answer": _answer
        }.toString();
    }
}

class ProblemTypeItem {
    String _question;
    List<String> _options;
    List<int> _answers;
    bool _used;

    ProblemTypeItem(this._question, this._options, this._answers);

    String get question => _question;

    List<String> get options => _options;
    List<int> get answers => _answers;

    bool get used => _used;
    void set used(bool used) {
        this._used = used;
    }

    String toString() {
        return {
            "question": _question,
            "options": _options,
            "answers": _answers
        }.toString();
    }
}
