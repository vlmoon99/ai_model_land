

import { AutoTokenizer, AutoModelForCausalLM, InterruptableStoppingCriteria,} from "https://cdn.jsdelivr.net/npm/@huggingface/transformers@3.0.0";

let tokenizer;
let model;
let stopping_criteria;

async function loadTextGenerationPipelin({model_id, dtype, device, progress_callback = null}) {
    try{
        tokenizer ??= AutoTokenizer.from_pretrained(model_id, {
            progress_callback,
        });
    
        model ??= AutoModelForCausalLM.from_pretrained(model_id, {
            dtype: dtype,
            device: device,
            progress_callback,
        });
        self.postMessage({ status: "successful" });
        stopping_criteria = new InterruptableStoppingCriteria();
    } catch(error) {
        throw  new Error(`Load was stop by Error: ${error}`);
    }
}



async function generate({ tokenizerChatOptions = null, max_new_tokens = 1000}) { //{ add_generation_prompt: true,return_dict: true,}, 1024
  
    const inputs = tokenizer.apply_chat_template(messages, tokenizerChatOptions);      
    
    // let startTime;
    // let numTokens = 0;
    // let tps;
    // const token_callback_function = () => {
    //   startTime ??= performance.now();
  
    //   if (numTokens++ > 0) {
    //     tps = (numTokens / (performance.now() - startTime)) * 1000;
    //   }
    // };
    // const callback_function = (output) => {
    //   self.postMessage({
    //     status: "update",
    //     output,
    //     tps,
    //     numTokens,
    //   });
    // };
  
    // const streamer = new TextStreamer(tokenizer, {
    //   skip_prompt: true,
    //   skip_special_tokens: true,
    //   callback_function,
    //   token_callback_function,
    // });
  
    // Tell the main thread we are starting
  
    const { past_key_values, sequences } = await model.generate({
      ...inputs,
      // TODO: Add when model is fixed
      // past_key_values: past_key_values_cache,
  
      // Sampling
      do_sample: false,
  
      max_new_tokens: max_new_tokens,
    //   streamer,
      stopping_criteria,
      return_dict_in_generate: true,
    });
    // past_key_values_cache = past_key_values;
  
    const decoded = tokenizer.batch_decode(sequences, {
      skip_special_tokens: true,
    });
  
    // Send the output back to the main thread
    self.postMessage({
      status: "successful",
      output: decoded,
    });
  }









self.addEventListener("message", async (e) => {
    const { type, data } = e.data;
  
    switch (type) {
      case "load":
        loadTextGenerationPipelin();
        break;
  
      case "generate":
        stopping_criteria.reset();
        generate(data);
        break;
  
      case "interrupt":
        stopping_criteria.interrupt();
        break;
  
    //   case "reset":
    //     // past_key_values_cache = null;
    //     stopping_criteria.reset();
    //     break;
    }
  });