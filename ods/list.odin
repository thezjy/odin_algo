package ods

import "core:mem"
import "core:runtime"

List :: struct(T: typeid) {
	len: int,
	cap: int,
	ptr: ^T,
}


list_append :: proc(list: ^List($T), item: T) {
	if list.len + 1 > list.cap {list_resize(list)}
	mem.ptr_offset(list.ptr, list.len)^ = item
	list.len += 1
}

list_get :: proc(list: ^List($T), i: int) -> T {
	return mem.ptr_offset(list.ptr, i)^
}

list_resize :: proc(list: ^List($T)) {
	list.cap = max(list.cap * 2, 1)
	raw, err := mem.alloc(size_of(T) * list.cap, align_of(T))
	runtime.mem_copy_non_overlapping(raw, list.ptr, list.len)
	list.ptr = cast(^T)raw
}
