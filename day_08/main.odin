package main

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

// INPUT_FILE :: "example.txt"
// CONNECTIONS :: 10
INPUT_FILE :: "input.txt"
CONNECTIONS :: 1_000

Pair :: struct {
	p: int,
	q: int,
	d: int,
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
	points := parse_points(lines)
	defer delete(points)
	pairs := create_pairs(points)
	defer delete(pairs)
	slice.sort_by(pairs, proc(i, j: Pair) -> bool {
		return i.d < j.d
	})
	closest_n := pairs[:CONNECTIONS]

	circuits := create_circuits(closest_n)
	defer delete_circuits(circuits)

	part_1 := three_largest_product(circuits)
	fmt.println(part_1)
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

parse_points :: proc(lines: []string) -> [][3]int {
	points := make([][3]int, len(lines))
	for line, i in lines {
		line := line
		j := 0
		for s in strings.split_iterator(&line, ",") {
			if j >= 3 {
				fmt.printfln("failed to parse coordinates from: %q", lines[i])
				os.exit(1)
			}
			num, ok := strconv.parse_int(s)
			if !ok {
				fmt.printfln("failed to parse int from: %q", s)
				os.exit(1)
			}
			points[i][j] = num
			j += 1
		}
		if j != 3 {
			fmt.printfln("failed to parse coordinates from: %q", lines[i])
			os.exit(1)
		}
	}
	return points
}

create_pairs :: proc(points: [][3]int) -> []Pair {
	pairs: [dynamic]Pair

	for i in 0 ..< len(points) {
		for j in i + 1 ..< len(points) {
			new_pair := Pair{i, j, pseudo_distance(points[i], points[j])}
			append(&pairs, new_pair)
		}
	}

	return pairs[:]
}

pseudo_distance :: proc(p: [3]int, q: [3]int) -> int {
	d := p - q
	dist2 := d.x * d.x + d.y * d.y + d.z * d.z
	return dist2
}

create_circuits :: proc(pairs: []Pair) -> [][]int {
	circuits: [dynamic][dynamic]int
	defer delete(circuits)
	for pair in pairs {
		found_p := -1
		found_q := -1
		for i in 0 ..< len(circuits) {
			if slice.contains(circuits[i][:], pair.p) {
				found_p = i
			}
			if slice.contains(circuits[i][:], pair.q) {
				found_q = i
			}
		}
		if found_p != -1 && found_q != -1 {
			if found_p == found_q {
				continue
			}
			append(&circuits[found_p], ..circuits[found_q][:])
			delete(circuits[found_q])
			ordered_remove(&circuits, found_q)
			continue
		}
		if found_p != -1 {
			append(&circuits[found_p], pair.q)
			continue
		}
		if found_q != -1 {
			append(&circuits[found_q], pair.p)
			continue
		}
		circuit: [dynamic]int
		append(&circuit, pair.p, pair.q)
		append(&circuits, circuit)
	}

	result := make([][]int, len(circuits))
	for circuit, i in circuits {
		result[i] = circuit[:]
	}
	return result
}

delete_circuits :: proc(circuits: [][]int) {
	for circuit in circuits {
		delete(circuit)
	}
	delete(circuits)
}

three_largest_product :: proc(circuits: [][]int) -> int {
	if len(circuits) < 3 {
		fmt.println("failed to calculate product of circuits: less than three circuits")
		os.exit(1)
	}
	slice.sort_by(circuits, proc(i, j: []int) -> bool {
		return len(i) > len(j)
	})

	result := len(circuits[0])
	for c in circuits[1:3] {
		result *= len(c)
	}
	return result
}
