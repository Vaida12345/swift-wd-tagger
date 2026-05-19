# Run this script to convert original model to CoreML model

from torch import Tensor, nn
import torch
from torch.nn import functional as F
import coremltools as ct
import timm
import numpy as np
from timm.data import create_transform, resolve_data_config

class CoreMLWrapper(nn.Module):
    def __init__(self, model):
        super().__init__()
        self.model = model
        self.transform: Compose = create_transform(**resolve_data_config(model.pretrained_cfg, model=model))  # type: ignore

    def forward(self, x):
        x = self.transform(x)
        x = x[:, [2, 1, 0]]  # BGR to RGB
        
        outputs = self.model(x)
        outputs = F.sigmoid(outputs)
        return outputs

model_repo: str = "SmilingWolf/wd-swinv2-tagger-v3"
model: nn.Module = timm.create_model(f"hf-hub:{model_repo}").eval()
state_dict = timm.models.load_state_dict_from_hf(model_repo)
model.load_state_dict(state_dict)

wrapped = CoreMLWrapper(model).eval().to("cpu")

example_input = torch.randn(1, 3, 448, 448)
transformed_model = torch.jit.trace(wrapped, example_input)

mlmodel = ct.convert(
    transformed_model,
    inputs=[ct.TensorType(name="input", shape=example_input.shape)],
    outputs=[ct.TensorType(name="output", dtype=np.float32)],
    convert_to="neuralnetwork"
)

mlmodel.save("TaggerModel.mlmodel")
