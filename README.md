PMF Foundation
===
## ModelUpdateSwift
iOS Swift sample which demostrates Machine Learning CoreML Model update feature using Persistent Mobile Foundation 

![Model Update Screenshot](screenshot.jpg)

### Documentation
https://pmf.persistentproducts.com/tutorials/en/foundation/9.0/application-development/model-update/

### Usage

1. Use either Maven, MobileFirst CLI or your IDE of choice to [build and deploy the available `UserLogin` adapter](https://pmf.persistentproducts.com/tutorials/en/foundation/9.0/adapters/creating-adapters/.

    -  The UserLogin Security Check adapter can be found in https://github.com/Persistent-Mobile-Foundation/SecurityCheckAdapters

2. From a command-line window, navigate to the project's root folder and run the commands:
    - `pod update` followed by `pod install` - to add the MobileFirst SDK.
    - `pmfdev app register` - to register the application.

3. Add the sample images in iOS Simular or physical device. This is located in SampleData folder.

4. Run the application & login with credentials(vittal/vittal). Click on Damage Analyzer -> Analyzer -> Choose any one of the sample image. CoreML model fails to analyze the damage.

5. Now update the CorelML Model Update on Air using MobileFirst Console
    - Open the MobileFirst Operations Console and click the application entry in the left panel.
    - Navigate to Machine Learning tab and click Upload model archive 
    - Choose the `model-update.zip` file which is located inside ModelUpdatePackage folder and Click Ok to upload the packaged models.
    - ![Model Update Screenshot](modelupdate.png)

6. Kill and Re-run the application, User can notice the model gets downloaded in the Home page.

7. Once the download is finished, Click on Damage Analyzer -> Analyzer -> Choose any one of the sample image. This time CoreML model will able to analyze the damage.

### Version
Swift 5.0

### Supported Levels
PMF 9.0