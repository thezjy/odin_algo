package ods

import "core:fmt"
import "core:slice"
import "core:strings"
import "core:os"
import "core:bufio"
import q "core:container/queue"
import "core:math/rand"
import "core:unicode/utf8"
import "core:mem"


main :: proc() {
	e_1_6()
}

e_1_6 :: proc() {
	// naive List, USet and SSet

	DEFAULT_CAP :: 8


	l: List(int)
	fmt.println(l)
	list_append(&l, 321)
	list_append(&l, 123)
	fmt.println(l)
	fmt.println(list_get(&l, 0))
	fmt.println(list_get(&l, 1))
	for i in 0 ..< 40 {
		list_append(&l, i)
	}
	fmt.println(l)

}

e_1_3 :: proc() {
	matched :: proc(s: string) -> bool {
		stack := make([dynamic]u8)

		for c in s {
			switch c {
			case '{', '(', '[':
				append(&stack, u8(c))
			case:
				left := pop(&stack)
				if (c == '}' && left == '{') ||
				   (c == ')' && left == '(') ||
				   (c == ']' && left == '[') {
					continue
				} else {
					return false
				}
			}
		}
		return len(stack) == 0
	}


	assert(matched("{{()[]}}"))
	assert(!matched("{{()]}"))


}


e_1_1_9 :: proc() {
	data, ok := os.read_entire_file(os.stdin)
	if !ok {
		return
	}
	defer delete(data)

	it := string(data)
	lines := strings.split_lines(it)
	rand.shuffle(lines)
	for line in lines {
		fmt.println(line)
	}

}

e_1_1_8 :: proc() {
	data, ok := os.read_entire_file(os.stdin)
	if !ok {
		return
	}
	defer delete(data)

	it := string(data)
	lines := strings.split_lines(it)
	for i := 1; i < len(lines); i += 2 {
		fmt.println(lines[i])
	}
	for i := 0; i < len(lines); i += 2 {
		fmt.println(lines[i])
	}
}

e_1_1_7 :: proc() {
	unique_lines: map[string]int
	defer delete(unique_lines)

	r: bufio.Reader
	bufio.reader_init(&r, {os.stream_from_handle(os.stdin)})
	defer bufio.reader_destroy(&r)

	for {
		line, err := bufio.reader_read_string(&r, '\n')
		if err != nil {
			break
		}
		line = strings.trim_right_space(line)

		if count, ok := unique_lines[line]; ok {
			unique_lines[line] = count + 1
		} else {
			unique_lines[line] = 1
		}

	}

	lines := make([dynamic]string, 0, len(unique_lines))
	defer delete(lines)

	for line in unique_lines {
		append(&lines, line)
	}


	slice.sort(lines[:])

	for line in lines {
		count := unique_lines[line]
		for _ in 0 ..< count {
			fmt.println(line)
		}
	}

}

e_1_1_6 :: proc() {
	unique_lines: map[string]struct {}
	defer delete(unique_lines)

	r: bufio.Reader
	bufio.reader_init(&r, {os.stream_from_handle(os.stdin)})
	defer bufio.reader_destroy(&r)

	for {
		line, err := bufio.reader_read_string(&r, '\n')
		if err != nil {
			break
		}
		line = strings.trim_right_space(line)

		unique_lines[line] = {}
	}

	lines := make([dynamic]string, 0, len(unique_lines))
	defer delete(lines)

	for line in unique_lines {
		append(&lines, line)
	}


	slice.sort(lines[:])

	for line in lines {
		fmt.println(line)
	}
}

e_1_1_5 :: proc() {
	unique_lines: map[string]struct {}
	defer delete(unique_lines)

	r: bufio.Reader
	bufio.reader_init(&r, {os.stream_from_handle(os.stdin)})
	defer bufio.reader_destroy(&r)

	for {
		line, err := bufio.reader_read_string(&r, '\n')
		if err != nil {break}
		line = strings.trim_right_space(line)

		if line in unique_lines {
			fmt.println(line)
		} else {
			unique_lines[line] = {}
		}
	}
}

e_1_1_4 :: proc() {
	unique_lines: map[string]struct {}
	defer delete(unique_lines)

	r: bufio.Reader
	bufio.reader_init(&r, {os.stream_from_handle(os.stdin)})
	defer bufio.reader_destroy(&r)

	for {
		line, err := bufio.reader_read_string(&r, '\n')
		if err != nil {break}
		line = strings.trim_right_space(line)

		if !(line in unique_lines) {
			fmt.println(line)
			unique_lines[line] = {}
		}
	}


}


e_1_1_3 :: proc() {
	size :: 5
	lines: [size]string
	cur := 0


	r: bufio.Reader
	bufio.reader_init(&r, {os.stream_from_handle(os.stdin)})
	defer bufio.reader_destroy(&r)

	for {
		line, err := bufio.reader_read_string(&r, '\n')
		if err != nil {
			break
		}
		line = strings.trim_right_space(line)

		lines[cur] = line
		if (cur == size - 1 && len(line) == 0) {
			fmt.println(lines[0])
		}
		cur = (cur + 1) % size


	}


}

e_1_1_2 :: proc() {
	batch_count :: 3

	lines := make([dynamic]string, 0, batch_count)
	defer delete(lines)

	r: bufio.Reader
	bufio.reader_init(&r, {os.stream_from_handle(os.stdin)})
	defer bufio.reader_destroy(&r)

	for {
		line, err := bufio.reader_read_string(&r, '\n')
		fmt.printf("len(line): %v\n", len(line))
		if len(line) == 0 {
			break
		}
		if err != nil {
			fmt.printf("err: %v\n", err)
			break
		}
		line = strings.trim_right(line, "\r")

		append(&lines, line)

		if len(lines) == batch_count {
			for line, i in lines {
				fmt.printf("%v: %v", i, line)
			}
			clear(&lines)
		}
	}


	for line, i in lines {
		fmt.printf("%v: %v\n", i, line)
	}
}


read_file_by_lines_in_whole :: proc(filepath: string) {
	data, ok := os.read_entire_file(filepath, context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		// process line
	}
}

read_file_by_lines_with_buffering :: proc(filepath: string) {
	f, ferr := os.open(filepath)
	if ferr != 0 {
		// handle error appropriately
		return
	}
	defer os.close(f)

	r: bufio.Reader
	bufio.reader_init(&r, {os.stream_from_handle(f)})
	defer bufio.reader_destroy(&r)

	for {
		line, err := bufio.reader_read_string(&r, '\n')
		if err != nil {
			break
		}
		defer delete(line)
		line = strings.trim_right(line, "\r")

		// process line
	}
}
