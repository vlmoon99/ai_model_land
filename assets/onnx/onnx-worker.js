self.importScripts('https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/ort.min.js');
ort.env.wasm.wasmPaths = "https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/";
ort.env.wasm.numThreads = 1;
let session;
self.onmessage = async function(e) {
  const { isRun } = e.data;
  if(isRun == false){
  try {
    const { modelData } = e.data;
    session = await ort.InferenceSession.create(modelData);
    const inputNames = session["handler"]["inputNames"];
    const outputNames = session["handler"]["outputNames"];
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
        const { input } = e.data;
        const output = this.session.run({data: input});
        console.log('run');
        self.postMessage({
            status: 'success',
            output: output,
        });
    } catch (e) {
        self.postMessage({
            status: 'error',
            message: error.toString()
        });
    }
    }
};
