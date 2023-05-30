import sys
from PyQt5.QtWidgets import QApplication, QMainWindow, QPushButton, QLabel
from PyQt5.QtGui import QPixmap
import serial

port = "COM1"  # ser'nun bağlı olduğu portu buraya girin
baudrate = 9600

ser = serial.Serial(port, baudrate)

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("RADAR MOTOR CONTROLLER")
        self.setMinimumSize(950, 700)

        self.label = QLabel(self)
        self.label.setGeometry(300, 350, 640, 320)
        self.pixmap = QPixmap('project.jpg')  # Proje resmi yolunu doğru şekilde belirtin
        self.label.setPixmap(self.pixmap)

        self.label_text = QLabel("Burak Talha Güçlü-Mehmet Batuhan Orak-Abdullah Furkan Kaya-Muhammed Fatih Tekin", self)
        self.label_text.setGeometry(10, 10, 900, 50)
        self.label_text.setStyleSheet("font-size: 20px; font-weight: bold; text-align: center;")

        self.button_1 = QPushButton("FAST MODE", self)
        self.button_1.setGeometry(10, 50, 500, 100)
        self.button_1.clicked.connect(self.send_command_1)

        self.button_2 = QPushButton("MEDIUM MODE", self)
        self.button_2.setGeometry(10, 150, 500, 100)
        self.button_2.clicked.connect(self.send_command_2)

        self.button_3 = QPushButton("SLOW MODE", self)
        self.button_3.setGeometry(500, 150, 500, 100)
        self.button_3.clicked.connect(self.send_command_3)

        self.button_4 = QPushButton("STOP MODE", self)
        self.button_4.setGeometry(500, 50, 500, 100)
        self.button_4.clicked.connect(self.send_command_4)

        self.button_5 = QPushButton("TURN RIGHT", self)
        self.button_5.setGeometry(10, 250, 500, 100)
        self.button_5.pressed.connect(self.send_command_5_start)
        self.button_5.released.connect(self.send_command_5_stop)

        self.button_6 = QPushButton("TURN LEFT", self)
        self.button_6.setGeometry(500, 250, 500, 100)
        self.button_6.pressed.connect(self.send_command_6_start)
        self.button_6.released.connect(self.send_command_6_stop)

    def send_command_1(self):
        ser.write(b'\x01')

    def send_command_2(self):
        ser.write(b'\x02')

    def send_command_3(self):
        ser.write(b'\x03')

    def send_command_4(self):
        ser.write(b'\xAF')

    def send_command_5_start(self):
        ser.write(b'\xDD')

    def send_command_5_stop(self):
        ser.write(b'\xAF')

    def send_command_6_start(self):
        ser.write(b'\xCC')

    def send_command_6_stop(self):
        ser.write(b'\xAF')


if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec_())
