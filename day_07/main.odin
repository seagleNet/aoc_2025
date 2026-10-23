package main

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"

INPUT_FILE :: "input.txt"

Void :: struct {}

main :: proc() {
	data, err := os.read_entire_file(INPUT_FILE, context.allocator)
	if err != nil {
		fmt.printfln("failed to read file: %v: %v", INPUT_FILE, err)
		os.exit(1)
	}
	defer delete(data, context.allocator)

	lines := read_lines(data)
	defer delete(lines)
	grid := clone_grid(transmute([][]u8)lines)
	defer delete_grid(grid)

	fmt.println(count_splits(grid))

	cache := create_cache(grid)
	defer delete_cache(cache)

	start_col := find_start(grid)
	start_row := 1
	fmt.println(count_timelines(grid, start_row, start_col, cache))
}

read_lines :: proc(data: []byte) -> []string {
	str := string(data)
	lines: [dynamic]string
	split := strings.split_lines(str)
	defer delete(split)
	for s in split {
		trimmed := strings.trim_space(s)
		if len(trimmed) > 0 {
			append(&lines, trimmed)
		}
	}
	return lines[:]
}

clone_grid :: proc(grid: [][]u8) -> [][]u8 {
	clone := make([][]u8, len(grid))
	for row, i in grid {
		clone[i] = slice.clone(row)
	}
	return clone
}

delete_grid :: proc(grid: [][]u8) {
	for row in grid {
		delete(row)
	}
	delete(grid)
}

find_start :: proc(grid: [][]u8) -> int {
	for char, i in grid[0] {
		if char == 'S' {
			return i
		}
	}
	fmt.println("failed to find start")
	os.exit(1)
}

count_splits :: proc(grid: [][]u8) -> int {
	result := 0
	most_right := len(grid[0]) - 1
	beams := make(map[int]Void)
	defer delete(beams)

	map_insert(&beams, find_start(grid), {})
	for line in grid[1:] {
		if !slice.contains(line, '^') {
			continue
		}
		next_beams := make(map[int]Void)
		for i in beams {
			if line[i] != '^' {
				map_insert(&next_beams, i, {})
				continue
			}
			if i > 0 {
				map_insert(&next_beams, i - 1, {})
			}
			if i < most_right {
				map_insert(&next_beams, i + 1, {})
			}
			result += 1
		}
		delete(beams)
		beams = next_beams
	}

	return result
}

create_cache :: proc(grid: [][]u8) -> [][]int {
	cache := make([][]int, len(grid))
	default := make([]int, len(grid[0]))
	defer delete(default)
	slice.fill(default, -1)
	for &row in cache {
		row = slice.clone(default)
	}
	return cache
}

delete_cache :: proc(cache: [][]int) {
	for row in cache {
		delete(row)
	}
	delete(cache)
}

count_timelines :: proc(grid: [][]u8, row: int, col: int, cache: [][]int) -> int {
	if cache[row][col] != -1 {
		return cache[row][col]
	}
	result: int
	if row == len(grid) - 1 {
		return 1
	} else if grid[row][col] == '^' {
		switch col {
		case 0:
			result = count_timelines(grid, row + 1, col + 1, cache)
		case len(grid[row]) - 1:
			result = count_timelines(grid, row + 1, col - 1, cache)
		case:
			result =
				(count_timelines(grid, row + 1, col - 1, cache) +
					count_timelines(grid, row + 1, col + 1, cache))
		}
	} else {
		result = count_timelines(grid, row + 1, col, cache)
	}
	cache[row][col] = result
	return result
}
