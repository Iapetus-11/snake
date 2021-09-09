import std/random
import csfml

randomize()

const
    WINDOW_X: cint = 800
    WINDOW_Y: cint = 600
    BOARD_X = 800
    BOARD_Y = 600
    BOARD_PIECE_SIZE = 10
    BACKGROUND_COLOR = color(60, 60, 80)
    WALL_COLOR = color(0, 0, 0)
    SNAKE_HEAD_COLOR = color(30, 225, 75)
    SNAKE_BODY_COLOR = color(20, 200, 50)
    APPLE_COLOR = color(255, 20, 20)

type
    Snake = seq[Vector2i]
    Board = array[BOARD_X, array[BOARD_Y, int]]
    SnakeDirection = enum
        LEFT, UP, RIGHT, DOWN

iterator enumerate[T](s: seq[T]): tuple[i: int, v: T] =
    var i = 0

    for v in s:
        yield (i, v)
        i += 1

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

proc drawGameBorder(w: RenderWindow) =
    var
        rV = newRectangleShape(vec2(BOARD_PIECE_SIZE, BOARD_Y))
        rH = newRectangleShape(vec2(BOARD_X, BOARD_PIECE_SIZE))

    rV.fillColor = WALL_COLOR
    rH.fillColor = WALL_COLOR

    rV.position = vec2(0, 0)
    rH.position = vec2(0, 0)

    w.draw(rV)
    w.draw(rH)

    rV.position = vec2(0, BOARD_Y)
    rH.position = vec2(BOARD_X, 0)

    w.draw(rV)
    w.draw(rH)

    rV.destroy()
    rH.destroy()

let
    ctxSettings = ContextSettings(antialiasingLevel: 16)
    window = newRenderWindow(videoMode(WINDOW_X, WINDOW_Y), "Snake", settings = ctxSettings)

window.verticalSyncEnabled = true

var
    event: Event
    board: Board
    snake: Snake
    direction: SnakeDirection
    apple: Vector2i = vec2(BOARD_X - 5, BOARD_Y - 5)

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
            else: discard
        else: discard

    window.clear(BACKGROUND_COLOR)
    window.drawGameBorder()
    window.drawSnake(snake)
    window.drawApple(apple)
    window.display()


window.destroy()
