Amazon AVS Sample using AiVA-96 & DragonBoard 410c
---
The WizeIoT’s AiVA mezzanine board for DragonBoard and 96Boards enables developers of the smart home devices such as smart speaker, smart panels, kitchen equipment and other commercial and industrial electronics products to evaluate and prototype far-field hands-free voice interface using Amazon Alexa, Google Assistant, Microsoft Cortana voice service.

Built around XMOS XVF3000 voice processor with direct interfacing to a line array of four digital microphones, the AiVA board is an ideal platform for developers who want to integrate AI speaker into their products.

[Alexa Voice Service](https://developer.amazon.com/avs) (AVS) is Amazon’s intelligent voice recognition and natural language understanding service that allows you as a developer to voice-enable any connected device that has a microphone and speaker.

This project provides a step-by-step walkthrough to help you build a **hands-free** [Alexa Voice Service](https://developer.amazon.com/avs) (AVS) prototype in 60 minutes, using wake word engines from [CMU Sphinx](https://github.com/cmusphinx/sphinxbase). Now, in addition to pushing a button to "start listening", you can now also just say the wake word "Alexa", much like the [Amazon Echo](https://amazon.com/echo). 

To find out more, visit: https://www.wizeiot.com/aiva-96/ home page and: https://developer.amazon.com/alexa-voice-service

This respository provides a simple-to-use automated script to install the Amazon AVS SDK on a DragonBoard 410c and configure the Dragon Board 410c to use the AiVA-96 for AVS for audio.

Prerequisites
---
You will need:

- [AiVA-96 board](https://www.wizeiot.com/aiva-96/)
- [DragonBoard 410c](https://www.96boards.org/product/dragonboard410c/) or [compatible 96Boards](https://www.96boards.org/products/)
- [96Boards Compliant Power Supply](http://www.96boards.org/product/power/)
- MicroSD card (min. 16GB)
- Monitor with HDMI input, HDMI cable
- USB keyboard and mouse
- Wi-Fi with internet connectivity

You will also need an Amazon Developer account: https://developer.amazon.com

Hardware setup
---
- Make sure the DragonBoard is powered off
- Connect I/O devices (Monitor, Keyboard, etc...)
- Connect AiVA-96 boards on top of DragonBoard
- Connect AiVA-96 MEMS mic board and speakers
- Power on your DragonBoard 410c with 96Boards compliant power supply
- To make sure the microphone and speakers are connected successfully, go to Application Menu -> Sound & Video -> PulseAudio Volume Control and check the input and output device, set as "WizeIoT AiVA-96 DevKit (UAC1.0) Analog Stereo". 

    ![AiVA-96 and DB410c](https://github.com/wizeiot/aiva-96-alexa-avs-sample/wiki/assets/aiva_db410c.jpg)

AVS SDK installation and Dragon Board 410c audio setup
---
Full instructions to install the AVS SDK on to a Dragon Board 410c and configure the audio to use the AiVA-96 are detailed in the Getting Started Guide available from: https://www.wizeiot.com/aiva-96/ home page.

Brief instructions and additional notes are below:


1. You'll need to register a device and create a security profile at developer.amazon.com. [Click here](https://github.com/alexa/alexa-avs-sample-app/wiki/Create-Security-Profile) for step-by-step instructions.

    IMPORTANT: The allowed origins under web settings should be http://localhost:3000 and https://localhost:3000. The return URLs under web settings should be http://localhost:3000/authresponse and https://localhost:3000/authresponse.

    If you already have a registered product that you can use for testing, feel free to skip ahead.

2. Install Debian (Stretch) on the DragonBoard 410c
   + You shoud use [Debian 17.09](http://releases.linaro.org/96boards/dragonboard410c/linaro/debian/17.09/dragonboard410c_sdcard_install_debian-283.zip),  [Debian 18.01](http://releases.linaro.org/96boards/dragonboard410c/linaro/debian/18.01/dragonboard-410c-sdcard-installer-buster-359.zip) or higher. Note: '*apt-get upgrade*' from 18.01 possibly bring boot crash. You may hold kernel upgrade with below command line, before package upgrade.
    ```
    sudo apt-mark hold linux-image-4.14.0-qcomlt-arm64
    ```   

   + Write downloaded image file to your MicroSD card with [Etcher](https://etcher.io/) or other image writer software.
   + Turn on DragonBoard 410c's 'SD BOOT' dip switch and power on to install Debian.

3. Open a terminal on the Dragon Board 410c and clone this repository
    ```
    cd ~; git clone https://github.com/wizeiot/aiva-96-alexa-avs-sample.git
    ```   

4. Run the installation script
    ```
    cd aiva-96-alexa-avs-sample/
    bash automated_install.sh
    ```
    It takes at least 20 mins ~ 1 hour depending on your internet speed.
    
    If you use wakeWake Word Agent, connect GPIO 36 and GPIO 13 on AiVA-96 board using wire.  
    ![](https://github.com/wizeiot/aiva-96-alexa-avs-sample/wiki/assets/wakeword.png)

AVS Run and Authentication
---
To run the Alexa Voice Service, need 4 terminal windows. You can use below scripts to run it automatically and following the "3. Authentication" process. 
```
bash ./alexa_avs_sample.sh
bash ./wake_word_agent.sh
```
Also windows can be opened manually. For manual opertaion, see the following for more information.
*These commands should be run in this order.*
```
Terminal Windows 1: to run the web service for authorization
Terminal Windows 2: to run the sample app to communicate with AVS
Terminal Windows 3: to run the wake word engine which allows you to start an interaction using the phrase "Alexa"
Terminal Windows 4: to run the pocketSpinx
```

##### 1. Terminal Window 1 \(Ctrl + Alt + T\)
Open a new terminal window and type the following command to bring up the web service which is used to authorize the sample app with Amazon AVS.
```
cd ~/workspace/alexa-avs-sample-app/samples/companionService && npm start
```
![](https://github.com/wizeiot/aiva-96-alexa-avs-sample/wiki/assets/dragonBoard_alexa_step_1.png)

##### 2. Terminal Window 2
Open a new terminal window and type the following commands to run the sample app, which communicates with Amazon AVS.
```
cd ~/workspace/alexa-avs-sample-app/samples/javaclient && mvn exec:exec
```
![](https://github.com/wizeiot/aiva-96-alexa-avs-sample/wiki/assets/dragonBoard_alexa_step_2.png)

##### 3. Authentication
- A window should pop up with a message that says -  
    Please register your device by visiting the following URL in a web browser 
    and following the instructions: https://localhost:3000/provision/xxxxxxxxxxx
    Would you like to copied to your clipboard ?
- Click on "Yes".  
    ( IMPORTANT NOTE: Don't respond to the second pop up until after you've logged in to your Amazon account.)
![](https://github.com/wizeiot/aiva-96-alexa-avs-sample/wiki/assets/dragonBoard_alexa_step_3.png)

- Run Chromium web browser and then paste URL(Ctrl + V) on clipboard. Input ENTER key and click on "ADVANCED".
![](https://github.com/wizeiot/aiva-96-alexa-avs-sample/wiki/assets/dragonBoard_alexa_step_4.png)

- Click on "Proceed to localhost \(unsafe\)"
![](https://github.com/wizeiot/aiva-96-alexa-avs-sample/wiki/assets/dragonBoard_alexa_step_5.png)

- Input Amazon ID and Password and then click on "Sign in"
![](https://github.com/wizeiot/aiva-96-alexa-avs-sample/wiki/assets/dragonBoard_alexa_step_6.png)

- You will now be redirected to a URL beginning with https://localhost:3000/authresponse followed by a query string.  
    The body of the web page will say device tokens ready.
![](https://github.com/wizeiot/aiva-96-alexa-avs-sample/wiki/assets/dragonBoard_alexa_step_7.png)

- Return to the Java application and click the OK button. The sample app is now ready to accept Alexa requests.
![](https://github.com/wizeiot/aiva-96-alexa-avs-sample/wiki/assets/dragonBoard_alexa_step_8.png)

- If the following screen appears, the AVS sample app is executed normally.
![](https://github.com/wizeiot/aiva-96-alexa-avs-sample/wiki/assets/dragonBoard_alexa_step_9.png)

##### 4. Terminal Window 3
*Note: Skip this step to run the same app without a wake word engine.*

Open a new terminal window and use the following commands to bring up the wake word engine from pocketSpinx.  
The wake word engine will allow you to initiate interactions using the phrase "Alexa".

```
cd ~/alexa-avs-sample-app/samples/wakeWordAgent/src
sudo ./wakeWordAgent -e gpio
```

##### 5. Terminal Window 4
*Note: Skip this step to run the same app without a wake word engine.*

Open a new terminal window and use the following commands to run pocketSpinx app.
```
cd ~/alexa-avs-sample-app && run_sphinx_no_log.sh
```

Important considerations
---
* Review the AVS [Terms & Agreements](https://developer.amazon.com/public/solutions/alexa/alexa-voice-service/support/terms-and-agreements).  

* The earcons associated with the sample project are for **prototyping purposes only**. For implementation and design guidance for commercial products, please see [Designing for AVS](https://developer.amazon.com/public/solutions/alexa/alexa-voice-service/content/designing-for-the-alexa-voice-service) and [AVS UX Guidelines](https://developer.amazon.com/public/solutions/alexa/alexa-voice-service/content/alexa-voice-service-ux-design-guidelines).
