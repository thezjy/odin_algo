package sedgewick

import "core:sort"
import "core:intrinsics"
import "core:os"
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:time"
import "core:math/rand"
import "core:strconv"
import "core:unicode/utf8"

ORD :: intrinsics.type_is_ordered


selection_sort :: proc(data: $T/[]$E) where ORD(E) {
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

insertion_sort :: proc(data: $T/[]$E) where ORD(E) {
	for i in 1 ..< len(data) {
		for j := i; j > 0 && data[j] < data[j - 1]; j -= 1 {
			slice.swap(data, j, j - 1)
		}
	}
}

shell_sort :: proc(data: $T/[]$E) where ORD(E) {
	seq := make([dynamic]int)
	defer delete(seq)

	for h := 1; h < len(data); h = h * 3 + 1 {
		append(&seq, h)
	}

	for k in 0 ..< len(seq) {
		h := seq[len(seq) - 1 - k]
		for i in h ..< len(data) {
			for j := i; j >= h && data[j] < data[j - h]; j -= h {
				slice.swap(data, j, j - h)
			}
		}
	}
}

merge :: proc(data: $T/[]$E, aux: T, lo, mid, hi: int) where ORD(E) {
	if data[mid] <= data[mid + 1] {
		return
	}

	copy(aux[lo:hi + 1], data[lo:hi + 1])

	i := lo
	j := mid + 1

	for k in lo ..= hi {
		if i > mid {
			copy(data[k:hi + 1], aux[j:hi + 1])
			return
		} else if (j > hi) {
			copy(data[k:hi + 1], aux[i:mid + 1])
			return
		} else if (aux[i] < aux[j]) {
			data[k] = aux[i]
			i += 1
		} else {
			data[k] = aux[j]
			j += 1
		}
	}
}


merge_sort_td :: proc(data: $T/[]$E) where ORD(E) {
	aux := make([dynamic]E, len(data))
	defer {delete(aux)}


	sort :: proc(data: $T/[]$E, aux: T, lo, hi: int) where ORD(E) {
		// when will lo > hi?

		if hi - lo < 15 {
			insertion_sort(data[lo:hi])
			return
		}

		mid := lo + (hi - lo) / 2
		sort(data, aux, lo, mid)
		sort(data, aux, mid + 1, hi)
		merge(data, aux, lo, mid, hi)
	}

	sort(data, aux[:], 0, len(data) - 1)
}

merge_sort_bu :: proc(data: $T/[]$E) where ORD(E) {
	aux := make([dynamic]E, len(data))
	defer {delete(aux)}

	for size := 1; size < len(data); size = size + size {
		for lo := 0; lo < len(data) - size; lo += size + size {
			merge(data, aux[:], lo, lo + size - 1, min(lo + size + size - 1, len(data) - 1))
		}

	}

}

Sort_Stat :: struct {
	algo:     string,
	duration: time.Duration,
}

time_one_loop :: proc(algo: string, data: $T/[]$E) -> time.Duration {
	start := time.tick_now()

	switch algo {
	case "insertion":
		insertion_sort(data)
	case "selection":
		selection_sort(data)
	case "shell":
		shell_sort(data)
	case "merge_td":
		merge_sort_td(data)
	case "merge_bu":
		merge_sort_bu(data)
	case "odin_quick":
		slice.sort(data)
	case "odin_merge":
		sort.merge_sort(data)
	}

	return time.tick_since(start)
}


time_sort_algo :: proc(algo: string, data_size: int, loop_size: int) -> time.Duration {
	total: time.Duration

	for _ in 0 ..< loop_size {
		data := rand.perm(data_size)
		total += time_one_loop(algo, data)
	}

	return time.Duration(i64(total) / i64(loop_size))
}

compare_sort :: proc() {
	data_size, _ := strconv.parse_int(os.args[1])
	loop_size, _ := strconv.parse_int(os.args[2])

	algos :=
		len(os.args) < 4 \
		? []string{
			"insertion",
			"selection",
			"shell",
			"odin_quick",
			"odin_merge",
			"merge_td",
			"merge_bu",
		} \
		: os.args[3:]
	stats := make([dynamic]Sort_Stat, 0, len(algos))
	defer delete(stats)

	for algo in algos {
		append(&stats, Sort_Stat{algo, 0})
	}

	for stat, i in stats {
		stats[i].duration = time_sort_algo(stat.algo, data_size, loop_size)
	}

	slice.sort_by(stats[:], proc(a, b: Sort_Stat) -> bool {return a.duration < b.duration})

	for i in 0 ..< len(stats) - 1 {
		stat1 := stats[i]
		stat2 := stats[i + 1]

		fmt.printf(
			"%10v is %v times faster than %10v (%10v VS %10v)\n",
			stat1.algo,
			f64(stat2.duration) / f64(stat1.duration),
			stat2.algo,
			stat1.duration,
			stat2.duration,
		)
	}
}

test :: proc() {
	data := strings.split("SHELLSORTEXAMPLE", "")
	fmt.println(data)
	merge_sort_bu(data)
	fmt.println(data)
}


main :: proc() {
	// test()
	compare_sort()

}
