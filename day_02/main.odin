package main

import "core:fmt"
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

	ranges := parse(data)
	defer delete(ranges)

	fmt.println(part_1(ranges[:]))
	fmt.println(part_2(ranges[:]))
}

parse :: proc(data: []byte) -> [dynamic]string {
	str := string(data)
	ranges: [dynamic]string
	for s in strings.split_iterator(&str, ",") {
		append(&ranges, strings.trim_space(s))
	}

	return ranges
}

part_1 :: proc(ranges: []string) -> int {
	invalid := 0

	for range in ranges {
		lo, sep, hi := strings.partition(range, "-")
		if sep == "" {
			fmt.printfln("failed to parse id range: %v", range)
			os.exit(1)
		}

		low, l_ok := strconv.parse_int(lo)
		high, r_ok := strconv.parse_int(hi)
		if !l_ok || !r_ok {
			fmt.printfln("failed to parse id range: %q", range)
			os.exit(1)
		}

		for id in low ..= high {
			digit_count := count_digits(id)
			div := 1
			for _ in 0 ..< digit_count / 2 {
				div *= 10
			}
			top := id / div
			bot := id % div
			if top == bot {
				invalid += id
			}
		}
	}

	return invalid
}

count_digits :: proc(number: int) -> int {
	power := 0
	for i := number; i != 0; i = i / 10 {
		power += 1
	}
	return power
}

part_2 :: proc(ranges: []string) -> int {
	invalid := 0

	for range in ranges {
		lo, sep, hi := strings.partition(range, "-")
		if sep == "" {
			fmt.printfln("failed to parse id range: %v", range)
			os.exit(1)
		}

		low, l_ok := strconv.parse_int(lo)
		high, r_ok := strconv.parse_int(hi)
		if !l_ok || !r_ok {
			fmt.printfln("failed to parse id range: %q", range)
			os.exit(1)
		}

		for id in low ..= high {
			digit_count := count_digits(id)
			for chunk_size := 1; chunk_size <= digit_count / 2; chunk_size += 1 {
				if digit_count % chunk_size != 0 {
					continue
				}
				div := 1
				for _ in 0 ..< chunk_size {
					div *= 10
				}
				chunk_amount := digit_count / chunk_size
				numbers := split_id(id, chunk_amount, div)
				defer delete(numbers)

				if has_pattern(numbers) {
					invalid += id
					break
				}
			}
		}
	}

	return invalid
}

split_id :: proc(id: int, chunk_amount: int, div: int) -> [dynamic]int {
	number := id
	numbers: [dynamic]int

	for _ in 0 ..< chunk_amount {
		part := number % div
		number = number / div

		append(&numbers, part)
	}

	return numbers
}

has_pattern :: proc(numbers: [dynamic]int) -> bool {
	for num in numbers[1:] {
		if num != numbers[0] {
			return false
		}
	}
	return true
}
