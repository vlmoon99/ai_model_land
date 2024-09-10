import * as onnxruntime from 'https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/esm/ort.webgpu.min.js';

onnxruntime.env.wasm.wasmPaths = "https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/";
onnxruntime.env.wasm.numThreads = 1;

export class Onnx {
    ortSession;

    fileBuffer = [];
    
    receiveChunk(chunk) {
        this.fileBuffer.push(chunk);
        console.log('Received chunk of size:', chunk.length);
    }

    test(){
        return {input: this.ortSession["handler"]["inputNames"]};
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
            let totalLength = this.fileBuffer.reduce((acc, val) => acc + val.length, 0);
            let mergedArray = new Uint8Array(totalLength);
            let offset = 0;
            
            for (let chunk of this.fileBuffer) {
                mergedArray.set(chunk, offset);
                offset += chunk.length;
            }
            console.log(mergedArray.byteLength);
            this.fileBuffer = [];
            totalLength = null;
            offset = null;
            var res = await this.startOnnxWorker(mergedArray);
            // this.ortSession = await onnxruntime.InferenceSession.create(mergedArray);            
            mergedArray = null;
            this.ortSession = res.session;
            return res.res; //JSON.stringify({input: this.ortSession["handler"]["inputNames"], output: this.ortSession["handler"]["outputNames"]});
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

    startOnnxWorker(buffer) {
        return new Promise((resolve, reject) => {
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
                  
                  // Отправляем результат обратно в основной поток
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
      
            worker.postMessage({
                modelData: buffer
              });
      
            // Обработка ответа от worker-а
            worker.onmessage = function(e) {
              const { status, inputNames, outputNames, session, message } = e.data;
      
              if (status === 'success') {
                console.log('ONNX Session created successfully');
                console.log('Input Names:', inputNames);
                console.log('Output Names:', outputNames);
                resolve({ res: JSON.stringify({inputNames, outputNames}), session: session}); // Разрешаем промис с результатами
              } else if (status === 'error') {
                console.error('Error creating ONNX Session:', message);
                reject(new Error(message)); // Отправляем ошибку в reject
              }
            };
      
            // Обработка ошибок в worker-е
            worker.onerror = function(error) {
              console.error('Error in worker:', error.message);
              reject(error); // Отправляем ошибку в reject
            };
          } catch (e) {
            reject(e); // Отправляем ошибку в reject
          }
        });
      }

      

};

window.onnx = new Onnx();
console.log("AI Model Land initialized");
