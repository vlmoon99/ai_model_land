import { AutoTokenizer, AutoModelForCausalLM,} from "https://cdn.jsdelivr.net/npm/@huggingface/transformers@3.0.1";

let tokenizer;
let model;

async function loadTextGenerationPipeline({model_id, dtype, device, model_file_name = null, use_external_data_format = null, progress_callback = progress_callback || (() => {})}) { // 'default',{model_id: 'onnx-community/Llama-3.2-1B-Instruct-q4f16', device: 'webgpu', dtype: 'q4f16'}
    try{
        console.log("Start loading");
        tokenizer ??= await AutoTokenizer.from_pretrained(model_id, {
            progress_callback,
        });
    
        model ??= await AutoModelForCausalLM.from_pretrained(model_id, {
            dtype: dtype,
            device: device,
            model_file_name: model_file_name,
            use_external_data_format: use_external_data_format,
            progress_callback,
        });
        self.postMessage({ status: "successful"});
    } catch(error) {
        self.postMessage({
          status: 'error',
          message: error.toString()
        });
    }
}



async function runModel({ messages , useChatTemplate = false,tokenizerChatOptions = null, max_new_tokens = 1000, do_sample = null, return_dict_in_generate = null, skip_special_tokens = null}) { // tokenizerChatOptions: { add_generation_prompt: true,return_dict: true,}, max_new_tokens: 1024, do_sample: false, return_dict_in_generate: true, skip_special_tokens: true 
    try{
      let inputs;
      if (useChatTemplate == true) {
        inputs = await tokenizer.apply_chat_template(messages, tokenizerChatOptions ? tokenizerChatOptions : {});              
      } else {
        inputs = await tokenizer(messages);
      }
    

      const { past_key_values, sequences } = await model.generate({ 
        ...inputs,
        do_sample: do_sample,
        max_new_tokens: max_new_tokens,
        return_dict_in_generate: return_dict_in_generate,
        return_full_text: false,
      });    
      const decoded = await tokenizer.batch_decode(sequences, {
        skip_special_tokens: skip_special_tokens,
      });
    
      self.postMessage({
        status: "successful",
        output: decoded,
      });
  
    } catch(error) {
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
        await loadTextGenerationPipeline(data);
        break;
      case "runModel":
        await runModel(data);
        break;
      default:
        self.postMessage({
          status: 'error',
          message: 'Input correct function type'
        });
      }
  });