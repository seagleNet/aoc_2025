package main

import "core:fmt"
import "core:os"
import "core:strings"

INPUT_FILE :: "input.txt"

main :: proc() {
	data, err := os.read_entire_file(INPUT_FILE, context.allocator)
	if err != nil {
		fmt.printfln("failed to read file: %v: %v", INPUT_FILE, err)
		os.exit(1)
	}
	defer delete(data, context.allocator)

	lines := parse(data)
	defer delete(lines)

	fmt.println(part_1_2(lines[:], 2))
	fmt.println(part_1_2(lines[:], 12))
}

parse :: proc(data: []byte) -> [dynamic]string {
	str := string(data)
	lines: [dynamic]string
	for s in strings.split_lines(str) {
		if len(s) > 0 {
			append(&lines, strings.trim_space(s))
		}
	}
	return lines
}

part_1_2 :: proc(lines: []string, n: int) -> int {
	joltage := 0

	for line in lines {
		batts := line
		largest_batts := largest_n(batts, n)
		joltage += calc_joltage(largest_batts)
	}

	return joltage
}

largest_n :: proc(batts: string, n: int) -> []int {
	best := make([]int, n)
	count := len(batts)
	start := 0
	end := count - n

	for pick in 0 ..< len(best) {
		best_pick := start
		for i in start ..= end {
			batt := int(batts[i] - '0')
			if batt > best[pick] {
				best[pick] = batt
				best_pick = i
			}
		}
		start = best_pick + 1
		end += 1
	}

	return best
}

calc_joltage :: proc(batts: []int) -> int {
	joltage := 0

	for i in 0 ..< len(batts) {
		mul := 1
		for _ in 1 ..< len(batts) - i {
			mul *= 10
		}
		joltage += batts[i] * mul
	}

	return joltage
}
