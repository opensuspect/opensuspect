# 1. Naming conventions
## 1.1. Descriptive names
The function / variable / class names should hint at their role.
### Bad
````
    func computerTime(d):
````
### Good
````
    func computeTime(daysElapsed):
````
## 1.2. Consistency
Look at how others named things in the code, and foolow that.

Be mindful of naming conventions, i.e.:

 * *player* refers to the person playing the game, while *character* is used for the 
    player's ingame representation,
 * *team* refers to the collection of players who can win the game together, *role* 
    refers to the special abilities one gets for the game.
### Bad
````
    obj.fetch()
    thing.Get()
````
### Good
````
    obj.get()
    thing.get()
````
## 1.3. Function and class / variable names
The first word in a function name should be a verb, in a class /
variable it should be a noun.
### Bad
````
    timerIncrement()
    calculatedTime
````
### Good
````
    incrementTimer()
    timeCalculated
````
## 1.4. Capitalization
Use camelCase inside files and use snake_case in filenames. Enumerations
are in CamelCase with first letter capitalized.
### Bad
````
    directoryCrawler.gd
    crawl_directory(path_name)
````
### Good
````
    directory_crawler.gd
    crawlDirectory(pathName)
````
# 2. Code organization
## 2.1. Separate the back end and front end
Whenever applicable, do not mix back end calculations with front end display
functions. Use autoloads for complex back end work.

## 2.2. Use autoloads for networking
The nodes on the scene tree are not that easy to syncronize. The important
game state should be stored in an autoload singleton, which should also take
care of the networking. Always send data to the server, and let the server
distribute the data to the other clients.

## 2.3. Always set types
Adding types to all variables make development much more simple and less error-
prone.
### Bad
````
    func doesSomething(a, b):
        var counter = 0
        var result = a
        while counter < 5:
            result = result ^ b
        return result
````
### Good
````
    func doesSomething(a: float, b:int) -> float:
        var counter: int = 0
        var result: float = a
        while counter < 5:
            result = result ^ b
        return result
````
## 2.4. Use `Assert` wherever it makes sense
Assertions help us find places with predictable bugs and functions that are
not yet implemented.
### Bad
````
    funct doSomething():
        # TODO: implement this function
        pass
````
### Good
````
    funct doSomething():
        assert(False, "Not implemented yet")
    
    funct getData():
        assert(len(data) > 0, "The data should be saved first before trying to access it")
        return data
    
    funct movement():
        match a:
            1: 
                goLeft()
            2:
                goRight()
            3:
                jump()
            _:
                assert(False, "Unreachable")
````


## 2.5. Obey the Law of Demeter
Apply the principle of "least knowledge".

 * Each unit should have only limited knowledge about other units: only units
  "closely" related to the current unit.
 * Each unit should only talk to its friends; don't talk to strangers.
 * Only talk to your immediate friends.

https://en.wikipedia.org/wiki/Law_of_Demeter
### Bad
````
    Players[i].player.inventory += item
````
### Good
````
    Players[current].AddInventoryItem(item)
````

## 2.6. Avoid excessive elif
Use match instead whenever possible.
### Bad
````
if (a ==1):
   doSomething()
elif (a == 2)
  doSomethingElse()
elif (a ==3)
  doYetAnotherThing()
else
  doDefaultThing()
````
### Good
````
match a:
  1: 
    doSomething()
  2:
    doSomethingElse()
  3:
   doYetAnotherThing()
 _:
   doDefaultThing()
````
## 2.7. Avoid deep nesting
### Bad
````
if objectExists():
    if objectIsGreen():
        if objectIsMoving():
            return true
        else:
            return false
    else:
        return false
else:
    return false
````
### Good
````
if not objectExists():
    return false
if not objectIsGreen():
    return false
if not objectIsMoving():
    return false
return true
````
## 2.8. Avoid horizontally long code
### Bad
    var colors = {1: "green", 2: "red", 3: "orange", 4: "purple"}
### Good
```
var colors = {}
colors[1] = "green"
colors[2] = "red"
colors[3] = "orange"
colors[4] = "purple"
```
## 2.9. Break long functions up
### Bad
````
func doSomethingComplex:
  # Setup
  [ 30 lines of code ]
  # Process
  [ 60 lines of code ]
  # Cleanup
  [ 20 lines of code ]
````
### Good
````
func doSomethingComplex:
  var values = setup()
  process(values)
  cleanup()
````
## 2.10. Keep code DRY
(don't repeat yourself)
### Bad
````
  process(obj1)
  process(obj2)
  process(obj3)
````
### Good
    for obj in [obj1, obj2, obj3]:
      process(obj)

# 3. Comments and readablilty
## 3.1. Use separatators
It should be easy to navigate the code at a glance. Separate private
and public functions whenever applicable. Separate the server-side and
client-side functions.

Separators are comment lines start with # -- and can contain any number of
dashes. Separated server and client functions are used by the control flow
charting script.

### Bad
````
    func receiveClientData():
        [ ... ]
    
    func notifyServer():
        [ ... ]
       
    func recieveClientNotification():
        [...]
````

### Good

````
# -- Client functions --
    func notifyServer():
        [ ... ]

# -- Server functions --
    func receiveClientData():
        [ ... ]

    func recieveClientNotification():
        [...]
````
## 3.2. Describe what your function does
The control flow charting scripts looks for comments in the code make the
function boxes. Use comments with two "hash" symbols to describe the code
conscisely for the graphing script. The script understands comment lines
*above* the code and on the same line to the *right* of the code. Multi-line
description is possible by using multiple lines *above* the code.
````
func addCharacter(networkId: int) -> void:
    ## Create character resource
    var newCharacterResource: CharacterResource = Characters.createCharacter(networkId)
    ## Create character node
    var newCharacter: KinematicBody2D = newCharacterResource.getCharacterNode()
    ## Randomize position
    var characterPosition: Vector2
    characterPosition.x = rng.randi_range(100, 500)
    characterPosition.y = rng.randi_range(100, 500)
    add_child_below_node(characterNode, newCharacter) ## Add node to scene
    newCharacterResource.setPosition(characterPosition) ## Apply position
````

## 3.3. Avoid vague comments
### Bad
````
    # TODO
    setTime()
````
### Good
````
    # TODO: add timezones
    setTime()
````
