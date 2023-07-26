package allocation

import "core:fmt"
import "core:mem"

Arena :: struct {
	buf:         []byte,
	curr_offset: int,
	prev_offset: int,
}

arena_init :: proc(a: ^Arena, buf: []byte) {
	a.buf = buf
	a.curr_offset = 0
	a.prev_offset = 0
}

arena_alloc :: proc(a: ^Arena, size: int, align: uintptr) -> rawptr {
	// align 'curr_offset' forward to the specified alignment
	curr_ptr := cast(uintptr)raw_data(a.buf) + cast(uintptr)a.curr_offset
	offset := cast(int)align_forward(curr_ptr, align)
	offset -= cast(int)cast(uintptr)raw_data(a.buf) // change to relative offset


	if offset + size <= len(a.buf) {
		ptr := &a.buf[a.curr_offset]
		a.prev_offset = offset
		a.curr_offset = offset + size

		// zero new memory by default
		mem.zero(ptr, size)
		return ptr
	}

	return nil
}

arena_free_all :: proc(a: ^Arena) {
	a.curr_offset = 0
	a.prev_offset = 0
}


align_forward :: proc(ptr: uintptr, align: uintptr) -> uintptr {
	p, modulo: uintptr

	assert(is_power_of_two(align))

	p = ptr
	modulo = p & (align - 1)


	if modulo != 0 {
		p += align - modulo
	}
	return p
}

print_address :: proc(a: uintptr) {
	fmt.printf("%3d %x %64b\n", a, a, a)
}

print_binary :: proc(a: uintptr) {
	fmt.printf("%2d - %8b\n", a, a)
}

is_power_of_two :: proc(x: uintptr) -> bool {
	return (x & (x - 1)) == 0
}


arena_alloc_type :: proc($T: typeid, a: ^Arena) -> ^T {
	t := cast(^T)arena_alloc(a, size_of(T), align_of(T))
	t^ = T{} // Use default initialization value
	return t
}


main :: proc() {
	backing_buffer: [256]byte = ---
	a: Arena
	arena_init(&a, backing_buffer[:])

	p1 := arena_alloc_type(complex64, &a)
	p1^ = complex(3.0, 4.0)
	fmt.println(p1, p1^)
	fmt.println()

	p3 := arena_alloc_type([3]u8, &a)
	p3^ = {0, 255, 255}
	fmt.println(p3, p3^)
	fmt.println()

	p2 := arena_alloc_type(complex128, &a)
	p2^ = complex(3.1, 4.1)
	fmt.println(p2, p2^)
	fmt.println()


	p4 := arena_alloc_type(complex32, &a)
	p4^ = complex(3.2, 4.2)
	fmt.println(p4, p4^)


}
