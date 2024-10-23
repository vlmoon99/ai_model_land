import { pipeline, AutoTokenizer, AutoModelForCausalLM } from "https://cdn.jsdelivr.net/npm/@huggingface/transformers@3.0.0";

export class Transformers {
    worker;


    async test () {
        const classifier = await pipeline(
            "image-classification",
            "onnx-community/mobilenetv4_conv_small.e2400_r224_in1k",
            { device: "webgpu" },
          );
          
          // Classify an image from a URL
          const url = 'https://huggingface.co/datasets/Xenova/transformers.js-docs/resolve/main/tiger.jpg';
          const output = await classifier(url);
          console.log(output);
    }


    async loadTextGenerationPipelin(model_id, dtype, device,progress_callback = null) {
        if(this.worker != null){
            throw new Error("Worker work already");
        }
        this.worker = new Worker(new URL("./workers/text_generation.js", import.meta.url), {
            type: "module",
        });
        this.worker.postMessage({type: "load", data: {model_id, dtype, device, progress_callback}});
    }


    async loadModel(typeLoad, {model_id = null, dtype, nameUseFor = null, pathToModel = null, device = null, data = null, optionsForGnerator = null, progress_callback = null}){
        switch (typeLoad) {
            case 'default': 
                if(!nameUseFor || !pathToModel || !device){
                    throw new Error('Input all parameters');
                }
                await this.loadPipelineDefault(nameUseFor, pathToModel, device, data, optionsForGnerator);
            case 'text-generation':
                await this.loadTextGenerationPipelin(model_id, dtype, device, progress_callback)
        }
    }


    async loadPipelineDefault(nameUseFor, pathToModel, device, data, optionsForGnerator){ //'text-generation', 'onnx-community/Llama-3.2-1B-Instruct-q4f16', 'webgpu', { role: "system", content: "You are a helpful assistant." },{ role: "user", content: "What is the capital of France?" }, { max_new_tokens: 128 }
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
}

window.transformers = new Transformers();
console.log("Transformers.js initialized");