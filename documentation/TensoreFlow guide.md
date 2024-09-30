# **How to interact with TensorFlow Lite in Ai Model Land?**

## **Initialization**

To initialize TensorFlow Lite, we can use the default constructor and named constructor `defaultInstance`.

```dart
final tensorFlow = TensorFlowLiteIO.defaultInstance();
```

## **Base model**

In this step, we need to create information about the model. How to create a base model, you can check [here](../README.md#how-to-use). When creating the base model, we need to choose `ModelFormat.tflite`.

```dart
BaseModel baseModel = BaseModel(
    source: "assets/tensorflowlite/image_classification/mobilenet_v1_1.0_224.tflite",
    nameFile: "photo-detection-classification",
    format: ModelFormat.tflite,
    sourceType: ModelSourceType.local);
```

## **Add model**

The first step for interacting with a TensorFlow Lite model is to add and load it into the provider. You can do this by calling `addModel`. To run this function, you need to fill in the following parameters:

- In the `request` row, input the class `TensorFlowRequestModel` with the required parameters: `loadModelWay` (in TensorFlow Lite provider, we support `fromFile`, `fromAssets`, `fromBuffer`, `fromAddress`). If you choose `LoadModelWay.fromBuffer`, you need to add a `uint8list` row, and if you choose `LoadModelWay.fromAddress`, you need to add `addressModel`.
- Base model.

This function returns **`true`** if the model was successfully created.

```dart
bool isLoadModel = await tensorFlow.addModel(
    request: TensorFlowRequestModel(loadModelWay: LoadModelWay.fromAssets),
    baseModel: baseModel);
```

## **Check model load**

To make sure that the model is loaded, we can check the status in the provider. For this, we need to use the `isModelLoaded` function. It returns a `bool` value.

```dart
bool isLoadModel = await tensorFlow.isModelLoaded();
```

## **Run model**

When the model is loaded, we can run it by calling `runTaskOnTheModel`. It takes one parameter: `request`.

We need to input:

- `dataMulti` for multi-input interaction or `data` for single-input interaction – this is the input Tensor data.

Additionally, we have optional parameters:

- `async` – this allows the model to run in an `Isolate`.
- `threshold` – this sorts predictions by the smallest prediction value.
- `labelsFile` or `labelsList` – this is a file or list with labels. This allows substituting the list of labels with predictions, providing a complete answer. It can only be used for single-input interaction.

**Important:** If you want to input `labels`, you must also input `threshold`.

After using this function, we get a `TensorFlowResponseModel` with the following possible rows in `predict`, where our prediction is stored:

- `predictForSingle` – prediction for single input without labels.
- `predictForSingleLabels` – prediction for single input with labels.
- `predictForMultiLabels` – prediction for multi-input without labels.

```dart
TensorFlowResponseModel output = await tensorFlow.runTaskOnTheModel(
    request: TensorFlowRequestModel(
        data: inputObject,
        async: true,
        labelsList: lines,
        threshold: 0.01)) as TensorFlowResponseModel;
```

## **Stop model**

If we need to stop the model, we can use the `stopModel` function. Return `bool` value.

```dart
await tensorFlow.stopModel();
```

## **Restart model**

If we need to reload the model, we can use the `restartModel` function with the following parameters:

- `request` – `TensorFlowRequestModel` with the same parameters as in [addModel](#add-model).<br>
- Base model.<br>

Return `bool` value.

```dart
await tensorFlow.restartModel(
    request: TensorFlowRequestModel(loadModelWay: LoadModelWay.fromAssets), baseModel: baseModel);
```
