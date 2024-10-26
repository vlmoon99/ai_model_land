import { pipeline, AutoTokenizer, AutoModelForCausalLM } from "https://cdn.jsdelivr.net/npm/@huggingface/transformers@3.0.0";

export class Transformers {
    worker;
    typeLoad;

    async loadTextGenerationPipeline(model_id, dtype, device ,progress_callback = null) {
        if (this.worker != null){
            throw new Error("Worker work already");
        }
        if (!model_id || !dtype || !device){
            throw new Error("Input all required parameters");
        }
        try{
            this.worker = new Worker(new URL("./workers/text_generation.js", import.meta.url), {
                type: "module",
            });
            this.worker.postMessage({type: "load", data: {model_id, dtype, device, progress_callback}});
            console.log("Start loading");
            const loadResponse = await this.waitForWorkerMessage();
            console.log("Model loaded successfully", loadResponse);
            return loadResponse;    
        } catch (error) { 
            throw JSON.stringify({error: new Error(`Model load by default error: ${error.toString()}`)});

        }
    }

    async loadPipelineDefault(typeModel, pathToModel, device){ //'text_generation', 'onnx-community/Llama-3.2-1B-Instruct-q4f16', 'webgpu', { role: "system", content: "You are a helpful assistant." },{ role: "user", content: "What is the capital of France?" }, { max_new_tokens: 128 }
        if (!typeModel || !pathToModel || !device) {
            throw new Error("Input all required parameters");
        }
        if (this.worker != null){
            throw new Error("Worker work already");
        }
        try{
            this.worker = new Worker(new URL("./workers/default_generation.js", import.meta.url), {
                type: "module",
            });
            this.worker.postMessage({type: "load", data: {typeModel , pathToModel, device}});
            console.log("Start loading");
            const loadResponse = await this.waitForWorkerMessage();
            console.log("Model loaded successfully", loadResponse);
            return loadResponse;
        } catch (error) {
            throw JSON.stringify({error: new Error(`Model load by text_generation error: ${error.message}`)});
        }
    }

async waitForWorkerMessage() {
    return new Promise((resolve, reject) => {
        this.worker.onmessage = function(e) {
            const { status, message } = e.data;
            if (status === 'successful') {
                resolve(JSON.stringify({res: e.data}));
            } else if (status === 'error') {
                reject(JSON.stringify({error: "Worker Error: " + (message || "Unknown error")}));
            }
        };

        this.worker.onerror = function(error) {
            reject(JSON.stringify({error: error.toString()}));
        };
    });
}

    async loadModel(typeLoad, {model_id = null, dtype, typeModel = null, device = null, progress_callback = null}){
        this.typeLoad = typeLoad;
        switch (typeLoad) {
            case 'standard': 
                if(!typeModel || !model_id || !device){
                    throw JSON.stringify({ error: 'Input all parameters'});
                }
                return await this.loadPipelineDefault(typeModel, model_id, device);
            case 'text_generation':
                if(!model_id || !dtype || !device){
                    throw JSON.stringify({ error: 'Input all parameters'});
                }
                return await this.loadTextGenerationPipeline(model_id, dtype, device, progress_callback)
            default:
                throw JSON.stringify({ error: 'Incorrect type load'});
        }
    }

    async runModel({ messages, tokenizerChatOptions = null, max_new_tokens = 1000, do_sample = null, return_dict_in_generate = null, skip_special_tokens = null, optionsForGnerator = null}){
        if(this.worker == null || this.typeLoad == null){
            throw JSON.stringify({ error: "You need load model"});
        }
        switch (this.typeLoad) {
            case 'standard': 
                this.worker.postMessage({type: "runModel", data: { messages: messages, optionsForGnerator: optionsForGnerator}});
                const loadResponse = await this.waitForWorkerMessage();
                console.log("Model loaded successfully", loadResponse);
                return loadResponse;
            case 'text_generation':
                this.worker.postMessage({type: "runModel", data: { messages: messages, tokenizerChatOptions: tokenizerChatOptions, max_new_tokens: max_new_tokens, do_sample: do_sample, return_dict_in_generate: return_dict_in_generate, skip_special_tokens: skip_special_tokens}});
                const TextRes = await this.waitForWorkerMessage();
                console.log("Model loaded successfully", TextRes);
                return TextRes;
        }
    }

    async stopModel(){
        if(this.worker == null) {
            throw JSON.stringify({error: new Error("Model not loaded")});
        }
        try{
            await this.worker.terminate();
            this.worker = null;
            return JSON.stringify({res: true});
        } catch (e) {
            throw JSON.stringify({error: new Error(`${e}`)});
        }
    }

    isModelLoaded(){
      if(this.worker == null) {
        return JSON.stringify({res: false});
      } else {
        return JSON.stringify({res: true});
      }
    }
}

window.transformers = new Transformers();
console.log("Transformers.js initialized");