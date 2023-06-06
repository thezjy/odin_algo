package union_find

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:time"

UF :: struct {
	id:     [dynamic]u64,
	size:   [dynamic]u64,
	height: [dynamic]u64,
	count:  u64,
}

uf_init :: proc(uf: ^UF, n: u64) {
	uf.id = make([dynamic]u64, n)
	uf.size = make([dynamic]u64, n)

	for i in 0 ..< n {
		uf.id[i] = i
		uf.size[i] = 1
		uf.height[i] = 1
	}

	uf.count = n
}

uf_destroy :: proc(uf: ^UF) {
	delete(uf.id)
	delete(uf.size)
}

uf_connected :: proc(uf: ^UF, p, q: u64) -> bool {
	return uf_find(uf, p) == uf_find(uf, q)
}

uf_find :: proc(uf: ^UF, p: u64) -> (root: u64) {
	root = p

	for root != uf.id[root] do root = uf.id[root]

	// path compression
	// cur_id := p
	// next_id := uf.id[cur_id]
	// for cur_id != next_id {
	// 	uf.id[cur_id] = root
	// 	cur_id = next_id
	// 	next_id = uf.id[cur_id]
	// }

	return
}

uf_connect :: proc(uf: ^UF, p, q: u64) {
	p_root := uf_find(uf, p)
	q_root := uf_find(uf, q)

	if p_root == q_root do return

	if uf.size[p_root] < uf.size[q_root] {
		uf.id[p_root] = q_root
		uf.size[q_root] += uf.size[p_root]
	} else {
		uf.id[q_root] = p_root
		uf.size[p_root] += uf.size[q_root]
	}

	uf.count -= 1
}

Pair :: struct {
	p: u64,
	q: u64,
}

uf_get_input :: proc() -> (n: u64, pairs: [dynamic]Pair) {
	bytes, _ := os.read_entire_file(os.args[1])
	defer delete(bytes)

	str := string(bytes)


	lines := strings.split(str, "\n")

	n, _ = strconv.parse_u64(lines[0])
	pairs = make([dynamic]Pair, 0, n)

	for line in lines[1:(len(lines) - 2)] {
		parts := strings.split(line, " ")
		p, _ := strconv.parse_u64(parts[0])
		q, _ := strconv.parse_u64(parts[1])
		append(&pairs, Pair{p, q})
	}

	return
}


main :: proc() {
	n, pairs := uf_get_input()

	start_time := time.tick_now()

	uf: UF
	uf_init(&uf, n)
	defer uf_destroy(&uf)

	for pair in pairs {
		uf_connect(&uf, pair.p, pair.q)
	}

	fmt.printf("total components: %d\n", uf.count)


	fmt.printf("time used: %v\n", time.tick_since(start_time))
}
