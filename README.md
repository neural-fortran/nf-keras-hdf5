# nf-keras-hdf5

A Keras HDF5 adapter for [neural-fortran](https://github.com/modern-fortran/neural-fortran).

nf-keras-hdf5 allows you to load neural-fortran networks from Keras models saved
in the HDF5 format.

## Getting started

Get the code:

```
git clone https://github.com/neural-fortran/nf-keras-hdf5
cd nf-keras-hdf5
```

### Dependencies

* A Fortran compiler
* [HDF5](https://www.hdfgroup.org/downloads/hdf5/)
  (must be provided by the OS package manager or your own build from source)
* [neural-fortran](https://github.com/modern-fortran/neural-fortran),
  [functional-fortran](https://github.com/wavebitscientific/functional-fortran),
  [h5fortran](https://github.com/geospace-code/h5fortran),
  [json-fortran](https://github.com/jacobwilliams/json-fortran)
  (all handled by the build systems, no need for a manual install)
* [fpm](https://github.com/fortran-lang/fpm) to build the code

### Build

First set the fpm include and link flags for HDF5.
For example, on Ubuntu the default paths for the HDF5 library are:

```
export FPM_FFLAGS=-I/usr/include/hdf5/serial
export FPM_LDFLAGS=-L/usr/lib/x86_64-linux-gnu/hdf5/serial
```

With gfortran, the following will create an optimized build of neural-fortran:

```
fpm build --profile release
```

To run the tests:

```
fpm test --profile release
```

If you use Conda, the following instructions work:

```
conda create -n nf hdf5
conda activate nf
export FPM_FFLAGS="-I$CONDA_PREFIX/include"
export FPM_LDFLAGS="-L$CONDA_PREFIX/lib"
fpm build --profile release
fpm test --profile release
```

See the [Fortran Package Manager](https://github.com/fortran-lang/fpm) for more info on fpm.

## Examples

Take a look at these examples to get a taste of how to use nf-keras-hdf5
with neural-fortran:

1. [dense_from_keras](example/dense_from_keras.f90): Creating a pre-trained
  dense model from a Keras HDF5 file and running the inference.
2. [cnn_from_keras](example/cnn_from_keras.f90): Creating a pre-trained
  convolutional model from a Keras HDF5 file and running the inference.

## Acknowledgement

Development of convolutional networks in neural-fortran and Keras HDF5 adapters
in nf-keras-hdf5 was funded by a contract from NASA Goddard Space Flight Center
to the University of Miami.
Development of optimizers was supported by the Google Summer of Code 2023 project
awarded to [Fortran-lang](https://github.com/fortran-lang).

<img src="assets/nasa.png" alt="NASA logo">
<img src="assets/gsoc.png" alt="GSoC logo">

## Impact

Neural-fortran has been used successfully in over a dozen published studies.
See all papers that cite it
[here](https://scholar.google.com/scholar?cites=7315840714744905948).
