package ui

import "yoga"

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

Frame :: struct {
	x, y:          f32,
	w, h:          f32,
	padding:       f32,
	gap:           f32,
	bg:            rl.Color,
	border:        rl.Color,
	border_px:     f32,
	corner_radius: f32,
	row:           bool,
	text_size:     f32,
	text_color:    rl.Color,
}

Label :: struct {
	text:  	 cstring,
	size:  	 f32,
	color: 	 rl.Color,
	padding: f32,
}

@(private)
NodeKind :: enum {
	Frame,
	Label
}

@(private)
Node :: struct {
	kind:          NodeKind,
	yg:            yoga.YGNodeRef,
	// frame
	x, y:          f32,
	bg:            rl.Color,
	border:        rl.Color,
	border_px:     f32,
	corner_radius: f32,
	// label (also points into _labels for external mut)
	label_idx:     int,
	// tree structure
	children:      [64]int,
	child_count:   int,
}

MAX :: 128
GLOBAL_FONT :: "./ui/fonts/cashmarket.ttf"
@(private) _font: rl.Font

@(private) nodes: [MAX]Node
@(private) node_count: int
@(private) labels: [MAX]Label
@(private) label_count: int
@(private) stack: [16]int
@(private) stack_depth: int

@(private) root: int
// temporary idea, later will implement something better, idk
@(private) _def_text_size: f32
@(private) _def_text_color: rl.Color

init :: proc() {
	_font = rl.LoadFont(GLOBAL_FONT)
}

unload :: proc() {
	rl.UnloadFont(_font)
}

begin :: proc(f: Frame) {
	if stack_depth == 0 {
		if node_count > 0 do yoga.YGNodeFreeRecursive(nodes[root].yg)
		node_count, label_count, root = 0, 0, 0
	}

	yg := yoga.YGNodeNew()
	yoga.YGNodeStyleSetFlexDirection(yg, .Row if f.row else .Column)

	if f.w > 0 do yoga.YGNodeStyleSetWidth(yg, auto_cast f.w)
	if f.h > 0 do yoga.YGNodeStyleSetHeight(yg, auto_cast f.h)

	if f.padding > 0 do yoga.YGNodeStyleSetPadding(yg, .All, auto_cast f.padding)
	if f.gap > 0 do yoga.YGNodeStyleSetGap(yg, .All, auto_cast f.gap)

	idx := node_count
	nodes[idx] = Node{
		kind = .Frame, yg = yg,
		x = f.x, y = f.y,
		bg = f.bg,
		border = f.border,
		border_px = f.border_px,
		corner_radius = f.corner_radius,
	}
	node_count += 1

	if f.text_size > 0 do _def_text_size = f.text_size
	if f.text_color.a > 0 do _def_text_color = f.text_color

	if stack_depth > 0 {
		parent := &nodes[stack[stack_depth - 1]]

		yoga.YGNodeInsertChild(
			parent.yg, yg, 
			auto_cast parent.child_count
		)
		parent.children[parent.child_count] = idx
		parent.child_count += 1
	} 
	else {
		root = idx
	}

	stack[stack_depth] = idx
	stack_depth += 1
}

end :: proc() {
	stack_depth -= 1
	if stack_depth > 0 do return
	_root := &nodes[root]

	yoga.YGNodeCalculateLayout(
		_root.yg, 
		auto_cast _root.x + 1e9, 
		1e9, .LTR
	)
	paint(root, _root.x, _root.y)
	free_all(context.temp_allocator)
}

label :: proc(text: string) -> ^Label {
	return push(strings.clone_to_cstring(text, context.temp_allocator))
}

labelf :: proc(fmt_str: string, args: ..any) -> ^Label {
	return push(fmt.ctprintf(fmt_str, ..args))
}

@(private)
push :: proc(text: cstring) -> ^Label {
	if (label_count >= MAX) || (node_count >= MAX) || (stack_depth == 0) {
		return &labels[0]
	}

	s := _def_text_size if _def_text_size > 0 else f32(14)
	c := _def_text_color if _def_text_color.a > 0 else rl.WHITE

	yg := yoga.YGNodeNew()
	yoga.YGNodeStyleSetWidth(yg, auto_cast f32(rl.MeasureText(text, i32(s))))
	yoga.YGNodeStyleSetHeight(yg, auto_cast s)

	parent := &nodes[stack[stack_depth - 1]]
	yoga.YGNodeInsertChild(parent.yg, yg, auto_cast parent.child_count)

	ni := node_count
	nodes[ni] = Node{
		kind = .Label, yg = yg, 
		label_idx = label_count
	}
	parent.children[parent.child_count] = ni
	parent.child_count += 1
	node_count += 1

	labels[label_count] = Label{text = text, size = s, color = c}
	ptr := &labels[label_count]
	label_count += 1

	return ptr
}

@(private)
paint :: proc(ni: int, ox, oy: f32) {
	n := &nodes[ni]

	lx := ox + f32(yoga.YGNodeLayoutGetLeft(n.yg))
	ly := oy + f32(yoga.YGNodeLayoutGetTop(n.yg))
	lw := f32(yoga.YGNodeLayoutGetWidth(n.yg))
	lh := f32(yoga.YGNodeLayoutGetHeight(n.yg))

	rec := rl.Rectangle{lx, ly, lw, lh}
	roundness := clamp(n.corner_radius * 2 / min(lw, lh), 0, 1) if n.corner_radius > 0 else f32(0)

	switch n.kind {
	case .Frame:
		if n.bg.a > 0 {
			if roundness > 0 {
				rl.DrawRectangleRounded(
					rec, roundness, 
					8, n.bg
				)
			} 
			else {
				rl.DrawRectangle(
					i32(lx), i32(ly), // position
					i32(lw), i32(lh), // size
					n.bg
				)
			}
		}
		if n.border_px > 0 && n.border.a > 0 {
			if roundness > 0 {
				rl.DrawRectangleRoundedLinesEx(
					rec, roundness, 8, 
					n.border_px, n.border
				)
			} 
			else {
				rl.DrawRectangleLinesEx(
					rec, n.border_px, 
					n.border
				)
			}
		}
		for i in 0 ..< n.child_count {
			paint(n.children[i], lx, ly)
		}

	case .Label:
		l := labels[n.label_idx]
		rl.DrawTextEx(
			_font, l.text,
			rl.Vector2{lx, ly},
			l.size, 
			l.padding, 
			l.color
		)
	}
}