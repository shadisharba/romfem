ROMFEM
---------------------

A reduced order finite element implementation to treat fatigue simulations in a continuum damage mechanics framework. This repository implementations the framework developed in my PhD thesis, titled ‘A Semi-Incremental Model Order Reduction Approach for Fatigue Damage Computations’ and available at the following link: https://doi.org/10.15488/9777.

A semi-incremental scheme and a displacement formulated standard finite element incremental framework are implemented to illustrate their differences in terms of computational time and memory footprint. Numerical examples with variable loadings that show speedups in the order of 10-100 are presented.

How to run
---------------------
This code has been tested on **MATLAB 2019b**. There are some issues to run it under MATLAB 2020a.

Start by running `add_folder_to_path` to add the needed folders to `Path`

The simplest example is `example_test` in the examples folders are

* `example_test.m`  
To change the applied load, look at `loading_history.m` that takes five inputs:
   * 1st clamped: boolean to select either clamped or symmetric BC on the example in my thesis (further details will be added here later)
   * 2nd tension: boolean to select either tension or bending
   * 3rd: amplitude of one cycle or more (array)
   * 4th: the period of one cycle or more (array)
   * 5th: time steps per 1/4 cycle

The material parameters are in input_verify.m


* `example_verify.m`  
Provide a comparison between LATIN and Newton-Raphson schemes.


Contact and discussion
---------------------

This software is still under construction, documentation and references have to be added.
If any of the examples (provided in the examples folder) don't run please open an issue.

Licensing
---------------------

See the `LICENSE.md` file for the project license and the licenses of the included dependencies.
