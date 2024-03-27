import RPi.GPIO as GPIO
from time import sleep
from matplotlib import pyplot as plt
GPIO.setwarnings(False)
dac = [8, 11, 7, 1, 0, 5, 12, 6]
GPIO.setmode(GPIO.BCM)
def dec2bin(num): return [int(element) for element in bin(num)[2:].zfill(8)]

s = 1
x = 0
t = 0
X = []
T = []
try:
    period = float(input("Type a period for signal\n"))
    while True:
        GPIO.output(dac, dec2bin(x))
        X.append(x)
        T.append(t)
        if x == 0: s = 1
        if x == 255: s = -1
        x = x + s
        t += 1
        sleep(period/512)
except Exception:
    print("Incorrect period")
finally:
    GPIO.output(dac, 0)
    GPIO.cleanup()
    plt.plot(T, X, "red")
    plt.show()