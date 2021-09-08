import csfml

const
    WINDOW_X: cint = 800
    WINDOW_Y: cint = 600
    BOARD_X = 75
    BOARD_Y = 50
    BACKGROUND_COLOR = color(30, 30, 40)
    SNAKE_HEAD_COLOR = color(30, 225, 75)
    SNAKE_BODY_COLOR = color(20, 200, 50)

type
    Point = tuple[x: int, y: int]
    Snake = seq[Point]
    Board = array[BOARD_X, array[BOARD_Y, int]]

iterator enumerate[T](s: seq[T]): tuple[i: int, v: T] =
    var i = 0

    for v in s:
        yield (i, v)
        i += 1

proc drawSnake(w: RenderWindow, s: Snake) =
    var vertices = newVertexArray(PrimitiveType.Quads, s.len)
    
    for i, p in enumerate(s):
        vertices[i] = newRectangleShape(vec2(0, 0))

let
    ctxSettings = ContextSettings(antialiasingLevel: 16)
    window = newRenderWindow(videoMode(WINDOW_X, WINDOW_Y), "Snake", settings = ctxSettings)

window.verticalSyncEnabled = true

var
    event: Event
    board: Board
    snake: Snake

while window.open:
    if window.pollEvent(event):
        case event.kind:
        of EventType.Closed:
            window.close()
            break
        of EventType.KeyPressed:
            if event.key.code == KeyCode.Escape:
                window.close()
                break
            else:
                echo event.key.code
        else: discard

    window.clear(BACKGROUND_COLOR)
    window.display()

window.destroy()
