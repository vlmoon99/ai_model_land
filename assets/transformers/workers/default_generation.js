import { pipeline} from "https://cdn.jsdelivr.net/npm/@huggingface/transformers@3.0.0";


let generator;

async function loadPipelineDefault({typeModel, pathToModel, device}){ //'text-generation', 'onnx-community/Llama-3.2-1B-Instruct-q4f16', 'webgpu', { role: "system", content: "You are a helpful assistant." },{ role: "user", content: "What is the capital of France?" }, { max_new_tokens: 128 }
    if (!typeModel || !pathToModel || !device) {
        throw new Error('All parameters are required.');
    }
    try{
      console.log("Start loading");
      generator = await pipeline(typeModel, pathToModel, {
          device: device,
      });
      console.log("successful");
      self.postMessage({ status: "successful" });
    } catch (error) {
      self.postMessage({
        status: 'error',
        message: error.toString()
      });
    }
}


async function runModel({messages, optionsForGnerator = null}){ //'text-generation', 'onnx-community/Llama-3.2-1B-Instruct-q4f16', 'webgpu', { role: "system", content: "You are a helpful assistant." },{ role: "user", content: "What is the capital of France?" }, { max_new_tokens: 128 }
    try{
      // Generate a response
      const output = await generator(messages, optionsForGnerator);
      console.log(output);
      self.postMessage({
        status: 'successful',
        message: output
      });
    } catch (error) {
      self.postMessage({
        status: 'error',
        message: error.toString()
      });
    }
}


self.addEventListener("message", async (e) => {
    const { type, data } = e.data;
  
    switch (type) {
      case "load":
        loadPipelineDefault(data);
        break;
  
      case "runModel":
        runModel(data);
        break;
    }
});