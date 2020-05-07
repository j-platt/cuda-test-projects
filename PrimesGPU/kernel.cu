
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include "utils.h"

#include <stdio.h>
#include <vector>
#include <chrono>

inline constexpr unsigned get_index_from_number(unsigned number)
{
	return (number - 3) / 2;//will never truncate any odd number which is all we work with here.
}

inline constexpr unsigned get_number_from_index(unsigned index)
{
	return (index * 2) + 3;
}

constexpr unsigned maxNumber = 1000000000;
constexpr unsigned arraySize = (maxNumber / 2) - 1;//all evens excluded as well as 1
constexpr unsigned maxRoot = static_cast<unsigned>(utils::ct_sqrt(maxNumber)) + 1;//ensure it rounds up
constexpr unsigned maxRootIndex = get_index_from_number(maxRoot);

__global__ void sieve(unsigned* composites)
{
	unsigned const rootIndex = blockIdx.x * blockDim.x + threadIdx.x;
	unsigned const root = ((rootIndex) * 2) + 3;
	if(rootIndex <= maxRootIndex)//for extra threads if tasks%threads != 0
	{
		#pragma unroll
		for(unsigned curIndex = rootIndex + root; curIndex < arraySize; curIndex += root)
		{
			composites[curIndex] |= ~0;
		}
	}
}

void printResults(long long const duration, unsigned* const composites)
{
	unsigned totalPrimes = 1;//2 is prime but never considered here
	for(unsigned i = 0; i < arraySize; ++i)
	{
		if(!composites[i])
		{
			//std::cout << get_number_from_index(i) << "\n";
			++totalPrimes;
		}
	}
	std::cout << "Found  " << totalPrimes << " primes in " << duration << " nanoseconds, " << duration / (1000 * 1000) << " miliseconds, or " << duration / (1000 * 1000 * 1000) << " seconds.";
}


int main()
{
	auto start(std::chrono::high_resolution_clock::now());

	unsigned threadsPerBlock = 32;
	unsigned blockCount = (arraySize + (threadsPerBlock - 1)) / threadsPerBlock;
	unsigned* composites;
	cudaError_t cudaStatus = cudaMallocManaged(&composites, arraySize * sizeof(unsigned));

	sieve<<<blockCount, threadsPerBlock>>>(composites);

	cudaDeviceSynchronize();

	auto end(std::chrono::high_resolution_clock::now());

	printResults(std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count(), composites);

	cudaFree(composites);

    return 0;
}