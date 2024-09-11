import * as onnxruntime from 'https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/esm/ort.webgpu.min.js';

onnxruntime.env.wasm.wasmPaths = "https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/";
onnxruntime.env.wasm.numThreads = 1;

export class Onnx {
    ortSession;

    modelBuffer = [];
    input;
    worker;
    
    receiveChunk(chunk, isModel) {
      if (isModel == true){
        this.modelBuffer.push(chunk);
        console.log('Received chunk of size model:', chunk.length);
      } else if (isModel == false){
        this.inputBuffer.push(chunk);
        console.log('Received chunk of size input data:', chunk.length);
      } else {
        console.error("Incorrect isModel data");
      }
    }

    async load() {
      try {
       this.worker = new Worker("./onnx-worker.js");
        const response = await fetch('../testModel/mobilenetv2-7.onnx');
        const arrayBuffer = await response.arrayBuffer();
        return await new Promise((resolve, reject) => {
          this.worker.postMessage({
              isRun: false,
              modelData: arrayBuffer
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
              reject(new Error(message));
            }
          };
    
  
          this.worker.onerror = function(error) {
            console.error('Error in worker:', error.message);
            reject(error);
          };
        });
      } catch (e) {
        console.error(`Error in start ONNX Worker: ${e.message}`);
        throw e;
      }
  }

  async run(datajson) {
     if (this.worker == null){
      console.log("Worker and session wasn`t create");
     } else {
      try {
      return await new Promise((resolve, reject) => {
          const input = new Float32Array(JSON.parse(datajson));
          console.log(input);
          const inputTensor = new onnxruntime.Tensor('float32', input, [1, 3, 224, 224]);
          this.worker.postMessage({
            isRun: true,
            input: inputTensor
          });
  

          this.worker.onmessage = function(e) {
          const { status, output, message } = e.data;
  
          if (status === 'success') {
            console.log('ONNX run model');

            
            resolve({ output: JSON.stringify({output})});
          } else if (status === 'error') {
            console.error('Error creating ONNX Session:', message);
            reject(new Error(message));
          }
        };
  

        this.worker.onerror = function(error) {
          console.error('Error in worker:', error.message);
          reject(error);
        };
      });
    } catch (e) {
      console.error(`Error in start ONNX Worker: ${e.message}`);
      throw e;
    }
  }
}

    async createSessionPath(){
        try{ 
            this.ortSession = await onnxruntime.InferenceSession.create("../testModel/mobilenetv2-7.onnx"); //"../testModel/model.onnx"
            //   let loadModel = await ortSession.handler.loadModel(); 
            // const inputNames = ortSession.inputNames;
            // const outputNames = ortSession.outputNames;
            // const feeds = {
            //     a: new onnxruntime.Tensor('float32', Float32Array.from([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]), [3, 4]),
            //     b: new onnxruntime.Tensor('float32', Float32Array.from([10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120]), [4, 3])
            // };
            // const result = await  ortSession.run(feeds);
            // return  {ortsesion: ortSession, onnxruntime: onnxruntime, result: result};
            return this.ortSession;
        }catch(e){
            return `Error: ${e}`;
        }
    }


    async createSessionBuffer(){
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
            var res = await this.startOnnxWorker(mergedArray);
            mergedArray = null;
            this.ortSession = res.session;
            return res.res;
        }catch(e){
            return `Error: ${e}`;
        }
    }


    async createSessionArrayBuffer(arrayBuffer, offset, length){
        try{
            let ortSession = await onnxruntime.InferenceSession.create(arrayBuffer, offset, length);
            //   let loadModel = await ortSession.handler.loadModel(); 
            return  {ortsesion: ortSession, onnxruntime: onnxruntime};
        }catch(e){
            return `Error: ${e}`;
        }
    }

    async startOnnxWorker(buffer) {
          try {
            const workerCode = `
              self.importScripts('https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/ort.min.js');
              ort.env.wasm.wasmPaths = "https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/";
      
              self.onmessage = async function(e) {
                const { modelData } = e.data;
                try {
                  const session = await ort.InferenceSession.create(modelData);
                  const inputNames = session["handler"]["inputNames"];
                  const outputNames = session["handler"]["outputNames"];
                  
                 
                  self.postMessage({
                    status: 'success',
                    inputNames: inputNames,
                    outputNames: outputNames,
                    session: session
                  });
                } catch (error) {
                  self.postMessage({
                    status: 'error',
                    message: error.toString()
                  });
                }
              };
            `;
          
            const blob = new Blob([workerCode], { type: 'application/javascript' });
            const worker = new Worker(URL.createObjectURL(blob));
            return await new Promise((resolve, reject) => {
              worker.postMessage({
                  modelData: buffer
                });
        

              worker.onmessage = function(e) {
                const { status, inputNames, outputNames, session, message } = e.data;
        
                if (status === 'success') {
                  console.log('ONNX Session created successfully');
                  console.log('Input Names:', inputNames);
                  console.log('Output Names:', outputNames);
                  resolve({ res: JSON.stringify({inputNames, outputNames}), session: session});
                } else if (status === 'error') {
                  console.error('Error creating ONNX Session:', message);
                  reject(new Error(message));
                }
                worker.terminate();
              };
        
      
              worker.onerror = function(error) {
                console.error('Error in worker:', error.message);
                reject(error);
                worker.terminate();
              };
            });
          } catch (e) {
            console.error(`Error in start ONNX Worker: ${e.message}`);
            throw e;
          }
      }


      async runModel(datajson){
        if(this.ortSession != null){
        try {
          const input = new Float32Array(JSON.parse(datajson));
          console.log(input);
          const inputTensor = new onnxruntime.Tensor('float32', input, [1, 3, 224, 224]);
          console.log("Run session");
          return JSON.stringify({result: output});
        } catch (e) {
          console.error("Error:", e);
        }
      } else {
        console.error("Session not create");
      }
      }
      

};

window.onnx = new Onnx();
console.log("AI Model Land initialized");
