### Basics

- [X] Image
- [X] Histogram
- [X] Vantage Point Tree
- [X] V-P Search
- [ ] Colormap
- [ ] Quantization
  - [ ] No Dithering
  - [ ] Dithering
- [ ] C API
- [ ] Benchmarks

### Optimizations
- [ ] Prep: Setup benchmarks using [zBench](https://github.com/hendriknielaender/zBench)
- [ ] Histogram: Use a simpler key hash function via context.
- [ ] Histogram: See if map can be replaced with array like [SIMD Histogram](https://github.com/ermig1979/Simd/blob/acf9583a5c813f01a97a59f20b1cb0009c04028b/src/Simd/SimdBaseHistogram.cpp#L61-L84)
- [ ] VP Search: Do an allocation profile and see where we can save on `accept`.
