#!/usr/bin/env bash
set -e
# Path to the latest llama.cpp compiled with all packages installed under conda
# git clone https://github.com/ggerganov/llama.cpp.git
# cd llama.cpp
# conda create --name llama.cpp python=3.12
# conda activate llama.cpp
# python -m pip install -r requirements.txt
# cmake .
TUNING_TOOL=mlx
HF_ORG=CycloneDX
TOOL_BASE_MODEL=cdx1
LLAMA_CPP_PATH=/Volumes/Work/sandbox/llama.cpp
cd $LLAMA_CPP_PATH
CDXGEN_FT_PATH=/Volumes/Work/CycloneDX/cdxgen/contrib/fine-tuning

GGUF_MODEL_Q8_0_NAME=${HF_ORG}/${TOOL_BASE_MODEL}-gguf-Q8_0-GGUF
GGUF_MODEL_Q8_0_PATH=${CDXGEN_FT_PATH}/${HF_ORG}/${TOOL_BASE_MODEL}-gguf-Q8_0-GGUF
FUSED_MODEL=${CDXGEN_FT_PATH}/${HF_ORG}/${TOOL_BASE_MODEL}-${TUNING_TOOL}

rm -rf ${GGUF_MODEL_Q8_0_PATH}
mkdir -p ${GGUF_MODEL_Q8_0_PATH}
python convert_hf_to_gguf.py --outtype q8_0 --outfile ${CDXGEN_FT_PATH}/${HF_ORG}/${TOOL_BASE_MODEL}-gguf-Q8_0-GGUF/${TOOL_BASE_MODEL}-gguf-q8_0.gguf --model-name ${GGUF_MODEL_Q8_0_NAME} ${FUSED_MODEL}
cp ${CDXGEN_FT_PATH}/Modelfile ${GGUF_MODEL_Q8_0_PATH}/
# cp ${FUSED_MODEL}/*.json ${FUSED_MODEL}/merges.txt ${GGUF_MODEL_Q8_0_PATH}/

GGUF_MODEL_BF16_0_NAME=${HF_ORG}/${TOOL_BASE_MODEL}-gguf-BF16-GGUF
GGUF_MODEL_BF16_0_PATH=${CDXGEN_FT_PATH}/${HF_ORG}/${TOOL_BASE_MODEL}-gguf-BF16-GGUF
rm -rf ${GGUF_MODEL_BF16_0_PATH}
mkdir -p ${GGUF_MODEL_BF16_0_PATH}
python convert_hf_to_gguf.py --outtype bf16 --outfile ${CDXGEN_FT_PATH}/${HF_ORG}/${TOOL_BASE_MODEL}-gguf-BF16-GGUF/${TOOL_BASE_MODEL}-gguf-bf16.gguf --model-name ${GGUF_MODEL_BF16_0_NAME} ${FUSED_MODEL}
cp ${CDXGEN_FT_PATH}/Modelfile ${GGUF_MODEL_BF16_0_PATH}/
sed -i '' 's|./cdx1-gguf-q8_0.gguf|./cdx1-gguf-bf16.gguf|g' ${GGUF_MODEL_BF16_0_PATH}/Modelfile

### Testing with ollama
# cd ${GGUF_MODEL_Q8_0_PATH}
# ollama create cdx1-gguf -f Modelfile
# ollama show cdx1-gguf
# ollama run cdx1-gguf "tell me about cdxgen"

export HF_HUB_ENABLE_HF_TRANSFER=0
huggingface-cli whoami
huggingface-cli upload --quiet --repo-type model ${GGUF_MODEL_Q8_0_NAME} ${GGUF_MODEL_Q8_0_PATH} .
huggingface-cli upload --quiet --repo-type model ${GGUF_MODEL_BF16_0_NAME} ${GGUF_MODEL_BF16_0_PATH} .
