import * as onnxruntime from 'https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/esm/ort.webgpu.min.js';

onnxruntime.env.wasm.wasmPaths = "https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/";
onnxruntime.env.wasm.numThreads = 1;
export class Onnx {
    async createSession(){
        try{
            let ortSession = await onnxruntime.InferenceSession.create("../testModel/mobilenetv2-7.onnx");
            //   let loadModel = await ortSession.handler.loadModel(); 
            return  {ortsesion: ortSession, onnxruntime: onnxruntime};
        }catch(e){
            return e;
        }
    }

    async createSessionByffer(byffer){
        try{
            let ortSession = await onnxruntime.InferenceSession.create(byffer);
            //   let loadModel = await ortSession.handler.loadModel(); 
            return  {ortsesion: ortSession, onnxruntime: onnxruntime};
        }catch(e){
            return e;
        }
    }

    async createSessionArrayBuffer(arrayBuffer, offset, length){
        try{
            let ortSession = await onnxruntime.InferenceSession.create(arrayBuffer, offset, length);
            //   let loadModel = await ortSession.handler.loadModel(); 
            return  {ortsesion: ortSession, onnxruntime: onnxruntime};
        }catch(e){
            return e;
        }
    }



};
window.onnx = new Onnx();
console.log("Init lib ai model land");
