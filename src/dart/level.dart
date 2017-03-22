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
part of Computer_Science_Project;

class GameLevel {
    static GameLevel newLevel(CanvasElement canvas, ProblemManager problems, UserManagement managemnt) {
        GameLevel level = new GameLevel(problems, canvas, managemnt);
        managemnt.database.createNewGame(0).then((game) => level.gameTasks = game);
        return level;
    }

    Random _random = new Random();

    int _score, _shapesCollected, _shapesNeeded = 10;

    SpaceStation _baseStation;

    GuiTypeSelector _currentProblemGui;

    EntityHandler<Asteroid> _asteroids;
    EntityHandler<SpaceTrash> _shapes;
    EntityHandler<Mob> _currentMob;

    List<Task> _gameTasks;

    // ignore: unused_field
    UserManagement _userManagement;

    bool _freeze = false;

    double _time = 0.0;
    double _spawnTime = 3.5;
    int _level = 0;

    GameLevel(ProblemManager problems, CanvasElement canvas, this._userManagement) {
        _baseStation = new SpaceStation();
        _score = 0;
        _shapesCollected = 0;

        _asteroids = new EntityHandler<Asteroid>(2.0, () {
            Asteroid asteroid = new Asteroid(_baseStation);
            asteroid.vector2 = genericSpawnLocation();
            return asteroid;
        });
        _asteroids.delay = _spawnTime - (_level * 0.5);

        _shapes = new EntityHandler<SpaceTrash>(_spawnTime, () {
            SpaceTrash trash = new SpaceTrash(canvas, ResourceManager.getSprite('game.enities.parts.${_random.nextInt(11) + 1}'), _baseStation);
            Direction spawnSide = Direction.values[_random.nextInt(4)], oppositeSide;
            trash.vector2 = genericSpawnLocation(side: spawnSide);

            if (spawnSide == Direction.NORTH) oppositeSide = Direction.SOUTH;
            if (spawnSide == Direction.SOUTH) oppositeSide = Direction.NORTH;
            if (spawnSide == Direction.WEST) oppositeSide = Direction.EAST;
            if (spawnSide == Direction.EAST) oppositeSide = Direction.WEST;

            trash.target = genericSpawnLocation(side: oppositeSide);
            trash.action((e) {
                if (e.detail['action'] == MobAction.click.index) {
					ResourceManager.playAudio("game.entity.trash.${_random.nextInt(5) + 1}");
                    if (!_freeze && _currentProblemGui == null) {
                        _freeze = true;
                        ProblemTypeItem item = problems.randomProblemType;
                        _currentProblemGui = new GuiTypeSelector(50, GameHost.height - 140, item.question, item.options, canvas);
                        _currentProblemGui.visible = true;
                        bool called = false;
                        _currentProblemGui.listen(canvas, (e, i) {
                            if (!Util.isLive()) log.info("$i has been clicked");
                            if (!called) {
                                if (item.answers.contains(i)) {
                                    _currentProblemGui.text = ResourceManager.getString("game.problem.answer.correct");
                                    addPoints(200);
                                    _shapesCollected += 1;
                                } else {
                                    _currentProblemGui.text = ResourceManager.getString("game.problem.answer.wrong");
                                    ResourceManager.playAudio("game.event.failed");
                                }
                                double delay = _spawnTime - (_shapesCollected / 2);
                                if (delay < 2.0) delay = 2.0;
                                _shapes.delay = delay;
                                if (_currentProblemGui != null) _currentProblemGui.removeListeners();
                                new Future.delayed(const Duration(seconds: 1, milliseconds: 750), () {
                                    if (_currentProblemGui != null) _currentProblemGui.visible = false;
                                    _currentProblemGui = null;
                                    _freeze = false;
                                    trash.remove();
                                });
                            }
                            called = true;
                        });
                    }
                }
            });
            return trash;
        });

        _currentMob = _shapes;
    }

    /// Renders the Level
    void render(CanvasRenderingContext2D context) {
        _currentMob.render(context);
        _baseStation.render(context);
        if (_currentProblemGui != null) _currentProblemGui.render(context);
    }

    /// Updates the Level
    void update(final double delta) {
        if (!_freeze) {
            _currentMob.update(delta);
            _baseStation.update(delta);
        }
        if (_currentProblemGui != null) _currentProblemGui.update(delta);
    }

    Asteroid get nearestAsteroid {
        Asteroid nearest;
        double distance = 0.0;
        _asteroids.entities.forEach((asteroid) {
            double d = getDistanceFromEntity(asteroid);
            if (d > distance) {
                d = distance;
                nearest = asteroid;
            }
        });
        return nearest;
    }

    double get nearestAsteroidDistance {
        double distance = 0.0;
        _asteroids.entities.forEach((asteroid) {
            double d = getDistanceFromEntity(asteroid);
            if (d > distance) {
                d = distance;
            }
        });
        return distance;
    }

    double getDistanceFromEntity(Entity goal, [Entity start]) {
        if (start == null) start = _baseStation;
        return start.vector2.distanceTo(goal.vector2);
    }

    void addPoints(int points) {
        this._score += points;
        ResourceManager.playAudio("game.event.points");
    }

    List<Task> get gameTasks => _gameTasks;
    void set gameTasks(List<Task> tasks) {
        _gameTasks.clear();
        _gameTasks = tasks;
    }

    int get score => _score;
    int get collectedShapes => _shapesCollected;
    String get formattedScore => _score.toString().padLeft(5, '0');
    String get formattedCollectedSahpes => ResourceManager.getString("game.word.shapes") + " $_shapesCollected/$_shapesNeeded";

    Vector2 genericSpawnLocation({Direction side}) {
        if (side == null) side = Direction.values[_random.nextInt(4)];
        int x = 0, y = 0, margins = 200, offset = 50;
        switch (side) {
            case Direction.WEST: {
                x = -offset;
                y = _random.nextInt(GameHost.height - margins);
                break;
            }
            case Direction.NORTH: {
                x = _random.nextInt(GameHost.width - margins);
                y = -offset;
                break;
            }
            case Direction.EAST: {
                 x = GameHost.width + offset;
                 y = _random.nextInt(GameHost.height - margins);
                break;
            }
            case Direction.SOUTH: {
                x = _random.nextInt(GameHost.width - margins);
                y = GameHost.height + offset;
                break;
            }
        }
        return new Vector2(x.toDouble(), y.toDouble());
    }
}

typedef Entity SpawnEntity();

class EntityHandler<T> {
    final Random _random = new Random();

    double _time = 0.0, _delay =0.0;

    List<T> _entities;

    SpawnEntity _spawn;

    EntityHandler(this._delay, this._spawn) {
        _entities = new List<T>();
    }

    void forceSpawn() {
        if (_spawn != null) {
            Entity entity = _spawn();
            if (entity is T) {
                _entities.add(entity as T);
                if (!Util.isLive()) log.info("Spawned new $T");
            } else log.warning('Entity is not type $T');
        } else log.severe("Spawn is null!");
    }

    void render(CanvasRenderingContext2D context) {
        _entities.forEach((entity) => entity.render(context));
    }

    void update(final double delta) {
        if (_time == 0.0) forceSpawn();
        _time += delta;
        if (_time >= _delay) {
            _time = 0.0;
        }

        List<T> removed = new List<T>();
        _entities.forEach((entity) {
            entity.update(delta);
            if (entity.isRemoved()) removed.add(entity);
        });

        removed.forEach((entity) => _entities.remove(entity));
    }

    double get delay => _delay;
    void set delay(double new_delay) {
        _delay = new_delay;
    }

    List<T> get entities => _entities;
}
