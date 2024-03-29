# ELE432_ULTRASONIC_RADAR
DE1-SOC RADAR PROJECT<br />
ULTRASONIC RADAR<br />
--------Project Partners----------------------------------------------------------------<br />
--MEHMET BATUHAN ORAK<br />--ABDULLAH FURKAN KAYA<br />--BURAK TALHA GUCLU<br />--MUHAMMED FATİH TEKİN<br />
----------------------------------------------------------------------------------------<br />
AN ULTRASONIC SENSOR AND A STEP MOTOR CAN BE EMPLOYED TO DETECT THE PRESENCE OF OBJECTS IN A GIVEN ENVIRONMENT. THE DATA GENERATED BY THIS SYSTEM CAN BE DISPLAYED ON A VGA MONITOR TO PROVIDE A VISUAL REPRESENTATION OF THE DETECTED OBJECTS.ALSO USING THE VGA WILL BE THE DISPLAY  FOR THE DETECTED OBJECTS VIA THE CAMERA <br />
----------------------------------------------------------------------------------------<br />
Youtube link of the project :https://www.youtube.com/watch?v=0fVdlBlgzgo
----------------------------------------------------------------------------------------<br />
FPGA Part: DE1-SoC
![resim](https://github.com/mbatuhanorak/ELE432_ULTRASONIC_RADAR/assets/63021742/bf403399-07c5-4d90-a715-42432058ae75)


The DE1-SoC board will be used as the FPGA platform for implementing the Ultrasonic Radar project. The DE1-SoC is a versatile development board that combines the capabilities of a Cyclone V FPGA, an ARM Cortex-A9 processor, and various peripherals, making it suitable for a wide range of applications.

Components:

    Ultrasonic Sensor: An ultrasonic sensor will be connected to the DE1-SoC board to emit ultrasonic waves and measure the time it takes for the waves to bounce back. This information will be used to calculate the distance between the sensor and the objects.

    Step Motor: The DE1-SoC board will control a step motor, which will be responsible for rotating the ultrasonic sensor in a 360-degree field of view. The FPGA on the DE1-SoC board will generate the necessary control signals for the step motor.

    VGA Monitor: The DE1-SoC board features a VGA output port, allowing the generated data to be displayed on a VGA monitor. The FPGA will process the distance measurements and generate appropriate signals to display the detected objects on the monitor.

    Camera : If a camera is available, it can be connected to the DE1-SoC board. The FPGA can process the camera feed and display it alongside the detected objects on the VGA monitor.

System Operation:

    Initialization: The FPGA on the DE1-SoC board will initialize the system by configuring the necessary settings for the ultrasonic sensor, step motor, VGA output, and camera (if used).

    Ultrasonic Sensing: The FPGA will control the step motor to rotate the ultrasonic sensor in a circular motion. At each position, the sensor will emit ultrasonic waves, and the FPGA will measure the time it takes for the waves to return.

    Distance Calculation: Based on the time measurements, the FPGA will calculate the distances between the sensor and the detected objects using appropriate algorithms. This may involve using the speed of sound and time-of-flight calculations.

    Object Detection: The FPGA will analyze the calculated distances and determine the presence of objects within a certain threshold distance. This can be done using comparison logic or pattern recognition algorithms.

    Visualization: The FPGA will generate signals to display the detected objects on the VGA monitor connected to the DE1-SoC board. Each object can be represented by a graphical element, such as a point or shape, indicating its position in the environment.

    Camera Integration : If a camera is connected to the DE1-SoC board, the FPGA can process the camera feed and display it on the VGA monitor alongside the detected objects. This allows for real-time imaging and visual representation of the objects.

By utilizing the DE1-SoC FPGA board, the ultrasonic radar system can effectively detect and display objects in a given environment, providing distance measurements and visual representation. The flexibility of the DE1-SoC allows for easy integration of peripherals and efficient FPGA processing, making it an ideal platform for this project.<br />
----------------------------------------------------------------------------------------<br />
PROBLEM PART<br />
Sometimes the camera does not work efficiently due to the gpio connector problem.Cable is so important for the solution.<br />
There is timing problem.<br />
----------------------------------------------------------------------------------------<br />
