package union_find

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

UF :: struct {
	id:    [dynamic]int,
	size:  [dynamic]int,
	count: int,
}

uf_init :: proc(uf: ^UF, n: int) {
	uf.id = make([dynamic]int, n)
	uf.size = make([dynamic]int, n)

	for i in 0 ..< n {
		uf.id[i] = i
		uf.size[i] = 1
	}

	uf.count = n
}

uf_destroy :: proc(uf: ^UF) {
	delete(uf.id)
	delete(uf.size)
}

uf_connected :: proc(uf: ^UF, p, q: int) -> bool {
	return uf_find(uf, p) == uf_find(uf, q)
}

uf_find :: proc(uf: ^UF, p: int) -> int {
	p := p

	for p != uf.id[p] do p = uf.id[p]

	return p
}

uf_connect :: proc(uf: ^UF, p, q: int) {
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


main :: proc() {
	bytes, ok := os.read_entire_file(os.args[1])
	defer delete(bytes)

	str := string(bytes)

	lines := strings.split(str, "\n")

	n, _ := strconv.parse_int(lines[0])

	uf: UF
	uf_init(&uf, n)
	defer uf_destroy(&uf)

	// last line is empty
	for line in lines[1:(len(lines) - 2)] {
		parts := strings.split(line, " ")
		p, _ := strconv.parse_int(parts[0])
		q, _ := strconv.parse_int(parts[1])

		if uf_connected(&uf, p, q) do continue

		uf_connect(&uf, p, q)
		// fmt.printf("%v - %v\n", p, q)
	}

	fmt.printf("%v components\n", uf.count)


}
