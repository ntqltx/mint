package voxel

import rl "vendor:raylib"

CHUNK_SIZE :: 16

Voxel :: struct {
	id: u8,
}

Chunk :: struct {
	voxels: [CHUNK_SIZE][CHUNK_SIZE][CHUNK_SIZE]Voxel,
	mesh: rl.Mesh,
}

World :: struct {
	chunk: Chunk,
}

world_init :: proc() -> World {
	w := World{}

	for x in 0 ..< CHUNK_SIZE {
		for z in 0 ..< CHUNK_SIZE {
			w.chunk.voxels[x][0][z].id = 1
		}
	}

	return w
}