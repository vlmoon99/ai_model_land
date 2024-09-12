import * as onnxruntime from 'https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/esm/ort.webgpu.min.js';

onnxruntime.env.wasm.wasmPaths = "https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/";
onnxruntime.env.wasm.numThreads = 1;

export class Onnx {
    ortSession;

    modelBuffer = [];
    input;
    worker;
    
    receiveChunk(chunk) {
        this.modelBuffer.push(chunk);
        console.log('Received chunk of size model:', chunk.length);
    }

    async loadWorkerModel(mergedArray) {
      if (this.worker != null) {
        throw new Error("Worker work already");
      } else {
      try {
       this.worker = new Worker("./onnx-worker.js");
        return await new Promise((resolve, reject) => {
          this.worker.postMessage({
              isRun: false,
              modelData: mergedArray
            });
    

            this.worker.onmessage = function(e) {
            const { status, inputNames, outputNames, message } = e.data;
    
            if (status === 'success') {
              console.log('ONNX Session created successfully');
              console.log('Input Names:', inputNames);
              console.log('Output Names:', outputNames);
              resolve({ res: JSON.stringify({inputNames, outputNames})});
            } else if (status === 'error') {
              console.error('Error creating ONNX Session:', message);
              reject(new Error('Error creating ONNX Session:' + message));
            }
          };
    
  
          this.worker.onerror = function(error) {
            console.error('Error in worker:', error.message);
            reject(error);
          };
        });
      } catch (e) {
        console.error(`Error in load ONNX Worker: ${e.message}`);
        throw new Error(`Error in load ONNX Worker: ${e.message}`);
      }
    }
  }

  async runModel(datajson) {
     if (this.worker == null){
      throw new Error("Worker and session wasn`t create");
     } else {
      try {
      return await new Promise((resolve, reject) => {
          const input = new Float32Array(JSON.parse(datajson));
          this.worker.postMessage({
            isRun: true,
            input: input
          });
  

          this.worker.onmessage = function(e) {
          const { status, output, message } = e.data;
  
          if (status === 'success') {
            console.log('ONNX run model');

            
            resolve(JSON.stringify({output}));
          } else if (status === 'error') {
            console.error('Error run ONNX model:', message);
            reject(new Error('Error run ONNX model:', message));
          }
        };
  

        this.worker.onerror = function(error) {
          console.error('Error in worker:', error.message);
          reject(error);
        };
      });
    } catch (e) {
      console.error(`Error in run ONNX Worker: ${e.message}`);
      return JSON.stringify({error: new Error(`Error in run ONNX Worker: ${e.message}`)});
    }
  }
}

    async createSessionPath(){
        try{ 
            this.ortSession = await onnxruntime.InferenceSession.create("../testModel/mobilenetv2-7.onnx"); //"../testModel/model.onnx"
            return this.ortSession;
        }catch(e){
            return `Error: ${e}`;
        }
    }


    async createSessionBuffer(){
      if(this.modelBuffer.length != 0){
        try{
            let totalLength = this.modelBuffer.reduce((acc, val) => acc + val.length, 0);
            let mergedArray = new Uint8Array(totalLength);
            let offset = 0;
            
            for (let chunk of this.modelBuffer) {
                mergedArray.set(chunk, offset);
                offset += chunk.length;
            }
            console.log(mergedArray.byteLength);
            this.modelBuffer = [];
            totalLength = null;
            offset = null;
            var res = await this.loadWorkerModel(mergedArray);
            mergedArray = null;
            return res.res;
        }catch(e){
            return JSON.stringify({error: `${e}`});
        }
      } else {
        console.error("Model not loaded");
        return JSON.stringify({error: "Model not loaded"});
      }
    }

    async stopModel(){}
      

    async test(){
      const response = await fetch('./onnx-worker.js');
      if (response.status == 200){
        console.log("exist");
      } else {
        console.error("not exist");
      }
    }

};

window.onnx = new Onnx();
console.log("AI Model Land initialized");
