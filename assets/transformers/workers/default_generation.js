import { pipeline } from "https://cdn.jsdelivr.net/npm/@huggingface/transformers@3.0.0";

async function loadPipelineDefault(nameUseFor, pathToModel, device, data, optionsForGnerator){ //'text-generation', 'onnx-community/Llama-3.2-1B-Instruct-q4f16', 'webgpu', { role: "system", content: "You are a helpful assistant." },{ role: "user", content: "What is the capital of France?" }, { max_new_tokens: 128 }
        if (!nameUseFor || !pathToModel || !device || !data || !optionsForGnerator) {
            throw new Error('All parameters are required.');
        }
        try{
            const generator = await pipeline(nameUseFor, pathToModel, {
                device: device, // <- Run on WebGPU
            });
            
            // Define the list of messages
            const messages = data;
            
            // Generate a response
            const output = await generator(messages, optionsForGnerator);
            console.log(output);
        } catch (error) {
            throw new Error('Model execution error:', error);
        }
    }






self.addEventListener("message", async (e) => {
    const { type, data } = e.data;
  
    switch (type) {
      case "load":
        loadPipelineDefault();
        break;
  
      case "generate":
        stopping_criteria.reset();
        generate(data);
        break;
  
      case "interrupt":
        stopping_criteria.interrupt();
        break;
  
      case "reset":
        // past_key_values_cache = null;
        stopping_criteria.reset();
        break;
    }
  });