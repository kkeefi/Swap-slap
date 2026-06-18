extends Node

const GRAVITY: float = 580.0
const SPEED: float = 130.0
const JUMP_FORCE: float = -295.0
const JUMP_BOOTS_MULT: float = 1.45
const PUSH_FORCE: float = 300.0
const PUSH_UP: float = 100.0
const PUSH_GLOVE_MULT: float = 2.0
const PUSH_CD: float = 0.7
const VW: float = 480.0
const VH: float = 270.0
const PW: float = 7.0
const PH: float = 10.0
const KING_WIN_TIME: float = 7.0

const C_P1: Color = Color(0.22, 0.52, 1.00)
const C_P2: Color = Color(1.00, 0.25, 0.25)
const C_GLOVE: Color = Color(1.00, 0.84, 0.08)
const C_BOOTS: Color = Color(0.18, 0.88, 0.48)
const C_GOLD: Color = Color(1.00, 0.86, 0.18)
const C_BG: Color = Color(0.055, 0.055, 0.12)

enum Mode { BATTLE_RING=0, CRUMBLING=1, LAVA=2, KING=3, CHAOS=4 }
const MODE_COUNT: int = 5
const MODE_NAMES: Array = ["БОЕВОЙ РИНГ","ТАЮЩИЙ ПОЛ","ПОЛ — ЭТО ЛАВА","КРЫША","ХАОС"]
const MODE_DESCS: Array = [
	"Вытолкни врага с ринга!\nПерчатки — удар x2  ·  Ботинки — прыжок x1.5",
	"Платформа крошится — не упади!",
	"Прыгай по платформам над лавой. Она поднимается!",
	"Стой в зоне 10 секунд — и победа.",
	"Управление случайно меняется. Хаос!"
]
const MODE_ICONS : Array = ["🥊","🧱","🌋","🏔","⚡"]

enum BotDifficulty { EASY=0, MEDIUM=1, HARD=2, AI=3 }
var bot_difficulty: int = BotDifficulty.MEDIUM
const DIFF_NAMES : Array = ["EASY","MEDIUM","HARD","ИИ"]
const DIFF_COLORS: Array = [Color(0.3,0.9,0.3), Color(0.9,0.85,0.3), Color(0.9,0.3,0.3), Color(0.7,0.2,1.0)]

var player_count: int = 2
var selected_mode: int = 0
var scores: Array = [0, 0]
var last_winner: int = 0
var forced_bg: int = -1

var debug_mode: bool = false
var dj_mode: bool = false

var match_stats : Dictionary = {"hits":[0,0],"deaths":[0,0],"pickups":[0,0]}

func reset_scores() -> void:
	scores = [0, 0]
	match_stats = {"hits":[0,0],"deaths":[0,0],"pickups":[0,0]}

static func draw_ellipse(canvas: Node2D, center: Vector2,
		rx: float, ry: float, color: Color, segs: int = 12) -> void:
	var pts := PackedVector2Array()
	for i in range(segs):
		var a : float = i * TAU / segs
		pts.append(center + Vector2(cos(a)*rx, sin(a)*ry))
	canvas.draw_colored_polygon(pts, color)
