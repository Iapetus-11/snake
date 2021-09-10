import std/[os, random, strformat]

randomize()

const ROBOTO_FONT_TTF = cstring(slurp("../Roboto-Black.ttf"))

block: # jank to extract the required dll on startup
    when defined windows:
        const CSFML_GRAPHICS_2_DLL = slurp("../csfml-graphics-2.dll")

    if not fileExists("csfml-graphics-2.dll"):
        writeFile("csfml-graphics-2.dll", CSFML_GRAPHICS_2_DLL)

import csfml

const
    WINDOW_X: cint = 800
    WINDOW_Y: cint = 600
    BOARD_PIECE_SIZE = 20 # must be a factor of both WINDOW_X and WINDOW_Y
    MOVE_DELAY = 80
    # BOARD_X = int(int(WINDOW_X) / BOARD_PIECE_SIZE)
    # BOARD_Y = int(int(WINDOW_Y) / BOARD_PIECE_SIZE)
    BOARD_X = int(WINDOW_X) - BOARD_PIECE_SIZE
    BOARD_Y = int(WINDOW_Y) - BOARD_PIECE_SIZE
    BACKGROUND_COLOR = color(60, 60, 80)
    WALL_COLOR = color(0, 0, 0)
    SNAKE_HEAD_COLOR = color(30, 225, 75)
    SNAKE_BODY_COLOR = color(20, 170, 50)
    APPLE_COLOR = color(255, 20, 20)

type
    Snake = seq[Vector2i]
    SnakeDirection = enum
        NONE, LEFT, UP, RIGHT, DOWN

iterator enumerate[T](s: seq[T]): tuple[i: int, v: T] =
    var i = 0

    for v in s:
        yield (i, v)
        i += 1

proc drawGameBorder(w: RenderWindow) =
    var
        rV = newRectangleShape(vec2(BOARD_PIECE_SIZE, BOARD_Y + BOARD_PIECE_SIZE))
        rH = newRectangleShape(vec2(BOARD_X + BOARD_PIECE_SIZE, BOARD_PIECE_SIZE))

    rV.fillColor = WALL_COLOR
    rH.fillColor = WALL_COLOR

    rV.position = vec2(0, 0)
    rH.position = vec2(0, 0)

    w.draw(rV)
    w.draw(rH)

    rV.position = vec2(BOARD_X, 0)
    rH.position = vec2(0, BOARD_Y)

    w.draw(rV)
    w.draw(rH)

    rV.destroy()
    rH.destroy()

proc drawSnake(w: RenderWindow, s: Snake) =
    for i, p in enumerate(s):
        var r = newRectangleShape(vec2(BOARD_PIECE_SIZE, BOARD_PIECE_SIZE))
        r.position = p
        r.fillColor = if i == 0: SNAKE_HEAD_COLOR else: SNAKE_BODY_COLOR

        w.draw(r)
        r.destroy()

proc drawApple(w: RenderWindow, p: Vector2i) =
    var r = newRectangleShape(vec2(BOARD_PIECE_SIZE, BOARD_PIECE_SIZE))
    r.position = p
    r.fillColor = APPLE_COLOR

    w.draw(r)
    r.destroy()

proc randomBoardPosition(): Vector2i =
    return vec2(
        rand(int(BOARD_X / BOARD_PIECE_SIZE)) * BOARD_PIECE_SIZE + int(BOARD_PIECE_SIZE / 2),
        rand(int(BOARD_Y / BOARD_PIECE_SIZE)) * BOARD_PIECE_SIZE + int(BOARD_PIECE_SIZE / 2)
    )

proc updateGame(s: var Snake, d: SnakeDirection, ld: SnakeDirection, a: Vector2i): tuple[
        success: bool, apple: Vector2i, scoreDiff: int] =
    let head = s[0]
    var
        nextPoint: Vector2i
        success = false
        apple = a
        scoreDiff = 0

    # figure out what the next point will be based off the head
    case d:
    of SnakeDirection.LEFT: nextPoint = vec2(head.x-BOARD_PIECE_SIZE, head.y)
    of SnakeDirection.UP: nextPoint = vec2(head.x, head.y-BOARD_PIECE_SIZE)
    of SnakeDirection.RIGHT: nextPoint = vec2(head.x+BOARD_PIECE_SIZE, head.y)
    of SnakeDirection.DOWN: nextPoint = vec2(head.x, head.y+BOARD_PIECE_SIZE)
    of SnakeDirection.NONE: return (true, apple, 0)

    if nextPoint == a:
        scoreDiff += 1
    else:
        s.delete(s.high)

    success = not (
        nextPoint.x < BOARD_PIECE_SIZE or
        nextPoint.x > BOARD_X - BOARD_PIECE_SIZE or
        nextPoint.y < BOARD_PIECE_SIZE or
        nextPoint.y > BOARD_Y - BOARD_PIECE_SIZE or
        nextPoint in s
    )

    # move head of snake
    s.insert(nextPoint, 0)

    # check + update apple
    while (
        apple == head or
        apple.x < BOARD_PIECE_SIZE or
        apple.x > BOARD_X - BOARD_PIECE_SIZE or
        apple.y < BOARD_PIECE_SIZE or
        apple.y > BOARD_Y - BOARD_PIECE_SIZE or
        apple in s
    ):
        apple = randomBoardPosition()

    return (success, apple, scoreDiff)


let
    ctxSettings = ContextSettings(antialiasingLevel: 16)
    window = newRenderWindow(videoMode(WINDOW_X, WINDOW_Y), "Snake", settings = ctxSettings)
    roboto = newFont(pointer ROBOTO_FONT_TTF, ROBOTO_FONT_TTF.len)
    # roboto = newFont("Roboto-Black.ttf")

window.verticalSyncEnabled = true

var
    event: Event
    snake: Snake
    lastDirection: SnakeDirection
    direction: SnakeDirection
    apple: Vector2i
    success: bool
    score: int

proc setupGame() =
    snake = @[vec2(int(BOARD_X / 2), int(BOARD_Y / 2))]
    lastDirection = SnakeDirection.NONE
    direction = SnakeDirection.NONE
    apple = vec2(snake[0].x - BOARD_PIECE_SIZE * 4, snake[0].y)
    score = 0

setupGame()

while window.open:
    if window.pollEvent(event):
        case event.kind:
        of EventType.Closed:
            window.close()
            break
        of EventType.KeyPressed:
            case event.key.code:
            of KeyCode.Escape:
                window.close()
                break
            of KeyCode.A, KeyCode.Left: direction = SnakeDirection.LEFT
            of KeyCode.W, KeyCode.Up: direction = SnakeDirection.UP
            of KeyCode.D, KeyCode.Right: direction = SnakeDirection.RIGHT
            of KeyCode.S, KeyCode.Down: direction = SnakeDirection.DOWN
            of KeyCode.Space, KeyCode.P: direction = SnakeDirection.NONE
            else: discard
        else: discard

    if (
        (direction == SnakeDirection.UP and lastDirection == SnakeDirection.DOWN) or
        (direction == SnakeDirection.DOWN and lastDirection == SnakeDirection.UP) or
        (direction == SnakeDirection.LEFT and lastDirection == SnakeDirection.RIGHT) or
        (direction == SnakeDirection.RIGHT and lastDirection == SnakeDirection.LEFT)
    ):
        direction = lastDirection


    let r = updateGame(snake, direction, lastDirection, apple)
    success = r.success
    apple = r.apple
    score += r.scoreDiff

    window.clear(BACKGROUND_COLOR)
    window.drawGameBorder()
    window.drawSnake(snake)
    window.drawApple(apple)

    lastDirection = direction

    if direction == SnakeDirection.NONE:
        window.title = &"Snake [Score: {score}] PAUSED"
        let t = newText("PAUSED", roboto, 30)
        t.position = vec2(WINDOW_X / 2 - t.localBounds.width / 2, 40)
        t.fillColor = color(200, 200, 200)
        window.draw(t)
        t.destroy()
    else:
        window.title = &"Snake [Score: {score}]"

    if not success:
        let t = newText("GAME OVER", roboto, 60)
        t.position = vec2(WINDOW_X / 2 - t.localBounds.width / 2, WINDOW_Y / 2 -
                t.localBounds.height)
        t.fillColor = color(255, 10, 10)
        window.draw(t)
        t.destroy()

    window.display()

    if not success:
        sleep(seconds(3))
        # ensures there's no keys pressed left in the queue while the window is sleeping
        while window.pollEvent(event): discard
        setupGame()

    sleep(milliseconds(MOVE_DELAY))

window.destroy()
