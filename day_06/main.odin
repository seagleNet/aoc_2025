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

	lines := read_lines(data)
	defer delete(lines)

	rows := parse_rows(lines)
	defer delete_rows(rows)
	symbols := parse_symbols(lines)
	defer delete(symbols)

	fmt.println(grand_total(rows, symbols))
}

read_lines :: proc(data: []byte) -> []string {
	str := string(data)
	lines: [dynamic]string
	split := strings.split_lines(str)
	defer delete(split)
	for s in split {
		trimmed := strings.trim_space(s)
		if len(trimmed) == 0 {
			continue
		}
		append(&lines, trimmed)
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

parse_symbols :: proc(lines: []string) -> []string {
	symbols: [dynamic]string

	line := lines[len(lines) - 1]
	for symbol in strings.fields_iterator(&line) {
		append(&symbols, symbol)
	}

	return symbols[:]
}

grand_total :: proc(rows: [][]int, symbols: []string) -> int {
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

calculate :: proc(a: int, b: int, symbol: string) -> int {
	switch symbol {
	case "+":
		return a + b
	case "*":
		return a * b
	case:
		fmt.printfln("unknown operator symbol: %q", symbol)
		os.exit(1)
	}
}
