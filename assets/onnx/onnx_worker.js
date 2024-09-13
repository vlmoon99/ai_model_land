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
        const { input } = e.data;
        let outputData = {};          
        console.log(input);
        const output = await session.run({data: new ort.Tensor('float32', input, [1, 3, 224, 224])});
        console.log('run');
        for(var i = 0; i < outputNames.length; i++) {
          outputData[outputNames[i]] = output[outputNames[i]]["cpuData"];
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
