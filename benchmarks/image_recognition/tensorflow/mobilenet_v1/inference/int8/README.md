<!--- 0. Title -->
# MobileNet V1 Int8 inference

<!-- 10. Description -->
## Description

This document has instructions for running MobileNet V1 Int8 inference using
Intel-optimized TensorFlow.

<!--- 30. Datasets -->
## Datasets

This step is required only for running accuracy, for running benchmark we do not need to provide dataset.

Download and preprocess the ImageNet dataset using the [instructions here](/datasets/imagenet/README.md).
After running the conversion script you should have a directory with the ImageNet dataset in the TF records format.

Set the `DATASET_DIR` to point to this directory when running MobileNet V1.

<!--- 40. Quick Start Scripts -->
## Quick Start Scripts

| Script name | Description |
|-------------|-------------|
| [`int8_online_inference.sh`](/quickstart/image_recognition/tensorflow/mobilenet_v1/inference/cpu/int8/int8_online_inference.sh) | Runs online inference (batch_size=1). |
| [`int8_batch_inference.sh`](/quickstart/image_recognition/tensorflow/mobilenet_v1/inference/cpu/int8/int8_batch_inference.sh) | Runs batch inference (batch_size=240). |
| [`int8_accuracy.sh`](/quickstart/image_recognition/tensorflow/mobilenet_v1/inference/cpu/int8/int8_accuracy.sh) | Measures the model accuracy (batch_size=100). |
| [`multi_instance_batch_inference.sh`](/quickstart/image_recognition/tensorflow/mobilenet_v1/inference/cpu/int8/multi_instance_batch_inference.sh) | A multi-instance run that uses all the cores for each socket for each instance with a batch size of 56. Uses synthetic data if no `DATASET_DIR` is set. |
| [`multi_instance_online_inference.sh`](/quickstart/image_recognition/tensorflow/mobilenet_v1/inference/cpu/int8/multi_instance_online_inference.sh) | A multi-instance run that uses 4 cores per instance with a batch size of 1. Uses synthetic data if no `DATASET_DIR` is set. |

<!--- 50. AI Kit -->
## Run the model

Setup your environment using the instructions below, depending on if you are
using [AI Kit](/docs/general/tensorflow/AIKit.md):

<table>
  <tr>
    <th>Setup using AI Kit on Linux</th>
    <th>Setup without AI Kit on Linux</th>
    <th>Setup without AI Kit on Windows</th>
  </tr>
  <tr>
    <td>
      <p>To run using AI Kit on Linux you will need:</p>
      <ul>
        <li>numactl
        <li>wget
        <li>Activate the tensorflow conda environment
        <pre>conda activate tensorflow</pre>
      </ul>
    </td>
    <td>
      <p>To run without AI Kit on Linux you will need:</p>
      <ul>
        <li>Python 3
        <li><a href="https://pypi.org/project/intel-tensorflow/">intel-tensorflow>=2.5.0</a>
        <li>git
        <li>numactl
        <li>wget
        <li>A clone of the Model Zoo repo<br />
        <pre>git clone https://github.com/IntelAI/models.git</pre>
      </ul>
    </td>
    <td>
      <p>To run without AI Kit on Windows you will need:</p>
      <ul>
        <li><a href="/docs/general/Windows.md">Intel Model Zoo on Windows Systems prerequisites</a>
        <li>A clone of the Model Zoo repo<br />
        <pre>git clone https://github.com/IntelAI/models.git</pre>
      </ul>
    </td>
  </tr>
</table>

After finishing the setup above, download the pretrained model and set the
`PRETRAINED_MODEL` environment var to the path to the frozen graph.
If you run on Windows, please use a browser to download the pretrained model using the link below.
For Linux, run:
```
wget https://storage.googleapis.com/intel-optimized-tensorflow/models/v1_8/mobilenetv1_int8_pretrained_model.pb
export PRETRAINED_MODEL=$(pwd)/mobilenetv1_int8_pretrained_model.pb
```
Intel® Neural Compressor int8 quantized MobileNet V1 pre-trained model is available as another option to download and try.
```
wget https://storage.googleapis.com/intel-optimized-tensorflow/intel-neural-compressor/v1_13/mobilenetv1-inc-int8-inference.pb
export PRETRAINED_MODEL=$(pwd)/mobilenetv1-inc-int8-inference.pb
```
Check the [instructions](/quickstart/image_recognition/tensorflow/generate_int8/README.md) for more details on how to quantize FP32 model using Intel® Neural Compressor.

Set environment variables for the path to your `DATASET_DIR` for ImageNet
and an `OUTPUT_DIR` where log files will be written. Navigate to your
model zoo directory and then run a [quickstart script](#quick-start-scripts) on either Linux or Windows.

### Run on Linux:
```
# cd to your model zoo directory
cd models

export PRETRAINED_MODEL=<path to the frozen graph downloaded above>
export DATASET_DIR=<path to the ImageNet TF records>
export OUTPUT_DIR=<path to the directory where log files will be written>
# For a custom batch size, set env var `BATCH_SIZE` or it will run with a default value.
export BATCH_SIZE=<customized batch size value>

./quickstart/image_recognition/tensorflow/mobilenet_v1/inference/cpu/int8/<script name>.sh
```

### Run on Windows
Using `cmd.exe` run:
```
# cd to your model zoo directory
cd models

set PRETRAINED_MODEL=<path to the frozen graph downloaded above>
set DATASET_DIR=<path to the ImageNet TF records>
set OUTPUT_DIR=<directory where log files will be written>
# For a custom batch size, set env var `BATCH_SIZE` or it will run with a default value.
set BATCH_SIZE=<customized batch size value>

bash quickstart\image_recognition\tensorflow\mobilenet_v1\inference\cpu\int8\<script name>.sh
```
> Note: You may use `cygpath` to convert the Windows paths to Unix paths before setting the environment variables.
As an example, if the dataset location on Windows is `D:\user\ImageNet`, convert the Windows path to Unix as shown:
> ```
> cygpath D:\user\ImageNet
> /d/user/ImageNet
>```
>Then, set the `DATASET_DIR` environment variable `set DATASET_DIR=/d/user/ImageNet`.

<!--- 90. Resource Links-->
## Additional Resources

* To run more advanced use cases, see the instructions [here](Advanced.md)
  for calling the `launch_benchmark.py` script directly.
* To run the model using docker, please see the [oneContainer](http://software.intel.com/containers)
  workload container:<br />
  [https://software.intel.com/content/www/us/en/develop/articles/containers/mobilenetv1-int8-inference-tensorflow-container.html](https://software.intel.com/content/www/us/en/develop/articles/containers/mobilenetv1-int8-inference-tensorflow-container.html).

