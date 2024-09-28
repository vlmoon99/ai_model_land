# **How to interact with ONNXRUNTIME in Ai Model Land?**

## **Initialization**

To initialize ONNXRUNTIME, we can use the default constructor or the named constructor `defaultInstance`.

**Example**:

```dart
final onnxruntime = ONNX.defaultInstance();
```

## **Check WebGPU and WebGL capabilities**

We can check if our device supports WebGPU or WebGL by using `checkWebGLAndWebGPU`. After executing this function, we get a map with two keys: `webgl` and `webgpu`. The value will be a `bool` indicating whether we have this support.

**Example**:

```dart
Map<String, bool> supportBackend = await onnxruntime.webBackendSupport();
```

## **Base model**

In this step, we need to create information about the model. You can check how to create a base model [here]. When creating the base model, we need to choose `ModelFormat.onnx`.

**Example**:

```dart
BaseModel baseModel = BaseModel(
    source: "assets/onnx/image_classification/mobilenetv2-7.onnx",
    nameFile: "photo-detection-classification",
    format: ModelFormat.onnx,
    sourceType: ModelSourceType.local
);
```

## **Add model**

The first step in interacting with an ONNX model is to add and load it into the provider. You can do this using the `addModel` function. To run this function, you need to provide the following parameters:

- `request`: an instance of `OnnxRequestModel` with the required parameters `loadModelWay` (in the ONNX provider, we support `fromFile`, `fromAssets`, and `fromBuffer` loading methods) and `onnxBackend`. If you choose `LoadModelWay.fromBuffer`, you need to provide a `uint8list`.
  Optional parameters:
  - `onProgressUpdate`: a callback function for monitoring the loading progress of the model.
  - `numThreads`: specifies how many threads to use for this model (default is 1).
- Base model.

This function returns `true` if the model was successfully created.

**Example**:

```dart
bool isLoadModel = await onnxruntime.addModel(
    request: OnnxRequestModel(
        loadModelWay: LoadModelWay.fromAssets,
        onnxBackend: ONNXBackend.cpu,
        onProgressUpdate: (double newProgress) {
            setState(() {
                percentNotifier.value = newProgress;
            });
        },
    ),
    baseModel: baseModel
);
```

## **Check if the model is loaded**

To make sure the model is loaded, we can check its status in the provider. For this, we use the `isModelLoaded` function, which returns a `bool` value.

**Example**:

```dart
bool isLoadModel = await onnxruntime.isModelLoaded();
```

## **Run model**

Once the model is loaded, we can run it using the `runTaskOnTheModel` function. It takes one parameter: `request`.

You need to input:

- `dataMulti`: a list with input Tensor data.
- `shape`: a list with the shape for the input Tensor.

**Important**: The data in `dataMulti` and `shape` should correspond to each other. For example, if we have two inputs for the Tensor, we create `dataMulti` with two data items, and the shape must match the data (shape for data in `dataMulti[0]` must locates in `shape` on index 0).

Optional parameters:

- `threshold`: sorts predictions by the smallest predicted value.
- `topPredictEntries`: sorts output predictions by the highest values.

After using this function, we get an `OnnxResponsModel` with the raw predictions stored in `predict`.

**Example**:

```dart
OnnxResponsModel predict = await onnxruntime.runTaskOnTheModel(
    request: OnnxRequestModel(
        dataMulti: [inputBytes],
        shape: [[1, 3, 224, 224]],
        threshold: 3,
        topPredictEntries: 5
    )
) as OnnxResponsModel;
```

## **Stop model**

If we need to stop the model, we can use the `stopModel` function.

**Example**:

```dart
await onnxruntime.stopModel();
```

## **Restart model**

If you need to reload the model, you can use the `restartModel` function with the following parameters:

- `request`: an instance of `OnnxRequestModel` with the `onnxBackend` specified, and an optional `onProgressUpdate` callback (similar to the one in the `addModel` function).
- Base model.

**Example**:

```dart
await onnxruntime.restartModel(
    request: OnnxRequestModel(onnxBackend: ONNXBackend.cpu),
    baseModel: baseModel
);
```
