# **AIModelLand**

[About AIModelLand](#about-aimodelland)<br>
[Installing](#installing)<br>
[How to use](#how-to-use)<br>
[Running Examples](#running-examples)<br>
[Contributing](#contributing)<br>

## **About AIModelLand**

AIModelLand is a library that provides developers with a simple API for interacting with various AI providers. It allows developers to easily integrate popular AI providers into their projects. Using this library, developers don't have to waste time connecting a new provider to a project and can easily use all the functionality that the provider and AI model provide without any difficulty.

## **Installing**

1. Add this code to the `index.html` for Web projects:

   ```html
   <head>
     <!-- other head elements -->
     <script type="application/javascript" src="flutter.js" defer></script>
     <script
       type="application/javascript"
       src="/assets/packages/flutter_inappwebview_web/assets/web/web_support.js"
       defer
     ></script>
     <script
       type="module"
       src="/assets/packages/ai_model_land/assets/onnx/index.js"
       defer
     ></script>
   </head>
   <script>
     window.addEventListener("load", async function (ev) {
       {
         {
           flutter_js;
         }
       }
       {
         {
           flutter_build_config;
         }
       }

       _flutter.loader.load({
         serviceWorker: {
           serviceWorkerVersion: "{{flutter_service_worker_version}}",
         },
         onEntrypointLoaded: function (engineInitializer) {
           engineInitializer.initializeEngine().then(function (appRunner) {
             appRunner.runApp();
           });
         },
       });
     });
   </script>
   ```

2. Set Android: `minSdkVersion >= 26`, `compileSdk >= 34`, `AGP version >= 7.3.0` in the `android/app/build.gradle` file and add to the `AndroidManifest.xml` the `usesCleartextTraffic` parameter and Internet permission:

   ```xml
   <manifest> ...
     <application> ...
       android:usesCleartextTraffic="true"
     </application>
     <uses-permission android:name="android.permission.INTERNET"/>
   </manifest>
   ```

3. Set Flutter version `>= 3.24.3 stable`.  
   Example code for updating to the latest Flutter stable version:

   ```bash
   flutter channel stable
   flutter upgrade
   ```

4. Initialize the `AIModelLand` library after `WidgetsFlutterBinding.ensureInitialized()` in the `main` function:

   ```dart
   void main() {
     WidgetsFlutterBinding.ensureInitialized();
     initAIModelLandLib();
     ...
     runApp(MyApp());
   }
   ```

## **How to use**

With the library, you can easily manage the most popular AI providers without any problems. To initialize `AIModelLand`, we can use the default constructor and the named constructor `defaultInstance()`.

**Example:**

```dart
final aiModelLand = AiModelLandLib.defaultInstance();
```

The next step is to create base information about the model by using the `BaseModel` class.

In this class, we have the following parameters:

- `sourceType` with enum `ModelSourceType` – choose where your model is located. If you choose `network`, the file will be downloaded to your device.
- `source` – in this parameter, input the file location. It can be a file explorer path or an assets path. If you choose `network` in `sourceType`, input the URL to the model. If in the future you will load the model to the provider using `uint8List` format, you can input an empty string.
- `nameFile` – input the existing file name, or if you download the model, this will be the future file name.
- `format` with enum `ModelFormat` – choose the provider that you want to use.

Then you can reuse this `BaseModel` in all functions for each AI provider.

You can check how to use all functions for each AI provider by the following links:

- [ONNXRUNTIME](./documentation/ONNXRUNTIME%20guide.md)
- [TensorFlow Lite](./documentation/TensoreFlow%20guide.md)

**Example of using the AIModelLand library:**

```dart
//create base model
BaseModel baseModel = BaseModel(
    source: "assets/onnx/image_classification/mobilenetv2-7.onnx",
    nameFile: "photo-detection-classification",
    format: ModelFormat.onnx,
    sourceType: ModelSourceType.local);

//load model to provider
bool isLoadModel = await aiModelLand.loadModel(
        request: OnnxRequestModel(
          loadModelWay: LoadModelWay.fromAssets,
          onnxBackend: ONNXBackend.cpu ),
        baseModel: baseModel);

//run model (get prediction)
OnnxResponsModel predict = await aiModelLand.runTaskOnTheModel(
        request: OnnxRequestModel(dataMulti: [
          inputBytes
        ], shape: [
          [1, 3, 224, 224]
        ], threshold: 3, topPredictEntries: 5),
        baseModel: baseModel) as OnnxResponsModel;

//restart model
await aiModelLand.restartModel(
        request: OnnxRequestModel(
        loadModelWay: LoadModelWay.fromAssets,
        onnxBackend: ONNXBackend.cpu),
        baseModel: baseModel);

//stop model
await aiModelLand.stopModel(baseModel: baseModel);


//delete model from device
await aiModelLand.deleteModelFromDevice(baseModel: baseModel);

//you can check information about device
await aiModelLand.checkPlatformInfo();
```

## **Running Examples**

Instructions for running the included examples:

1. Navigate to the example directory:  
   **`cd example`**
2. Run **`flutter run`** to launch the example app on your preferred device.
3. Explore the example app to see how to use the library in your own project.

## **Contributing**

Instructions for contributing to this library:

1. Fork this repository.
2. Create a new branch:  
   **`git checkout -b my-new-branch`**
3. Make changes and commit them:  
   **`git commit -m "My message"`**
4. Push to the remote branch:  
   **`git push origin my-new-branch`**
5. Create a pull request.

List any dependencies or prerequisites needed before getting started with editing this library:

- Flutter
- Installed Android Studio and Android SDK (For Android dev)
- Installed Xcode (For iOS, macOS dev)

Instructions for building the library from source code:

1. Clone this repository:  
   **`git clone https://github.com/vlmoon99/ai_model_land`**
2. Navigate to the project root directory:  
   **`cd ai_model_land`**
