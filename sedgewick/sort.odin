package sedgewick

import "core:intrinsics"
import "core:os"
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:time"
import "core:math/rand"
import "core:strconv"
import "core:unicode/utf8"


selection_sort :: proc(data: $T/[]$E) where intrinsics.type_is_ordered(E) {
	for i in 0 ..< len(data) - 1 {
		min := i

		for j in i ..< len(data) {
			if data[min] > data[j] {
				min = j
			}
		}

		slice.swap(data, i, min)
	}
}

insertion_sort :: proc(data: $T/[]$E) where intrinsics.type_is_ordered(E) {
	for i in 1 ..< len(data) {
		for j := i; j > 0 && data[j - 1] > data[j]; j -= 1 {
			slice.swap(data, j - 1, j)
		}
	}
}

time_one_loop :: proc(
	algo: string,
	data: $T/[]$E,
) -> time.Duration where intrinsics.type_is_ordered(E) {

	start := time.tick_now()

	switch algo {
	case "insertion":
		insertion_sort(data)
	case "selection":
		selection_sort(data)
	case "odin":
		slice.sort(data)
	}

	return time.tick_since(start)


}


time_sort_algo :: proc(algo: string, data_size: int, loop_size: int) -> time.Duration {
	total: time.Duration

	for _ in 0 ..< loop_size {
		data := rand.perm(data_size)
		total += time_one_loop(algo, data)
	}

	return time.Duration(int(total) / loop_size)

}

compare_sort :: proc() {

	data_size, _ := strconv.parse_int(os.args[1])
	loop_size, _ := strconv.parse_int(os.args[2])
	algos := os.args[3:]
	durations := make([dynamic]time.Duration, 0, len(algos))


	for algo in algos {
		append(&durations, time_sort_algo(algo, data_size, loop_size))
	}

	for algo, i in algos {
		fmt.printf("%v uses %v\n", algo, int(durations[i]))
	}
}


main :: proc() {
	fmt.printf("%s\n", "詹abc俊宇µ")
	// compare_sort()


}
