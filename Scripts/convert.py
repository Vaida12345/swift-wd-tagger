# Run this script to convert original model to CoreML model

from torch import Tensor, nn
import torch
from torch.nn import functional as F
import coremltools as ct
import timm
import numpy as np

class CoreMLWrapper(nn.Module):
    def __init__(self, model):
        super().__init__()
        self.model = model

    def forward(self, x):
        # force no Python casting paths
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
    inputs=[ct.ImageType(name="input", shape=example_input.shape)],
    outputs=[ct.TensorType(name="output", dtype=np.float32)],
    convert_to="neuralnetwork"
)

mlmodel.save("model.mlmodel")
