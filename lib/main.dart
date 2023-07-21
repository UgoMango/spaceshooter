import 'dart:math' as math;
/// Spaceship of the player
PlayerSpaceship player =
PlayerSpaceship(x: 0, y: 0, speed: 2, health: 100, attackPower: 20);
/// List of enemy spaceships
List<EnemySpaceship> enemies = [
EnemySpaceship(x: 2, y: 5, speed: 1, health: 50, attackPower: 15),
EnemySpaceship(x: -6, y: 2, speed: 2, health: 70, attackPower: 10),
EnemySpaceship(x: 9, y: -9, speed: 1, health: 30, attackPower: 20),
EnemySpaceship(x: 4, y: 8, speed: 2, health: 100, attackPower: 5),
];
/// List of repair stations
List<RepairStation> stations = [
RepairStation(x: 2, y: -8),
RepairStation(x: 8, y: -2),
RepairStation(x: 10, y: -6),
RepairStation(x: 4, y: -6),
];
/// List of teleportStations
List<Teleporter> teleportStations = [
Teleporter(x: 4, y: -8),
Teleporter(x: 2, y: -2),
Teleporter(x: 3, y: -6),
Teleporter(x: 6, y: -6),
];
/// Level-Designer, iterates through each level (1-), while taking levelData from the Lists [teleportStations], [stations] and [enemies]
Map<String, Map<String, dynamic>> levels = {
"Level 1": {
"boundaryX": 10,
"boundaryY": 10,
"enemies": [
      enemies[0],
      enemies[1],
      enemies[2],
      enemies[3],
    ],
"repairStations": [
      stations[0],
      stations[1],
    ],
"teleportStations": [
      teleportStations[0],
      teleportStations[1],
    ]
  },
"Level 2": {
"boundaryX": 15,
"boundaryY": 15,
"enemies": [enemies[1], enemies[2]],
"repairStations": [
      stations[0],
      stations[1],
    ],
"teleportStations": [
      teleportStations[0],
      teleportStations[1],
    ]
  },
"Level 3": {
"boundaryX": 20,
"boundaryY": 20,
"enemies": [
      enemies[3],
      enemies[0],
      enemies[1],
    ],
"repairStations": [
      stations[0],
      stations[1],
    ],
"teleportStations": [
      teleportStations[0],
      teleportStations[1],
    ]
  }
};
void main() {
for (var levelName in levels.keys) {
bool isLevelCompleted = playLevel(levelName, levels[levelName]!);
if (isLevelCompleted) {
print('Level "$levelName" wurde erfolgreich abgeschlossen');
    } else {
print('Level "$levelName" wurde nicht erfolgreich abgeschlossen');
    }
  }
}
bool playLevel(String levelName, Map<String, dynamic> levelData) {
/// Retrieving information from Map [levels]
  int boundaryX = levelData['boundaryX'];
int boundaryY = levelData['boundaryY'];
List<EnemySpaceship> enemies = List.from(levelData['enemies']);
List<RepairStation> stations = List.from(levelData['repairStations']);
List<Teleporter> teleportStations = List.from(levelData['teleportStations']);
bool isGameOver = false;
int round = 1;
while (!isGameOver) {
print('Level: $levelName, R: $round');
    player.move(boundaryY, boundaryX);
for (RepairStation station in stations) {
if (station.x == player.x && station.y == player.y) {
        station.repair(player);
      }
    }
for (Teleporter teleportStation in teleportStations) {
if (teleportStation.x == player.x && teleportStation.y == player.y) {
        teleportStation.teleport(player, boundaryY, boundaryX);
      }
    }
for (EnemySpaceship enemy in enemies) {
      enemy.move(boundaryX, boundaryY);
print("Gegner ${enemies.indexOf(enemy) + 1}: ${enemy.health}");
if (enemy.x == player.x && enemy.y == player.y) {
print('Du hast ein feindliches Schiff entdeckt');
Weapons weapon = player.attackEnemy(enemy, player.attackPower);
        enemy.attackPlayer(player, enemy.attackPower);
print(
'Du hast das feindliche Schiff mit ${weaponToString(weapon)} zerstört!');
print('Du hast ${player.health} Lebenspunkte übrig');
print('Der Gegner hat ${enemy.health} Lebenspunkte übrig');
if (enemy.health <= 0) {
print("Gegnerisches Schiff wurde zerstört!");
        }
      }
    }
    enemies.removeWhere((enemy) => enemy.health <= 0);
if (player.health <= 0) {
      isGameOver = true;
print('Du hast keine Lebenspunkte mehr. Game Over!');
    } else if (enemies.isEmpty) {
      isGameOver = true;
print('Keine Feinde mehr! Du hast gewonnen!');
    }
if (round >= 2000) {
      isGameOver = true;
    }
    round++;
  }
return !isGameOver && enemies.isEmpty;
}
enum Direction { forward, backward, left, right }
enum Weapons { rockets, bombs, shield, laser }
Direction getRandomDirection() {
int ind = math.Random().nextInt(4);
return Direction.values[ind];
}
Weapons getRandomWeapons() {
int ind = math.Random().nextInt(4);
return Weapons.values[ind];
}
abstract class Spaceship {
int x, y, speed, health, attackPower;
Spaceship({
required this.x,
required this.y,
required this.speed,
required this.health,
required this.attackPower,
  });
void move(int boundaryY, int boundaryX) {
Direction direction = getRandomDirection();
switch (direction) {
case Direction.forward:
        y += y >= boundaryY ? 0 : speed;
break;
case Direction.backward:
        y -= y <= -boundaryY ? 0 : speed;
break;
case Direction.left:
        x -= x <= -boundaryX ? 0 : speed;
break;
case Direction.right:
        x += x >= boundaryX ? 0 : speed;
break;
default:
break;
    }
  }
void damageSpaceship(int damage) {
    health -= damage;
  }
}
class PlayerSpaceship extends Spaceship {
PlayerSpaceship({
required int x,
required int y,
required int speed,
required int health,
required int attackPower,
  }) : super(
          x: x,
          y: y,
          speed: speed,
          health: health,
          attackPower: attackPower,
        );
Weapons attackEnemy(EnemySpaceship enemy, int damage) {
    enemy.damageSpaceship(damage);
return attack();
  }
Weapons attack() {
Weapons weapon = getRandomWeapons();
switch (weapon) {
case Weapons.rockets:
        attackPower = 20;
break;
case Weapons.bombs:
        attackPower = 30;
break;
case Weapons.shield:
        attackPower = 0;
break;
case Weapons.laser:
        attackPower = 5;
break;
default:
break;
    }
return weapon;
  }
}
/// Decides with what [Weapons] the enemy spaceships get destroyed
String weaponToString(Weapons weapon) {
switch (weapon) {
case Weapons.rockets:
return "Raketen";
case Weapons.bombs:
return "Bomben";
case Weapons.shield:
return "Schild";
case Weapons.laser:
return "Laser";
default:
return "";
  }
}
class EnemySpaceship extends Spaceship {
EnemySpaceship({
required int x,
required int y,
required int speed,
required int health,
required int attackPower,
  }) : super(
          x: x,
          y: y,
          speed: speed,
          health: health,
          attackPower: attackPower,
        );
void attackPlayer(PlayerSpaceship player, int damage) {
    player.damageSpaceship(damage);
  }
}
class RepairStation {
int x, y;
RepairStation({required this.x, required this.y});
/// repairs the [PlayerShip] while encountering a [RepairStation]
  void repair(PlayerSpaceship spaceship) {
print("Dein Schiff wurde vollständig repariert!");
    spaceship.health = 100;
  }
}
class Teleporter {
int x, y;
Teleporter({required this.x, required this.y});
/// teleports the [PlayerShip] to a random location, based on the boundaries given by [levels]
  void teleport(PlayerSpaceship player, int boundaryX, int boundaryY) {
print("Spaceship wurde teleportiert");
    player.x = math.Random().nextInt(boundaryX * 2 + 1) - boundaryX;
    player.y = math.Random().nextInt(boundaryY * 2 + 1) - boundaryY;
  }
}







