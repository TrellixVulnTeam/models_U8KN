#!/bin/bash
#
# Copyright (c) 2021 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
oneccl_bindings_for_pytorch_path=$(python -c "import torch; import oneccl_bindings_for_pytorch; import os;  print(os.path.abspath(os.path.dirname(oneccl_bindings_for_pytorch.__file__)))")
source $oneccl_bindings_for_pytorch_path/env/setvars.sh

MODEL_DIR=${MODEL_DIR-../../../../../..}

#export DNNL_MAX_CPU_ISA=AVX512_CORE_AMX
ARGS="--benchmark"
precision=fp32
batch_size=28
if [[ "$1" == "bf16" ]]
then
    ARGS="$ARGS --bf16"
    precision=bf16
    batch_size=56
    echo "### running bf16 mode"
elif [[ $1 == "bf32" ]]; then
    echo "### running BF32 mode"
    ARGS="$ARGS --bf32"
    precision=bf32
elif [[ $1 == "fp32" ]]; then
    echo "### running FP32 mode"

else
    echo "The specified precision '$1' is unsupported."
    echo "Supported precisions are: fp32, bf16, bf32"
    exit 1
fi

PRETRAINED_MODEL=${PRETRAINED_MODEL:-~/dataset/checkpoint/}
DATASET_DIR=${DATASET_DIR:-~/dataset/}
TRAIN_SCRIPT=${TRAIN_SCRIPT:-${MODEL_DIR}/models/language_modeling/pytorch/bert_large/training/run_pretrain_mlperf.py}
OUTPUT_DIR=${OUTPUT_DIR:-${PWD}}
SOCKETS=`lscpu | grep Socket | awk '{print $2}'`
NNODES=${NNODES:-1}
HOSTFILE=${HOSTFILE:-./hostfile}
work_space=${work_space:-${OUTPUT_DIR}}
rm -rf ${OUTPUT_DIR}/throughput_log_phase2_*

NUM_RANKS=$(( NNODES * SOCKETS ))
LBS=$(( batch_size / NUM_RANKS ))
params="--train_batch_size=$LBS     --learning_rate=3.5e-4     --opt_lamb_beta_1=0.9     --opt_lamb_beta_2=0.999     --warmup_proportion=0.0     --warmup_steps=0.0     --start_warmup_step=0     --max_steps=13700     --phase2    --max_predictions_per_seq=76      --do_train     --skip_checkpoint     --train_mlm_accuracy_window_size=0     --target_mlm_accuracy=0.720     --weight_decay_rate=0.01     --max_samples_termination=4500000     --eval_iter_start_samples=150000 --eval_iter_samples=150000     --eval_batch_size=16  --gradient_accumulation_steps=1     --log_freq=0 "

python -m intel_extension_for_pytorch.cpu.launch --distributed --nnodes ${NNODES} --hostfile ${HOSTFILE}  --log_path=${OUTPUT_DIR} --log_file_prefix="./throughput_log_phase2_${precision}" ${TRAIN_SCRIPT} \
    --input_dir ${DATASET_DIR}/2048_shards_uncompressed_512/ \
    --eval_dir ${DATASET_DIR}/eval_set_uncompressed/ \
    --model_type 'bert' \
    --model_name_or_path ${PRETRAINED_MODEL} \
    --output_dir model_save \
    --dense_seq_output \
    $ARGS \
    $params \
    2>&1 | tee ${OUTPUT_DIR}/throughput_log_phase2_${precision}.log

# For the summary of results
wait
throughput=$(grep 'Throughput:' ${OUTPUT_DIR}/throughput_log_phase2_${precision}* |sed -e 's/.*Throughput//;s/[^0-9.]//g' |awk '
BEGIN {
        sum = 0;
        i = 0;
      }
      {
        sum = sum + $1;
i++;
      }
END   {
sum = sum / i;
printf("%.3f", sum);
}')
echo ""BERT";"training phase2 distributed throughput";${precision}; ${batch_size};${throughput}" | tee -a ${OUTPUT_DIR}/summary.log
