package main

import "core:fmt"
import "core:math"
import "core:os"
import "core:strconv"
import "core:strings"

INPUT_FILE :: "input.txt"

main :: proc() {
	data, err := os.read_entire_file(INPUT_FILE, context.allocator)
	if err != nil {
		fmt.printfln("failed to read file: %v: %v", INPUT_FILE, err)
		os.exit(1)
	}
	defer delete(data, context.allocator)

	fmt.println(part_1(data))
	fmt.println(part_2(data))
}

part_1 :: proc(data: []byte) -> int {
	str := string(data)
	start := 50
	end := 50
	zero_count := 0

	for line in strings.split_lines_iterator(&str) {
		line_trim := strings.trim_space(line)
		if len(line_trim) == 0 {
			continue
		}

		op := line_trim[0]
		steps, ok := strconv.parse_int(line_trim[1:])
		if !ok {
			fmt.println("failed to parse_int: ", steps)
			os.exit(1)
		}

		start = end
		switch op {
		case 'L':
			end = start - steps
		case 'R':
			end = start + steps
		case:
			fmt.println("unknown op: ", op)
			os.exit(1)
		}

		if end %% 100 == 0 {
			zero_count += 1
		}
	}

	return zero_count
}

part_2 :: proc(data: []byte) -> int {
	str := string(data)
	start := 50
	end := 50
	zero_count := 0

	for line in strings.split_lines_iterator(&str) {
		line_trim := strings.trim_space(line)
		if len(line_trim) == 0 {
			continue
		}

		op := line_trim[0]
		steps, ok := strconv.parse_int(line_trim[1:])
		if !ok {
			fmt.println("failed to parse_int: ", steps)
			os.exit(1)
		}

		start = end
		switch op {
		case 'L':
			end = start - steps
			zero_count += math.floor_div(start - 1, 100) - math.floor_div(end - 1, 100)
		case 'R':
			end = start + steps
			zero_count += math.floor_div(end, 100) - math.floor_div(start, 100)
		case:
			fmt.println("unknown op: ", op)
			os.exit(1)
		}
	}

	return zero_count
}
