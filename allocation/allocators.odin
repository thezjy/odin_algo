package allocation

import "core:fmt"
import "core:mem"
import "core:intrinsics"

ArenaAllocator :: struct {
	buffer: []byte,
	offset: int,
}

arena_init :: proc(a: ^ArenaAllocator, buffer: []byte) {
	a.buffer = buffer
	a.offset = 0
}

arena_alloc :: proc(a: ^ArenaAllocator, size: int) -> rawptr {
	if a.offset + size <= len(a.buffer) {
		ptr := &a.buffer[a.offset]
		a.offset += size
		intrinsics.mem_zero(ptr, size)
		is_power_of_two(cast(uintptr)ptr)
		return ptr
	}

	return nil
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

align_forward :: proc(ptr: uintptr, align: uintptr) -> uintptr {
	p, modulo: uintptr

	assert(is_power_of_two(align))

	p = ptr
	print_binary(p)
	print_binary(align)
	print_binary(align - 1)
	modulo = p & (align - 1)
	print_binary(modulo)

	if modulo != 0 {
		print_binary(align - modulo)
		p += align - modulo
		print_binary(p)
	}
	return p
}


main :: proc() {
	// buffer: [1024]byte = ---
	// a: ArenaAllocator
	// arena_init(&a, buffer[:])

	// p1 := cast(^u16)arena_alloc(&a, 1)
	// p1^ = 65535
	// p2 := cast(^i8)arena_alloc(&a, 1)
	// p2^ = -4
	// for byte in buffer[0:8] {
	// 	fmt.printf("%8b ", byte)
	// }
	// fmt.println()
	// fmt.println(p1^)
	// fmt.println(p2^)


	// is_power_of_two(9)

	fmt.println(align_forward(37, 16))


}
