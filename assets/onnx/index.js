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
        const workerCode = `
        self.importScripts('https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/ort.min.js');
        ort.env.wasm.wasmPaths = "https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/";
        ort.env.wasm.numThreads = 1;
        let session;
        let inputNames;
        let outputNames;
        self.onmessage = async function(e) {
          const { isRun } = e.data;
          if(isRun == false){
            console.log("In worker");
          try {
            const { modelData } = e.data;
            session = await ort.InferenceSession.create(modelData);
            inputNames = session["handler"]["inputNames"];
            outputNames = session["handler"]["outputNames"];
            console.log('Create');
            self.postMessage({
              status: 'success',
              inputNames: inputNames,
              outputNames: outputNames,
            });
          } catch (error) {
            self.postMessage({
              status: 'error',
              message: error.toString()
            });
          }
        } else {
            try{
                const { input, threshold, shape } = e.data;
                let outputData = {};          
                console.log(input);
                let inputData = {};
                for(var i = 0; i < input.length; i++){
                  inputData[inputNames[i]] = new ort.Tensor(input[i], shape[i]);
                }
                const output = await session.run(inputData);
                console.log('run');
                if (threshold != 0){
                  for(var i = 0; i < outputNames.length; i++) {
                    const data = output[outputNames[i]]["cpuData"];
                    const entries = Object.entries(data);
                    const filteredEntries = entries.filter(([, value]) => value > threshold);
                    filteredEntries.sort(([, valueA], [, valueB]) => valueB - valueA);
                    const sortedObject = Object.fromEntries(filteredEntries);

                    console.log(sortedObject);
                    outputData[outputNames[i]] = sortedObject;
                  }
                } else {
                  for(var i = 0; i < outputNames.length; i++) {
                    outputData[outputNames[i]] = output[outputNames[i]]["cpuData"];
                  }
                }
                self.postMessage({
                    status: 'success',
                    output: outputData,
                });
            } catch (e) {
                self.postMessage({
                    status: 'error',
                    message: error.toString()
                });
            }
            }
        };
      `;
      const blob = new Blob([workerCode], { type: 'application/javascript' });
       this.worker = new Worker(URL.createObjectURL(blob));
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

  async runModel(inputsDatajson, shape, typeInputData ,threshold = null) {
     if (this.worker == null){
      throw new Error("Worker and session wasn`t create");
     } else {
      try {
      return await new Promise((resolve, reject) => {
       
        let input = [];
        for(var i = 0; i < inputsDatajson.length; i++){
          switch (typeInputData[i]) {
            case "Float32List":
              const correctDataFloat32 = new Float32Array(JSON.parse(inputsDatajson[i]));
              input.push(correctDataFloat32);
              break;
            case "Float64List":
              const correctDataFloat64 = new Float64Array(JSON.parse(inputsDatajson[i]));
              input.push(correctDataFloat64);
              break;
            case "Uint8List":
              const correctDataUint8Array = new Uint8Array(JSON.parse(inputsDatajson[i]));
              input.push(correctDataUint8Array);
              break;
            case "Uint16List":
              const correctDataUint16Array = new Uint16Array(JSON.parse(inputsDatajson[i]));
              input.push(correctDataUint16Array);
              break;
            case "Uint32List":
              const correctDataUint32Array = new Uint32Array(JSON.parse(inputsDatajson[i]));
              input.push(correctDataUint32Array);
              break;
            case "String":
              const correctDataString = inputsDatajson[i];
              input.push(correctDataString);
              break;
            case "Int32List":
              const correctDataInt32Array = new Int32Array(JSON.parse(inputsDatajson[i]));
              input.push(correctDataInt32Array);
              break;
            case "Int16List":
              const correctDataInt16Array = new Int16Array(JSON.parse(inputsDatajson[i]));
              input.push(correctDataInt16Array);
              break;
            case "Int8List":
              const correctDataInt8Array = new Int8Array(JSON.parse(inputsDatajson[i]));
              input.push(correctDataInt8Array);
              break;
            default:
              throw new Error("This type data don`t support");
          }
        }
          this.worker.postMessage({
            isRun: true,
            input: input,
            threshold: threshold,
            shape: shape
          });
  

          this.worker.onmessage = function(e) {
          const { status, output, message } = e.data;
  
          if (status === 'success') {
            console.log('ONNX run model');

            
            resolve(JSON.stringify({output: output}));
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
      const response = await fetch('./sdafsdaf.js');
      if (response.status == 200){
        console.log("exist");
      } else {
        console.error("not exist");
      }
    }

};

window.onnx = new Onnx();
console.log("AI Model Land initialized");
