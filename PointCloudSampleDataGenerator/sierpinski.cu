#include <cuda.h>
#include <curand_kernel.h>
#include <fstream>
#include <iostream>

#define NUM_POINTS 10000000l
#define BLOCK_SIZE 512

struct Point {
    float x, y, z;
};

struct Color {
    float r, g, b;
};

__global__ void generatePoints(Point *points, Color *colors, long n) {
    unsigned long id = blockIdx.x * blockDim.x + threadIdx.x;
    curandState state;
    curand_init(id, id, 0, &state);

    Point vertices[4] = {{0.0, 0.0, 0.0}, {1.0, 0.0, 0.0}, {0.5, sqrtf(3.0)/2, 0.0}, {0.5, sqrtf(3.0)/6, sqrtf(2.0/3.0)}};
    Point p = {curand_uniform(&state), curand_uniform(&state), curand_uniform(&state)};

    if (id < n) {
        for (long i = 0; i < 10; ++i) { // Skip first few points
            int rnd = curand(&state) % 4;
            p.x = (p.x + vertices[rnd].x) / 2;
            p.y = (p.y + vertices[rnd].y) / 2;
            p.z = (p.z + vertices[rnd].z) / 2;
        }
        points[id] = p;

        // Assign color based on z-coordinate
        colors[id].r = p.z; // red component
        colors[id].g = 1.0 - p.z; // green component
        colors[id].b = p.x; // blue component
    }
}

int main() {
    Point *dev_points, *points;
    Color *dev_colors, *colors;
    
    points = (Point*)malloc(NUM_POINTS * sizeof(Point));
    colors = (Color*)malloc(NUM_POINTS * sizeof(Color));
    
    cudaMalloc((void**)&dev_points, NUM_POINTS * sizeof(Point));
    cudaMalloc((void**)&dev_colors, NUM_POINTS * sizeof(Color));

    dim3 blocksPerGrid((NUM_POINTS + BLOCK_SIZE - 1) / BLOCK_SIZE, 1, 1);
    dim3 threadsPerBlock(BLOCK_SIZE, 1, 1);

    generatePoints<<<blocksPerGrid, threadsPerBlock>>>(dev_points, dev_colors, NUM_POINTS);

    cudaMemcpy(points, dev_points, NUM_POINTS * sizeof(Point), cudaMemcpyDeviceToHost);
    cudaMemcpy(colors, dev_colors, NUM_POINTS * sizeof(Color), cudaMemcpyDeviceToHost);

    cudaFree(dev_points);
    cudaFree(dev_colors);

    std::ofstream output_file("sierpinski.csv");
    for (long i = 0; i < NUM_POINTS; i++)
        output_file << points[i].x << "," << points[i].y << "," << points[i].z << "," << colors[i].r << "," << colors[i].g << "," << colors[i].b << "\n";

    free(points);
    free(colors);

    return 0;
}

