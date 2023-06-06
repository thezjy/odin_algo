package fib

import "core:time"
import "core:fmt"

fib1 :: proc(n: u64) -> u64 {
	switch n {
	case 0:
		return 0
	case 1:
		return 1
	case:
		return fib1(n - 1) + fib1(n - 2)
	}
}


fib2 :: proc(n: u64) -> u64 {
	fibs := make([dynamic]u64, n + 1)
	defer delete(fibs)

	fibs[0] = 0
	fibs[1] = 1

	for i in 2 ..= n {
		fibs[i] = fibs[i - 1] + fibs[i - 2]
	}

	return fibs[n]
}


main :: proc() {
	n: u64 = 45

	fib1_start_time := time.tick_now()
	fib1_result := fib1(n)
	fib1_duration := time.tick_since(fib1_start_time)
	fmt.printf("fib2(%v) = %v, duration: %v\n", n, fib1_result, fib1_duration)

	fib2_start_time := time.tick_now()
	fib2_result := fib2(n)
	fib2_duration := time.tick_since(fib2_start_time)
	fmt.printf("fib2(%v) = %v, duration: %v\n", n, fib2_result, fib2_duration)


}
