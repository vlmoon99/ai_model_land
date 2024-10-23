export class Onnx {
    modelBuffer = [];
    worker;
    numThreads;
    
    receiveChunk(chunk) {
        this.modelBuffer.push(chunk);
        console.log('Received chunk of size model:', chunk.length);
    }

    async loadWorkerModel(dataModel, numThreads, providWebGLWebGPU) {
      if (this.worker != null) {
        throw new Error("Worker work already");
      } else {
      try {
        const workerCode = `
        let session;
        let inputNames;
        let outputNames;
        self.onmessage = async function(e) {
          const { isRun } = e.data;
          if(isRun == false){
            console.log("In worker");
            const { providWebGLWebGPU } = e.data;
  
            if (providWebGLWebGPU == "webgpu") {
              self.importScripts('https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/ort.webgpu.min.js');
            } else if (providWebGLWebGPU == "webgl" || providWebGLWebGPU == "wasm" || providWebGLWebGPU == "cpu"){
              self.importScripts('https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/ort.min.js');
            } else {
              return self.postMessage({
                status: 'error',
                message: "Incorrect backend onnx"
              });
            }
  
            ort.env.wasm.wasmPaths = 'https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/';
            ort.env.wasm.numThreads = ${numThreads}; 
  
          try {
            const { modelData } = e.data;
            session = await ort.InferenceSession.create(modelData, { executionProviders: [providWebGLWebGPU] });
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
                let inputData = {};
                for(var i = 0; i < input.length; i++){
                  inputData[inputNames[i]] = new ort.Tensor(input[i], shape[i]);
                }
                const output = await session.run(inputData);
                console.log('run');
                if (threshold != undefined){
                  for(var i = 0; i < outputNames.length; i++) {
                    const data = output[outputNames[i]]["cpuData"];
                    const entries = Object.entries(data);
                    const filteredEntries = entries.filter(([, value]) => value > threshold);
                    filteredEntries.sort(([, valueA], [, valueB]) => valueB - valueA);
                    const sortedObject = Object.fromEntries(filteredEntries);
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
            } catch (error) {
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
              modelData: dataModel,
              providWebGLWebGPU: providWebGLWebGPU
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


  async testloadWorkerModel(providWebGLWebGPU = "") {
    if (this.worker != null) {
      throw new Error("Worker work already");
    } else {
    try {
      
      const response = await fetch('./mobilenetv2-7.onnx');
      const data = await response.arrayBuffer();
      const uint8Array = new Uint8Array(data);
      console.log(uint8Array.length);
      const workerCode = `
      let session;
      let inputNames;
      let outputNames;
      self.onmessage = async function(e) {
        const { isRun } = e.data;
        if(isRun == false){
          console.log("In worker");
          const { providWebGLWebGPU } = e.data;

          if (providWebGLWebGPU == "webgpu") {
            self.importScripts('https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/ort.webgpu.min.js');
          } else if (providWebGLWebGPU == "webgl" || providWebGLWebGPU == "wasm" || providWebGLWebGPU == "cpu"){
            self.importScripts('https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/ort.min.js');
          } else {
            return self.postMessage({
              status: 'error',
              message: "Incorrect backend onnx"
            });
          }

          ort.env.wasm.wasmPaths = 'https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/';
          ort.env.wasm.numThreads = 1; 

        try {
          const { modelData } = e.data;
          session = await ort.InferenceSession.create(modelData, { executionProviders: [providWebGLWebGPU] });
          inputNames = session["handler"]["inputNames"];
          outputNames = session["handler"]["outputNames"];
          console.log('Create');
           console.log(session);
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
              console.log(input.length);
              let inputData = {};
              for(var i = 0; i < input.length; i++){
                inputData[inputNames[i]] = new ort.Tensor(input[i], shape[i]);
              }
              const output = await session.run(inputData);
              console.log('run');
              if (threshold != undefined){
                for(var i = 0; i < outputNames.length; i++) {
                  console.log(output);
                  const data = output[outputNames[i]]["cpuData"];
                  const entries = Object.entries(data);
                  const filteredEntries = entries.filter(([, value]) => value > threshold);
                  filteredEntries.sort(([, valueA], [, valueB]) => valueB - valueA);
                  const sortedObject = Object.fromEntries(filteredEntries);
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
          } catch (error) {
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
            modelData: uint8Array,
            providWebGLWebGPU: providWebGLWebGPU
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
      this.worker = null;
      console.error(`Error in load ONNX Worker: ${e.message}`);
      throw new Error(`Error in load ONNX Worker: ${e.message}`);
    }
  }
}


  async runModel(inputsDatajson, shape, typeInputData ,threshold = undefined) {
     if (this.worker == null){
      throw new Error("Worker and session wasn`t create");
     } else {
      try {
      return await new Promise((resolve, reject) => {
        const convertTypeInputData = JSON.parse(typeInputData);
        const convertInputsDatajson = JSON.parse(inputsDatajson);
        let input = [];
        for(var i = 0; i < convertInputsDatajson.length; i++){
          switch (convertTypeInputData[i]) {
            case "_Float32ArrayView":
            case "Float32List":
              const correctDataFloat32 = new Float32Array(convertInputsDatajson[i]);
              input.push(correctDataFloat32);
              break;
            case "Float64List":
            case "_Float64ArrayView":
              const correctDataFloat64 = new Float64Array(convertInputsDatajson[i]);
              input.push(correctDataFloat64);
              break;
            case "_Uint8ArrayView":
            case "Uint8List":
              const correctDataUint8Array = new Uint8Array(convertInputsDatajson[i]);
              input.push(correctDataUint8Array);
              break;
            case "Uint16List":
              const correctDataUint16Array = new Uint16Array(convertInputsDatajson[i]);
              input.push(correctDataUint16Array);
              break;
            case "Uint32List":
              const correctDataUint32Array = new Uint32Array(convertInputsDatajson[i]);
              input.push(correctDataUint32Array);
              break;
            case "String":
              const correctDataString = inputsDatajson[i];
              input.push(correctDataString);
              break;
            case "Int32List":
              const correctDataInt32Array = new Int32Array(convertInputsDatajson[i]);
              input.push(correctDataInt32Array);
              break;
            case "Int16List":
              const correctDataInt16Array = new Int16Array(convertInputsDatajson[i]);
              input.push(correctDataInt16Array);
              break;
            case "Int8List":
              const correctDataInt8Array = new Int8Array(convertInputsDatajson[i]);
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


    async createSessionBufferPath(numThreads = 1, providWebGLWebGPU = "", urlToModel){
      this.numThreads = numThreads;
      const response = await fetch('assets/onnx/llm/model_q4f16.onnx');
      console.log(response);
      if(this.modelBuffer.length != 0){
        try{
            let totalLength = this.modelBuffer.reduce((acc, val) => acc + val.length, 0);
            const mergedArray = new Uint8Array(totalLength);
            let offset = 0;
            
            for (let chunk of this.modelBuffer) {
              mergedArray.set(chunk, offset);
                offset += chunk.length;
            }
            console.log(mergedArray.byteLength);
            this.modelBuffer = [];
            totalLength = null;
            offset = null;
            const res = await this.loadWorkerModel(mergedArray, numThreads, providWebGLWebGPU);
            return res.res;
        }catch(e){
            return JSON.stringify({error: `${e}`});
        }
      } else if (urlToModel != null) {
        try{
            const response = await fetch(urlToModel);
            console.log(response);
            const data = await response.arrayBuffer();
            const uint8Array = new Uint8Array(data);
            console.log(uint8Array);
            const res = await this.loadWorkerModel(uint8Array, numThreads, providWebGLWebGPU);
            return res.res;
        } catch(e){
            return JSON.stringify({error: `${e}`});
        }
      } else {
        console.error("Model not loaded");
        return JSON.stringify({error: "Model not loaded"});
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

};

window.onnx = new Onnx();
console.log("ONNX initialized");
