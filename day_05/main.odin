package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

INPUT_FILE :: "input.txt"

Range :: struct {
	lo, hi: int,
}

main :: proc() {
	data, err := os.read_entire_file(INPUT_FILE, context.allocator)
	if err != nil {
		fmt.printfln("failed to read file: %v: %v", INPUT_FILE, err)
		os.exit(1)
	}
	defer delete(data, context.allocator)

	lines := read_lines(data)
	defer delete(lines)
	ranges, inventory := parse_ranges(lines)
	defer delete(ranges)
	ids := parse_ids(inventory)
	defer delete(ids)
	unexpired_count := count_unexpired(ids, ranges)
	fmt.printfln("part 1: %v", unexpired_count)
}

read_lines :: proc(data: []byte) -> []string {
	str := string(data)
	lines: [dynamic]string
	split := strings.split_lines(str)
	defer delete(split)
	for s in split {
		trimmed := strings.trim_space(s)
		append(&lines, trimmed)
	}
	return lines[:]
}

parse_ranges :: proc(lines: []string) -> ([]Range, []string) {
	ranges: [dynamic]Range
	end_line := 0

	for line, i in lines {
		end_line = i
		if len(line) == 0 {
			break
		}
		lo, sep, hi := strings.partition(line, "-")
		if sep == "" {
			fmt.printfln("failed to parse range: %q", line)
			os.exit(1)
		}
		l, l_ok := strconv.parse_int(lo)
		h, h_ok := strconv.parse_int(hi)
		if !l_ok || !h_ok {
			fmt.printfln("failed to parse range: %q", line)
			os.exit(1)
		}
		append(&ranges, Range{l, h})
	}

	return ranges[:], lines[end_line + 1:]
}

parse_ids :: proc(inventory: []string) -> []int {
	ids: [dynamic]int

	for item in inventory {
		if len(item) == 0 {
			continue
		}
		id, ok := strconv.parse_int(item)
		if !ok {
			fmt.printfln("failed to parse id: %q", item)
			os.exit(1)
		}
		append(&ids, id)
	}

	return ids[:]
}

count_unexpired :: proc(ids: []int, ranges: []Range) -> int {
	result := 0
	for id in ids {
		for r in ranges {
			if id >= r.lo && id <= r.hi {
				result += 1
				break
			}
		}
	}
	return result
}
