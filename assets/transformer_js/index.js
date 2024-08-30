import * as onnxruntime from 'https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/esm/ort.webgpu.min.js';

onnxruntime.env.wasm.wasmPaths = "https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/";
onnxruntime.env.wasm.numThreads = 1;
export class Onnx {
    ortSession;

    async createSessionDefault(path){
        try{
            this.ortSession = await onnxruntime.InferenceSession.create(path); //"../testModel/model.onnx"
            //   let loadModel = await ortSession.handler.loadModel(); 
            // const inputNames = ortSession.inputNames;
            // const outputNames = ortSession.outputNames;
            // const feeds = {
            //     a: new onnxruntime.Tensor('float32', Float32Array.from([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]), [3, 4]),
            //     b: new onnxruntime.Tensor('float32', Float32Array.from([10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120]), [4, 3])
            // };
            // const result = await  ortSession.run(feeds);
            // return  {ortsesion: ortSession, onnxruntime: onnxruntime, result: result};
            return this.ortSession
        }catch(e){
            return `Error: ${e}`;
        }
    }

    async test(){
       return {test: "hello"};
    }

    async createSessionByffer(byffer){
        try{
            let ortSession = await onnxruntime.InferenceSession.create(byffer);
            //   let loadModel = await ortSession.handler.loadModel(); 
            return  {ortsesion: ortSession, onnxruntime: onnxruntime};
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

    async createSessionBrowser(url){
        try{
            const arrayBuffer03_C = await fetchMyModel(url);
            const ortSession = await InferenceSession.create(arrayBuffer03_C);
            return  {ortsesion: ortSession, onnxruntime: onnxruntime};
        }catch(e){
            return `Error: ${e}`;
        }
    }

    async fetchMyModel(filepathOrUri) {
        // use fetch to read model file (browser) as ArrayBuffer
        if (typeof fetch !== 'undefined') {
            const response = await fetch(filepathOrUri);
            return await response.arrayBuffer();
        }
    }

};
window.onnx = new Onnx();
console.log("Init lib ai model land");
