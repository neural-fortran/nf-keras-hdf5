submodule(nf_network) nf_network_keras_submodule

  use nf_conv2d_layer, only: conv2d_layer
  use nf_dense_layer, only: dense_layer
  use nf_flatten_layer, only: flatten_layer
  use nf_input1d_layer, only: input1d_layer
  use nf_input3d_layer, only: input3d_layer
  use nf_maxpool2d_layer, only: maxpool2d_layer
  use nf_reshape_layer, only: reshape3d_layer
  use nf_io_hdf5, only: get_hdf5_dataset
  use nf_keras, only: get_keras_h5_layers, keras_layer
  use nf_layer, only: layer
  use nf_layer_constructors, only: conv2d, dense, flatten, input, maxpool2d, reshape
  use nf_activation, only: activation_function, get_activation_by_name

  implicit none

contains

  module function network_from_keras(filename) result(res)
    character(*), intent(in) :: filename
    type(network) :: res
    type(keras_layer), allocatable :: keras_layers(:)
    type(layer), allocatable :: layers(:)
    character(:), allocatable :: layer_name
    character(:), allocatable :: object_name
    integer :: n

    keras_layers = get_keras_h5_layers(filename)

    allocate(layers(size(keras_layers)))

    do n = 1, size(layers)

      select case(keras_layers(n) % class)

        case('Conv2D')

          if (keras_layers(n) % kernel_size(1) &
            /= keras_layers(n) % kernel_size(2)) &
            error stop 'Non-square kernel in conv2d layer not supported.'

          layers(n) = conv2d( &
            keras_layers(n) % filters, &
            !FIXME add support for non-square kernel
            keras_layers(n) % kernel_size(1), &
            get_activation_by_name(keras_layers(n) % activation) &
          )

        case('Dense')

          layers(n) = dense( &
            keras_layers(n) % units(1), &
            get_activation_by_name(keras_layers(n) % activation) &
          )

        case('Flatten')
          layers(n) = flatten()

        case('InputLayer')
          if (size(keras_layers(n) % units) == 1) then
            ! input1d
            layers(n) = input(keras_layers(n) % units(1))
          else
            ! input3d
            layers(n) = input(keras_layers(n) % units)
          end if

        case('MaxPooling2D')

          if (keras_layers(n) % pool_size(1) &
            /= keras_layers(n) % pool_size(2)) &
            error stop 'Non-square pool in maxpool2d layer not supported.'

          if (keras_layers(n) % strides(1) &
            /= keras_layers(n) % strides(2)) &
            error stop 'Unequal strides in maxpool2d layer are not supported.'

          layers(n) = maxpool2d( &
            !FIXME add support for non-square pool and stride
            keras_layers(n) % pool_size(1), &
            keras_layers(n) % strides(1) &
          )

        case('Reshape')
          layers(n) = reshape(keras_layers(n) % target_shape)

        case default
          error stop 'This Keras layer is not supported'

      end select

    end do

    res = network(layers)

    ! Loop over layers and read weights and biases from the Keras h5 file
    ! for each; currently only dense layers are implemented.
    do n = 2, size(res % layers)

      layer_name = keras_layers(n) % name

      select type(this_layer => res % layers(n) % p)

        type is(conv2d_layer)
          ! Read biases from file
          object_name = '/model_weights/' // layer_name // '/' &
            // layer_name // '/bias:0'
          call get_hdf5_dataset(filename, object_name, this_layer % biases)

          ! Read weights from file
          object_name = '/model_weights/' // layer_name // '/' &
            // layer_name // '/kernel:0'
          call get_hdf5_dataset(filename, object_name, this_layer % kernel)

        type is(dense_layer)

          ! Read biases from file
          object_name = '/model_weights/' // layer_name // '/' &
            // layer_name // '/bias:0'
          call get_hdf5_dataset(filename, object_name, this_layer % biases)

          ! Read weights from file
          object_name = '/model_weights/' // layer_name // '/' &
            // layer_name // '/kernel:0'
          call get_hdf5_dataset(filename, object_name, this_layer % weights)

        type is(flatten_layer)
          ! Nothing to do
          continue

        type is(maxpool2d_layer)
          ! Nothing to do
          continue

        type is(reshape3d_layer)
          ! Nothing to do
          continue

        class default
          error stop 'Internal error in network_from_keras(); ' &
            // 'mismatch in layer types between the Keras and ' &
            // 'neural-fortran model layers.'

      end select

  end do

  end function network_from_keras

end submodule nf_network_keras_submodule
