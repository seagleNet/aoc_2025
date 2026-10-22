package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

INPUT_FILE :: "input.txt"

Ceph :: struct {
	numbers: []int,
	symbol:  u8,
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

	rows := parse_rows(lines)
	defer delete_rows(rows)
	symbols := parse_symbols(lines)
	defer delete(symbols)

	fmt.println(grand_total(rows, symbols))

	cephs := parse_cephs(lines)
	defer delete_cephs(cephs)

	fmt.println(grand_total_cephs(cephs))
}

read_lines :: proc(data: []byte) -> []string {
	str := string(data)
	lines: [dynamic]string
	split := strings.split_lines(str)
	defer delete(split)
	for s in split {
		if len(s) == 0 {
			continue
		}
		append(&lines, s)
	}
	return lines[:]
}

parse_rows :: proc(lines: []string) -> [][]int {
	rows: [dynamic][]int

	for line in lines[:len(lines) - 1] {
		line := line
		row: [dynamic]int
		for number in strings.fields_iterator(&line) {
			n, ok := strconv.parse_int(number)
			if !ok {
				fmt.printfln("failed to parse int from: %q", number)
				os.exit(1)
			}
			append(&row, n)
		}
		append(&rows, row[:])
	}

	return rows[:]
}

delete_rows :: proc(rows: [][]int) {
	for row in rows {
		delete(row)
	}
	delete(rows)
}

parse_symbols :: proc(lines: []string) -> []u8 {
	symbols: [dynamic]u8

	line := lines[len(lines) - 1]
	for symbol in strings.fields_iterator(&line) {
		append(&symbols, symbol)
	}

	return symbols[:]
}

parse_cephs :: proc(lines: []string) -> []Ceph {
	pattern_len := len(lines[0])
	for line, i in lines {
		if len(line) != pattern_len {
			fmt.printfln(
				"line[%v] does not match pattern length: expected %v, got %v",
				i,
				pattern_len,
				len(line),
			)
			os.exit(1)
		}
	}

	cephs: [dynamic]Ceph
	numbers: [dynamic]int
	defer delete(numbers)
	symbol: Maybe(u8)

	for c := pattern_len - 1; c >= 0; c -= 1 {
		digits: [dynamic]u8
		defer delete(digits)
		for line in lines {
			switch char := line[c]; char {
			case ' ':
				continue
			case '0' ..= '9':
				append(&digits, char)
			case '+', '*':
				symbol = char
			case:
				fmt.printfln("failed to parse: %q", char)
				os.exit(1)
			}
		}
		if len(digits) == 0 {
			continue
		}
		num := int_from_digits(digits[:])
		append(&numbers, num)
		if s, ok := symbol.?; ok {
			append(&cephs, Ceph{numbers[:], s})
			numbers = {}
			symbol = nil
		}
	}

	return cephs[:]
}

int_from_digits :: proc(digits: []u8) -> int {
	digits := string(digits)
	result, ok := strconv.parse_int(digits)
	if !ok {
		fmt.printfln("failed to parse int from: %q", digits)
		os.exit(1)
	}
	return result
}

delete_cephs :: proc(cephs: []Ceph) {
	for ceph in cephs {
		delete(ceph.numbers)
	}
	delete(cephs)
}

grand_total :: proc(rows: [][]int, symbols: []u8) -> int {
	result := 0

	for symbol, i in symbols {
		interim := rows[0][i]
		for row in rows[1:] {
			interim = calculate(interim, row[i], symbol)
		}
		result += interim
	}

	return result
}

grand_total_cephs :: proc(cephs: []Ceph) -> int {
	result := 0

	for ceph in cephs {
		interim := ceph.numbers[0]
		for num in ceph.numbers[1:] {
			interim = calculate(interim, num, ceph.symbol)
		}
		result += interim
	}

	return result
}

calculate :: proc(a: int, b: int, symbol: u8) -> int {
	switch symbol {
	case '+':
		return a + b
	case '*':
		return a * b
	case:
		fmt.printfln("unknown operator symbol: %q", symbol)
		os.exit(1)
	}
}
