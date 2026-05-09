package yoga

import "core:c"

@(extra_linker_flags = "-lc++")
foreign import lib "libyogacore.a"

YGNodeRef       :: distinct rawptr
YGDirection     :: enum c.int { LTR = 1, RTL = 2 }
YGFlexDirection :: enum c.int { Column = 0, Column_Reverse, Row, Row_Reverse }
YGJustify       :: enum c.int { Flex_Start = 0, Center, Flex_End, Space_Between, Space_Around, Space_Evenly }
YGAlign         :: enum c.int { Auto = 0, Flex_Start, Center, Flex_End, Stretch, Baseline, Space_Between, Space_Around }
YGEdge          :: enum c.int { Left = 0, Top, Right, Bottom, Start, End, Horizontal, Vertical, All }
YGGutter        :: enum c.int { Column = 0, Row, All }
YGWrap          :: enum c.int { No_Wrap = 0, Wrap, Wrap_Reverse }

@(default_calling_convention = "c")
foreign lib {
	YGNodeNew                    :: proc() -> YGNodeRef ---
	YGNodeFree                   :: proc(node: YGNodeRef) ---
	YGNodeInsertChild            :: proc(node, child: YGNodeRef, index: c.uint) ---
	YGNodeCalculateLayout        :: proc(node: YGNodeRef, w, h: c.float, direction: YGDirection) ---
	YGNodeLayoutGetLeft          :: proc(node: YGNodeRef) -> c.float ---
	YGNodeLayoutGetTop           :: proc(node: YGNodeRef) -> c.float ---
	YGNodeLayoutGetWidth         :: proc(node: YGNodeRef) -> c.float ---
	YGNodeLayoutGetHeight        :: proc(node: YGNodeRef) -> c.float ---
	YGNodeStyleSetFlexDirection  :: proc(node: YGNodeRef, direction: YGFlexDirection) ---
	YGNodeStyleSetJustifyContent :: proc(node: YGNodeRef, justify: YGJustify) ---
	YGNodeStyleSetAlignItems     :: proc(node: YGNodeRef, align: YGAlign) ---
	YGNodeStyleSetAlignSelf      :: proc(node: YGNodeRef, align: YGAlign) ---
	YGNodeStyleSetFlexGrow       :: proc(node: YGNodeRef, grow: c.float) ---
	YGNodeStyleSetFlexShrink     :: proc(node: YGNodeRef, shrink: c.float) ---
	YGNodeStyleSetFlexBasis      :: proc(node: YGNodeRef, basis: c.float) ---
	YGNodeStyleSetGap            :: proc(node: YGNodeRef, gutter: YGGutter, gap: c.float) ---
	YGNodeStyleSetPadding        :: proc(node: YGNodeRef, edge: YGEdge, padding: c.float) ---
	YGNodeStyleSetMargin         :: proc(node: YGNodeRef, edge: YGEdge, margin: c.float) ---
	YGNodeStyleSetWidth          :: proc(node: YGNodeRef, width: c.float) ---
	YGNodeStyleSetHeight         :: proc(node: YGNodeRef, height: c.float) ---
	YGNodeStyleSetFlexWrap       :: proc(node: YGNodeRef, wrap: YGWrap) ---
	YGNodeFreeRecursive          :: proc(node: YGNodeRef) ---
}