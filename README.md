# Computing Project (2016-2017)

This is the source code for my [A Level](https://en.wikipedia.org/wiki/GCE_Advanced_Level_(United_Kingdom)) [Computer Science](http://www.aqa.org.uk/subjects/computer-science-and-it/as-and-a-level) project.

|title|institution|development period|language|license|
|:----:|:---------:|:----------------:|:------:|:------:|
|To be determined|[Godalming College](http://www.godalming.ac.uk/)|Autumn 2016 - ongoing|[dart](https://www.dartlang.org/)|[![license][https://img.shields.io/badge/license-Apache%202-blue.svg?style=flat-square]](LICENSE)|

|branch|status|
|:----:|:----:|
|[prototype](https://github.com/GOGO98901/computing-project/tree/prototype)|[![Buis Status][https://img.shields.io/travis/GOGO98901/computing-project/prototype.svg?style=flat-square]](http://travis-ci.org/GOGO98901/computing-project/branches)|
|[project](https://github.com/GOGO98901/computing-project/tree/project)|[![Build Status][https://img.shields.io/travis/GOGO98901/computing-project/project.svg?style=flat-square]](http://travis-ci.org/GOGO98901/computing-project/branches)[![alt text][project-deps]](pubspec.yaml)|
|[gh-pages](https://github.com/GOGO98901/computing-project/tree/gh-pages)|building from project|

### Usage

My project is being build to [github pages](http://gogo98901.github.io/computing-project) already in a playable state. If you want to build and run it yourself follow the instructions bellow.

#### Requirements

- Dart ([latest](https://www.dartlang.org/))
- Jekyll ([latest](https://jekyllrb.com/))
    - Requires [Ruby](https://www.ruby-lang.org/en/) [Gems](https://rubygems.org/)

#### Instructions

1. Clone repository and pull submodules
```shell
git clone https://github.com/GOGO98901/computing-project.git
git submodule update --recursive --remote
```

2. Any Changes to code should happen here.

    Example Changes may include:
    - Changes the database URL
    - Change/Addition/Remove of assets
    - And many more

3. Build Jekyll
```shell
jekyll build ./_site
```

4. Build dart to JavaScript
```shell
pub build
pub build ./_site --mode=release
```

5. Ready for deployment

    The built project now sits in the `build/_site` directory

## Licenses

##### [Source Code](https://github.com/GOGO98901/computing-project/) `./`

```
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
```

##### [bootswatch](http://bootswatch.com) `./public/assets/styles/_variables.scss`

```
The MIT License (MIT)

Copyright (c) 2013 Thomas Park

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```

#### [js-cookie](https://github.com/js-cookie/) `./src/javascript/js.cookie.js`

```
Copyright 2014 Klaus Hartl

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

#### [compress](http://jch.penibelst.de/) `./public/_layouts/compress.html`

```
The MIT License (MIT)

Copyright (c) 2014 Anatol Broder

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

#### [iziToast](https://github.com/dolce/iziToast) `./public/assets/iziToast`

```
Copyright 2016 Marcelo Dolce

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```

#### [OpenGameArt.org *Assets*](http://opengameart.org/)

Audio taken from this source has been converted ([See audio readme](src/audio/readme.md)).

Files taken from this source are under individual licenses (listed bellow)

- [CC0 3.0 Unported](https://creativecommons.org/licenses/by/3.0/)
- [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)

#### [Kenney *Assets*](http://kenney.nl/assets)

- `./src/images/game/ui/kenney/`
- `./src/images/game/background/kenney/`
- `./src/audio/kenney/`

[CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)
