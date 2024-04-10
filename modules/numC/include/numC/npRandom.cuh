#ifndef NPRANDOM_CUH
#define NPRANDOM_CUH

#include <numC/npRandom.cuh>
#include <numC/customKernels.cuh>
#include <numC/npGPUArray.cuh>
#include <numC/errorCheckUtils.cuh>
#include <numC/gpuConfig.cuh>

#include <cuda_runtime.h>

#include <time.h>

namespace np
{
    class Random
    {
    public:
        // from uniform distribution
        template <typename TP>
        static ArrayGPU<TP> rand(const unsigned int rows = 1, const unsigned int cols = 1, const unsigned int lo = 0, const unsigned int hi = 1, const unsigned long long seed = static_cast<unsigned long long>(time(NULL)));

        template <typename TP>
        static ArrayGPU<TP> rand(const unsigned int rows, const unsigned int cols, const unsigned long long seed);

        // from normal distribution
        template <typename TP>
        static ArrayGPU<TP> randn(const unsigned int rows = 1, const unsigned int cols = 1, const unsigned long long seed = static_cast<unsigned long long>(time(NULL)));
    };

    template <typename TP>
    ArrayGPU<TP> Random::rand(const unsigned int rows, const unsigned int cols, const unsigned long long seed)
    {
        ArrayGPU<TP> ar(rows, cols);

        const int BLOCK_SIZE = (GPU_NUM_CUDA_CORE == 64)?64:128;
        dim3 block(BLOCK_SIZE);
        dim3 grid(np_ceil( ar.size(), (block.x * 50)));
        kernelInitializeRandomUnif<TP><<<grid, block>>>(ar.mat, rows * cols, seed);
        cudaDeviceSynchronize();

        return ar;
    }

    template <typename TP>
    ArrayGPU<TP> Random::rand(const unsigned int rows, const unsigned int cols, const unsigned int lo, const unsigned int hi, const unsigned long long seed)
    {
        return rand<TP>(rows, cols, seed) * (hi - lo) + lo;
    }

    // from normal distribution
    template <typename TP>
    ArrayGPU<TP> Random::randn(const unsigned int rows, const unsigned int cols, const unsigned long long seed)
    {
        ArrayGPU<TP> ar(rows, cols);
        const int BLOCK_SIZE = (GPU_NUM_CUDA_CORE == 64)?64:128;
        dim3 block(BLOCK_SIZE);
        dim3 grid(np_ceil(ar.size(), (block.x * 50)));
        kernelInitializeRandomNorm<TP><<<grid, block>>>(ar.mat, ar.size(), seed);
        cudaDeviceSynchronize();
        return ar;
    }
}

#endif