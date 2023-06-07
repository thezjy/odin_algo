package algo

import "core:math"
import "core:testing"
import "core:fmt"

multiply :: proc(x, y: int) -> int {
	fmt.printf("%v * %v\n", x, y)
	if y == 0 {
		return 0
	}


	z := multiply(x, cast(int)math.floor(f64(y / 2)))


	if y % 2 == 0 {
		fmt.printf("%v * %v = 2(%v * floor(%v / 2))\n", x, y, x, y)
		return 2 * z
	} else {
		fmt.printf("%v * %v = %v + 2(%v * floor(%v / 2))\n", x, y, x, x, y)
		return x + 2 * z
	}
}


@(test)
test_multiply :: proc(t: ^testing.T) {
	testing.expect_value(t, multiply(13, 11), 143)
}
