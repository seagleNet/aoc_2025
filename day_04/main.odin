package main

import "core:fmt"
import "core:os"
import "core:slice"
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
	grid := clone_grid(transmute([][]u8)lines)
	defer delete_grid(grid)

	fmt.println(part_1(grid))
	fmt.println(part_2(grid))
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

part_1 :: proc(grid: [][]u8) -> int {
	return scan_and_remove(grid, remove = false)
}

part_2 :: proc(grid: [][]u8) -> int {
	result := 0
	grid_clone := clone_grid(grid)
	defer delete_grid(grid_clone)

	for {
		removed := scan_and_remove(grid_clone, remove = true)
		if removed == 0 {
			break
		}
		result += removed
	}

	return result
}

scan_and_remove :: proc(grid: [][]u8, remove: bool) -> int {
	result := 0

	for y in 0 ..< len(grid) {
		line := grid[y]
		for x in 0 ..< len(line) {
			cell := line[x]
			if cell != '@' {
				continue
			}
			if count_adjacent_rolls(grid, x, y) < 4 {
				result += 1
				if remove {
					grid[y][x] = '.'
				}
			}
		}
	}

	return result
}

count_adjacent_rolls :: proc(grid: [][]u8, x: int, y: int) -> int {
	result := 0

	for dy in -1 ..= 1 {
		ny := y + dy
		if ny < 0 || ny >= len(grid) {
			continue
		}
		line := grid[ny]
		for dx in -1 ..= 1 {
			if dx == 0 && dy == 0 {
				continue
			}
			nx := x + dx
			if nx < 0 || nx >= len(line) {
				continue
			}
			cell := line[nx]

			if cell == '@' {
				result += 1
			}
		}
	}

	return result
}
